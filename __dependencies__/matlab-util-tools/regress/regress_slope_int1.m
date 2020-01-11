function intercept=regress_slope_int1(input)

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
[xxx,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@point2line_slope,0,[],[],optimset('Display','off'),x,y);            % Least square fitting

if exitflag>0
    intercept=xxx(1);
else
    intercept=nan;%regress_slope(input);
end
