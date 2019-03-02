%{
-> firefly.Session 
---
# add additional attributes

%}

classdef Behaviour < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from
            % monkeyInfoFile.m
            
            % switch to that folder
            
            % start reading the log and SMR files
        end
    end
end