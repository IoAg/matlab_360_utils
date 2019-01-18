% Perpendicular.m
%
% This function returns a vector perpendicular to the input vector.

function [perpVec] = Perpendicular(vec)
    range = 0.5;
    vec = vec./norm(vec);

    if (vec(1) == 0)
        perpVec = [1 0 0]';
        return;
    elseif (vec(2) == 0)
        perpVec = [0 1 0]';
        return;
    elseif (vec(3) == 0)
        perpVec = [0 0 1]';
        return;
    end

    perpVec = zeros(3,1);
    perpVec(1) = rand - 0.5;
    perpVec(2) = rand - 0.5;
    perpVec(3) = -(vec(1)*perpVec(1) + vec(2)*perpVec(2))/ vec(3);
end
