%{
firefly.Animal (manual)                 # all animals
animal_name    : varchar(128)           # string name
-----
# add additional attributes
date_of_birth  : date                   # the date in YYYY-MM-DD
sex            : enum ("M", "F", "U")
%}

classdef Animal < dj.Manual
end