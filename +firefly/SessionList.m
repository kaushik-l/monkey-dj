%{
# List of sessions
monk_sess_id                : varchar(20)       # unique id 'monk_id-sess_id' as 'xx-yyy'
---
experiment_name             : varchar(20)       # name of the experiment
monk_name                   : varchar(20)       # name of the subject
monk_id                     : int               # monkey id
session_date                : date              # the date in YYYY-MM-DD
session_id                  : int               # session id
units                       : int               # Analyse all units? (sorted units=0; all units=1)
folder                      : varchar(256)      # location of raw datafiles
electrode_type              : blob              # choose from linearprobe16, linearprobe24, linearprobe32, utah96, utah2x48
electrode_coord             : tinyblob          # recording location on grid (row, col, depth)
brain_area                  : blob              # cell array of strings, choose from PPC, VIP, MST, PFC
eyechannels                 : tinyblob          # [lefteye righteye], 0 for none; 1 for eye-coil; 2 for eye-tracker
comments                    : blob              # session-specific remarks
%}
classdef SessionList < dj.Lookup
    properties
        contents = {
            '51-041' 'firefly-densities' 'Bruno' 51 '2017-08-03' 41 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Bruno\Utah array\Aug 03 2017' {'utah96'}  [0 0 0] {'PPC'} [0 1] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '51-042' 'firefly-densities' 'Bruno' 51 '2017-08-04' 42 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Bruno\Utah array\Aug 04 2017' {'utah96'}  [0 0 0] {'PPC'} [0 1] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '51-043' 'firefly-densities' 'Bruno' 51 '2017-08-05' 43 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Bruno\Utah array\Aug 05 2017' {'utah96'}  [0 0 0] {'PPC'} [0 1] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-034' 'firefly-densities' 'Schro' 53 '2018-02-09' 34 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 09 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-091' 'firefly-densities' 'Schro' 53 '2018-07-10' 91 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Sim_recordings\Jul 10 2018' {'linearprobe24','utah2x48'}  [0 0 0] {'MST',{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-149' 'firefly-densities' 'Quigley' 44 '2017-08-08' 149 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 08 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-150' 'firefly-densities' 'Quigley' 44 '2017-08-09' 150 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 09 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
        }
    end
end