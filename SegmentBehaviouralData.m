function trials = SegmentBehaviouralData(behv_data,event_data,prs,analysisprs)

%% gather events
tbeg = event_data.tbeg + behv_data.behv_tstart(1);
trew = event_data.trew + behv_data.behv_tstart(1);
tend = event_data.tend + behv_data.behv_tstart(1);
tptb = event_data.tptb + behv_data.behv_tstart(1);
tmove = event_data.tmove + behv_data.behv_tstart(1);
tstop = event_data.tstop + behv_data.behv_tstart(1);
tsac = behv_data.behv_tsac + behv_data.behv_tstart(1);
ntrials = numel(event_data.tend);

%% gather fieldnames
fieldnames = fields(behv_data);
fieldnames_continuous = fieldnames(cellfun(@(k) (length(behv_data.(k))==length(behv_data.behv_time)) ||...
    strcmp(char(behv_data.(k)),'0'), fieldnames));
fieldnames_discrete = fieldnames(cellfun(@(k) (length(behv_data.(k)) > ntrials-10 &&...
    length(behv_data.(k)) < ntrials+10), fieldnames));
ntrlslog = numel(behv_data.(fieldnames_discrete{1}));
% log file has target status of the next trial, not current
behv_data.firefly_on = circshift(behv_data.firefly_on,1); behv_data.firefly_on(1) = 0;

%% extract trials and downsample for storage
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
for j=1:ntrials
    for i=1:length(fieldnames_continuous)
        trials(j).(fieldnames_continuous{i}) = ...
            downsample(trials(j).(fieldnames_continuous{i}),prs.factor_downsample);
        trials(j).(fieldnames_continuous{i}) = trials(j).(fieldnames_continuous{i})(:);
    end
end