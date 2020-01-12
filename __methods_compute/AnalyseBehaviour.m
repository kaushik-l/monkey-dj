function stats = AnalyseBehaviour(trials,analysisprs,stimulusprs)

analysisprs.maxrewardwin = 400; %##$$#$# move to analysisparam table
x0 = stimulusprs.x0; y0 = stimulusprs.y0;
ntrials = numel(trials);
for j=1:ntrials
    t = trials(j).behv_time;
    timeindx = find(t>trials(j).behv_tbeg & t<trials(j).behv_tstop);
    firefly_x(j) = nanmedian(trials(j).firefly_x(timeindx)) - x0;
    firefly_y(j) = nanmedian(trials(j).firefly_y(timeindx)) - y0;
    
    monkey_xf(j) = trials(j).monkey_xtraj(timeindx(end)) - x0;
    monkey_yf(j) = trials(j).monkey_ytraj(timeindx(end)) - y0;
end
firefly_r = sqrt(firefly_x.^2 + firefly_y.^2);
firefly_th = atan2d(firefly_x , firefly_y);
monkey_rf = sqrt(monkey_xf.^2 + monkey_yf.^2);
monkey_thf = atan2d(monkey_xf , monkey_yf);

%% euclidean errors
dist2firefly = sqrt((firefly_x - monkey_xf).^2 + (firefly_y - monkey_yf).^2);
indx = randperm(ntrials); 
dist2firefly_shuffled = sqrt((firefly_x(indx) - monkey_xf).^2 + (firefly_y(indx) - monkey_yf).^2);

%% regression without intercept
[M1_beta_r, ~, M1_betaCI_r, ~, corr_r, pval_r] = regress_perp(firefly_r(:), monkey_rf(:), 0.05, 2);
[M1_beta_th, ~, M1_betaCI_th, ~, corr_th, pval_th] = regress_perp(firefly_th(:), monkey_thf(:), 0.05, 2);

%% regression with intercept
[M2_beta_r, M2_alpha_r, M2_betaCI_r, M2_alphaCI_r] = regress_perp(firefly_r(:), monkey_rf(:), 0.05, 1);
[M2_beta_th, M2_alpha_th, M2_betaCI_th, M2_alphaCI_th] = regress_perp(firefly_th(:), monkey_thf(:), 0.05, 1);

%% local linear regression 
[x,y] = NPregress_locallinear(firefly_r,monkey_rf,[],[],[],[],[]); M3_r = x.mu(:); M3_betalocal_r = y.mu(:);
[x,y] = NPregress_locallinear(firefly_th,monkey_thf,[],[],[],[],[]); M3_th = x.mu(:); M3_betalocal_th = y.mu(:);

%% ROC curve
maxrewardwin = analysisprs.maxrewardwin;
npermutations = analysisprs.npermutations;
[roc_rewardwin, roc_pCorrect, roc_pCorrect_shuffled, auc] = ComputeROCFirefly([firefly_r(:) (pi/180)*firefly_th(:)],...
    [monkey_rf(:) (pi/180)*monkey_thf(:)],maxrewardwin,npermutations);
[auc_rbin, auc_r, auc_thbin, auc_th] = ComputeROCFireflyLocation([firefly_r(:) (pi/180)*firefly_th(:)],...
    [monkey_rf(:) (pi/180)*monkey_thf(:)],maxrewardwin);

%% spatial analyses
% spatial map of response variance
targ.r = firefly_r(:); targ.theta = firefly_th(:);
resp.r = monkey_rf(:); resp.theta = monkey_thf(:);
spatialerr = ComputeSpatialError(targ,resp);
spatial_x = spatialerr.x(:);
spatial_y = spatialerr.y(:);
spatial_xerr = spatialerr.x_err_smooth;
spatial_yerr = spatialerr.y_err_smooth;
% spatial map of response errors
resp.r = resp.r/regress(resp.r(:),targ.r(:)); resp.theta = resp.theta/regress(resp.theta(:),targ.theta(:));
spatialstd = ComputeSpatialError(targ,resp);
spatial_xstd = spatialstd.x_err_smooth;
spatial_ystd = spatialstd.y_err_smooth;

%% save variables
stats.firefly_x = firefly_x;
stats.firefly_y = firefly_y;
stats.firefly_r = firefly_r;
stats.firefly_th = firefly_th;

stats.monkey_xf = monkey_xf;
stats.monkey_yf = monkey_yf;
stats.monkey_rf = monkey_rf;
stats.monkey_thf = monkey_thf;

stats.dist2firefly = dist2firefly;
stats.dist2firefly_shuffled = dist2firefly_shuffled;

stats.m1_beta_r = M1_beta_r;
stats.m1_betaci_r = M1_betaCI_r;
stats.m1_beta_th = M1_beta_th;
stats.m1_betaci_th = M1_betaCI_th;
stats.m2_beta_r = M2_beta_r;             
stats.m2_betaci_r = M2_betaCI_r;               
stats.m2_beta_th = M2_beta_th;                  
stats.m2_betaci_th = M2_betaCI_th;                
stats.m2_alpha_r = M2_alpha_r;                  
stats.m2_alphaci_r = M2_alphaCI_r;                
stats.m2_alpha_th = M2_alpha_th;                 
stats.m2_alphaci_th = M2_alphaCI_th;
stats.m3_r = M3_r;
stats.m3_betalocal_r = M3_betalocal_r;
stats.m3_th = M3_th;   
stats.m3_betalocal_th = M3_betalocal_th;
stats.corr_r = corr_r;
stats.pval_r = pval_r;
stats.corr_th = corr_th;
stats.pval_th = pval_th;

stats.roc_rewardwin = roc_rewardwin;
stats.roc_pcorrect = roc_pCorrect;
stats.roc_pcorrect_shuffled = roc_pCorrect_shuffled;
stats.auc = auc;
stats.auc_rbin = auc_rbin;
stats.auc_r = auc_r;
stats.auc_thbin = auc_thbin;
stats.auc_th = auc_th;

stats.spatial_x = spatial_x;
stats.spatial_y = spatial_y;
stats.spatial_xerr = spatial_xerr;
stats.spatial_yerr = spatial_yerr;
stats.spatial_xstd = spatial_xstd;
stats.spatial_ystd = spatial_ystd;