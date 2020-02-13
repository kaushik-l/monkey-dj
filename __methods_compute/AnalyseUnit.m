function stats = AnalyseUnit(trials,trialsbehv,trialslfp,analysisprs)

ntrials = numel(trials);
twin = analysisprs.neuron_eventtriggerwindow;
dt = analysisprs.dt;
nbootstraps = analysisprs.nbootstraps;
minpeakprom = analysisprs.minpeakprom_neural;
mintrialsforstats = analysisprs.mintrialsforstats;
peaktimewindow = analysisprs.peaktimewindow;
duration_zeropad = analysisprs.duration_zeropad;
duration_nanpad = analysisprs.duration_nanpad;
corr_lag = analysisprs.corr_lag;
sta_window = analysisprs.sta_window;
sfc_window = analysisprs.sfc_window;
spectralparams.tapers = analysisprs.spectrum_tapers;
spectralparams.Fs = 1/dt;
spectralparams.trialave = analysisprs.spectrum_trialave;

%% event-triggered firing rates
% movement-triggered
spiketimes = ShiftSpikes(trials,[trials.neuron_tmove]);
[stats.mta_rate,stats.mta_time] = Spiketimes2Rate(spiketimes,twin,dt);
peakresp = EvaluatePeakresponse(spiketimes,twin,dt,...
    peaktimewindow,minpeakprom,nbootstraps,mintrialsforstats);
stats.mta_peakrate = [peakresp.preevent.rate peakresp.postevent.rate];
stats.mta_peaktime = [peakresp.preevent.time peakresp.postevent.time];
stats.mta_peakpval = [peakresp.preevent.pval peakresp.postevent.pval];

% fireflyonset-triggered
spiketimes = ShiftSpikes(trials,[trials.neuron_tbeg]);
[stats.fta_rate,stats.fta_time] = Spiketimes2Rate(spiketimes,twin,dt);
peakresp = EvaluatePeakresponse(spiketimes,twin,dt,...
    peaktimewindow,minpeakprom,nbootstraps,mintrialsforstats);
stats.fta_peakrate = [peakresp.preevent.rate peakresp.postevent.rate];
stats.fta_peaktime = [peakresp.preevent.time peakresp.postevent.time];
stats.fta_peakpval = [peakresp.preevent.pval peakresp.postevent.pval];

% stop-triggered
spiketimes = ShiftSpikes(trials,[trials.neuron_tstop]);
[stats.sta_rate,stats.sta_time] = Spiketimes2Rate(spiketimes,twin,dt);
peakresp = EvaluatePeakresponse(spiketimes,twin,dt,...
    peaktimewindow,minpeakprom,nbootstraps,mintrialsforstats);
stats.sta_peakrate = [peakresp.preevent.rate peakresp.postevent.rate];
stats.sta_peaktime = [peakresp.preevent.time peakresp.postevent.time];
stats.sta_peakpval = [peakresp.preevent.pval peakresp.postevent.pval];

% reward-triggered
spiketimes = ShiftSpikes(trials,[trials.neuron_trew]);
[stats.rta_rate,stats.rta_time] = Spiketimes2Rate(spiketimes,twin,dt);
peakresp = EvaluatePeakresponse(spiketimes,twin,dt,...
    peaktimewindow,minpeakprom,nbootstraps,mintrialsforstats);
stats.rta_peakrate = [peakresp.preevent.rate peakresp.postevent.rate];
stats.rta_peaktime = [peakresp.preevent.time peakresp.postevent.time];
stats.rta_peakpval = [peakresp.preevent.pval peakresp.postevent.pval];

%% tuning functions
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
timewindow_move = [[trials.neuron_tmove]' [trials.neuron_tstop]']; % when the subject is moving
timewindow_path = [[trials.neuron_tbeg]' [trials.neuron_tstop]']; % when the subject is integrating path

% velocity
tuning_v = ComputeTuning({trialsbehv.joy_linvel},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_v);
tuning_w = ComputeTuning({trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_move,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrang_w);
tuning_vw = ComputeTuning2D({trialsbehv.joy_linvel},{trialsbehv.joy_angvel},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_move,tuning,'binning');

% position along path
d = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{trialsbehv.joy_linvel},{trialsbehv.behv_time},'UniformOutput',false);
tuning_d = ComputeTuning(d,{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_d);
phi = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{trialsbehv.joy_angvel},{trialsbehv.behv_time},'UniformOutput',false);
tuning_phi = ComputeTuning(phi,{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_phi); %%#^%$^%$^ fix spelling error in analysisparam

% position relative to target
tuning_r = ComputeTuning({trialsbehv.dist2firefly_r},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_r_targ);
tuning_theta = ComputeTuning({trialsbehv.dist2firefly_th},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_theta_targ);

% position in world
tuning_xy = ComputeTuning2D({trialsbehv.monkey_xtraj},{trialsbehv.monkey_ytraj},{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,tuning,'binning');

% eye position
ev = cellfun(@(x,y) nanmean([x y],2), {trialsbehv.leye_verpos}, {trialsbehv.reye_verpos}, 'UniformOutput', false);
tuning_ev = ComputeTuning(ev,{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',[]);
eh = cellfun(@(x,y) nanmean([x y],2), {trialsbehv.leye_horpos}, {trialsbehv.reye_horpos}, 'UniformOutput', false);
tuning_eh = ComputeTuning(eh,{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_eye_hor);
tuning_evh = ComputeTuning2D(ev,eh,{trialsbehv.behv_time},{trials.spike_times},...
    timewindow_path,tuning,'binning');

% lfp phase
lfp_phase = cellfun(@(x) angle(x), {trialslfp.lfp_amplitude}, 'UniformOutput', false);
tuning_phase = ComputeTuning(lfp_phase,{trialslfp.lfp_time},{trials.spike_times},...
    timewindow_path,duration_zeropad,corr_lag,[],tuning,'binning',analysisprs.binrange_phase);

% save                    
stats.tuning_v = tuning_v.tuning.stim.mu;
stats.tuning_vrate = tuning_v.tuning.rate.mu;
stats.tuning_vpval = tuning_v.tuning.pval;
stats.tuning_w = tuning_w.tuning.stim.mu;
stats.tuning_wrate = tuning_w.tuning.rate.mu;
stats.tuning_wpval = tuning_w.tuning.pval;
stats.tuning_vw = tuning_vw.tuning.stim.mu;
stats.tuning_vwrate = tuning_vw.tuning.rate.mu;
stats.tuning_d = tuning_d.tuning.stim.mu;
stats.tuning_drate = tuning_d.tuning.rate.mu;
stats.tuning_dpval = tuning_d.tuning.pval;
stats.tuning_phi = tuning_phi.tuning.stim.mu;
stats.tuning_phirate = tuning_phi.tuning.rate.mu;
stats.tuning_phipval = tuning_phi.tuning.pval;
stats.tuning_r = tuning_r.tuning.stim.mu;
stats.tuning_rrate = tuning_r.tuning.rate.mu;
stats.tuning_rpval = tuning_r.tuning.pval;
stats.tuning_theta = tuning_theta.tuning.stim.mu;
stats.tuning_thetarate = tuning_theta.tuning.rate.mu;
stats.tuning_thetapval = tuning_theta.tuning.pval;
stats.tuning_xy = tuning_xy.tuning.stim.mu;
stats.tuning_xyrate = tuning_xy.tuning.rate.mu;
stats.tuning_eh = tuning_eh.tuning.stim.mu;
stats.tuning_ehrate = tuning_eh.tuning.rate.mu;
stats.tuning_ehpval = tuning_eh.tuning.pval;
stats.tuning_ev = tuning_ev.tuning.stim.mu;
stats.tuning_evrate = tuning_ev.tuning.rate.mu;
stats.tuning_evpval = tuning_ev.tuning.pval;
stats.tuning_evh = tuning_evh.tuning.stim.mu;
stats.tuning_evhrate = tuning_evh.tuning.rate.mu;
stats.tuning_phase = tuning_phase.tuning.stim.mu;
stats.tuning_phaserate = tuning_phase.tuning.rate.mu;
stats.tuning_phasepval = tuning_phase.tuning.pval;

%% spike-triggered average of LFP (###do as a function of time rel. to events)
sta = SpikeTriggeredLFP({trialslfp.lfp_amplitude},{trialslfp.lfp_time},{trials.spike_times},...
    timewindow_path,sta_window,sfc_window,duration_nanpad,spectralparams);
stats.spiketrig_time = sta.t(:);
stats.spiketrig_avg = sta.lfp(:);
stats.spikefield_freq = sta.f(:);
stats.spikefield_coh = sta.sfc(:);