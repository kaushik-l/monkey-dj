function stats = AnalyseLfp(trials,trialsbehv,analysisprs)

ntrials = numel(trials);
twin = analysisprs.lfp_eventtriggerwindow;
dt = analysisprs.dt;
duration_zeropad = analysisprs.duration_zeropad;
corr_lag = analysisprs.corr_lag;
nbootstraps = analysisprs.nbootstraps;
spectralparams.tapers = analysisprs.spectrum_tapers;
spectralparams.Fs = 1/dt;
spectralparams.trialave = analysisprs.spectrum_trialave;
winsize = analysisprs.tfspectrum_twinsize;

%% event-triggered averages and spectrograms
% movement-triggered
[lfps, ts] = ShiftLfps(trials,[trials.lfp_tmove],dt);
timeindx = (ts>twin(1) & ts<twin(2));
lfps = lfps(timeindx,:); 
ts = ts(timeindx);
stats.mta_amplitude = nanmean(real(lfps),2);
stats.mta_power = nanmean(abs(lfps),2);
stats.mta_time = ts(:);
[stats.tfspectrum_mtpsd,stats.tfspectrum_time,stats.tfspectrum_freq] = ...
    mtspecgramc(real(lfps),[winsize 5*dt],spectralparams);

% fireflyonset-triggered
[lfps, ts] = ShiftLfps(trials,[trials.lfp_tbeg],dt);
timeindx = (ts>twin(1) & ts<twin(2));
lfps = lfps(timeindx,:); 
ts = ts(timeindx);
stats.fta_amplitude = nanmean(real(lfps),2);
stats.fta_power = nanmean(abs(lfps),2);
stats.fta_time = ts(:);
[stats.tfspectrum_ftpsd,stats.tfspectrum_time,stats.tfspectrum_freq] = ...
    mtspecgramc(real(lfps),[winsize 5*dt],spectralparams);

% stop-triggered
[lfps, ts] = ShiftLfps(trials,[trials.lfp_tstop],dt);
timeindx = (ts>twin(1) & ts<twin(2));
lfps = lfps(timeindx,:); 
ts = ts(timeindx);
stats.sta_amplitude = nanmean(real(lfps),2);
stats.sta_power = nanmean(abs(lfps),2);
stats.sta_time = ts(:);
[stats.tfspectrum_stpsd,stats.tfspectrum_time,stats.tfspectrum_freq] = ...
    mtspecgramc(real(lfps),[winsize 5*dt],spectralparams);

% reward-triggered
[lfps, ts] = ShiftLfps(trials,[trials.lfp_trew],dt);
timeindx = (ts>twin(1) & ts<twin(2));
lfps = lfps(timeindx,:); 
ts = ts(timeindx);
stats.rta_amplitude = nanmean(real(lfps),2);
stats.rta_power = nanmean(abs(lfps),2);
stats.rta_time = ts(:);
[stats.tfspectrum_rtpsd,stats.tfspectrum_time,stats.tfspectrum_freq] = ...
    mtspecgramc(real(lfps),[winsize 5*dt],spectralparams);
stats.tfspectrum_time = stats.tfspectrum_time + twin(1);

%% compute tuning to velocity
tuning.nbins1d_binning = analysisprs.tuning_nbins1d_binning; % bin edges for tuning curves by 'binning' method
tuning.nbins2d_binning = analysisprs.tuning_nbins2d_binning; % define bin edges for 2-D tuning curves by 'binning' method
tuning.nbins1d_knn = analysisprs.tuning_nbins1d_knn; 
tuning.nbins2d_knn = analysisprs.tuning_nbins2d_knn;
tuning.kernel_nw = analysisprs.tuning_kernel_nw; % choose from 'Uniform', 'Epanechnikov', 'Biweight', 'Gaussian'
tuning.bandwidth_nw = analysisprs.tuning_bandwidth_nw; 
tuning.bandwidth2d_nw = analysisprs.tuning_bandwidth2d_nw;
tuning.nbins_nw = analysisprs.tuning_nbins_nw; 
tuning.nbins2d_nw = analysisprs.tuning_nbins2d_nw;
tuning.kernel_locallinear = analysisprs.tuning_kernel_locallinear;
tuning.bandwidth_locallinear = analysisprs.tuning_bandwidth_locallinear;
tuning.use_binrange = analysisprs.tuning_use_binrange;
timewindow_move = [[trials.lfp_tmove]' [trials.lfp_tstop]'];

% tuning of instantaneous frequency
for i=1:ntrials
    instfreq = [(1/dt)/(2*pi)*diff(unwrap(angle(trials(i).lfp_amplitude))) ; nan];
    instfreq(instfreq<trials(i).lfp_freqrange(1) | instfreq>trials(i).lfp_freqrange(2)) = nan;
    trials(i).instfreq = instfreq;
end
freqtuning_v = ComputeTuning({trialsbehv.joy_linvel},{trialsbehv.behv_time},{trials.instfreq},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning');
freqtuning_w = ComputeTuning({trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.instfreq},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning');
freqtuning_vw = ComputeTuning2D({trialsbehv.joy_linvel},{trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.instfreq},...
    timewindow_move,tuning,'binning');

% tuning of instantaneous power
for i=1:ntrials, trials(i).instpower = abs(trials(i).lfp_amplitude); end
powertuning_v = ComputeTuning({trialsbehv.joy_linvel},{trialsbehv.behv_time},{trials.instpower},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning');
powertuning_w = ComputeTuning({trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.instpower},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning');
powertuning_vw = ComputeTuning2D({trialsbehv.joy_linvel},{trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.instpower},...
    timewindow_move,tuning,'binning');

% save
stats.tuning_v = freqtuning_v.tuning.stim.mu; 
stats.tuning_w = freqtuning_w.tuning.stim.mu;
stats.tuning_vw = freqtuning_vw.tuning.stim.mu; 
stats.tuning_vfreq = freqtuning_v.tuning.rate.mu; stats.pval_vfreq = freqtuning_v.tuning.pval;
stats.tuning_wfreq = freqtuning_w.tuning.rate.mu; stats.pval_wfreq = freqtuning_w.tuning.pval;
stats.tuning_vwfreq = freqtuning_vw.tuning.rate.mu;
stats.tuning_vpower = powertuning_v.tuning.rate.mu; stats.pval_vpower = powertuning_v.tuning.pval;
stats.tuning_wpower = powertuning_w.tuning.rate.mu; stats.pval_wpower = powertuning_w.tuning.pval;
stats.tuning_vwpower = powertuning_vw.tuning.rate.mu;

%% power-spectral density
sMarkers = [];
lfp_concat = cell2mat({trials.lfp_amplitude}'); % concatenate trials
triallen = cellfun(@(x) length(x), {trials.lfp_amplitude});
sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
[stats.spectrum_psd , stats.spectrum_freq] = ...
    mtspectrumc_unequal_length_trials(lfp_concat, analysisprs.spectrum_movingwin , spectralparams, sMarkers);% needs http://chronux.org/