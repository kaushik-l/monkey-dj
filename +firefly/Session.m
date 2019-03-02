%{
# Recording sessions
-> firefly.Animal
session_date                 : date             # the date in YYYY-MM-DD
session_id                   : int              # session number as integer
---
# add additional attributes
experiment_name              : varchar(128)     # name as string
experimenter_name            : varchar(128)     # name as string
%}

classdef Session < dj.Manual
end