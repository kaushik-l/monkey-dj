%{
-> firefly.Session
---
# add additional attributes
floor_den         : longblob     # data as array
joy_gain=0          : longblob     # data as array
ptb_linvel        : longblob     # data as array
ptb_angvel        : longblob     # data as array
landmark_lin=0      : longblob     # data as array
landmark_ang=0      : longblob     # data as array
floor_static=0      : longblob     # data as array
trial_period=0      : longblob     # data as array
reward_period=0     : longblob     # data as array
%}

classdef Stimulus < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from sessionLookup.m
            sessionLookup;
            session_ids = [sessionInfo.session_id];
            animal_names = {sessionInfo.animal_name};
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));
            
            % create file path
            filepath = ['C:\Users\jkl9\Documents\Data\firefly-monkey\' mysession.folder '\behavioural data'];
            
            % read log file
            [values,features] = PrepareLogData(filepath);
            key.floor_den = values(strcmp(features,'floor_den'),:);
            key.ptb_linvel = values(strcmp(features,'ptb_linvel'),:);
            key.ptb_angvel = values(strcmp(features,'ptb_angvel'),:);
            self.insert(key);
        end
    end
end