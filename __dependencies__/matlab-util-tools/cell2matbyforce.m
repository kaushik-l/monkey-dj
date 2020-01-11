function X = cell2matbyforce(X,N,rule)
% convert 1 x M cell array to N x M matrix by padding nans if needed

switch rule
    case 'nan'
        X = cell2mat(cellfun(@(x) [x ; nan(N-length(x),1)], X, 'UniformOutput',false));
    case 'last'
        X = cell2mat(cellfun(@(x) [x ; repmat(x(end),N-length(x),1)], X, 'UniformOutput',false));
end