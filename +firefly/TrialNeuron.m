%{
# Single-trial neural data (spike times)
-> firefly.Neuron
-> firefly.Event
-> firefly.AnalysisParam
trial_number=1              : int          # trial number
---
# add additional attributes
spike_times                 : longblob

neuron_tbeg=0               : tinyblob        # data as array
neuron_tmove=0              : tinyblob        # data as array
neuron_tstop=0              : tinyblob        # data as array
neuron_trew=0               : tinyblob        # data as array
neuron_tend=0               : tinyblob        # data as array
neuron_tptb=0               : tinyblob        # data as array
%}

classdef TrialNeuron < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            neural_data = fetch(firefly.Neuron &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & ...
                ['cluster_id = ' num2str(key.cluster_id)],'*');
            event_data = fetch(firefly.Event &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            
            trials = SegmentNeuralData(neural_data,event_data,analysisprs);
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
            fprintf('Populated trial-by-trial neural data for cluster %d of experiment done on %s with monkey %s \n',...
                key.cluster_id,key.session_date,key.monk_name);
        end
    end
end