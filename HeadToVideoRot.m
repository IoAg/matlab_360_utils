% HeadToVideoRot.m
%
% Calculates the rotation of the head vector to the provided video vector.

function [rot] = HeadToVideoRot(headVec, headAngleRads, videoVec)
    headToRef = YZXrotation(headVec, -headAngleRads);
    videoToRef = YZXrotation(videoVec, 0);

    rot = videoToRef*(headToRef');
end
