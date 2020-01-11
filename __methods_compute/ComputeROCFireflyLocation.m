function [auc_rbin, auc_r, auc_thbin, auc_th] = ...
    ComputeROCFireflyLocation(X_fly,X_monk,maxrewardwin)

%% initialise
rewardwin = linspace(0, maxrewardwin, 20); % total of 20 reward windows
pCorrect = zeros(1,length(rewardwin));
pCorrect_shuffled = zeros(1,length(rewardwin));
ntrls = length(X_fly);
dist2fly = zeros(1,ntrls);

%% bin r and theta
rbinedges = linspace(prctile(X_fly(:,1),1),prctile(X_fly(:,1),99),11);
thbinedges = linspace(prctile(X_fly(:,2),1),prctile(X_fly(:,2),99),11);

%% compute AUC vs target distance
nbinedges = numel(rbinedges);
for k=1:nbinedges-1
    trlindx = X_fly(:,1)>rbinedges(k) & X_fly(:,1)<rbinedges(k+1);
    for j=1:length(rewardwin)
        % unshuffled errors
        for i=1:ntrls
            dist2fly(i) = distance(X_fly(i,:), X_monk(i,:), 'polar');
        end
        % unshuffled accuracy
        pCorrect(k,j) = sum(dist2fly(trlindx) < rewardwin(j))/sum(trlindx); % fraction of correct trials
        indx = randperm(ntrls);
        X_monk2 = X_monk(indx,:);
        % shuffled errors
        dist2fly_shuffled = zeros(1,ntrls);
        for i=1:ntrls
            dist2fly_shuffled(i) = distance(X_fly(i,:), X_monk2(i,:), 'polar');
        end
        % shuffled accuracy
        pCorrect_shuffled(k,j) = sum(dist2fly_shuffled(trlindx) < rewardwin(j))/sum(trlindx);
    end
    %% AUC
    auc_r(k) = sum(diff(pCorrect_shuffled(k,:)).*pCorrect(k,2:end));
end

%% compute AUC vs target angle
nbinedges = numel(thbinedges);
for k=1:nbinedges-1
    trlindx = X_fly(:,2)>thbinedges(k) & X_fly(:,2)<thbinedges(k+1);
    for j=1:length(rewardwin)
        % unshuffled errors
        for i=1:ntrls
            dist2fly(i) = distance(X_fly(i,:), X_monk(i,:), 'polar');
        end
        % unshuffled accuracy
        pCorrect(k,j) = sum(dist2fly(trlindx) < rewardwin(j))/sum(trlindx); % fraction of correct trials
        indx = randperm(ntrls);
        X_monk2 = X_monk(indx,:);
        % shuffled errors
        dist2fly_shuffled = zeros(1,ntrls);
        for i=1:ntrls
            dist2fly_shuffled(i) = distance(X_fly(i,:), X_monk2(i,:), 'polar');
        end
        % shuffled accuracy
        pCorrect_shuffled(k,j) = sum(dist2fly_shuffled(trlindx) < rewardwin(j))/sum(trlindx);
    end
    %% AUC
    auc_th(k) = sum(diff(pCorrect_shuffled(k,:)).*pCorrect(k,2:end));
end

auc_rbin = 0.5*(rbinedges(1:end-1) + rbinedges(2:end));
auc_thbin = 0.5*(thbinedges(1:end-1) + thbinedges(2:end));