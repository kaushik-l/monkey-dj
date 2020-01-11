function [b, a, bint, aint, r, p]=regress_perp(x,y,alpha,option)

% regress_perp.m 
% 
% [slope, intercept]=regress(x,y);
% [slope, intercept]=regress(x,y,alpha);
% [slope, intercept, slopeInt, interceptInt, r, p]=regress_perp(x,y,alpha)
% [slope, intercept, slopeInt, interceptInt, r, p]=regress_perp(x,y,alpha,option)
%
% x and y are two column vectors that contain the data set's x and y value, the
% two's size must match. The function return slope, intercept, slopes 95%
% confidence intervel, intercept 95% confidence intervel, r value,
% and p value, the user may specify the confidence interval by input alpha.
% (alpha input is optional)
% option:
% 1--free intercept (default)
% 2--set intercept 0
% 
% this script estimates the linear regression line by minimizing the 
% perpendicular offset. This is different from the general linear regression
% method which minimizes the vertical offset. (See function regress.m)

% disp('***** b--slope; a--intercept; bint--slope confidence int; aint--inter confidence int *****')
% disp('***** 1--free intercept (default); 2--set intercept 0*****')
% commented out 10/29/2015

if  nargin < 2,              
    error('REGRESS_PERP requires at least two input arguments.');      
end 

if nargin == 2, 
    alpha = 0.05;
    option = 1;
end

if option~=1 & option~=2
    error('option input is not recognized');
end

% remove nans
nanxy = isnan(x)|isnan(y);
x(nanxy) = []; y(nanxy) = [];

%estimating slope and intercept via nonlinear least square fitting
%the fitting minimizes perpendicular offset (point2line distance)
if option==1
    b=regress_slope([x y]);
    a=regress_int([x y]);
else
    b=regress_slope_int([x y]);
    a=0;
end
    
if isnan(b) | isnan(a)
    error('The program failed to extact slope and intercept from the data set via least square');
end

if nargout>2
    clear index;
    %estimating confidence interval for slope
    if option==1
        slope_sam=bootstrp(1000,'regress_slope',[x y]);           %re-sample data via bootstrap to estimate distribution for slope
    else
        slope_sam=bootstrp(1000,'regress_slope_int',[x y]);           %re-sample data via bootstrap to estimate distribution for slope
    end
    slope_sam=sort(slope_sam);
    index=find(isnan(slope_sam));
    if ~isempty(index)
        slope_sam=slope_sam(1:index(1));
    end
    bint = [slope_sam(round(alpha/2*length(slope_sam))), slope_sam(round((1-alpha/2)*length(slope_sam)))];

    if option==1
        clear index;
        int_sam=bootstrp(1000,'regress_int',[x y]);               %re-sample data via bootstrap to estimate distribution for intercept
        int_sam=sort(int_sam);
        index=find(isnan(int_sam));
        if ~isempty(index)
            int_sam=int_sam(1:index(1));
        end
        aint = [int_sam(round(alpha/2*length(int_sam))), int_sam(round((1-alpha/2)*length(int_sam)))];
        clear index;
    else
        aint=[];
    end
    
    [r,p]=corrcoef(x,y);                                        %correlation coefficient and p value for significance of correlation
    r=r(2,1);
    p=p(2,1);
end

return