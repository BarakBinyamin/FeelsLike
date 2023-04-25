function maximum=absmax(A)
% Returns the value of the element with the largest abs value in the input
% matrix 'A'. Input 'A' must be numeric, but can be any size and shape.
% 
% This is useful because it eliminates iterating through all the dimensions
% of a matrix.
% 
% examples:
%   A=[-5 3 2 3; 3 2 1 4];
%   absmax(A) will return -5
% 
%   A=[643,10];
%   absmax(A) will return 643
%
% Adam McNeilly

assert(isnumeric(A), 'Input matrix must be numeric');

if numel(A)==1
    maximum=A;
else
    maximum=absmax(max(abs(A)).*((max(abs(A))==max(A))-(max(abs(A))~=max(A))));
end