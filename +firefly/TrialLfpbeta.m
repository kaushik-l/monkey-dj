%{
# Single-trial beta lfp data (voltage)
-> firefly.Lfp
-> firefly.Event
-> firefly.AnalysisParam
trial_number=1              : int               # trial number
---
# add additional attributes
lfp_freqrange               : blob              # [fmin fmax]
lfp_amplitude               : longblob          # hilbert-transformed
lfp_time                    : longblob

lfp_tbeg=0                  : tinyblob          # data as array
lfp_tmove=0                 : tinyblob          # data as array
lfp_tstop=0                 : tinyblob          # data as array
lfp_trew=0                  : tinyblob          # data as array
lfp_tend=0                  : tinyblob          # data as array
lfp_tptb=0                  : tinyblob          # data as array
%}

classdef TrialLfpbeta < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            lfp_data = fetch(firefly.Lfp &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                ['channel_id = ' num2str(key.channel_id)],'*');
            event_data = fetch(firefly.Event &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            
            trials = SegmentLfpData(lfp_data,event_data,analysisprs,'beta');
            key.lfp_freqrange = analysisprs.lfp_beta;
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            ntrials = numel(trials);
            for j=1:ntrials
                key.trial_number = j;
                for i=1:length(selfAttributes)
                    if any(strcmp(fields(trials(j)),selfAttributes{i}))
                        key.(selfAttributes{i}) = trials(j).(selfAttributes{i});
                    end
                end
                self.insert(key);
            end            
            fprintf('Populated trial-by-trial theta lfp data from channel %d for experiment done on %s with monkey %s \n',...
                key.channel_id,key.session_date,key.monk_name);
        end
    end
end