function events = InsertNaN2rewardtimes(events)

%% convert to columns vectors
events.t_beg = events.t_beg(:);
events.t_end = events.t_end(:);
events.t_rew = events.t_rew(:);

%%
ntrls = length(events.t_beg);
nrewards = length(events.t_rew);
[rewarded,~] = ind2sub([ntrls nrewards],find((events.t_rew' > events.t_beg) & (events.t_rew' < events.t_end)));
t_rew = nan(size(events.t_beg));
t_rew(rewarded) = events.t_rew;
events.t_rew = t_rew;