%{
-> firefly.Electrode 
-> firefly.Neuralrecsystem 
channel_id               : int
---
# add additional attributes
lfp_amplitude             : longblob
lfp_time                  : longblob
lfp_filestart=0           : longblob
lfp_trialbeg=0            : longblob
lfp_trialend=0            : longblob
lfp_trialrew=0            : longblob
%}

classdef Lfp < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            sessionLookup; default_prs;
            session_ids = [sessionInfo.session_id];
            animal_names = {sessionInfo.animal_name};
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));
            cd(['C:\Users\ok24\Documents\Data\firefly-monkey\' mysession.folder '\neural data']);
            if strcmp(key.recsystem_name, 'Cereplex')
                file_ns1=dir('*.ns1');
                file_nev=dir('*.nev');
                NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV');
                events_nev = GetEvents_nev(file_nev.name,prs);
                events_nev = InsertNaN2rewardtimes(events_nev);
                [nchannels, nt] = size(NS1.Data);
                dt = 1/NS1.MetaTags.SamplingFreq;
                t = dt:dt:dt*nt;
                for i=1:nchannels
                    key.channel_id = i;
                    key.lfp_amplitude = NS1.Data(i,:);
                    key.lfp_time = t;
                    key.lfp_filestart = events_nev.t_start;
                    key.lfp_trialbeg = events_nev.t_beg;
                    key.lfp_trialend = events_nev.t_end;
                    key.lfp_trialrew = events_nev.t_rew;
                    self.insert(key);
                    fprintf('Populated LFP channel %d for experiment done on %s in animal %s \n',key.channel_id,key.session_date,key.animal_name);
                end
            elseif strcmp(key.recsystem_name, 'Plexon')
                file_ead=dir('*_lfp.plx');
                [adfreq, n, ~, fn, ad] = plx_ad_v(file_lfp.name, j-1);
            end
        end
    end
end