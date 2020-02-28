function [chdata_out,chnames_out,eventdata_out,eventnames_out,ntrialevents] = ...
    PrepareSMRData(filepath,prs,analysisprs,paramnames,paramvals)

cd(filepath);

%% firefly position from log file (if available)
xfp = paramvals(strcmp(paramnames,'xfp'),:);
yfp = paramvals(strcmp(paramnames,'yfp'),:);

%% list all files to read
flist_log=dir('*.log'); 
for i=1:length(flist_log), fnum_log(i) = str2num(flist_log(i).name(end-6:end-4)); end
flist_smr=dir('*.smr');
for i=1:length(flist_smr), fnum_smr(i) = str2num(flist_smr(i).name(end-6:end-4)); end
nblocks = length(flist_log);
nsmrfiles = length(flist_smr);

t_blockstart = 0;
for block = 1:nblocks
    if block<nblocks, indx_smr = find(fnum_smr >= fnum_log(block) & fnum_smr < fnum_log(block+1));
    else indx_smr = find(fnum_smr >= fnum_log(block)); end
    
    chdata = cell(1,numel(indx_smr));
    trialeventdata = cell(1,sum(indx_smr));
    othereventdata = cell(1,sum(indx_smr));
    t_startoffset = []; t_filestart = 0;
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
        chno.FFDraw = find(strcmp(ch_title,'FFDraw'));
        chno.xmp = find(strcmp(ch_title,'MonkeyX')); chno.ymp = find(strcmp(ch_title,'MonkeyY'));
        chno.v = find(strcmp(ch_title,'ForwardV')); chno.w = find(strcmp(ch_title,'AngularV'));
        chno.mrk = find(strcmp(ch_title,'marker'));
        if ~isempty(find(strcmp(ch_title,'Pulse'), 1)), chno.microstim = find(strcmp(ch_title,'Pulse')); end
        if isempty(chno.xfp), isavailable_flypos = false;
        else, isavailable_flypos = true; end
        
        %% scale
        scaling.yle = data(chno.yle).hdr.adc.Scale; offset.yle = data(chno.yle).hdr.adc.DC;
        scaling.yre = data(chno.yre).hdr.adc.Scale; offset.yre = data(chno.yre).hdr.adc.DC;
        scaling.zle = data(chno.zle).hdr.adc.Scale; offset.zle = data(chno.zle).hdr.adc.DC;
        scaling.zre = data(chno.zre).hdr.adc.Scale; offset.zre = data(chno.zre).hdr.adc.DC;
        if isavailable_flypos
            scaling.xfp = data(chno.xfp).hdr.adc.Scale; offset.xfp = data(chno.xfp).hdr.adc.DC;
            scaling.yfp = -data(chno.yfp).hdr.adc.Scale; offset.yfp = -data(chno.yfp).hdr.adc.DC;
        elseif ~isempty(chno.FFDraw)
            scaling.FFDraw = data(chno.FFDraw).hdr.adc.Scale; offset.FFDraw = data(chno.FFDraw).hdr.adc.DC;
        else
            fprintf('firefly position and/or firefly status channels missing \n');
            return;
        end
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
            if isavailable_flypos
                if ~any(strcmp(chnames{i},'mrk'))
                    ch.(chnames{i}) = double(data(chno.(chnames{i})).imp.adc)*scaling.(chnames{i}) + offset.(chnames{i});
                    dt = [dt prod(data(chno.(chnames{i})).hdr.adc.SampleInterval)];
                    MAX_LENGTH = min(length(ch.(chnames{i})),MAX_LENGTH);
                end
            else
                if ~any(strcmp(chnames{i},{'mrk','xfp','yfp'}))
                    ch.(chnames{i}) = double(data(chno.(chnames{i})).imp.adc)*scaling.(chnames{i}) + offset.(chnames{i});
                    dt = [dt prod(data(chno.(chnames{i})).hdr.adc.SampleInterval)];
                    MAX_LENGTH = min(length(ch.(chnames{i})),MAX_LENGTH);
                end
            end
        end
        if length(unique(dt))==1
            dt = dt(1);
        else
            error('channels must all have identical sampling rates');
        end     
        
        %% filter position and velocity channels
        for i=1:length(chnames)
            if isavailable_flypos
                if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre'}))
                    ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
                end
            else
                if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre','xfp','yfp'}))
                    ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
                end
            end
        end
        ch.yle = ch.yle(1:MAX_LENGTH);
        ch.yre = ch.yre(1:MAX_LENGTH);
        ch.zle = ch.zle(1:MAX_LENGTH);
        ch.zre = ch.zre(1:MAX_LENGTH);
        ch.v = ch.v(1:MAX_LENGTH);
        ch.w = ch.w(1:MAX_LENGTH);
        ch.t = (dt:dt:dt*MAX_LENGTH)'; % create t using dt and nt ****************
        
        %% replace the signal from the untracked eye (if any) with NaNs
        if analysisprs.eyechannels(1) == 0
            ch.zle(:) = nan;
            ch.yle(:) = nan;
        end
        if analysisprs.eyechannels(2) == 0
            ch.zre(:) = nan;
            ch.yre(:) = nan;
        end
        if all(analysisprs.eyechannels == 0), warning('No eye signal for this dataset'); end
        
        %% if using eye tracker, remove eye blinks and smooth
        if any(analysisprs.eyechannels == 2)
            X = [ch.zle ch.zre ch.yle ch.yre];
            X = ReplaceWithNans(X, analysisprs.blink_thresh, analysisprs.nanpadding);
            ch.zle = X(:,1); ch.zre = X(:,2); ch.yle = X(:,3); ch.yre = X(:,4);
            sig = 10*prs.filtwidth; %filter width
            sz = 10*prs.filtsize; %filter size
            t2 = linspace(-sz/2, sz/2, sz);
            h = exp(-t2.^2/(2*sig^2));
            h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered
            ch.zle = conv(ch.zle,h,'same'); ch.zre = conv(ch.zre,h,'same');
            ch.yle = conv(ch.yle,h,'same'); ch.yre = conv(ch.yre,h,'same');
        end
        
        %% detect saccade times
        % take derivative of eye position = eye velocity
        if all(analysisprs.eyechannels ~= 0)
            dze = diff(0.5*(ch.zle + ch.zre));
            dye = diff(0.5*(ch.yle + ch.yre));
        elseif analysisprs.eyechannels(1) ~= 0
            dze = diff(ch.zle);
            dye = diff(ch.yle);
        else
            dze = diff(ch.zre);
            dye = diff(ch.yre);
        end
        
        % estimate eye speed
        de = sqrt(dze.^2 + dye.^2); % speed of eye movement
        de_smooth = conv(de,h,'same')/dt;
        
        % apply threshold on eye speed
        indx_thresh = de_smooth>analysisprs.saccade_thresh;
        dindx_thresh = diff(indx_thresh);
        t_saccade = find(dindx_thresh>0)*dt;
        
        % remove duplicates by applying a saccade refractory period
        t_saccade(diff(t_saccade)<analysisprs.min_intersaccade) = [];
        
        %% interpolate nans
        if any(analysisprs.eyechannels == 2) % conditional statement not necessary perhaps
            nanx = isnan(ch.zle); t1 = 1:numel(ch.zle); ch.zle(nanx) = interp1(t1(~nanx), ch.zle(~nanx), t1(nanx), 'pchip');
            nanx = isnan(ch.zre); t1 = 1:numel(ch.zle); ch.zre(nanx) = interp1(t1(~nanx), ch.zre(~nanx), t1(nanx), 'pchip');
            nanx = isnan(ch.yle); t1 = 1:numel(ch.yle); ch.yle(nanx) = interp1(t1(~nanx), ch.yle(~nanx), t1(nanx), 'pchip');
            nanx = isnan(ch.yre); t1 = 1:numel(ch.yre); ch.yre(nanx) = interp1(t1(~nanx), ch.yre(~nanx), t1(nanx), 'pchip');
        end        
        
        %% load relevant events
        markers = data(chno.mrk).imp.mrk(:,1);
        t_events = double(data(chno.mrk).imp.tim)*scaling.t;
        t_startoffset = [t_startoffset t_events(markers == 1)];
        events_smr.t_beg = t_events(markers ==2);
        events_smr.t_end = t_events(markers ==3);
        events_smr.t_rew = t_events(markers ==4);
        events_smr.t_beg = events_smr.t_beg(1:length(events_smr.t_end));

        events_smr.t_ptb = t_events(markers==5 | markers==8);
        if isempty(events_smr.t_ptb), events_smr.t_ptb = nan(size(events_smr.t_end)); end
        
        events_smr = InsertNaN2eventtimes(events_smr);
        
        %% refine t_beg to ensure it corresponds to target onset
        if isavailable_flypos % use firefly channel to correct for jitter
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
            % set trial begin time equal to target onset except for first trial
            for i=2:length(events_smr.t_beg)
                if ~isnan(t_flyON_trl(i)), events_smr.t_beg(i) = t_flyON_trl(i);
                elseif ~isnan(t_teleport_trl(i)), events_smr.t_beg(i) = t_teleport_trl(i) + tflyON_minus_teleport;
                end
            end
        else % use FFDraw to correct for jitter
           jitter = prs.jitter_marker;
           dPf__dt = [0 ; diff(ch.FFDraw)]; % derivative of firefly ON/OFF status
           [~,t_flyON] = findpeaks(dPf__dt,dt*(1:length(dPf__dt)),'MinPeakHeight', analysisprs.minpeakprom_flypos); % detect peaks
           for i=1:length(events_smr.t_beg)
               t_flyON_temp = t_flyON(t_flyON > (events_smr.t_beg(i) - jitter) &  (t_flyON < events_smr.t_beg(i) + jitter));
               if ~isempty(t_flyON_temp), events_smr.t_beg(i) = t_flyON_temp(end); end
           end
           % create xfp and yfp channels from log file data
           ch.xfp = zeros(MAX_LENGTH,1); ch.yfp = zeros(MAX_LENGTH,1);
           for i=1:length(events_smr.t_beg)-1
               ch.xfp((ch.t >= events_smr.t_beg(i)) & (ch.t < events_smr.t_beg(i+1))) = -xfp(i); % data looks flipped
               ch.yfp((ch.t >= events_smr.t_beg(i)) & (ch.t < events_smr.t_beg(i+1))) = -yfp(i);
           end
           if length(events_smr.t_beg)>=2
               ch.xfp(ch.t >= events_smr.t_beg(i+1)) = -xfp(i+1);
               ch.yfp(ch.t >= events_smr.t_beg(i+1)) = -yfp(i+1);
           end
           % remove entries corresponding to this block
           xfp(1:length(events_smr.t_beg)) = [];
           yfp(1:length(events_smr.t_beg)) = [];
           ch = rmfield(ch,'FFDraw');
           chnames(strcmp(chnames,'FFDraw')) = [];
           chnames(strcmp(chnames,'xfp')) = [];
           chnames(strcmp(chnames,'yfp')) = [];
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
        
        %% re-reference timing to start offset marker for this block
        ch.t  = ch.t + t_blockstart(block) + t_filestart(end);                
        events_smr.t_beg = events_smr.t_beg + t_blockstart(block) + t_filestart(end);
        events_smr.t_rew = events_smr.t_rew + t_blockstart(block) + t_filestart(end);
        events_smr.t_end = events_smr.t_end + t_blockstart(block) + t_filestart(end);
        events_smr.t_ptb = events_smr.t_ptb + t_blockstart(block) + t_filestart(end);
        events_smr.t_move = events_smr.t_move + t_blockstart(block) + t_filestart(end);
        events_smr.t_stop = events_smr.t_stop + t_blockstart(block) + t_filestart(end);
        t_saccade = t_saccade + t_blockstart(block) + t_filestart(end);
        
        t_filestart(end+1) = t_filestart(end) + dt*MAX_LENGTH;
        
        %% store continuous channel data
        chdata{j} = struct2array(ch)';
        
        %% store event data
        trialeventdata{j} = {events_smr.t_beg(:),events_smr.t_rew(:),events_smr.t_end(:),events_smr.t_ptb(:),...
            events_smr.t_move(:),events_smr.t_stop(:)};
        othereventdata{j} = {t_saccade};
        
    end
    t_filestart(end) = [];
    t_blockstart(block+1) = ch.t(end); t_blockstart(block) =  t_blockstart(block) + t_startoffset(1);
    trialeventdata = cell2mat(vertcat(trialeventdata{:})); % concatenate trial events
    othereventdata = cell2mat(vertcat(othereventdata{:})); % concatenate other events
    eventdata_out{block} = [mat2cell(trialeventdata,size(trialeventdata,1),ones(1,size(trialeventdata,2)))...
        mat2cell(othereventdata,size(othereventdata,1),ones(1,size(othereventdata,2))) {t_blockstart(block)}]; % add filestart to trialevents
    ntrialevents(block) = size(trialeventdata,1);
    
    %% concatenate data matrices from different smr files
    chdata_out{block} = cell2mat(chdata);
   
end

chdata_out = cell2mat(chdata_out);
eventdata_out = vertcat(eventdata_out{:});
eventdata_out = arrayfun(@(i) cell2mat(eventdata_out(:,i)),1:size(eventdata_out,2),'UniformOutput',false);

%% name the channels/events so they contain attribute names of firefly.Event and firefly.Behaviour classes
chnames_out = chnames;
chnames_out{strcmp(chnames_out,'yle')} = 'leye_horpos';
chnames_out{strcmp(chnames_out,'yre')} = 'reye_horpos';
chnames_out{strcmp(chnames_out,'zle')} = 'leye_verpos';
chnames_out{strcmp(chnames_out,'zre')} = 'reye_verpos';
chnames_out{strcmp(chnames_out,'v')} = 'joy_linvel';
chnames_out{strcmp(chnames_out,'w')} = 'joy_angvel';
chnames_out{strcmp(chnames_out,'xmp')} = 'monkey_x';
chnames_out{strcmp(chnames_out,'ymp')} = 'monkey_y';
chnames_out{end} = 'behv_time';
if isavailable_flypos
    chnames_out{strcmp(chnames_out,'xfp')} = 'firefly_x';
    chnames_out{strcmp(chnames_out,'yfp')} = 'firefly_y';
else
    chnames_out{end+1} = 'firefly_x';
    chnames_out{end+1} = 'firefly_y';
end
eventnames_out = {'tbeg' ; 'trew' ; 'tend' ; 'tptb' ; 'tmove' ; 'tstop' ; 'behv_tsac' ; 'behv_tblockstart'};