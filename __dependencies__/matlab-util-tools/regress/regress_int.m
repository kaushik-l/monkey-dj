function int=regress_int(input)

%regress_int.m 
%
% int=regress_slope([x,y])
% x and y are two columns of data set. 
% 
% The script estimates the intercept of the regression line
% by minimizing the perpendicular offset.

x=input(:,1);
y=input(:,2);

%--------- added by GY 07/27/07 estimate slope first, otherwise cannot work for
% negative slope 
estimate = polyfit(x,y,1);
%--------------------------------------------------------------------------

[xxx,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@point2line,[estimate(1) estimate(2)],[],[],optimset('Display','off'),x,y);            %Least square fitting

if exitflag>0
    int=xxx(2);
else
    int=nan;%regress_slope(input);
end
