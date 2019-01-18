% GetMaxDispersion.m
%
% This function gets 2 vector lists as input and returns the maximum dispersion
% for an input vector in comparison with the second vector list.
% 
% input:
%   vecList1    - list of vectors to iterate through
%   vecList2    - (optional) list of vectors to use for dispersion
%
% output:
%   maxDisp     - maximum dispersion
%   index1      - pointer to the element in the vecList1 with maxDisp
%   index2      - pointer to the element in the vecList2 with maxDisp

function [maxDisp, index1, index2] = GetMaxDispersion(vecList1, vecList2)
    if (nargin < 2)
        vecList2 = vecList1;
    end
    maxDisp = 0;
    index = -1;

    for ind=1:size(vecList1)
        [dispersion, tmpInd] = GetDispersion(vecList1(ind,:), vecList2);
        if (dispersion > maxDisp)
            maxDisp = dispersion;
            index1 = ind;
            index2 = tmpInd;
        end
    end

end
