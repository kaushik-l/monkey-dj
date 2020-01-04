function trials = SegmentLfpData(lfp_data,event_data,prs,analysisprs)

%% gather events
tbeg = event_data.tbeg + behv_data.lfp_tstart(1);
trew = event_data.trew + behv_data.lfp_tstart(1);
tend = event_data.tend + behv_data.lfp_tstart(1);
tptb = event_data.tptb + behv_data.lfp_tstart(1);
tmove = event_data.tmove + behv_data.lfp_tstart(1);
tstop = event_data.tstop + behv_data.lfp_tstart(1);
tsac = behv_data.behv_tsac + behv_data.lfp_tstart(1);
ntrials = numel(event_data.tend);