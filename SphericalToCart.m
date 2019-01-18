% SphericalTocart.m
%
% This function converts spherical coordinates to cartesian coordinates.

function [vec] = SphericalToCart(horRads, verRads)
    vec = zeros(3,1);
    vec(1) = sin(verRads) * cos(horRads);
    vec(2) = cos(verRads);
    vec(3) = sin(verRads) * sin(horRads);
end
