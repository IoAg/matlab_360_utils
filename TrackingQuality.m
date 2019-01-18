% TrackingQuality.m
%
% This function gets as input the position of a target and a time interval
% during which the target was fixated. It then returns the divergence of gaze
% from the target in degrees.
%
% NOTE: Be careful to provide a time interval in which gaze is not noisy
%
% input:
%   arffFile        - path to ARFF file
%   targetStartTime - target diplay starting time in us
%   targetEndTime   - target diplay starting time in us
%   targetPos       - [x, y] equirectangular position
%
% output:
%   divergence      - divergence from target in degrees

function [divergence] = TrackingQuality(arffFile, targetStartTime, targetEndTime, targetPos)
    if (targetStartTime < 0 || targetEndTime < 0)
        divergence = -1;
        return;
    end
    c_timeName = 'time';
    c_xName = 'x';
    c_yName = 'y';
    c_confName = 'confidence';
    c_confThreshold = 0.8;

    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    timeInd = GetAttPositionArff(attributes, c_timeName);
    xInd = GetAttPositionArff(attributes, c_xName);
    yInd = GetAttPositionArff(attributes, c_yName);
    confInd = GetAttPositionArff(attributes, c_confName);

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

    % find mean gaze vector
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
    
    vecNum = indEnd - indStart + 1;
    gazeVecMean = gazeVecMean / norm(gazeVecMean);

    divergence = GetDispersion(targetVec, gazeVecMean');
end
