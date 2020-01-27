function spiketimes = ShiftSpikes(trials,eventtimes)
% shifts spike trains by eventtimes - used to align spike trains to events

%% check if there as as many event times as there are trials
if length(trials)~=length(eventtimes)
    fprintf('error: event times should be a vector of same length as trials \n');
    return;
end

%% shift spike train on each trial by the event time on that trial
spiketimes = cell(length(trials),1);
for i=1:length(trials)
    spiketimes{i} = trials(i).spike_times - eventtimes(i);
end