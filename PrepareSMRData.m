function [chdata,chnames,eventdata,eventnames] = PrepareSMRData(filepath,prs)

cd(filepath);

file_smr=dir('*.smr');
nsmrfiles = length(file_smr);
chdata = cell(1,nsmrfiles);
t_filestart = 0;
for j=1:nsmrfiles
    data=ImportSMR(file_smr(j).name);
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
    
    %% store continuous channel data
    chdata{j} = struct2array(ch)';
    
    %% load relevant events
    markers = data(chno.mrk).imp.mrk(:,1);
    t_events = double(data(chno.mrk).imp.tim)*scaling.t;
    t_startoffset = t_events(markers == 1);
    events_smr.t_beg = t_events(markers ==2) + t_filestart(end) + t_startoffset;
    events_smr.t_end = t_events(markers ==3) + t_filestart(end) + t_startoffset;
    events_smr.t_rew = t_events(markers ==4) + t_filestart(end) + t_startoffset;
    events_smr.t_beg = events_smr.t_beg(1:length(events_smr.t_end));
    events_smr = InsertNaN2rewardtimes(events_smr);
    t_filestart(end+1) = t_filestart(end) + dt*MAX_LENGTH;
    
    %% store event data
    eventdata{j} = {events_smr.t_beg,events_smr.t_rew,events_smr.t_end};
    
end
t_filestart(end) = [];
eventdata = cell2mat(vertcat(eventdata{:})); % concatenate trialevents
eventdata = [mat2cell(eventdata,size(eventdata,1),ones(1,size(eventdata,2)))  {t_filestart(:)}]; % add filestart to trialevents
eventnames = {'behv_trialbeg';'behv_trialend';'behv_trialrew';'behv_filestart'};

%% concatenate data matrices from different smr files
chdata = cell2mat(chdata);

%% rename the channels so chnames contains {'lefteye_horpos','lefteye_verpos',...}
chnames{strcmp(chnames,'yle')} = 'leye_horpos';
chnames{strcmp(chnames,'yre')} = 'reye_horpos';
chnames{strcmp(chnames,'zle')} = 'leye_verpos';
chnames{strcmp(chnames,'zre')} = 'reye_verpos';
chnames{strcmp(chnames,'v')} = 'joy_linvel';
chnames{strcmp(chnames,'w')} = 'joy_angvel';
chnames{end} = 'behv_time';