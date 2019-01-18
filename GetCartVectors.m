% GetCartVectors.m
%
% This function returns an nx3 arrays of cartesian vectors for the eye direction
% within the FOV of the headset, the eye direction in the world coordinates and
% the head direction in the world.
%
% input:
%   data        - ARFF data
%   metadata    - metadata of ARFF data
%   attributes  - attributes of ARFF data
%
% output:
%   eyeFovVec   - nx3 (x,y,z) array corresponding to FOV vector of gaze centered 
%                 around the middle of the video corresponding to (1,0,0) vector
%   eyeHeadVec  - nx3 (x,y,z) array corresponding to the direction of the eye in 
%                 the world. That is the head+eye position
%   headVec     - nx3 (x,y,z) array corresponding to the direction of the head in
%                 the world

function [eyeFovVec, eyeHeadVec, headVec] = GetCartVectors(data, metadata, attributes)
    c_xName = 'x';
    c_yName = 'y';
    c_xHeadName = 'x_head';
    c_yHeadName = 'y_head';
    c_angleHeadName = 'angle_deg_head';

    xInd = GetAttPositionArff(attributes, c_xName);
    yInd = GetAttPositionArff(attributes, c_yName);
    xHeadInd = GetAttPositionArff(attributes, c_xHeadName);
    yHeadInd = GetAttPositionArff(attributes, c_yHeadName);
    angleHeadInd = GetAttPositionArff(attributes, c_angleHeadName);

    eyeFovVec = zeros(size(data,1),3);
    eyeHeadVec = zeros(size(data,1),3);
    headVec = zeros(size(data,1),3);

    for ind=1:size(data,1)
        [horHeadRads, verheadRads] = EquirectToSpherical(data(ind, xHeadInd), data(ind, yHeadInd), metadata.width_px, metadata.height_px);
        curHeadVec = SphericalToCart(horHeadRads, verheadRads);
        headVec(ind,:) = curHeadVec;

        angleHeadRads = data(ind, angleHeadInd) * pi / 180;
        videoVec = [-1; 0; 0]; % middle of the video is considered its center

        rot = HeadToVideoRot(curHeadVec, angleHeadRads, videoVec);
        rot = rot';

        [horGazeRads, verGazeRads] = EquirectToSpherical(data(ind, xInd), data(ind, yInd), metadata.width_px, metadata.height_px);
        gazeVec = SphericalToCart(horGazeRads, verGazeRads);
        eyeHeadVec(ind,:) = gazeVec;

        gazeWithinVec = RotatePoint(rot, gazeVec);

        eyeFovVec(ind,:) = gazeWithinVec(:);
    end
end
