function X_mat = cell2matspecial(X_cell,opt)

nrows = length(X_cell); ncols = nan(1,nrows);
for i=1:nrows
    ncols(i) = length(X_cell{i});
end
maxcols = max(ncols);
X_mat = nan(nrows,maxcols);
if nargin<2, opt = 'pad'; end

if strcmp(opt,'pad')
    for i=1:nrows
        X_mat(i,1:ncols(i)) = X_cell{i};
    end
elseif strcmp(opt,'warp')
    X_mat = X_cell;
end