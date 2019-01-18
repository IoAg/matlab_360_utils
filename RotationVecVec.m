% RotationVecVec.m
%
% Calculates the rotation matrix between 2 vectors based on the Rodrigues' formula.

function [rot] = RotationVecVec(vec1, vec2)
    assert(size(vec1,1) > size(vec1,2), 'Not using column vectors');
    assert(size(vec1,2) == 1, 'Not using column vectors');
    assert(size(vec1,1) == size(vec2,1), 'Vector dimensions mismatch');
    assert(size(vec1,2) == size(vec2,2), 'Vector dimensions mismatch');

    vec1 = vec1 / norm(vec1);
    vec2 = vec2 / norm(vec2);

    if (sum(abs(vec1 + vec2) < 0.000001) == 3) % opposite vectors
        midVec = Perpendicular(vec1);
    else
        midVec = vec1 + vec2;
    end

    midVec = midVec/norm(midVec);

    rot = Rodrigues(midVec, pi);
end
