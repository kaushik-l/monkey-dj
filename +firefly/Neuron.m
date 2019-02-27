%{
-> firefly.Electrode
  
---
# add additional attributes
channel_id               : varchar(128)     
neuron_id                : varchar(128)  
spike_times
spike_waveform
%}

classdef Neuron < dj.Manual
end