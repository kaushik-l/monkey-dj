%{
-> firefly.Electrode  
---
# add additional attributes
channel_id               : varchar(128)     
lfp_analytic             : longblob
%}

classdef Lfp < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            sessionLookup;
            session_ids = [sessionInfo.session_id]; animal_names = {sessionInfo.animal_name};            
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));
            cd(['C:\Users\jkl9\Documents\Data\firefly-monkey\' mysession.folder '\neural data']);
            file_ead=dir('*_lfp.plx'); file_ns1=dir('*.ns1');
            if ~isempty(file_ns1), NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV'); end
        end
    end
end