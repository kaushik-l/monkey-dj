function trials = SegmentBehaviouralData(behv_data,event_data,analysisprs,stimulusprs)

RotMat = @(phi) [cosd(phi) -sind(phi); sind(phi) cosd(phi)];
%% gather events
event_data.tblockstart(end+1) = inf;
nblocks = numel(behv_data.behv_tblockstart);
tbeg = []; trew = []; tend = []; tptb = [];
tmove = []; tstop = []; tsac = [];

for block = 1:nblocks
    trialindx = event_data.tend > event_data.tblockstart(block) & event_data.tend < event_data.tblockstart(block+1);
    tbeg = [tbeg ; event_data.tbeg(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    trew = [trew ; event_data.trew(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    tend = [tend ; event_data.tend(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    tptb = [tptb ; event_data.tptb(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    tmove = [tmove ; event_data.tmove(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    tstop = [tstop ; event_data.tstop(trialindx) - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
    tsac = [tsac ; behv_data.behv_tsac(behv_data.behv_tsac > event_data.tblockstart(block) & behv_data.behv_tsac < event_data.tblockstart(block+1))...
        - event_data.tblockstart(block) + behv_data.behv_tblockstart(block)];
end
ntrials = numel(tend);

%% gather fieldnames
fieldnames = fields(behv_data);
fieldnames_continuous = fieldnames(cellfun(@(k) (length(behv_data.(k))==length(behv_data.behv_time)) ||...
    (strcmp(char(behv_data.(k)),'0') && ~strcmp(k,'session_id')), fieldnames));
fieldnames_discrete = fieldnames(cellfun(@(k) (length(behv_data.(k)) > ntrials-10 &&...
    length(behv_data.(k)) < ntrials+10), fieldnames));
ntrlslog = numel(behv_data.(fieldnames_discrete{1}));
% log file has target status of the next trial, not current
behv_data.firefly_on = circshift(behv_data.firefly_on,1); behv_data.firefly_on(1) = 0;

%% starting position
startpos = [stimulusprs.x0 stimulusprs.y0 stimulusprs.phi0];

%% extract trials
t = behv_data.behv_time;                                % timepoints
dt = round(median(diff(behv_data.behv_time))*1e4)*1e-4; % timesteps
for j=1:ntrials
    %% save discrete variables
    for i=1:length(fieldnames_discrete)
        trials(j).(fieldnames_discrete{i}) = behv_data.(fieldnames_discrete{i})(min(j,ntrlslog));
    end
    
    %% save continuous variables
    % define pretrial and posttrial periods
    pretrial = max(tbeg(j) - tmove(j),0) + analysisprs.pretrial; % extract everything from "movement onset - pretrial" or "target onset - pretrial" - whichever is first
    posttrial = analysisprs.posttrial; % extract everything until "t_end + posttrial"
    for i=1:length(fieldnames_continuous)
        if ~strcmp(fieldnames_continuous{i},'behv_time')
            if ~strcmp(char(behv_data.(fieldnames_continuous{i})),'0')  % these channels were recorded
                trials(j).(fieldnames_continuous{i}) = ...
                    behv_data.(fieldnames_continuous{i})(t>tbeg(j)-pretrial & t<tend(j)+posttrial);
                % set position values prior to target onset to nan
                if any(strcmp(fieldnames_continuous{i},{'firefly_x','monkey_x','firefly_y','monkey_y'}))
                    trials(j).(fieldnames_continuous{i})(1:floor(pretrial/dt)) = nan;
                end
            else                                                        % these channels were NOT recorded
                trials(j).(fieldnames_continuous{i}) = behv_data.(fieldnames_continuous{i});
            end
        end
    end
        
    %% generate time indices
    trials(j).behv_time = (dt:dt:length(trials(j).(fieldnames_continuous{1}))*dt)' + ...
        ((tbeg(j)-pretrial)<0)*(-tbeg(j)) + ((tbeg(j)-pretrial)>0)*(-pretrial); % because not enough pretrial before 1st trial    
    
    %% reference trial events to target onset (tbeg)
    trials(j).behv_tbeg = tbeg(j) - tbeg(j);
    trials(j).behv_tmove = tmove(j) - tbeg(j);
    trials(j).behv_tstop = tstop(j) - tbeg(j);
    trials(j).behv_trew = trew(j) - tbeg(j);
    trials(j).behv_tend = tend(j) - tbeg(j);
    % perturbation onset time
    trials(j).behv_tptb = tptb(j) - tbeg(j);
    % saccade time
    trials(j).behv_tsac = tsac(tsac>(tbeg(j)-pretrial) & tsac<tend(j)) - tbeg(j);
    
    %% generate monkey trajectories by integrating velocity (redundant but smoother than raw)
    if isfield(trials(j),'joy_linvel') && isfield(trials(j),'joy_angvel')
        vt = trials(j).joy_linvel; wt = trials(j).joy_angvel; ts = trials(j).behv_time;
        if isnan(trials(j).stop2feedback_intv), trials(j).stop2feedback_intv = 0; end
        if isnan(trials(j).intertrial_intv), trials(j).intertrial_intv = 0; end
        if isnan(trials(j).firefly_on), trials(j).firefly_on = 0; end
        indx = ts>trials(j).behv_tbeg & ts<(trials(j).behv_tstop+trials(j).stop2feedback_intv);
        trials(j).monkey_xtraj = nan(1,numel(ts));
        trials(j).monkey_ytraj = nan(1,numel(ts));
        trials(j).monkey_phitraj = nan(1,numel(ts));
        [trials(j).monkey_xtraj(indx),trials(j).monkey_ytraj(indx),trials(j).monkey_phitraj(indx)] = ...
            gen_traj(wt(indx),vt(indx),ts(indx),startpos);
        
        trials(j).dist2firefly_x = trials(j).firefly_x - trials(j).monkey_xtraj;
        trials(j).dist2firefly_y = trials(j).firefly_y - trials(j).monkey_ytraj;
        XY = cell2mat(arrayfun(@(phi,x,y) RotMat(phi)*[x ; y], trials(j).monkey_phitraj,...
            trials(j).dist2firefly_x, trials(j).dist2firefly_y, 'UniformOutput', false));
        trials(j).dist2firefly_x = XY(1,:)'; trials(j).dist2firefly_y = XY(2,:)';
        trials(j).dist2firefly_r = sqrt(trials(j).dist2firefly_x.^2 + trials(j).dist2firefly_y.^2);
        trials(j).dist2firefly_th = atan2d(trials(j).dist2firefly_x,trials(j).dist2firefly_y);
    end
    
    %% detect attempted trials
    v_thresh = analysisprs.v_thresh; w_thresh = analysisprs.w_thresh; tmax = 4;
    yfinal = trials(j).monkey_ytraj(find(~isnan(trials(j).monkey_ytraj),1,'last'));
    vfinal = trials(j).joy_linvel(find(trials(j).behv_time > trials(j).behv_tend,1));
    wfinal = trials(j).joy_angvel(find(trials(j).behv_time > trials(j).behv_tend,1));
    if ~isempty(yfinal) && ~((yfinal<0) || (abs(vfinal)>v_thresh) || (abs(wfinal)>w_thresh) || (trials(j).behv_tstop>tmax))
        trials(j).attempted = 1;
    else, trials(j).attempted = 0;
    end
    
    %% detect rewarded trials
    if ~isnan(trials(j).behv_trew), trials(j).rewarded = 1; 
    else, trials(j).rewarded = 0; end
    
    %% detect perturbed trials
    if ~isnan(trials(j).behv_tptb), trials(j).perturbed = 1; 
    else, trials(j).perturbed = 0; end
end

%% detect trials where targets appeared again during trial (apparently during some U-probe recs in moog2, not sure)
% for j=1:ntrials
%     timeindx = trials(j).behv_time<trials(j).behv_tend;
%     dPf__dt = [0 sqrt(diff(trials(j).firefly_x(timeindx)).^2 + diff(trials(j).firefly_y(timeindx)).^2)];
%     if findpeaks(dPf__dt,dt*(1:length(dPf__dt)),'MinPeakHeight',analysisprs.minpeakprom_flypos)>0 % detect peaks
%         trials(j).spurioustarg = true;
%     else, trials(j).spurioustarg = false; 
%     end
% end

%% downsample continuous data
fieldnames = fields(trials);
fieldnames_continuous = fieldnames(cellfun(@(k) (length(trials(1).(k))==length(trials(1).behv_time)) ||...
    strcmp(char(trials(1).(k)),'0'), fieldnames));
factor_downsample = round(analysisprs.dt/dt);
for j=1:ntrials
    for i=1:length(fieldnames_continuous)
        trials(j).(fieldnames_continuous{i}) = ...
            downsample(trials(j).(fieldnames_continuous{i}),factor_downsample);
        trials(j).(fieldnames_continuous{i}) = trials(j).(fieldnames_continuous{i})(:);
    end
end