%{
# Single-trial behavioural data (stimulus parameters and continuous behavioural variables)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
trial_number=1              : int          # trial number
---
# add additional attributes
floor_den=0                 : double       
v_max=0                     : double       
w_max=0                     : double       
ptb_linvel=0                : double       
ptb_angvel=0                : double       
ptb_delay=0                 : double       
firefly_on=0                : double       
landmark_lin=0              : double       
landmark_ang=0              : double       
landmark_fixedground=0      : double       
replay=0                    : double       
stop2feedback_intv=0        : double       
intertrial_intv=0           : double       
reward_duration=0           : double
spurious_targ=0             : double

leye_horpos=0               : longblob     # data as array
leye_verpos=0               : longblob     # data as array
leye_torpos=0               : longblob     # data as array
reye_horpos=0               : longblob     # data as array
reye_verpos=0               : longblob     # data as array
reye_torpos=0               : longblob     # data as array
pupildia=0                  : longblob     # data as array
head_horpos=0               : longblob     # data as array
head_verpos=0               : longblob     # data as array
head_torpos=0               : longblob     # data as array
joy_linvel=0                : longblob     # data as array
joy_angvel=0                : longblob     # data as array
firefly_x=0                 : longblob     # data as array
firefly_y=0                 : longblob     # data as array
monkey_x=0                  : longblob     # data as array
monkey_y=0                  : longblob     # data as array
hand_x=0                    : longblob     # data as array
hand_y=0                    : longblob     # data as array
behv_time=0                 : longblob     # data as array

behv_tbeg=0                 : tinyblob     # data as array
behv_tmove=0                : tinyblob     # data as array
behv_tstop=0                : tinyblob     # data as array
behv_trew=0                 : tinyblob     # data as array
behv_tend=0                 : tinyblob     # data as array
behv_tptb=0                 : tinyblob     # data as array
behv_tsac=0                 : longblob     # data as array
%}

classdef TrialBehaviour < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            behv_data = fetch(firefly.Behaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            event_data = fetch(firefly.Event &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            
            trials = SegmentBehaviouralData(behv_data,event_data,analysisprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            ntrials = numel(trials);
            for j=1:ntrials
                key.trial_number = j;
                for i=1:length(selfAttributes)
                    if any(strcmp(fields(trials(j)),selfAttributes{i}))
                        key.(selfAttributes{i}) = trials(j).(selfAttributes{i});
                    end
                end
                self.insert(key);
            end            
            fprintf('Populated trial-by-trial behavioural data for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end