% CartToSpherical.m
%
% Converts cartesian coordinates to spherical coordinates.

function [horRads, verRads] = CartToSpherical(vec)
    horRads = atan2(vec(3), vec(1));
    verRads = acos(vec(2));
end
