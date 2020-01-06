function trials = SegmentNeuralData(neural_data,event_data,analysisprs)

%% gather events
nblocks = numel(neural_data.neuron_tblockstart);
event_data.tblockstart(nblocks+1) = inf;
tbeg = []; trew = []; tend = []; tptb = [];
tmove = []; tstop = []; tsac = [];

for block = 1:nblocks
    trialindx = event_data.tend > event_data.tblockstart(block) & event_data.tend < event_data.tblockstart(block+1);
    tbeg = [tbeg ; event_data.tbeg(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
    trew = [trew ; event_data.trew(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
    tend = [tend ; event_data.tend(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
    tptb = [tptb ; event_data.tptb(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
    tmove = [tmove ; event_data.tmove(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
    tstop = [tstop ; event_data.tstop(trialindx) - event_data.tblockstart(block) + neural_data.neuron_tblockstart(block)];
end
ntrials = numel(tend);

%% extract trials
spike_times = neural_data.spike_times;
for j=1:ntrials
    %% save continuous variables
    % define pretrial and posttrial periods
    pretrial = max(tbeg(j) - tmove(j),0) + analysisprs.pretrial; % extract everything from "movement onset - pretrial" or "target onset - pretrial" - whichever is first
    posttrial = analysisprs.posttrial; % extract everything until "t_end + posttrial"
    trials(j).spike_times = spike_times(spike_times>tbeg(j)-pretrial & spike_times<tend(j)+posttrial) - tbeg(j);
    
    %% reference trial events to target onset (tbeg)
    trials(j).neuron_tbeg = tbeg(j) - tbeg(j);
    trials(j).neuron_tmove = tmove(j) - tbeg(j);
    trials(j).neuron_tstop = tstop(j) - tbeg(j);
    trials(j).neuron_trew = trew(j) - tbeg(j);
    trials(j).neuron_tend = tend(j) - tbeg(j);
    % perturbation onset time
    trials(j).neuron_tptb = tptb(j) - tbeg(j);
end