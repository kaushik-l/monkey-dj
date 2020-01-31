%{
# LFP population data (voltage and event markers)
-> firefly.Session 
brain_area                  : varchar(128)      # brain area targeted by electrode
trial_number=1              : int               # trial number
---
# add additional attributes
channel_id                  : blob              # channel numbers
electrode_id                : blob              # electrode numbers
electrode_type              : blob              # electrode type ['utah96','utah2x48','linearprobe32',...]
 
lfp_amplitude               : longblob          # lfp amplitude [muV]
lfp_time                    : longblob          # time index [s]

lfp_tbeg=0                  : longblob          # target onset marker [s]
lfp_tmove=0                 : longblob          # target onset marker [s]
lfp_tstop=0                 : longblob          # target onset marker [s]
lfp_trew=0                  : longblob          # reward marker [s]
lfp_tend=0                  : longblob          # end of trial marker [s]
%}

classdef LfpPopulation < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            %% lfp data
            lfp_data = fetch(firefly.TrialLfp &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            brain_areas = unique({lfp_data.brain_area});
            numbrainareas = numel(brain_areas);
            numtrials = numel(unique([lfp_data.trial_number]));
            for i=1:numbrainareas
                key.brain_area = brain_areas{i};
                for j=1:numtrials
                    key.trial_number = j;
                    lfps = lfp_data(strcmp({lfp_data.brain_area},key.brain_area) & ...
                        [lfp_data.trial_number]==j);
                    key.channel_id = [lfps.channel_id];
                    key.electrode_id = [lfps.electrode_id];
                    key.electrode_type = {lfps.electrode_type};
                    key.lfp_amplitude = cell2mat({lfps.lfp_amplitude})';
                    key.lfp_time = lfps(1).lfp_time;
                    key.lfp_tbeg = lfps(1).lfp_tbeg;
                    key.lfp_tbeg = lfps(1).lfp_tmove;
                    key.lfp_tend = lfps(1).lfp_tstop;
                    key.lfp_trew = lfps(1).lfp_trew;
                    key.lfp_tend = lfps(1).lfp_tend;
                    self.insert(key);
                    fprintf('Populated lfp population from trial %d for experiment done on %s with animal %s \n',...
                        key.trial_number,key.session_date,key.monk_name);
                end
            end
        end
    end
end