%{
# Recording sessions
-> firefly.Monkey
session_date                 : date             # the date in YYYY-MM-DD
session_id                   : int              # session number as integer
---
# add additional attributes
experimenter_name            : varchar(128)     # name as string
%}

classdef Session < dj.Manual
end