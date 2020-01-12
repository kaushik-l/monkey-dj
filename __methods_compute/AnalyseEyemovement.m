function eyestats = AnalyseEyemovement(trials,behvstats,analysisprs,stimulusprs)
%function eye_movement = AnalyseEyemovement(eye_fixation,x_fly,y_fly,x_monk,y_monk,zle,yle,zre,yre,t_sac,t_stop,ts,trlerrors,spatialerr,prs)

%% prs
delta = stimulusprs.interoculardist/2;
zt = -stimulusprs.height;
saccade_duration = analysisprs.saccade_duration;
fly_onduration = stimulusprs.fly_onduration;
Nboots = analysisprs.nbootstraps;
ntrials = numel(trials);
pretrial = analysisprs.pretrial;
posttrial = analysisprs.posttrial;

%% sort trials by error
trlerrors = behvstats.dist2firefly;
[~,errorindx] = sort(trlerrors);

%% eye position immediately after the first saccade following target onset
tsac = {trials.behv_tsac}; t_stop = [trials.behv_tstop];
ts = {trials.behv_time}; 
yle = {trials.leye_horpos}; yre = {trials.reye_horpos}; zle = {trials.leye_verpos}; zre = {trials.reye_verpos};
firefly_x = {trials.firefly_x}; firefly_y = {trials.firefly_y};
monkey_x = {trials.monkey_xtraj}; monkey_y = {trials.monkey_ytraj};
for i=1:ntrials
    % identify time of target fixation
    sacstart = []; sacend = []; sacampli = [];
    t_sac2 = tsac{i};
    sac_indx = tsac{i}>0 & tsac{i}<2*fly_onduration;
    if any(sac_indx)
        t_sacs = tsac{i}(sac_indx); % candidate target-fixation saccades
        % choose one candidate
        for j=1:length(t_sacs)
            sacstart(j) = find(ts{i}>(t_sacs(j)), 1);
            sacend(j) = find(ts{i}>(t_sacs(j) + saccade_duration), 1);
            sacampli(j) = nanmean([sum(abs(zle{i}(sacstart(j)) - zle{i}(sacend(j)))^2 + abs(yle{i}(sacstart(j)) - yle{i}(sacend(j)))^2) ...
                sum(abs(zre{i}(sacstart(j)) - zre{i}(sacend(j)))^2 + abs(yre{i}(sacstart(j)) - yre{i}(sacend(j)))^2)]);
        end
        t_fix(i) = t_sacs(sacampli == max(sacampli)) + saccade_duration/2;
    else, t_fix(i) = 0 + saccade_duration/2; 
    end % if no saccade detected, assume monkey was already fixating on target
    % remove saccade periods from eye position data
    sacstart = []; sacend = [];
    for j=1:length(t_sac2)
        sacstart(j) = find(ts{i}>(t_sac2(j) - saccade_duration/2), 1);
        sacend(j) = find(ts{i}>(t_sac2(j) + saccade_duration/2), 1);
        yle{i}(sacstart(j):sacend(j)) = nan; % left eye horizontal position
        yre{i}(sacstart(j):sacend(j)) = nan; % right eye horizontal position
        zle{i}(sacstart(j):sacend(j)) = nan; % left eye vertical position
        zre{i}(sacstart(j):sacend(j)) = nan; % right eye vertical position
    end
%     t_fix(i) = 0;
    pretrial = 0; posttrial = 0;
    % select data between target fixation and end of movement
    timeindx = find(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
    
    % target position
    xt{i} = firefly_x{i}(timeindx); yt{i} = firefly_y{i}(timeindx);
    xt{i}(isnan(xt{i})) = xt{i}(find(~isnan(xt{i}),1)); yt{i}(isnan(yt{i})) = yt{i}(find(~isnan(yt{i}),1));
    % subject position
    xmt{i} = monkey_x{i}(timeindx) - monkey_x{i}(find(~isnan(monkey_x{i}),1)); ymt{i} = monkey_y{i}(timeindx) - monkey_y{i}(find(~isnan(monkey_y{i}),1));
    xmt{i}(isnan(xmt{i})) = xmt{i}(find(~isnan(xmt{i}),1)); ymt{i}(isnan(ymt{i})) = ymt{i}(find(~isnan(ymt{i}),1));
    % variance in subject position
    [~,x_indx] = min(abs(xmt{i}-behvstats.spatial_x'),[],2);
    [~,y_indx] = min(abs(ymt{i}-behvstats.spatial_y'),[],2);
    var_xmt{i} = (behvstats.spatial_xstd(sub2ind(size(behvstats.spatial_xstd), x_indx, y_indx))).^2;
    var_ymt{i} = (behvstats.spatial_ystd(sub2ind(size(behvstats.spatial_ystd), x_indx, y_indx))).^2;
    % eye position
    yle{i} = yle{i}(timeindx); yre{i} = yre{i}(timeindx);
    zle{i} = zle{i}(timeindx); zre{i} = zre{i}(timeindx);
    
    % ground truth prediction for eye position (if the monkey really followed the target)
    yle_pred{i} = atan2d(xt{i} + delta, sqrt(yt{i}.^2 + zt^2));
    yre_pred{i} = atan2d(xt{i} - delta, sqrt(yt{i}.^2 + zt^2));
    zle_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} + delta).^2));
    zre_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} - delta).^2));
    ver_mean_pred{i} = nanmean([zle_pred{i} , zre_pred{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean_pred{i} = nanmean([yle_pred{i} , yre_pred{i}],2); % mean horizontal eye position
    ver_diff_pred{i} = 0.5*(zle_pred{i} - zre_pred{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff_pred{i} = 0.5*(yle_pred{i} - yre_pred{i}); % 0.5*difference between horizontal eye positions
    % actual eye position
    ver_mean{i} = nanmean([zle{i} , zre{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean{i} = nanmean([yle{i} , yre{i}],2); % mean horizontal eye position
    ver_diff{i} = 0.5*(zle{i} - zre{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff{i} = 0.5*(yle{i} - yre{i}); % 0.5*difference between horizontal eye positions
    % fly position
    rt{i} = sqrt(xt{i}.^2 + yt{i}.^2);
    thetat{i} = atan2d(xt{i},yt{i});
    
    % saccade direction
    sacxy{i} = []; sacxy_pred{i} = []; sacdir{i} = []; sacdir_pred{i} = []; sac_time{i} = [];
    if ~isempty(timeindx)
        for j=1:length(t_sac2)
            sacstartindx = find(ts{i}>(t_sac2(j) - saccade_duration/2), 1) - timeindx(1) - 2;
            sacendindx = find(ts{i}>(t_sac2(j) + saccade_duration/2), 1) - timeindx(1) + 2;
            if sacstartindx>0 && sacendindx<=(numel(timeindx)-round(0.3/analysisprs.dt)) % only consider saccades 300ms (= 50 samples) before stopping
                sacxy{i} = [sacxy{i} [ver_mean{i}(sacendindx) - ver_mean{i}(sacstartindx); hor_mean{i}(sacendindx) - hor_mean{i}(sacstartindx)]];
                sacdir{i} = [sacdir{i} atan2d(sacxy{i}(1,end),sacxy{i}(2,end))];
                sacxy_pred{i} = [sacxy_pred{i} [ver_mean_pred{i}(sacstartindx) - ver_mean{i}(sacstartindx); hor_mean_pred{i}(sacstartindx) - hor_mean{i}(sacstartindx)]];
                sacdir_pred{i} = [sacdir_pred{i} atan2d(sacxy_pred{i}(1,end),sacxy_pred{i}(2,end))];
                sac_time{i} = [sac_time{i} sacstartindx*analysisprs.dt]; % time since target fixation
            end
        end
    end
end

%% save saccadic eye movements
eyestats.saccade_trueval = cell2mat(sacxy);
eyestats.saccade_truedir = cell2mat(sacdir);
eyestats.saccade_predval = cell2mat(sacxy_pred);
eyestats.saccade_preddir = cell2mat(sacdir_pred);
eyestats.saccade_time = cell2mat(sac_time);

%% correlation between behv error and eye-movement prediction error
eye_mean_err = nan(ntrials, 1);
for i=1:ntrials
    nt = length(ver_mean{i});
    eye_mean_err(i) = sqrt(nanmean((ver_mean{i}(1:nt-200) - ver_mean_pred{i}(1:nt-200)).^2 + (hor_mean{i}(1:nt-200) - hor_mean_pred{i}(1:nt-200)).^2));
end
[eyestats.eyebehvcorr_r,eyestats.eyebehvcorr_pval] = nancorr(trlerrors(:), eye_mean_err(:));
eyestats.eyepos_err = eye_mean_err(:); eyestats.stoppos_err = trlerrors(:);

%% save true and predicted eye positions
for i=1:ntrials
%     eyestats.flypos_r{i} = rt{i};
%     eyestats.flypos_theta{i} = thetat{i};
    eyestats.ver_pred{i} = ver_mean_pred{i};
    eyestats.hor_pred{i} = hor_mean_pred{i};
    eyestats.verdiff_pred{i} = ver_diff_pred{i};
    eyestats.hordiff_pred{i} = hor_diff_pred{i};
    eyestats.ver_true{i} = ver_mean{i};
    eyestats.hor_true{i} = hor_mean{i};
    eyestats.verdiff_true{i} = ver_diff{i};
    eyestats.hordiff_true{i} = hor_diff{i};
end

Nt = max(cellfun(@(x) length(x),rt)); % max number of timepoints
%% compare predicted & eye positions from all trials aligned to target fixation
% gather predicted eye position
ver_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
% compute variance of predicted eye position
ver_var_pred1 = ComputeVarianceEyeVer(xt,yt,zt,var_xmt,var_ymt,'normal');
hor_var_pred1 = ComputeVarianceEyeHor(xt,yt,zt,var_xmt,var_ymt,'normal');
% gather true eye position
ver_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));

% cross-correlation between observed and predicted eye positions
zeropad_length = 200; % pad these many bins around each trial

pred = [zeros(zeropad_length,ntrials); ver_mean_pred1; zeros(zeropad_length,ntrials)]; pred_shuffled = pred(:,randperm(ntrials));
pred = pred(:); pred(isnan(pred)) = 0; pred_shuffled = pred_shuffled(:); pred_shuffled(isnan(pred_shuffled)) = 0;
obs = [zeros(zeropad_length,ntrials); ver_mean1; zeros(zeropad_length,ntrials)];  obs = obs(:); obs(isnan(obs)) = 0;
[eyestats.ver_xcorr,eyestats.ver_xcorrlag] = xcorr(pred,obs,400,'coeff');
eyestats.ver_xcorrshuf = xcorr(pred_shuffled,obs,400,'coeff');

pred = [zeros(zeropad_length,ntrials); hor_mean_pred1; zeros(zeropad_length,ntrials)]; pred_shuffled = pred(:,randperm(ntrials));
pred = pred(:); pred(isnan(pred)) = 0; pred_shuffled = pred_shuffled(:); pred_shuffled(isnan(pred_shuffled)) = 0;
obs = [zeros(zeropad_length,ntrials); hor_mean1; zeros(zeropad_length,ntrials)];  obs = obs(:); obs(isnan(obs)) = 0;
[eyestats.hor_xcorr,eyestats.hor_xcorrlag] = xcorr(pred,obs,400,'coeff');
eyestats.hor_xcorrshuf = xcorr(pred_shuffled,obs,400,'coeff');

% timecourse of component-wise corr between predicted & true eye position
[eyestats.ver_rfix,eyestats.ver_pvalfix] = arrayfun(@(i) corr(ver_mean1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.hor_rfix,eyestats.hor_pvalfix] = arrayfun(@(i) corr(hor_mean1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.verdiff_rfix,eyestats.verdiff_pvalfix] = arrayfun(@(i) corr(ver_diff1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.hordiff_rfix,eyestats.hordiff_pvalfix] = arrayfun(@(i) corr(hor_diff1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% timecourse of component-wise regression between predicted & true eye position
% beta = cell2mat(arrayfun(@(i) regress(ver_mean1(i,:)',[ver_mean_pred1(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_verpredvstrue_beta10fix,eyestats.eyepos_verpredvstrue_beta00fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_mean1(i,:)',[hor_mean_pred1(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_horpredvstrue_beta10fix,eyestats.eyepos_horpredvstrue_beta00fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_diff1(i,:)',[ver_diff_pred1(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_verdiffpredvstrue_beta10fix,eyestats.eyepos_verdiffpredvstrue_beta00fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_diff1(i,:)',[hor_diff_pred1(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_hordiffpredvstrue_beta10fix,eyestats.eyepos_hordiffpredvstrue_beta00fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_mean1(i,:)',[ver_mean_pred1(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_verpredvstrue_beta1fix,eyestats.eyepos_verpredvstrue_beta0fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_mean1(i,:)',[hor_mean_pred1(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_horpredvstrue_beta1fix,eyestats.eyepos_horpredvstrue_beta0fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_diff1(i,:)',[ver_diff_pred1(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_verdiffpredvstrue_beta1fix,eyestats.eyepos_verdiffpredvstrue_beta0fix] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_diff1(i,:)',[hor_diff_pred1(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos_hordiffpredvstrue_beta1fix,eyestats.eyepos_hordiffpredvstrue_beta0fix] = deal(beta(1,:),beta(2,:));

% timecourse of cosine similarity between predicted & true eye position
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]);
true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]);
cos_similarity = nan(Nboots,Nt); cos_similarity_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrials,ntrials,1); randtrls2 = randsample(ntrials,ntrials,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
    cos_similarity_shuffled(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls2)), 1:Nt);
end
eyestats.cossim_meanfix = mean(cos_similarity)';
eyestats.cossim_semfix = std(cos_similarity)';
eyestats.cossim_meanshuffix = mean(cos_similarity_shuffled)';
eyestats.cossim_semshuffix = std(cos_similarity_shuffled)';

% timecourse of cosine similarity between predicted & true eye position
ngroups = 5;
ntrls_per_group = (ntrials - mod(ntrials,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
cos_similarity = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,trlgroup),true(:,i,trlgroup)), 1:Nt);
end
eyestats.cossimgrouped_fix = cos_similarity;

% timecourse of centered cosine similarity between predicted & true eye position -
% pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrials]))./repmat(nanstd(pred,[],3),[1 1 ntrials]);
% true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrials]))./repmat(nanstd(true,[],3),[1 1 ntrials]);
% cntr_cos_similarity = nan(Nboots,Nt);
% for i=1:Nboots
%     randtrls = randsample(ntrials,ntrials,1);
%     cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
% end
% eyestats.cntrcossim_predvstrue_meanfix = mean(cntr_cos_similarity);
% eyestats.cntrcossimpredvstrue_semfix = std(cntr_cos_similarity);

% timecourse of variance explained
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]);
true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]);
var_explained = nan(Nboots,Nt); var_explained_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrials,ntrials,1); randtrls2 = randsample(ntrials,ntrials,1);
    squared_err = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls)).^2,3)); var_pred = sum(nanvar(pred(:,:,randtrls),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
    squared_err_shuffled = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls2)).^2,3)); var_pred_shuffled = sum(nanvar(pred(:,:,randtrls2),[],3));
    var_explained_shuffled(i,:) =  1 - (squared_err_shuffled(:)./var_pred_shuffled(:));
end
eyestats.varexp_meanfix = nanmean(var_explained)';
eyestats.varexp_semfix = nanstd(var_explained)';
eyestats.varexp_meanshuffix = nanmean(var_explained_shuffled)';
eyestats.varexp_semshuffix = nanstd(var_explained_shuffled)';

% timecourse of upper bound on variance explained
expected_squared_err = (nanmean(ver_var_pred1,2) + nanmean(hor_var_pred1,2)); var_pred = sum(nanvar(pred,[],3)); var_true = sum(nanvar(true,[],3));
eyestats.varexpbound_fix = 1 - (expected_squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
eyestats.sqerr_fix = expected_squared_err(:);
eyestats.var_pred_fix = var_pred(:);
eyestats.var_true_fix = var_true(:);

% timecourse of variance explained for various accuracies
ngroups = 5;
ntrls_per_group = (ntrials - mod(ntrials,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
var_explained = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    squared_err = sum(nanmean((true(:,:,trlgroup) - pred(:,:,trlgroup)).^2,3)); var_pred = sum(nanvar(pred(:,:,trlgroup),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
end
eyestats.varexpgrouped_fix = var_explained;

% timecourse of similarity measure based on Mahalanobis distance
% dist_mahalanobis = nan(Nboots,Nt); dist_mahalanobis_shuffled = nan(Nboots,Nt);
% for i=1:Nboots
%     randtrls = randsample(ntrials,ntrials,1);
%     [~,indx1] = min(abs(squeeze(true(1,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
%     [~,indx2] = min(abs(squeeze(true(2,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
%     ver_mahalanobis = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
%     hor_mahalanobis = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
%     randtrls2 = randsample(ntrials,ntrials,1);
%     ver_mahalanobis_shuffled = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls2))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
%     hor_mahalanobis_shuffled = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls2))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
%     dist_mahalanobis(i,:) = sqrt(ver_mahalanobis + hor_mahalanobis);
%     dist_mahalanobis_shuffled(i,:) = sqrt(ver_mahalanobis_shuffled + hor_mahalanobis_shuffled);
% end
% dist_mahalanobis = nanmean(dist_mahalanobis); d0 = min(dist_mahalanobis(1:50)); % reused for stopaligned analysis
% eyestats.eyepos.pred_vs_true.mahalanobis_distance.mu.startaligned = dist_mahalanobis;
% eyestats.eyepos.pred_vs_true.mahalanobis_similarity.mu.startaligned = 2./(1 + dist_mahalanobis/d0);
% dist_mahalanobis_shuffled = nanmean(dist_mahalanobis_shuffled);
% eyestats.eyepos.pred_vs_true.mahalanobis_distance_shuffled.mu.startaligned = dist_mahalanobis_shuffled;
% eyestats.eyepos.pred_vs_true.mahalanobis_similarity_shuffled.mu.startaligned = 2./(1 + dist_mahalanobis_shuffled/d0);
% 
% % timecourse of upper bound on similarity measure based on Mahalanobis distance
% [~,indx1] = min(abs(squeeze(true(1,:,:)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
% ver_mahalanobis_expected = nanmean(ver_var_pred1./(eye_fixation.eyepos.true.hor_mean.sig(indx1).^2),2);
% [~,indx2] = min(abs(squeeze(true(2,:,:)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
% hor_mahalanobis_expected = nanmean(hor_var_pred1./(eye_fixation.eyepos.true.ver_mean.sig(indx2).^2),2);
% dist_mahalanobis_expected = sqrt(ver_mahalanobis_expected + hor_mahalanobis_expected);
% eyestats.eyepos.pred_vs_true.mahalanobis_upperbound.mu.startaligned = 2./(1 + dist_mahalanobis_expected/d0);

%% compare predicted & eye positions from all trials aligned to end of movement
% predicted eye position
ver_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
% compute variance of predicted eye position
ver_var_pred2 = ComputeVarianceEyeVer(xt,yt,zt,var_xmt,var_ymt,'reverse');
hor_var_pred2 = ComputeVarianceEyeHor(xt,yt,zt,var_xmt,var_ymt,'reverse');
% true eye position
ver_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));

% timecourse of component-wise corr between predicted & true eye position
[eyestats.ver_rstop,eyestats.ver_pvalstop] = arrayfun(@(i) corr(ver_mean2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.hor_rstop,eyestats.hor_pvalstop] = arrayfun(@(i) corr(hor_mean2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.verdiff_rstop,eyestats.verdiff_pvalstop] = arrayfun(@(i) corr(ver_diff2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eyestats.hordiff_rstop,eyestats.hordiff_pvalstop] = arrayfun(@(i) corr(hor_diff2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% component-wise regression between predicted & true eye position
% beta = cell2mat(arrayfun(@(i) regress(ver_mean2(i,:)',[ver_mean_pred2(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.ver_mean.beta10.stopaligned,eyestats.eyepos.pred_vs_true.ver_mean.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_mean2(i,:)',[hor_mean_pred2(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.hor_mean.beta10.stopaligned,eyestats.eyepos.pred_vs_true.hor_mean.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_diff2(i,:)',[ver_diff_pred2(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.ver_diff.beta10.stopaligned,eyestats.eyepos.pred_vs_true.ver_diff.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_diff2(i,:)',[hor_diff_pred2(i,:)' zeros(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.hor_diff.beta10.stopaligned,eyestats.eyepos.pred_vs_true.hor_diff.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_mean2(i,:)',[ver_mean_pred2(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.ver_mean.beta1.stopaligned,eyestats.eyepos.pred_vs_true.ver_mean.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_mean2(i,:)',[hor_mean_pred2(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.hor_mean.beta1.stopaligned,eyestats.eyepos.pred_vs_true.hor_mean.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(ver_diff2(i,:)',[ver_diff_pred2(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.ver_diff.beta1.stopaligned,eyestats.eyepos.pred_vs_true.ver_diff.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
% beta = cell2mat(arrayfun(@(i) regress(hor_diff2(i,:)',[hor_diff_pred2(i,:)' ones(ntrials,1)]), 1:Nt, 'UniformOutput', false)); [eyestats.eyepos.pred_vs_true.hor_diff.beta1.stopaligned,eyestats.eyepos.pred_vs_true.hor_diff.beta0.stopaligned] = deal(beta(1,:),beta(2,:));

% timecourse of cosine similarity between predicted & true eye position
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]);
true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]);
cos_similarity = nan(Nboots,Nt); cos_similarity_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrials,ntrials,1); randtrls2 = randsample(ntrials,ntrials,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
    cos_similarity_shuffled(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls2)), 1:Nt);
end
eyestats.cossim_meanstop = mean(cos_similarity)';
eyestats.cossim_semstop = std(cos_similarity)';
eyestats.cossim_meanshufstop = mean(cos_similarity_shuffled)';
eyestats.cossim_semshufstop = std(cos_similarity_shuffled)';

% timecourse of cosine similarity between predicted & true eye position -
ngroups = 5;
ntrls_per_group = (ntrials - mod(ntrials,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
cos_similarity = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,trlgroup),true(:,i,trlgroup)), 1:Nt);
end
eyestats.cossimgrouped_stop = cos_similarity;

% timecourse of centered cosine similarity between predicted & true eye position -
% pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrials]))./repmat(nanstd(pred,[],3),[1 1 ntrials]);
% true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrials]))./repmat(nanstd(true,[],3),[1 1 ntrials]);
% cntr_cos_similarity = nan(Nboots,Nt);
% for i=1:Nboots
%     randtrls = randsample(ntrials,ntrials,1);
%     cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
% end
% eyestats.eyepos.pred_vs_true.cntr_cos_similarity.mu.stopaligned = mean(cntr_cos_similarity);
% eyestats.eyepos.pred_vs_true.cntr_cos_similarity.sem.stopaligned = std(cntr_cos_similarity);

% timecourse of variance explained
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]);
true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]);
var_explained = nan(Nboots,Nt); var_explained_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrials,ntrials,1); randtrls2 = randsample(ntrials,ntrials,1);
    squared_err = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls)).^2,3)); var_pred = sum(nanvar(pred(:,:,randtrls),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
    squared_err_shuffled = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls2)).^2,3)); var_pred_shuffled = sum(nanvar(pred(:,:,randtrls2),[],3));
    var_explained_shuffled(i,:) =  1 - (squared_err_shuffled(:)./var_pred_shuffled(:));
end
eyestats.varexp_meanstop = nanmean(var_explained)';
eyestats.varexp_semstop = nanstd(var_explained)';
eyestats.varexp_meanshufstop = nanmean(var_explained_shuffled)';
eyestats.varexp_semshufstop = nanstd(var_explained_shuffled)';

% timecourse of upper bound on variance explained
expected_squared_err = (nanmean(ver_var_pred2,2) + nanmean(hor_var_pred2,2)); var_pred = sum(nanvar(pred,[],3)); var_true = sum(nanvar(true,[],3));
eyestats.varexpbound_stop = 1 - (expected_squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
eyestats.sqerr_stop = expected_squared_err(:);
eyestats.var_pred_stop = var_pred(:);
eyestats.var_true_stop = var_true(:);

% timecourse of variance explained for various accuracies
ngroups = 5;
ntrls_per_group = (ntrials - mod(ntrials,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
var_explained = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    squared_err = sum(nanmean((true(:,:,trlgroup) - pred(:,:,trlgroup)).^2,3)); var_pred = sum(nanvar(pred(:,:,trlgroup),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
end
eyestats.varexpgrouped_stop = var_explained;

% timecourse of similarity measure based on Mahalanobis distance
% dist_mahalanobis = nan(Nboots,Nt); dist_mahalanobis_shuffled = nan(Nboots,Nt);
% for i=1:Nboots
%     randtrls = randsample(ntrials,ntrials,1);
%     [~,indx1] = min(abs(squeeze(true(1,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
%     [~,indx2] = min(abs(squeeze(true(2,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
%     ver_mahalanobis = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
%     hor_mahalanobis = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
%     randtrls2 = randsample(ntrials,ntrials,1);
%     ver_mahalanobis_shuffled = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls2))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
%     hor_mahalanobis_shuffled = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls2))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
%     dist_mahalanobis(i,:) = sqrt(ver_mahalanobis + hor_mahalanobis);
%     dist_mahalanobis_shuffled(i,:) = sqrt(ver_mahalanobis_shuffled + hor_mahalanobis_shuffled);
% end
% dist_mahalanobis = nanmean(dist_mahalanobis);
% eyestats.eyepos.pred_vs_true.mahalanobis_distance.mu.stopaligned = dist_mahalanobis;
% eyestats.eyepos.pred_vs_true.mahalanobis_similarity.mu.stopaligned = 2./(1 + dist_mahalanobis/d0);
% dist_mahalanobis_shuffled = nanmean(dist_mahalanobis_shuffled);
% eyestats.eyepos.pred_vs_true.mahalanobis_distance_shuffled.mu.stopaligned = dist_mahalanobis_shuffled;
% eyestats.eyepos.pred_vs_true.mahalanobis_similarity_shuffled.mu.stopaligned = 2./(1 + dist_mahalanobis_shuffled/d0);
% 
% % timecourse of upper bound on similarity measure based on Mahalanobis distance
% [~,indx1] = min(abs(squeeze(true(1,:,:)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
% ver_mahalanobis_expected = nanmean(ver_var_pred2./(eye_fixation.eyepos.true.hor_mean.sig(indx1).^2),2);
% [~,indx2] = min(abs(squeeze(true(2,:,:)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrials]),[2 3 1])),[],3);
% hor_mahalanobis_expected = nanmean(hor_var_pred2./(eye_fixation.eyepos.true.ver_mean.sig(indx2).^2),2);
% dist_mahalanobis_expected = sqrt(ver_mahalanobis_expected + hor_mahalanobis_expected);
% eyestats.eyepos.pred_vs_true.mahalanobis_upperbound.mu.stopaligned = 2./(1 + dist_mahalanobis_expected/d0);