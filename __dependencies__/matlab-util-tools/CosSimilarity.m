function cos_similarity = CosSimilarity(X,Y)

X = squeeze(X); Y = squeeze(Y);
xy = (nansum(X.*Y));
xx = (sqrt(nansum(X.*X)));
yy = (sqrt(nansum(Y.*Y)));
cos_similarity = nanmean(xy./(xx.*yy));