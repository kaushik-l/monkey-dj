function [rate,ts] = Spiketimes2Rate(spiketimes,timepoints,binwidth)

ntrials = length(spiketimes);
ts = timepoints(1):binwidth:timepoints(2);
ts = [ts(1)-binwidth ts ts(end)+binwidth];

% compute psth
[nspk,~] = hist(cell2mat(spiketimes),ts);

% throw away histogram edges
nspk = nspk(2:end-1); 
ts = ts(2:end-1);

% trial-average firing rates in units of spikes/s
rate = nspk/(ntrials*binwidth);