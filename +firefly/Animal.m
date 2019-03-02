%{
# Animal
animal_name    : varchar(128)           # name as string
-----
# add additional attributes
dob  : date                   # the date in YYYY-MM-DD
sex  : enum ("M", "F", "U")
%}

classdef Animal < dj.Manual
end