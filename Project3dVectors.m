% Project3dVectors.m
%
% This function takes as input a list of Cartesian vectors and moves them to the
% place of the equirectangular video with the least distortion. This is
% achieved by finding the rotation of the mean vector to the center of the
% video. Then it transforms all the vectors based on this rotation (i.e around
% the center of the equirectangular video). In this way most traditional
% algorithms can work directly on the transformed data.
%
% Note: in order for this method to work properly the vertical dispersion of the
% provided vectors has to be relatively small (< 45 degrees) in order to be in
% the almost linear part of the equirectangular video.
%
% input:
%   vectorList  - list of vectors in spherical coordinates
%   metadata    - metadata of the ARFF file
%
% output:
%   coords      - 2D x,y coordinates of the projected vectors

function [coords] = Project3dVectors(vecList, metadata)
    meanVec = mean(vecList,1)';

    videoMidVec = [-1; 0; 0];

    rot = HeadToVideoRot(meanVec, 0, videoMidVec);
    rot = rot'; % get rotation to middle of video

    coords = zeros(size(vecList,1), 2);
    maxVerRads = 0;
    minVerRads = pi;
    for ind=1:size(vecList,1)
        curVec = vecList(ind,:);
        rotVec = RotatePoint(rot, curVec);

        [horRads, verRads] = CartToSpherical(rotVec);
        maxVerRads = max(maxVerRads, verRads);
        minVerRads = min(minVerRads, verRads);
        [coords(ind,1), coords(ind,2)] = SphericalToEquirect(horRads, verRads, metadata.width_px, metadata.height_px);
    end
end
