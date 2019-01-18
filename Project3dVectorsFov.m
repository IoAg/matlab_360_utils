% Project3dVectorsFov.m
%
% This function projects the 3D eye FOV vectors into the FOV and stores a new
% file where the x, y, and tilt of the are accounted for.
%
% input:
%   arffFile    - file to process
%   outputFile  - file to store converted data

function Project3dVectorsFov(arffFile, outputFile)
    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    % Proccess the FOV vectors
    [eyeFovVec] = GetCartVectors(data, metadata, attributes); % rotation at (-1,0,0) point

    widthFov = str2num(GetMetaExtraValueArff(metadata, 'fov_width_deg'));
    widthFovRads = widthFov * pi / 180;
    heightFov = str2num(GetMetaExtraValueArff(metadata, 'fov_height_deg'));
    heightFovRads = heightFov * pi / 180;

    widthFovPx = str2num(GetMetaExtraValueArff(metadata, 'fov_width_px'));
    heightFovPx = str2num(GetMetaExtraValueArff(metadata, 'fov_height_px'));

    xFov = zeros(size(data,1),1);
    yFov = zeros(size(data,1),1);
    for i=1:size(data,1)
        [horRads, verRads] = CartToSpherical(eyeFovVec(i,:));
        if (horRads < 0)
            horRads = 2*pi + horRads;
        end

        horRads = horRads - pi; % reference vetor at (-1,0,0)
        verRads = verRads - pi/2;

        xFov(i) = widthFovPx * (horRads + widthFovRads / 2) / widthFovRads;
        yFov(i) = heightFovPx * (verRads + heightFovRads / 2) / heightFovRads;
    end
    
   
    metaOut = metadata;
    metaOut.width_px = 0;
    metaOut.height_px = 0;

    attOut = {};
    dataOut = zeros(size(data,1),0);
    timeInd = GetAttPositionArff(attributes, 'time');
    [dataOut, attOut] = AddAttArff(dataOut, attOut, data(:,timeInd), attributes{timeInd,1}, attributes{timeInd,2});
    [dataOut, attOut] = AddAttArff(dataOut, attOut, xFov, 'x', 'Numeric');
    [dataOut, attOut] = AddAttArff(dataOut, attOut, yFov, 'y', 'Numeric');
    confInd = GetAttPositionArff(attributes, 'confidence');
    [dataOut, attOut] = AddAttArff(dataOut, attOut, data(:,confInd), attributes{confInd,1}, attributes{confInd,2});

    relOut = 'gaze_fov';
    commentsOut = comments;

    SaveArff(outputFile, dataOut, metaOut, attOut, relOut, commentsOut);

end
