%{
-> firefly.Session
---
# add additional attributes
lefteye_horpos              : longblob     # data as array
lefteye_verpos              : longblob     # data as array
lefteye_torpos              : longblob     # data as array
righteye_horpos              : longblob     # data as array
righteye_verpos              : longblob     # data as array
righteye_torpos              : longblob     # data as array
eye_pupdia              : longblob     # data as array
head_horpos             : longblob     # data as array
head_verpos             : longblob     # data as array
head_torpos             : longblob     # data as array
joy_linvel              : longblob     # data as array
joy_angvel              : longblob     # data as array
hand_x                  : longblob     # data as array
hand_y                  : longblob     # data as array
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
            [chdata,chnames] = PrepareSMRData(filepath,prs);
            chdata = chdata{1};
            key.lefteye_horpos = chdata((find(strcmp(chnames,'lefteye_horpos'))),:);
            key.lefteye_verpos = chdata((find(strcmp(chnames,'lefteye_verpos'))),:);
            key.righteye_horpos = chdata((find(strcmp(chnames,'righteye_horpos'))),:);
            key.righteye_verpos = chdata((find(strcmp(chnames,'righteye_verpos'))),:);
            key.joy_linvel = chdata((find(strcmp(chnames,'joy_linvel'))),:);
            key.joy_angvel = chdata((find(strcmp(chnames,'joy_angvel'))),:);
            self.insert(key);
        end
    end
end