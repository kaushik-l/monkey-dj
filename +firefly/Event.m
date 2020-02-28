%{
# Event data (trial event markers)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
---
# add additional attributes
tblockstart=0               : longblob     # time when experimental block started
tbeg=0                      : longblob     # time when target appeared
tend=0                      : longblob     # time when trial ended
trew=0                      : longblob     # time when reward delivered
tptb=0                      : longblob     # time when perturbation started
tmove=0                     : longblob     # time when movement started
tstop=0                     : longblob     # time when movement ended
%}

classdef Event < dj.Imported    
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from SessionLog Table
            [folder,eyechannels] = fetchn(firefly.SessionList & ... % from table
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],... % restrict
                'folder','eyechannels'); % return attribute
            folder = folder{:}; eyechannels = eyechannels{:}; % unpack cell
            
            % create file path
            filepath = [folder '\behavioural data'];
            
            prs = fetch(firefly.DataAcquisitionParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*'); analysisprs.eyechannels = eyechannels;
            ntrialevents = CountSMREvents(filepath);
            % prepare log data 
            [paramnames,paramvals] = PrepareLogData(filepath,ntrialevents);
            % prepare SMR data 
            [~,~,eventdata,eventnames] = PrepareSMRData(filepath,prs,analysisprs,paramnames,paramvals);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmp(eventnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = eventdata{strcmp(eventnames,selfAttributes{i})};
                end
            end
            key.tblockstart = eventdata{strcmp(eventnames,'behv_tblockstart')};
            self.insert(key);
            fprintf('Populated event markers for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end