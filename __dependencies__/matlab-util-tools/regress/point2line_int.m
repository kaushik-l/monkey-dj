function d=point2line_int(b,x,y)

% point2line.m
% d=point2line(b,x,y)
% d is returned distance, b is slope of the line
% x and y are coordinates for the data point
%
% this script computes the distance from a point to a line,
% which is used to estimate the least square regression by
% minimizing PERPENDICULAR offset

slope=b;
intercept=0;
d=abs(y-(intercept+slope*x))/sqrt(1+slope^2);           %point to line distance
return