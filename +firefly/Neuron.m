%{
-> firefly.Electrode
-> firefly.Neuralrecsystem 
cluster_id               : int  
---
# add additional attributes
channel_id               : int     
electrode_id             : int     
neuron_type              : varchar(128)  
spike_times              : longblob
spike_waveform           : blob
neuron_filestart=0       : longblob
neuron_trialbeg=0        : longblob
neuron_trialend=0        : longblob
neuron_trialrew=0        : longblob
%}

classdef Neuron < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            sessionLookup; default_prs;
            session_ids = [sessionInfo.session_id];
            animal_names = {sessionInfo.animal_name};
            mysession = sessionInfo((session_ids == key.session_id) & strcmp(animal_names, key.animal_name));
            cd(['C:\Users\ok24\Documents\Data\firefly-monkey\' mysession.folder '\neural data']);
            if strcmp(key.recsystem_name, 'Cereplex')
                file_nev=dir('*.nev');
                events_nev = GetEvents_nev(file_nev.name,prs);
                [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv','cluster_location.xls',key.electrode_type); % requires npy-matlab package: https://github.com/kwikteam/npy-matlab
                nsua = length(sua);
                units = [sua mua]; nunits = length(units); 
                for i=1:nunits
                    key.cluster_id = units(i).cluster_id;
                    key.channel_id = units(i).channel_id; %99
                    key.electrode_id = units(i).electrode_id; %99
                    if i<=nsua, key.neuron_type = 'singleunit'; else, key.neuron_type = 'multiunit'; end % singleunit for single neuron and multiunit for multi neurons
                    key.spike_times = double(units(i).tspk)/3e4; % replace 3e4 with actual sampling rate from file
                    key.spike_waveform = units(i).spkwf; %99
                    key.neuron_filestart = events_nev.t_start;
                    key.neuron_trialbeg = events_nev.t_beg;
                    key.neuron_trialend = events_nev.t_end;
                    key.neuron_trialrew = events_nev.t_rew;
                    self.insert(key);
                    fprintf('Populated neuron %d for experiment done on %s in animal %s \n',key.cluster_id,key.session_date,key.animal_name);
                end
            end
        end
    end
end