% OnePointDriftCorrection.m
%
% This function applies drift correction for 360 degree videos. For correcting
% the drift it has to know when the point was displayed and at which video
% position (equirectangular) was displayed. It then calculates the mean head and
% gaze directions during this time. It basically follows the inverse of the drift
% correction during recording and applies the new displacements.
%
% NOTE: Be careful to provide a time interval in which gaze is not noisy
%
% input:
%   arffFile        - path to ARFF file
%   targetStartTime - target diplay starting time in us
%   targetEndTime   - target diplay starting time in us
%   targetPos       - [x, y] equirectangular position
%   saveFile        - file to save data

function OnePointDriftCorrection(arffFile, targetStartTime, targetEndTime, targetPos, saveFile)
    c_timeName = 'time';
	c_xName = 'x';
    c_yName = 'y';
    c_confName = 'confidence';
    c_xHeadName = 'x_head';
    c_yHeadName = 'y_head';
    c_angleHeadName = 'angle_deg_head';
    c_confThreshold = 0.8;

    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    timeInd = GetAttPositionArff(attributes, c_timeName);
    xInd = GetAttPositionArff(attributes, c_xName);
    yInd = GetAttPositionArff(attributes, c_yName);
    confInd = GetAttPositionArff(attributes, c_confName);
    xHeadInd = GetAttPositionArff(attributes, c_xHeadName);
    yHeadInd = GetAttPositionArff(attributes, c_yHeadName);

    % convert target position to cartesian
    [horTargetRads, verTargetRads] = EquirectToSpherical(targetPos(1), targetPos(2), metadata.width_px, metadata.height_px);
    targetVec = SphericalToCart(horTargetRads, verTargetRads);

    % find start/end ime position
    indStart = find(data(:,timeInd) > targetStartTime);
    assert(~isempty(indStart), 'Could not find provided start time');
    indStart = indStart(1);

    indEnd = find(data(:,timeInd) > targetEndTime);
    assert(~isempty(indEnd), 'Could not find provided end time');
    indEnd = indEnd(1);

    % find mean head and gaze vector
    gazeVecMean = zeros(3,1);
    for ind=indStart:indEnd
        if (data(ind, confInd) < c_confThreshold)
            continue;
        end

        % convert gaze to reference vector
        [horGazeRads, verGazeRads] = EquirectToSpherical(data(ind, xInd), data(ind, yInd), metadata.width_px, metadata.height_px);
        gazeVec = SphericalToCart(horGazeRads, verGazeRads);
        gazeVecMean = gazeVecMean + gazeVec;
    end
    gazeVecMean = gazeVecMean / norm(gazeVecMean);

    [horRads, verRads] = CartToSpherical(gazeVecMean);
    [xMean, yMean] = SphericalToEquirect(horRads, verRads, metadata.width_px, metadata.height_px);

    dispX = targetPos(1) - xMean;
    dispY = targetPos(2) - yMean;

    dispXInd = GetMetaExtraPosArff(metadata, 'displacement_x');
    newDispX = str2num(metadata.extra{dispXInd,2}) + dispX;
    metadata.extra{dispXInd,2} = num2str(newDispX, '%.2f');
    dispYInd = GetMetaExtraPosArff(metadata, 'displacement_y');
    newDispY = str2num(metadata.extra{dispYInd,2}) + dispY;
    metadata.extra{dispYInd,2} = num2str(newDispY, '%.2f');

    [data(:,xInd), data(:,yInd)] = UndoLimits(data(:,xInd), data(:,yInd), data(:,confInd));
    [data(:,xHeadInd), data(:,yHeadInd)] = UndoLimits(data(:,xHeadInd), data(:,yHeadInd), data(:,confInd));
    for ind=1:size(data,1)
        % Check if the limits were wrongly undone
        angle = GetAngle(data(ind,xInd), data(ind,xHeadInd));

        if (angle > 360/3)
            [data(ind,xInd), data(ind,yInd)] = BringWithinLimits(data(ind,xInd), data(ind,yInd));
        end

        % Check if difference comes from errors during recordings
        angle = GetAngle(data(ind,xInd), data(ind,xHeadInd));
        if (angle > 360/3 && angle < 2*360/3) 
            data(ind,xInd) = data(ind,xInd) - metadata.width_px/2;
            [data(ind,xInd), data(ind,yInd)] = BringWithinLimits(data(ind,xInd), data(ind,yInd));
        end

        data(ind,xInd) = data(ind,xInd) + dispX;
        data(ind,yInd) = data(ind,yInd) + dispY;
        [data(ind,xInd), data(ind,yInd)] = BringWithinLimits(data(ind,xInd), data(ind,yInd));

        data(ind,xHeadInd) = data(ind,xHeadInd) + dispX;
        data(ind,yHeadInd) = data(ind,yHeadInd) + dispY;
        [data(ind,xHeadInd), data(ind,yHeadInd)] = BringWithinLimits(data(ind,xHeadInd), data(ind,yHeadInd));
        if(data(ind, confInd) < 0.3)
            data(ind,xInd) = 0;
            data(ind,yInd) = 0;
        end

    end

    SaveArff(saveFile, data, metadata, attributes, relation, comments);

    % Returns angle between two x coordinates
    function angle = GetAngle(x1, x2)
        horRads1 = EquirectToSpherical(x1, 0, metadata.width_px, 1);
        horRads2 = EquirectToSpherical(x2, 0, metadata.width_px, 1);

        angle = abs(horRads1 - horRads2) * 180 / pi;
    end

	function [x, y] = BringWithinLimits(x, y)
        if (y < 0)
            y = -y;
            x = x + metadata.width_px / 2;
        end

        if (y > metadata.height_px)
            y = 2 * metadata.height_px - y - 1;
            x = x + metadata.width_px / 2;
        end

        if (x < 0)
            x = ceil(abs(x)/metadata.width_px)*metadata.width_px + x - 1;
            %x = metadata.width_px + x - 1;
        elseif (x > metadata.width_px)
            x = x - floor(x/metadata.width_px)*metadata.width_px;
            %x = x - metadata.width_px;
        end
    end

    % x,y are list vectors
    function [xConv, yConv] = UndoLimits(x, y, confidence)
        xConv = zeros(size(x));
        yConv = zeros(size(y));
        countHor = 0;
        xConv(1) = x(1);
        yConv(1) = y(1);
        % remove horizontal transitions
        for i=2:size(x,1)
            totConf = confidence(i) + confidence(i-1);
            if (totConf > 1.7)
                if (x(i) - x(i-1) > metadata.width_px - 100) 
                    countHor = countHor - 1;
                elseif (x(i) - x(i-1) < -(metadata.width_px - 100))
                    countHor = countHor + 1;
                end
            end

            if (countHor > 0)
                xConv(i) = x(i) + metadata.width_px;
            elseif (countHor < 0)
                xConv(i) = x(i) - metadata.width_px;
            else
                xConv(i) = x(i);
            end
            yConv(i) = y(i);
        end

        % remove vertical transitions
        countVert = 0;
        c_perc = 0.1;
        for i=2:size(xConv,1)
            diff = abs(x(i) - x(i-1));
            yCloseToLim = y(i) > metadata.height_px - 100 | y(i) < 100;
            
            if (diff > (1-c_perc)*metadata.width_px/2 && diff < (1+c_perc)*metadata.width_px/2 && yCloseToLim)
                countVert = countVert + 1;
            end

            if (mod(countVert,2) == 1)
                xConv(i) = xConv(i) + metadata.width_px/2;
                if (yConv(i) >= metadata.height_px/2)
                    yConv(i) = 2*metadata.height_px  - yConv(i) - 1;
                else
                    yConv(i) = -yConv(i);
                end
            end

        end
    end
end
