% Rodrigues.m
%
% Implements Rodrigues' formula for creating a rotation matrix

function [mat] = Rodrigues(vec, angle)
    mat = zeros(3,3);
	mat(1,1) = (1-cos(angle))*vec(1)*vec(1) + cos(angle);
    mat(1,2) = (1-cos(angle))*vec(1)*vec(2) - sin(angle)*vec(3);
    mat(1,3) = (1-cos(angle))*vec(1)*vec(3) + sin(angle)*vec(2);
    mat(2,1) = (1-cos(angle))*vec(2)*vec(1) + sin(angle)*vec(3);
    mat(2,2) = (1-cos(angle))*vec(2)*vec(2) + cos(angle);
    mat(2,3) = (1-cos(angle))*vec(2)*vec(3) - sin(angle)*vec(1);
    mat(3,1) = (1-cos(angle))*vec(3)*vec(1) - sin(angle)*vec(2);
    mat(3,2) = (1-cos(angle))*vec(3)*vec(2) + sin(angle)*vec(1);
    mat(3,3) = (1-cos(angle))*vec(3)*vec(3) + cos(angle);
end
