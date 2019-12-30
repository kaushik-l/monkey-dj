%{
# LFP data (voltage and event markers)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam  
-> firefly.ElectrodeParam
channel_id                  : int
---
# add additional attributes
electrode_id                : int     
electrode_type              : varchar(128) 
lfp_amplitude               : longblob
lfp_time                    : longblob
lfp_filestart=0             : longblob
lfp_trialbeg=0              : longblob
lfp_trialend=0              : longblob
lfp_trialrew=0              : longblob
%}

classdef Lfp < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from SessionLog Table
            [folder,electrode_type,brain_area] = fetchn(firefly.SessionList & ... % from table
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],... % restrict
                'folder','electrode_type','brain_area'); % return attribute 
            folder = folder{:}; electrode_type = electrode_type{:}; brain_area = brain_area{:}; % unpack cell
            % move to data folder
            filepath = [folder '\neural data'];          
            cd(filepath);
            
            % determine type of electrode
            lineararray_types = fetch1(firefly.ElectrodeParam,'lineararray_types');
            utaharray_types = fetch1(firefly.ElectrodeParam,'utaharray_types');
            lineararray_type = []; utaharray_type = [];
            for k=1:length(electrode_type)
                lineararray_type = [lineararray_type find(cellfun(@(type) strcmp(electrode_type{k},type), lineararray_types),1)];
                utaharray_type = [utaharray_type find(cellfun(@(type) strcmp(electrode_type{k},type), utaharray_types),1)];
            end
            
            if ~isempty(utaharray_type) % assume utaharray is recorded using Cereplex
                file_ns1=dir('*.ns1');
                file_nev=dir('*.nev');
                NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV');
                events_nev = GetEvents_nev(file_nev.name);
                events_nev = InsertNaN2rewardtimes(events_nev);
                [nchannels, nt] = size(NS1.Data);
                dt = 1/NS1.MetaTags.SamplingFreq;
                t = dt:dt:dt*10000;
                [~,electrode_id] = MapChannel2Electrode(utaharray_types{utaharray_type});
                for i=1:nchannels
                    key.channel_id = i;
                    key.electrode_id = electrode_id(i);
                    key.electrode_type = utaharray_types{utaharray_type};
                    key.lfp_amplitude = NS1.Data(i,1:10000);
                    key.lfp_time = t;
                    key.lfp_filestart = events_nev.t_start;
                    key.lfp_trialbeg = events_nev.t_beg;
                    key.lfp_trialend = events_nev.t_end;
                    key.lfp_trialrew = events_nev.t_rew;
                    self.insert(key);
                    fprintf('Populated LFP channel %d for experiment done on %s with animal %s \n',key.channel_id,key.session_date,key.monk_name);
                end
            end
            
        end
    end
end