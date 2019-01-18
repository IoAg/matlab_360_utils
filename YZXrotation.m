% YZXrotation.m
%
% This function calculates the rotation matrix to the coordinate system of
% reference.

function rot = YZXrotation(vec, tiltRads)
    theta = asin(vec(2));
    psi = 0;
    if (abs(theta) < pi/2 - 0.01)
        psi = atan2(vec(3), vec(1));

    rot = zeros(3);
    rot(1,1) = cos(theta)*cos(psi);
    rot(1,2) = -sin(theta);
    rot(1,3) = cos(theta)*sin(psi);
    rot(2,1) = cos(tiltRads)*sin(theta)*cos(psi) + sin(tiltRads)*sin(psi);
    rot(2,2) = cos(tiltRads)*cos(theta);
    rot(2,3) = cos(tiltRads)*sin(theta)*sin(psi) - sin(tiltRads)*cos(psi);
    rot(3,1) = sin(tiltRads)*sin(theta)*cos(psi) - cos(tiltRads)*sin(psi);
    rot(3,2) = sin(tiltRads)*cos(theta);
    rot(3,3) = sin(tiltRads)*sin(theta)*sin(psi) + cos(tiltRads)*cos(psi);
end
