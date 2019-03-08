%{
-> firefly.Electrode 
-> firefly.NeuralRecSystem 
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
            cd(['C:\Users\ok24\Documents\Data\firefly-monkey\' mysession.folder '\neural data']);
             
            if (key.recsystem_name == 'Cereplex'), file_ns1=dir('*.ns1');
                NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV');
                
            elseif (key.recsystem_name == 'Plexon'),file_ead=dir('*_lfp.plx');
                [adfreq, n, ~, fn, ad] = plx_ad_v(file_lfp.name, j-1);
            end
        end
    end
end