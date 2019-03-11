%{
-> firefly.Electrode 
-> firefly.Neuralrecsystem 
channel_id               : int
---
# add additional attributes
lfp_analytic             : longblob
%}

classdef Lfp < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            sessionLookup;
            session_ids = [sessionInfo.session_id]; animal_names = {sessionInfo.animal_name};            
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));
            cd(['C:\Users\ok24\Documents\Data\firefly-monkey\' mysession.folder '\neural data']);             
            if strcmp(key.recsystem_name, 'Cereplex')
                file_ns1=dir('*.ns1');
%                 NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV');
                NS1.Data = rand(10,200);
                nchannels = size(NS1.Data,1);
                for i=1:nchannels
                    key.channel_id = i;
                    key.lfp_analytic = NS1.Data(i,:);
                    self.insert(key);
                    sprintf('Populated LFP channel %d for experiment done on %s in animal %s',key.channel_id,key.session_date,key.animal_name);
                end
            elseif strcmp(key.recsystem_name, 'Plexon')
                file_ead=dir('*_lfp.plx');
                [adfreq, n, ~, fn, ad] = plx_ad_v(file_lfp.name, j-1);
            end
        end
    end
end