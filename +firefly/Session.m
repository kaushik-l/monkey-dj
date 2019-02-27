%{
# Recording sessions
-> firefly.Animal
date                         : date             # the date in YYYY-MM-DD
session_id                   : varchar(128)     # string ID
---
# add additional attributes
experimente_name             : varchar(128)     # string name or enum????
experimenter_name            : varchar(128)     # string ID
%}

classdef Session < dj.Manual
end