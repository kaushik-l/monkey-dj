%{
# Stimulus parameters
stimparam_id=1          : int               # unique id for this paramater set
---
# list of parameters
screendist=32.5         : float             # cm
height=10               : float             # cm
interoculardist=3.5     : float             # cm
framerate=60            : float             # (sec)^-1
x0=0                    : float             # subject's x-position at trial onset (cm)
y0=-32.5                : float             # subject's y-position at trial onset (cm)
fly_onduration=0.3      : float             # duration for which target is visible
rewardwin = 65          : float             # size of reward window around target (cm)
ptb_sigma = 0.1666      : float             # width of the gaussian func for ptb (s)
ptb_duration = 1        : float             # duration of ptb (s)
%}

classdef StimulusParam < dj.Lookup
    properties
        contents = {
            1,...
            32.5,10,3.5,60,...
            0,-32.5,...
            0.3,65,...
            0.1666,1
            }
    end
end