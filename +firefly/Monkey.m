%{
# Monkey
monk_name    : varchar(128)           # name as string
-----
# add additional attributes
monk_id  : int                   # unique monkey ID
sex  : enum ("M", "F", "U")
%}

classdef Monkey < dj.Manual
end