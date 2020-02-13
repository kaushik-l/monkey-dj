function events = InsertNaN2eventtimes(events)

%% convert to columns vectors
events.t_beg = events.t_beg(:);
events.t_end = events.t_end(:);
events.t_rew = events.t_rew(:);
if isfield(events,'t_ptb'), events.t_ptb = events.t_ptb(:); end

%% rewards
ntrls = length(events.t_beg);
nrewards = length(events.t_rew);
[rewarded,~] = ind2sub([ntrls nrewards],find((events.t_rew' > events.t_beg) & (events.t_rew' < events.t_end)));
if ~isempty(events.t_rew), events.t_rew(sum((events.t_rew' > events.t_beg) & (events.t_rew' < events.t_end))==0) = []; end
t_rew = nan(size(events.t_beg));
t_rew(rewarded) = events.t_rew;
events.t_rew = t_rew;

%% ptb
if isfield(events,'t_ptb')
    ntrls = length(events.t_beg);
    nptb = length(events.t_ptb);
    [perturbed,~] = ind2sub([ntrls nptb],find((events.t_ptb' > events.t_beg) & (events.t_ptb' < events.t_end)));
    if ~isempty(events.t_ptb), events.t_ptb(sum((events.t_ptb' > events.t_beg) & (events.t_ptb' < events.t_end))==0) = []; end
    t_ptb = nan(size(events.t_beg));
    t_ptb(perturbed) = events.t_ptb;
    events.t_ptb = t_ptb;
end