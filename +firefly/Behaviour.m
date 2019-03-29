%{
-> firefly.Session
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
            % use primary keys of session to lookup folder name from sessionLookup.m
            sessionLookup;
            session_ids = [sessionInfo.session_id];
            animal_names = {sessionInfo.animal_name};
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));            
            
            % create file path
            filepath = ['C:\Users\ok24\Documents\Data\firefly-monkey\' mysession.folder '\behavioural data'];            
            
            % prepare SMR data
            default_prs;
            [chdata,chnames,key.behv_filestart] = PrepareSMRData(filepath,prs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmp(chnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = chdata(strcmp(chnames,selfAttributes{i}),:); 
                end
            end
            self.insert(key);
            fprintf('Populated Behaviour channels for experiment done on %s in animal %s \n',key.session_date,key.animal_name);
        end
    end
end