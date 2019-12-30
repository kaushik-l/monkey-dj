%{
# Data acquisition parameters
acqparam_id=1           : int           # unique id for this paramater set
---
# list of parameters
fs_smr=833.3333         : float         # sampling rate of smr file
fs_ns6=3e4              : float         # sampling rate of ns6 file
fs_ns1=5e2              : float         # sampling rate of ns1 file
filtwidth=2             : int           # width in samples (10 samples @ fs_smr = 10x0.0012 = 12 ms)
filtsize=4              : int           # size in samples
factor_downsample=5     : int           # select every nth sample
dt=0.006                : float         # time resolution of downsampled data
jitter_marker=0.25      : float         # to allow for variability in marker time relative to actual event time (s)
mintrialduration=0.5    : float         # to detect bad trials (s)
%}

classdef DataAcquisitionParam < dj.Lookup
    properties
        contents = {
            1,...
            833.3333,3e4,5e2,...
            2,4,5,...
            0.006,0.25,0.5
            }
    end
end