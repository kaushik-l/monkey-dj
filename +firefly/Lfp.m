%{
# LFP data (voltage and event markers)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam  
-> firefly.ElectrodeParam
channel_id                  : int               # channel number
---
# add additional attributes
electrode_id                : int               # electrode number
electrode_type              : varchar(128)      # electrode type ['utah96','utah2x48','linearprobe32',...]
brain_area                  : varchar(128)      # brain area targeted by electrode
 
lfp_amplitude               : longblob          # lfp amplitude [muV]
lfp_time                    : longblob          # time index [s]

lfp_tblockstart=0           : longblob          # block start markers [s]
lfp_tbeg=0                  : longblob          # target onset marker [s]
lfp_tend=0                  : longblob          # end of trial marker [s]
lfp_trew=0                  : longblob          # reward marker [s]
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
                t = dt:dt:dt*nt;
                [~,electrode_id] = MapChannel2Electrode(utaharray_types{utaharray_type});
                brain_area = brain_area{strcmp(electrode_type,utaharray_types{utaharray_type})};
                for i=1:nchannels
                    key.channel_id = i;
                    key.electrode_id = electrode_id(i);
                    key.electrode_type = utaharray_types{utaharray_type};
                    if strcmp(key.electrode_type,'utah96'), key.brain_area = brain_area;
                    else, key.brain_area = MapDualArray2BrainArea(brain_area, key.electrode_id); end
                    key.lfp_amplitude = NS1.Data(i,:);
                    key.lfp_time = t;
                    key.lfp_tblockstart = events_nev.t_start;
                    key.lfp_tbeg = events_nev.t_beg;
                    key.lfp_tend = events_nev.t_end;
                    key.lfp_trew = events_nev.t_rew;
                    self.insert(key);
                    fprintf('Populated LFP channel %d for experiment done on %s with animal %s \n',...
                        key.channel_id,key.session_date,key.monk_name);
                end
            end
            
        end
    end
end