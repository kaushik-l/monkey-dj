%{
-> firefly.Session
electrode_type                 : varchar(128)     
---
# add additional attributes
electrode_region               : varchar(128)     
electrode_position             : varchar(128)      
%}

classdef Electrode < dj.Manual
end