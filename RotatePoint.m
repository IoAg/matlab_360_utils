% RotatePoint.m
%
% Rotates a point by multiplying from the left with the provided rotation matrix.

function rotVec = RotatePoint(rot, vec)
    if (size(vec,2) > size(vec,1))
        vec = vec';
    end
    assert(size(vec,1) == 3 && size(vec,2) == 1, 'Vector should have exactly 3 elements');
    assert(size(rot,1) == 3 && size(rot,2) == 3, 'Rotation matrix has incorrect dimensions');

    rotVec = rot * vec;
end
