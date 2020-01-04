%{
# Event data (trial event markers)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
block_number=1              : int          # experimental block
---
# add additional attributes
tbeg=0                      : longblob     # data as array
tend=0                      : longblob     # data as array
trew=0                      : longblob     # data as array
tptb=0                      : longblob     # data as array
tmove=0                     : longblob     # data as array
tstop=0                     : longblob     # data as array
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
            [~,~,eventdata,eventnames] = PrepareSMRData(filepath,prs,analysisprs);       % prepare SMR data
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            nblocks = numel(eventdata);
            for j=1:nblocks
                key.block_number = j;
                for i=1:length(selfAttributes)
                    if any(strcmp(eventnames{j},selfAttributes{i}))
                        key.(selfAttributes{i}) = eventdata{j}{strcmp(eventnames{j},selfAttributes{i})};
                    end
                end
                self.insert(key);
            end            
            fprintf('Populated %d block(s) of behavioural data for experiment done on %s with monkey %s \n',...
                nblocks,key.session_date,key.monk_name);
        end
    end
end