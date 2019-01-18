% EquirectToSpherical.m
%
% This function converts equirectangular coordinates to spherical coordinates.

function [horRads, verRads] = EquirectToSpherical(xEq, yEq, widthPx, heightPx)
    horRads = (xEq *2 * pi) / widthPx;
    verRads = (yEq * pi) / heightPx;
end
