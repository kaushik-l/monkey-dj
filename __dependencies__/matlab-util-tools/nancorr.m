function [r,p] = nancorr(x,y,varargin)

% correlation between two vectors with nans
[r,p] = corr(x(~isnan(x) & ~isnan(y)),y(~isnan(x) & ~isnan(y)), varargin{:});