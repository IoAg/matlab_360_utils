% GetSpeed.m
%
% This function gets a list of vectors together with their timestamps and
% returns a speed vector in degrees per second.
%
% input:
%   vecList - nx3 (x,y,z) list of vectors. Taken from GetCartVectors.m
%   time    - timestamp of vectors in us (microseconds)
%   step    - (optional, default=1) distance of samples for speed calculation
%
% output:
%   speed   - speed in deg/sec

function speed = GetSpeed(vecList, time, step)
    if (nargin < 3)
        step = 1;
    end
    c_maxDelta = 0.001;
    c_usToSec = 1000000;
    
    assert(size(time,1) == size(vecList,1), 'Provided number of vectors and timestamps should be the same')
    speed = zeros(size(vecList,1),1);
    for ind=step+1:size(vecList,1)
        dotProd = sum(vecList(ind,:) .* vecList(ind-step,:));

        assert(dotProd < 1+c_maxDelta, 'Provided vectors are not normalized');
        % account for double roundings
        if (dotProd > 1)
            dotProd = 1;
        end

        rads = acos(dotProd);
        degs = rads * 180 / pi;
        elapsedTime = (time(ind) - time(ind-step)) / c_usToSec;
        speed(ind - round(step/2)) = degs/elapsedTime;
        assert(speed(ind) >= 0 && ~isinf(speed(ind)), ['Provided timestamps are not monotonic ' num2str(ind)]);
    end
end
