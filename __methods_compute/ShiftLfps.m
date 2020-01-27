function [shiftedtrials_lfp, shiftedtrials_ts] = ShiftLfps(trials,eventtimes,dt)
% shifts lfps by eventtimes - used to align lfps to events

%% shift spike train on each trial by the event time on that trial
ntrials = length(trials);
t_min = min(cell2mat({trials.lfp_time}'));
t_max = max(cell2mat({trials.lfp_time}'));
nt = ceil((t_max - t_min)/dt);
ts = linspace(4*t_min, 4*t_max, 4*nt);
shiftedtrials(ntrials) = struct();
for i=1:length(trials)
    indx = find(ts > trials(i).lfp_time(1),1)-1;
    shiftlen = round(eventtimes(i)/dt);
    shiftedtrials(i).lfp = nan(4*nt,1);
    if ~isnan(shiftlen), shiftedtrials(i).lfp(indx-shiftlen : indx+length(trials(i).lfp_amplitude)-1 - shiftlen) = trials(i).lfp_amplitude; end
end
shiftedtrials_lfp = cell2mat({shiftedtrials.lfp});
shiftedtrials_ts = ts;