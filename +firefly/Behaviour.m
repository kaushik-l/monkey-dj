%{
# Behavioural data (continuous channels and event markers)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
---
# add additional attributes
leye_horpos=0               : longblob     # data as array
leye_verpos=0               : longblob     # data as array
leye_torpos=0               : longblob     # data as array
reye_horpos=0               : longblob     # data as array
reye_verpos=0               : longblob     # data as array
reye_torpos=0               : longblob     # data as array
pupildia=0                  : longblob     # data as array
head_horpos=0               : longblob     # data as array
head_verpos=0               : longblob     # data as array
head_torpos=0               : longblob     # data as array
joy_linvel=0                : longblob     # data as array
joy_angvel=0                : longblob     # data as array
hand_x=0                    : longblob     # data as array
hand_y=0                    : longblob     # data as array
behv_time=0                 : longblob
behv_filestart=0            : longblob
behv_trialbeg=0             : longblob
behv_trialend=0             : longblob
behv_trialrew=0             : longblob
%}

classdef Behaviour < dj.Imported
    
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from SessionLog Table
            folder = fetch1(firefly.SessionList & ... % from table
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],... % restrict
                'folder'); % return attribute
            
            % create file path
            filepath = [folder '\behavioural data'];
            
            % prepare SMR data
            prs = fetch(firefly.DataAcquisitionParam,'*');
            [chdata,chnames,eventdata,eventnames] = PrepareSMRData(filepath,prs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmp(chnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = chdata(strcmp(chnames,selfAttributes{i}),:); 
                elseif any(strcmp(eventnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = eventdata{strcmp(eventnames,selfAttributes{i})}; 
                end
            end
            self.insert(key);
            fprintf('Populated Behaviour channels for experiment done on %s with monkey %s \n',key.session_date,key.monk_name);
        end
    end
end