function ntrialevents = CountSMREvents(filepath)

cd(filepath);

%% list all files to read
flist_log=dir('*.log');
for i=1:length(flist_log)
    if any(strfind(flist_log(i).name,'_'))
        nameparts = split(flist_log(i).name,'_');
        fnum_log(i) = datenum((cellfun(@(x) str2num(x),...
            [split(nameparts{2},'-') ; split(nameparts{3}(1:end-4),'-')]))');
    else
        fnum_log(i) = str2num(flist_log(i).name(end-6:end-4));
    end
end
flist_smr=dir('*.smr');
for i=1:length(flist_smr)
    if any(strfind(flist_smr(i).name,'_'))
        nameparts = split(flist_smr(i).name,'_');
        fnum_smr(i) = datenum((cellfun(@(x) str2num(x),...
            [split(nameparts{2},'-') ; split(nameparts{3}(1:end-4),'-')]))');
    else
        fnum_smr(i) = str2num(flist_smr(i).name(end-6:end-4));
    end
end
nblocks = length(flist_log);
nsmrfiles = length(flist_smr);

for block = 1:nblocks
    if block<nblocks, indx_smr = find(fnum_smr >= (fnum_log(block)-eps) & fnum_smr < (fnum_log(block+1)+eps));
    else indx_smr = find(fnum_smr >= fnum_log(block)); end
    
    trialeventdata = cell(1,sum(indx_smr));
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
        chno.mrk = find(strcmp(ch_title,'marker'));
        scaling.t = data(chno.mrk).hdr.tim.Scale*data(chno.mrk).hdr.tim.Units;                
        
        %% load relevant events
        markers = data(chno.mrk).imp.mrk(:,1);
        t_events = double(data(chno.mrk).imp.tim)*scaling.t;
        events_smr.t_beg = t_events(markers ==2);
        events_smr.t_end = t_events(markers ==3);
        events_smr.t_rew = t_events(markers ==4);
        events_smr.t_beg = events_smr.t_beg(1:length(events_smr.t_end));

        events_smr.t_ptb = t_events(markers==5 | markers==8);
        if isempty(events_smr.t_ptb), events_smr.t_ptb = nan(size(events_smr.t_end)); end
        
        events_smr = InsertNaN2eventtimes(events_smr);   
        
        %% store event data
        trialeventdata{j} = {events_smr.t_beg(:),events_smr.t_rew(:),events_smr.t_end(:),events_smr.t_ptb(:)};
        
    end
    trialeventdata = cell2mat(vertcat(trialeventdata{:})); % concatenate trial events
    ntrialevents(block) = size(trialeventdata,1);
   
end