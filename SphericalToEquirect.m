% SphericalToEquirect.m
%
% This function converts spherical coordinates to equirectangular coordinates
% (pixels).

function [xEq, yEq] = SphericalToEquirect(horRads, verRads, widthPx, heightPx)
    xEq = (horRads / (2 * pi)) * widthPx;
    yEq = (verRads / pi) * heightPx;

    if (yEq < 0)
        yEq = -yEq;
        xEq = xEq + widthPx/2;
    end

    if (yEq >= heightPx)
        yEq = 2 * heightPx - yEq -1;
        xEq = xEq + widthPx/2;
    end

    if (xEq < 0)
        xEq = widthPx + xEq - 1;
    end

    if (xEq > widthPx)
        xEq = xEq - widthPx;
    end
end
