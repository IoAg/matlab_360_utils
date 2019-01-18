% GetDispersion.m
%
% This function returns the minimum angle (half of the total) of a cone
% starting from the beginning of the coordinate system, which is the place in
% the middle of the 360 degree sphere, with the cone vector denoting the
% direction of the middle of the cone that contains all the data points.
%
% input:
%   coneVec     - vector denoting the direction of the cone
%   vecList     - nx3 list of vectors
%
% output:
%   dispersion  - cone angle (degrees) that contains all vectors
%   index       - index to vector list that gave the maximum radius

function [dispersion, index] = GetDispersion(coneVec, vecList)
    assert(size(vecList,2) == 3, 'Vector list not in correct format');
    if (size(coneVec,1) > size(coneVec,2))
        coneVec = coneVec';
    end
    assert(size(coneVec,1) == 1 && size(coneVec,2) == 3, 'Provided vector has wrong dimensions');
    c_maxDelta = 0.001;

    dispersion = 0;
    for ind=1:size(vecList,1)
        dotProd = sum(coneVec .* vecList(ind,:));

		assert(dotProd < 1+c_maxDelta, 'Provided vectors are not normalized');
        % account for double roundings
        if (dotProd > 1)
            dotProd = 1;
        end

        rads = acos(dotProd);
        if (rads >= dispersion)
            dispersion = rads;
            index = ind;
        end
    end

    dispersion = dispersion * 180 / pi;
end

