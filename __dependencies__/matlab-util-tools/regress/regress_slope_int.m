function slope=regress_slope_int(input)

%regress_slope.m
%
% slope=regress_slope([x,y])
% x and y are two columns of data set. they have
% to match in size
% 
% The script estimates the slope of the regression line
% by minimizing the perpendicular offset.

x=input(:,1);
y=input(:,2);
[xxx,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@point2line_int,1,[],[],optimset('Display','off'),x,y);            % Least square fitting

if exitflag>0
    slope=xxx(1);
else
    slope=nan;%regress_slope(input);
end
