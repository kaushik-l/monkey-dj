%{
# Neuron population data (spike times and event markers)
-> firefly.Session 
brain_area                  : varchar(128)      # brain area targeted by electrode
trial_number=1              : int               # trial number
---
# add additional attributes
channel_id                  : blob              # channel numbers
electrode_id                : blob              # electrode numbers
electrode_type              : blob              # electrode type ['utah96','utah2x48','linearprobe32',...]
 
spike_counts                : longblob          # number of spikes
behv_time                   : longblob          # time index [s]

neuron_tbeg=0               : longblob          # target onset marker [s]
neuron_tmove=0              : longblob          # target onset marker [s]
neuron_tstop=0              : longblob          # target onset marker [s]
neuron_trew=0               : longblob          # reward marker [s]
neuron_tend=0               : longblob          # end of trial marker [s]
neuron_tptb=0               : tinyblob          # data as array
%}

classdef NeuronPopulation < dj.Imported
    methods(Access=protected)
        function makeTuples(self,key)
            %% neural data
            neural_data = fetch(firefly.TrialNeuron &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            behv_data = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            brain_areas = unique({neural_data.brain_area});
            numbrainareas = numel(brain_areas);
            numtrials = numel(unique([neural_data.trial_number]));
            for i=1:numbrainareas
                key.brain_area = brain_areas{i};
                for j=1:numtrials
                    key.trial_number = j;
                    neurons = neural_data(strcmp({neural_data.brain_area},key.brain_area) & ...
                        [neural_data.trial_number]==j);
                    key.channel_id = [neurons.channel_id];
                    key.electrode_id = [neurons.electrode_id];
                    key.electrode_type = {neurons.electrode_type};
                    %% concatenate units
                    numunits = numel(neurons);
                    timebins = behv_data(j).behv_time;
                    numbins = numel(timebins);
                    Yt = zeros(numbins,numunits);
                    for k=1:numunits, Yt(:,k) = hist(neurons(k).spike_times,timebins); end
                    %%
                    key.spike_counts = Yt;
                    key.behv_time = timebins;
                    key.neuron_tbeg = neurons(1).neuron_tbeg;
                    key.neuron_tbeg = neurons(1).neuron_tmove;
                    key.neuron_tend = neurons(1).neuron_tstop;
                    key.neuron_trew = neurons(1).neuron_trew;
                    key.neuron_tend = neurons(1).neuron_tend;
                    key.neuron_tend = neurons(1).neuron_tend;
                    self.insert(key);
                    fprintf('Populated neural population from trial %d for experiment done on %s with animal %s \n',...
                        key.trial_number,key.session_date,key.monk_name);
                end
            end
        end
    end
end