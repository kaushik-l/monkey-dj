%{
-> firefly.Session 
---
# add additional attributes
eye_horpos              : longblob     # data as array
eye_verpos              : longblob     # data as array
eye_torpos              : longblob     # data as array
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
            key;
            % use primary keys of session to lookup folder name from monkeyInfoFile.m
            % switch to that folder            
            % start reading the log and SMR files
        end
    end
end