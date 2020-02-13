function mergedneurons = MergeNeuronsByChannel(neurons,channels)

numchannels = numel(channels);
for i = 1:numchannels
    multineuron = neurons([neurons.channel_id] == channels(i));
    multineuron(1).spike_times = sort(cell2mat({multineuron.spike_times}'));
    mergedneurons(i) = multineuron(1);
end