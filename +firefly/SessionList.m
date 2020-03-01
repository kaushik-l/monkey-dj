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
            '51-042' 'firefly-densities' 'Bruno' 51 '2017-08-04' 42 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Bruno\Utah array\Aug 04 2017' {'s'}  [0 0 0] {'PPC'} [0 1] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '51-043' 'firefly-densities' 'Bruno' 51 '2017-08-05' 43 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Bruno\Utah array\Aug 05 2017' {'utah96'}  [0 0 0] {'PPC'} [0 1] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-033' 'firefly-densities' 'Schro' 53 '2018-02-08' 33 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 08 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-034' 'firefly-densities' 'Schro' 53 '2018-02-09' 34 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 09 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-035' 'firefly-densities' 'Schro' 53 '2018-02-12' 35 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 12 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-036' 'firefly-ptb' 'Schro' 53 '2018-02-13' 36 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 13 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'one density, no landmarks, ptb, random DCI, random ITI'}
            '53-037' 'firefly-ptb' 'Schro' 53 '2018-02-14' 37 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 14 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'one density, no landmarks, ptb, random DCI, random ITI'}
            '53-038' 'firefly-ptb' 'Schro' 53 '2018-02-15' 38 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 15 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'one density, no landmarks, ptb, random DCI, random ITI'}
            '53-039' 'firefly-ptb' 'Schro' 53 '2018-02-16' 39 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 16 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'one density, no landmarks, ptb, random DCI, random ITI'}
            '53-040' 'firefly-ptb' 'Schro' 53 '2018-02-19' 40 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 19 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'one density, no landmarks, ptb, random DCI, random ITI'}
            '53-041' 'firefly-gain' 'Schro' 53 '2018-02-20' 41 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 20 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'gain', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-042' 'firefly-gain' 'Schro' 53 '2018-02-21' 42 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 21 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'gain', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-043' 'firefly-gain' 'Schro' 53 '2018-02-26' 43 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 26 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'gain', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-044' 'firefly-gain' 'Schro' 53 '2018-02-27' 44 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 27 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'gain', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-045' 'firefly-replay' 'Schro' 53 '2018-02-28' 45 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Feb 28 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'replay', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-046' 'firefly-replay' 'Schro' 53 '2018-03-01' 46 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Mar 01 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'replay', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-047' 'firefly-replay' 'Schro' 53 '2018-03-02' 47 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Utah array\Mar 02 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'replay', 'one density, no landmarks, no ptb, random DCI, random ITI'}
            '53-091' 'firefly-densities' 'Schro' 53 '2018-07-10' 91 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Schro\Sim_recordings\Jul 10 2018' {'utah2x48'}  [0 0 0] {{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '53-228' 'firefly-densities' 'Schro' 53 '2018-09-06' 228 0 'Z:\Data\Monkey2_newzdrive\Schro\Utah Array\Sep 06 2018' {'linearprobe24','utah2x48'}  [0 0 0] {'MST',{'PPC', 'PFC'}} [2 2] {'two densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-60' 'firefly-densities' 'Quigley' 44 '2017-02-24' 60 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Feb 24 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-61' 'firefly-densities' 'Quigley' 44 '2017-02-25' 61 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Feb 25 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-62' 'firefly-densities' 'Quigley' 44 '2017-02-27' 62 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Feb 27 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-63' 'firefly-densities' 'Quigley' 44 '2017-02-28' 63 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Feb 28 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-64' 'firefly-densities' 'Quigley' 44 '2017-03-01' 64 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 01 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-65' 'firefly-densities' 'Quigley' 44 '2017-03-02' 65 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 02 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-66' 'firefly-densities' 'Quigley' 44 '2017-03-05' 66 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 05 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-68' 'firefly-densities' 'Quigley' 44 '2017-03-07' 68 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 07 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-69' 'firefly-densities' 'Quigley' 44 '2017-03-08' 69 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 08 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-70' 'firefly-densities' 'Quigley' 44 '2017-03-09' 70 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 09 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-71' 'firefly-densities' 'Quigley' 44 '2017-03-13' 71 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 13 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-72' 'firefly-densities' 'Quigley' 44 '2017-03-14' 72 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 14 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-73' 'firefly-densities' 'Quigley' 44 '2017-03-15' 73 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 15 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-74' 'firefly-densities' 'Quigley' 44 '2017-03-16' 74 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 16 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-75' 'firefly-densities' 'Quigley' 44 '2017-03-17' 75 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 17 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}
            '44-76' 'firefly-densities' 'Quigley' 44 '2017-03-20' 76 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Mar 20 2017' {'utah96'}  [0 0 0] {'PPC'} [1 1] {'four densities, no landmarks, no ptb, fixed DCI, fixed ITI'}            
            '44-145' 'firefly-densities' 'Quigley' 44 '2017-08-01' 145 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 01 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-146' 'firefly-densities' 'Quigley' 44 '2017-08-02' 146 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 02 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-147' 'firefly-densities' 'Quigley' 44 '2017-08-03' 147 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 03 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-148' 'firefly-densities' 'Quigley' 44 '2017-08-04' 148 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 04 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-149' 'firefly-densities' 'Quigley' 44 '2017-08-08' 149 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 08 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '44-150' 'firefly-densities' 'Quigley' 44 '2017-08-09' 150 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Quigley\Utah array\Aug 09 2017' {'utah96'}  [0 0 0] {'PPC'} [1 0] {'four densities, no landmarks, no ptb, random DCI, random ITI'}
            '70-001' 'firefly' 'Sparky' 70 '2020-01-31' 1 0 'C:\Users\jkl9\Documents\Data\firefly-monkey\Sparky\Training\Jan 31 2020' {[]} [0 0 0] {[]} [0 0] {'polarizer, fixed density, no landmarks, no ptb, random DCI, random ITI'}
        }
    end
end