function [eventdata_out,eventnames_out] = PrepareEventData(filepath,prs,analysisprs)

cd(filepath);

%% list all files to read
flist_log=dir('*.log'); 
for i=1:length(flist_log), fnum_log(i) = str2num(flist_log(i).name(end-6:end-4)); end
flist_smr=dir('*.smr');
for i=1:length(flist_smr), fnum_smr(i) = str2num(flist_smr(i).name(end-6:end-4)); end
nblocks = length(flist_log);
nsmrfiles = length(flist_smr);

for block = 1:nblocks
    if block<nblocks, indx_smr = find(fnum_smr >= fnum_log(block) & fnum_smr < fnum_log(block+1));
    else indx_smr = find(fnum_smr >= fnum_log(block)); end
    
    chdata = cell(1,numel(indx_smr));
    trialeventdata = cell(1,sum(indx_smr));
    t_filestart = 0;
    for j=indx_smr
        data=ImportSMR(flist_smr(j).name);
        %% check channel headers
        nch = length(data);
        ch_title = cell(1,nch);
        hdr = {data.hdr};
        for i=1:nch
            if ~isempty(hdr{i})
                ch_title{i} = hdr{i}.title;
            else
                ch_title{i} = 'nan';
            end
        end
        
        %% channel titles
        chno.yle = find(strcmp(ch_title,'LDy')); chno.zle = find(strcmp(ch_title,'LDz'));
        chno.yre = find(strcmp(ch_title,'RDy')); chno.zre = find(strcmp(ch_title,'RDz'));
        chno.xfp = find(strcmp(ch_title,'FireflyX')); chno.yfp = find(strcmp(ch_title,'FireflyY'));
        chno.xmp = find(strcmp(ch_title,'MonkeyX')); chno.ymp = find(strcmp(ch_title,'MonkeyY'));
        chno.v = find(strcmp(ch_title,'ForwardV')); chno.w = find(strcmp(ch_title,'AngularV'));
        chno.mrk = find(strcmp(ch_title,'marker'));
        if ~isempty(find(strcmp(ch_title,'Pulse'), 1)), chno.microstim = find(strcmp(ch_title,'Pulse')); end
        
        %% scale
        scaling.yle = data(chno.yle).hdr.adc.Scale; offset.yle = data(chno.yle).hdr.adc.DC;
        scaling.yre = data(chno.yre).hdr.adc.Scale; offset.yre = data(chno.yre).hdr.adc.DC;
        scaling.zle = data(chno.zle).hdr.adc.Scale; offset.zle = data(chno.zle).hdr.adc.DC;
        scaling.zre = data(chno.zre).hdr.adc.Scale; offset.zre = data(chno.zre).hdr.adc.DC;
        scaling.xfp = data(chno.xfp).hdr.adc.Scale; offset.xfp = data(chno.xfp).hdr.adc.DC;
        scaling.yfp = -data(chno.yfp).hdr.adc.Scale; offset.yfp = -data(chno.yfp).hdr.adc.DC;
        scaling.xmp = data(chno.xmp).hdr.adc.Scale; offset.xmp = data(chno.xmp).hdr.adc.DC;
        scaling.ymp = -data(chno.ymp).hdr.adc.Scale; offset.ymp = -data(chno.ymp).hdr.adc.DC;
        scaling.v = data(chno.v).hdr.adc.Scale; offset.v = data(chno.v).hdr.adc.DC;
        scaling.w = data(chno.w).hdr.adc.Scale; offset.w = data(chno.w).hdr.adc.DC;
        scaling.t = data(chno.mrk).hdr.tim.Scale*data(chno.mrk).hdr.tim.Units;
        
        %% define filter
        sig = prs.filtwidth; %filter width
        sz = prs.filtsize; %filter size
        t2 = linspace(-sz/2, sz/2, sz);
        h = exp(-t2.^2/(2*sig^2));
        h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered
        
        %% load relevant channels
        chnames = fieldnames(chno); MAX_LENGTH = inf; dt = [];
        for i=1:length(chnames)
            if ~any(strcmp(chnames{i},'mrk'))
                ch.(chnames{i}) = double(data(chno.(chnames{i})).imp.adc)*scaling.(chnames{i}) + offset.(chnames{i});
                dt = [dt prod(data(chno.(chnames{i})).hdr.adc.SampleInterval)];
                MAX_LENGTH = min(length(ch.(chnames{i})),MAX_LENGTH);
            end
        end
        if length(unique(dt))==1
            dt = dt(1);
        else
            error('channels must all have identical sampling rates');
        end
        
        %% filter position and velocity channels
        for i=1:length(chnames)
            if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre'}))
                ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
            end
        end
        ch.yle = ch.yle(1:MAX_LENGTH);
        ch.yre = ch.yre(1:MAX_LENGTH);
        ch.zle = ch.zle(1:MAX_LENGTH);
        ch.zre = ch.zre(1:MAX_LENGTH);
        ch.v = ch.v(1:MAX_LENGTH);
        ch.w = ch.w(1:MAX_LENGTH);
        ch.t = t_filestart(end) + (dt:dt:dt*MAX_LENGTH)'; % create t using dt and nt ****************                   
        
        %% load relevant events
        markers = data(chno.mrk).imp.mrk(:,1);
        t_events = double(data(chno.mrk).imp.tim)*scaling.t;
        t_startoffset = t_events(markers == 1);
        events_smr.t_beg = t_events(markers ==2) - t_startoffset + t_filestart(end);
        events_smr.t_end = t_events(markers ==3) - t_startoffset + t_filestart(end);
        events_smr.t_rew = t_events(markers ==4) - t_startoffset + t_filestart(end);
        events_smr.t_beg = events_smr.t_beg(1:length(events_smr.t_end));

        events_smr.t_ptb = t_events(markers==5 | markers==8) + t_filestart(end) + t_startoffset;
        if isempty(events_smr.t_ptb), events_smr.t_ptb = nan(size(events_smr.t_end)); end
        
        events_smr = InsertNaN2rewardtimes(events_smr);
        t_filestart(end+1) = t_filestart(end) + dt*MAX_LENGTH;
        
        %% refine t_beg to ensure it corresponds to target onset
        jitter = prs.jitter_marker;
        dPm__dt = [0 ; sqrt(diff(ch.ymp).^2 + diff(ch.xmp).^2)]; % derivative of monkey position
        [~,t_teleport] = findpeaks(dPm__dt,dt*(1:length(dPm__dt)),'MinPeakHeight', analysisprs.minpeakprom_monkpos); % detect peaks
        dPf__dt = [0 ; sqrt(diff(ch.yfp).^2 + diff(ch.xfp).^2)]; % derivative of firefly position
        [~,t_flyON] = findpeaks(dPf__dt,dt*(1:length(dPf__dt)),'MinPeakHeight',analysisprs.minpeakprom_flypos); % detect peaks
        t_teleport_trl = nan(length(events_smr.t_beg),1); t_flyON_trl = nan(length(events_smr.t_beg),1);
        for i=1:length(events_smr.t_beg)
            t_teleport_temp = t_teleport(t_teleport > (events_smr.t_beg(i) - jitter) &  t_teleport < (events_smr.t_beg(i) + jitter));
            if ~isempty(t_teleport_temp), t_teleport_trl(i) = t_teleport_temp(end); end
            t_flyON_temp = t_flyON(t_flyON > (events_smr.t_beg(i) - jitter) &  (t_flyON < events_smr.t_beg(i) + jitter));
            if ~isempty(t_flyON_temp), t_flyON_trl(i) = t_flyON_temp(end); end
        end
        tflyON_minus_teleport = nanmedian(t_flyON_trl - t_teleport_trl);
        % set trial begin time equal to target onset
        for i=1:length(events_smr.t_beg)
            if ~isnan(t_flyON_trl(i)), events_smr.t_beg(i) = t_flyON_trl(i);
            elseif ~isnan(t_teleport_trl(i)), events_smr.t_beg(i) = t_teleport_trl(i) + tflyON_minus_teleport;
            end
        end
        
        %% detect start-of-movement and end-of-movement times for each trial
        v_thresh = analysisprs.v_thresh; w_thresh = analysisprs.w_thresh;
        v_time2thresh = analysisprs.v_time2thresh;
        v = ch.v; w = ch.w;
        events_smr.t_move = []; events_smr.t_stop = [];
        for i=1:length(events_smr.t_end)
            % start-of-movement
            if i==1, events_smr.t_move(i) = events_smr.t_beg(i); % first trial is special because there is no pre-trial period
            else
                indx = find(v(ch.t>events_smr.t_end(i-1) & ch.t<events_smr.t_end(i)) > v_thresh,1); % first upward threshold-crossing
                if ~isempty(indx), events_smr.t_move(i) = events_smr.t_end(i-1) + indx*dt;
                else, events_smr.t_move(i) = events_smr.t_beg(i); end % if monkey never moved, set movement onset = target onset
            end
            % end-of-movement
            indx = find(abs(v(ch.t>events_smr.t_move(i) & ch.t<events_smr.t_end(i))) < v_thresh &...
                abs(w(ch.t>events_smr.t_move(i) & ch.t<events_smr.t_end(i))) < w_thresh,1); % first downward threshold-crossing
            if ~isempty(indx), events_smr.t_stop(i) = events_smr.t_move(i) + indx*dt;
            else, events_smr.t_stop(i) = events_smr.t_end(i); end % if monkey never stopped, set movement end = trial end
            % if monkey stopped prematurely, set movement end = trial end
            if (events_smr.t_stop(i)<events_smr.t_beg(i) || (events_smr.t_stop(i)-events_smr.t_move(i))<prs.mintrialduration)
                % second attempt to locate t_stop (added 12-04-2019)
                indx = find(abs(v(ch.t>events_smr.t_beg(i) & ch.t<events_smr.t_end(i))) > v_thresh |...
                    abs(w(ch.t>events_smr.t_beg(i) & ch.t<events_smr.t_end(i))) > w_thresh,1,'last');
                if ~isempty(indx), events_smr.t_stop(i) = events_smr.t_beg(i) + indx*dt;
                else, events_smr.t_stop(i) = events_smr.t_end(i); end
            end
        end

        %% store event data
        trialeventdata{j} = {events_smr.t_beg(:),events_smr.t_rew(:),events_smr.t_end(:),events_smr.t_ptb(:),...
            events_smr.t_move(:),events_smr.t_stop(:)};
        
    end
    t_filestart(end) = [];
    trialeventdata = cell2mat(vertcat(trialeventdata{:})); % concatenate trial events
    eventdata_out{block} = mat2cell(trialeventdata,size(trialeventdata,1),ones(1,size(trialeventdata,2))); % add filestart to trialevents
    eventnames_out{block} = {'behv_tbeg' 'behv_trew' 'behv_tend' 'behv_tptb' 'behv_tmove' 'behv_tstop'};    
end