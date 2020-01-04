%{
# Stimulus data (discrete variables)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
block_number=1              : int          # experimental block
---
# add additional attributes

%}

classdef Stimulus < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from SessionLog Table
            folder = fetch1(firefly.SessionList & ... % from table
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],... % restrict
                'folder'); % return attribute
            
            % create file path
            filepath = [folder '\behavioural data'];
            
            % read log file
            [paramnames,paramvals] = PrepareLogData(filepath);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            nblocks = numel(paramnames);
            for j=1:nblocks
                key.block_number = j;
                for i=1:length(selfAttributes)
                    if any(strcmp(paramnames{j},selfAttributes{i}))
                        key.(selfAttributes{i}) = paramvals{j}(strcmp(paramnames{j},selfAttributes{i}),:);
                    end
                end
                self.insert(key);
            end
            fprintf('Populated %d block(s) of stimulus data for experiment done on %s with monkey %s \n',nblocks,key.session_date,key.monk_name);
        end
    end
end