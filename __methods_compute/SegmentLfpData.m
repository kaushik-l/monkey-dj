function trials = SegmentLfpData(lfp_data,event_data,analysisprs,freqrange)

%% gather events
nblocks = numel(lfp_data.lfp_tblockstart);
event_data.tblockstart(nblocks+1) = inf;
tbeg = []; trew = []; tend = []; tptb = [];
tmove = []; tstop = []; tsac = [];

for block = 1:nblocks
    trialindx = event_data.tend > event_data.tblockstart(block) & event_data.tend < event_data.tblockstart(block+1);
    tbeg = [tbeg ; event_data.tbeg(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
    trew = [trew ; event_data.trew(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
    tend = [tend ; event_data.tend(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
    tptb = [tptb ; event_data.tptb(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
    tmove = [tmove ; event_data.tmove(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
    tstop = [tstop ; event_data.tstop(trialindx) - event_data.tblockstart(block) + lfp_data.lfp_tblockstart(block)];
end
ntrials = numel(tend);

%% filter LFP
t = lfp_data.lfp_time;                                % timepoints
dt = round(median(diff(lfp_data.lfp_time))*1e4)*1e-4; % timesteps
fs = 1/dt;
switch freqrange
    case 'raw'
        % full range
        [b,a] = butter(analysisprs.lfp_filtorder,[analysisprs.lfp_filt(1) analysisprs.lfp_filt(2)]/(fs/2));
        lfp_data.lfp_amplitude = filtfilt(b,a,lfp_data.lfp_amplitude);
    case 'theta'
        % theta range
        [b,a] = butter(analysisprs.lfp_filtorder,[analysisprs.lfp_theta(1) analysisprs.lfp_theta(2)]/(fs/2));
        lfp_data.lfp_amplitude = filtfilt(b,a,lfp_data.lfp_amplitude);
    case 'beta'
        % beta range
        [b,a] = butter(analysisprs.lfp_filtorder,[analysisprs.lfp_beta(1) analysisprs.lfp_beta(2)]/(fs/2));
        lfp_data.lfp_amplitude = filtfilt(b,a,lfp_data.lfp_amplitude);
end
% hilbert transform
lfp_data.lfp_amplitude = hilbert(lfp_data.lfp_amplitude);

%% gather fieldnames
fieldnames = fields(lfp_data);
fieldnames_continuous = fieldnames(cellfun(@(k) (length(lfp_data.(k))==length(lfp_data.lfp_time)), fieldnames));

%% extract trials and downsample for storage
for j=1:ntrials
    %% save continuous variables
    % define pretrial and posttrial periods
    pretrial = max(tbeg(j) - tmove(j),0) + analysisprs.pretrial; % extract everything from "movement onset - pretrial" or "target onset - pretrial" - whichever is first
    posttrial = analysisprs.posttrial; % extract everything until "t_end + posttrial"
    for i=1:length(fieldnames_continuous)
        if ~strcmp(fieldnames_continuous{i},'lfp_time')            
            trials(j).(fieldnames_continuous{i}) = ...
                lfp_data.(fieldnames_continuous{i})(t>tbeg(j)-pretrial & t<tend(j)+posttrial);
        end
    end
    trials(j).lfp_time = (dt:dt:length(trials(j).(fieldnames_continuous{1}))*dt)' + ...
        ((tbeg(j)-pretrial)<0)*(-tbeg(j)) + ((tbeg(j)-pretrial)>0)*(-pretrial); % because not enough pretrial before 1st trial
    
    %% reference trial events to target onset (tbeg)
    trials(j).lfp_tbeg = tbeg(j) - tbeg(j);
    trials(j).lfp_tmove = tmove(j) - tbeg(j);
    trials(j).lfp_tstop = tstop(j) - tbeg(j);
    trials(j).lfp_trew = trew(j) - tbeg(j);
    trials(j).lfp_tend = tend(j) - tbeg(j);
    % perturbation onset time
    trials(j).lfp_tptb = tptb(j) - tbeg(j);
end

%% downsample continuous data
factor_downsample = round(analysisprs.dt/dt);
for j=1:ntrials
    for i=1:length(fieldnames_continuous)
        trials(j).(fieldnames_continuous{i}) = ...
            downsample(trials(j).(fieldnames_continuous{i}),factor_downsample);
        trials(j).(fieldnames_continuous{i}) = trials(j).(fieldnames_continuous{i})(:);
    end
end