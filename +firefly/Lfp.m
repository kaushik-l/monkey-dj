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
            sessionInfo = sessionLookup;
            session_ids = [sessionInfo.session_id]; animal_names = [sessionInfo.animal_name];            
            mysession = sessionInfo((session_ids == key.session_id) & (animal_names == key.animal_name));
            cd(mysession.folder);
        end
    end
end