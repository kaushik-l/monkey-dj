%% example queries

% fetch only primary keys from entire Session table
data = fetch(firefly.Session);

% fetch entire Session table
data = fetch(firefly.Session,'*');

% fetch entire Session table from monkey Bruno
data = fetch(firefly.Session & 'monk_name="Bruno"','*');

% fetch only primary attributes of Behaviour table from monkey Bruno + session 41
data = fetch(firefly.Behaviour & 'monk_name = "Bruno"' & 'session_id = 41');

% fetch entire Behaviour table from monkey Bruno + session 41
data = fetch(firefly.Behaviour & 'monk_name = "Bruno"' & 'session_id = 41','*');

% fetch entire Behaviour table from monkey Schro + session 41
data = fetch(firefly.Behaviour & 'monk_name = "Schro"' & 'session_id = 41','*');

% fetch only linear velocity from Behaviour table from monkey Bruno + session 41
data = fetchn(firefly.Behaviour & 'monk_name = "Schro"' & 'session_id = 41','joy_linvel');

% fetch both linear and angular velocity from Behaviour table from monkey Bruno + session 41
[data1,data2] = fetchn(firefly.Behaviour & 'monk_name = "Bruno"' & 'session_id = 41','joy_linvel','joy_angvel');

% fetch all trials from entire TrialBehaviour table from monkey Bruno + session 41
data = fetch(firefly.TrialBehaviour & 'monk_name = "Bruno"' & 'session_id = 41','*');

% fetch only attempted trials from TrialBehaviour table from monkey Bruno + session 41
data = fetch(firefly.TrialBehaviour & 'monk_name = "Bruno"' & 'session_id = 41' & 'attempted = 1','*');

% fetch only rewarded trials in which monkey got reward from TrialBehaviour table from monkey Bruno + session 41
data = fetch(firefly.TrialBehaviour & 'monk_name = "Bruno"' & 'session_id = 41' & 'rewarded = 1','*');

% fetch linear velocity only from attempted trials from TrialBehaviour table from monkey Bruno + session 41
data = fetchn(firefly.TrialBehaviour & 'monk_name = "Bruno"' & 'session_id = 41'  & 'attempted = 1','joy_linvel');

% fetch floor densities only from attempted trials from TrialBehaviour table from monkey Bruno + session 41
data = fetchn(firefly.TrialBehaviour & 'monk_name = "Bruno"' & 'session_id = 41'  & 'attempted = 1','floor_den');

% fetch Event table from monkey Bruno + session 41
data = fetch(firefly.Event & 'monk_name = "Bruno"' & 'session_id = 41','*');

% fetch Lfp table from monkey Bruno + session 41
data = fetch(firefly.Lfp & 'monk_name = "Bruno"' & 'session_id = 41','*');

% fetch channel #7 from Lfp table from from monkey Bruno + session 41
data = fetch(firefly.Lfp & 'monk_name = "Bruno"' & 'session_id = 41' & 'channel_id = 7','*');

% fetch electrode #7 from Lfp table from  monkey Bruno + session 41
data = fetch(firefly.Lfp & 'monk_name = "Bruno"' & 'session_id = 41' & 'electrode_id = 7','*');

% fetch PPC electrodes Lfp table from monkey Bruno + session 41
data = fetch(firefly.Lfp & 'monk_name = "Bruno"' & 'session_id = 41' & 'brain_area = "PPC"','*');

% fetch singleunits from Neuron table from monkey Bruno + session 41
data = fetch(firefly.Neuron & 'monk_name = "Bruno"' & 'session_id = 41' & 'unit_type = "singleunit"','*');

% fetch behavioural statistics performed on all trials from StatsBehaviour table from monkey Bruno + session 41
data = fetch(firefly.StatsBehaviour & 'monk_name = "Bruno"' & 'session_id = 41' & 'trial_type = "all"','*');

% fetch behavioural statistics from analysis performed on trials with firefly on from StatsBehaviour table from monkey Bruno + session 41
data = fetch(firefly.StatsBehaviour & 'monk_name = "Bruno"' & 'session_id = 41' & 'trial_type = "all"','*');

% fetch area-under-curve from analysis performed on all trials with firefly ON from StatsBehaviour table from monkey Quigley all sessions
data = fetchn(firefly.StatsBehaviour & 'monk_name = "Quigley"' & 'trial_type = "fireflyon"','auc');

% fetch area-under-curve from analysis performed on all trials with firefly OFF from StatsBehaviour table from monkey Quigley all sessions
data = fetchn(firefly.StatsBehaviour & 'monk_name = "Quigley"' & 'trial_type = "fireflyoff"','auc');