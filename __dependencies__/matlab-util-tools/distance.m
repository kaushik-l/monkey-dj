function distance = distance(X1,X2,opt)

% Compute Eucledian distance between two 2x1 vectors X1 and X2
% Vectors may be specified in cartesian [x y] or polar [r theta] coords.
% Usage: distance([x1 y1], [x2 y2]) or distance([r1 theta1], [r2 theta2], 'polar')

if nargin<3, opt = 'cartesian';
elseif ~strcmp(opt,'polar') && ~strcmp(opt,'cartesian')
    error('opt must be "polar" or "cartesian"');
end

if strcmp(opt,'polar')
    X1 = [X1(1)*sin(X1(2)), X1(1)*cos(X1(2))];
    X2 = [X2(1)*sin(X2(2)), X2(1)*cos(X2(2))];
end
distance = sqrt(sum((X1 - X2).^2));