%{
# Single-trial behavioural data (stimulus parameters and continuous behavioural variables)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
trial_number=1              : int           # trial number
---
# add additional attributes
floor_den=0                 : double        # density of the ground plane [a.u]     
v_max=0                     : double        # maximum forward speed [cm/s]     
w_max=0                     : double        # maximum angular speed [deg/s]
v_gain=0                    : double        # forward speed joystick gain
w_gain=0                    : double        # angular speed joystick gain
ptb_linvel=0                : double        # amplitude of forward perturbation [cm/s]     
ptb_angvel=0                : double        # amplitude of angular perturbation [deg/s] 
ptb_delay=0                 : double        # timing of ptb from max(targ onset, move onset) [s]    
firefly_on=0                : double        # firefly on throughout the trial? [1/0]      
landmark_lin=0              : double        # linear landmark (concentric circ on ground)? [1/0]    
landmark_ang=0              : double        # angular landmark (mountainous bg)? [1/0]      
landmark_fixedground=0      : double        # ground plane elements not refreshed? [1/0]     
replay=0                    : double        # stimulus was replayed? [1/0]   
stop2feedback_intv=0        : double        # interval between stopping and feedback [s]
intertrial_intv=0           : double        # interval between trials [s]
reward_duration=0           : double        # quantity of reward [ms]
attempted=0                 : double        # attempted trial? [1/0]
rewarded=0                  : double        # rewarded trial? [1/0]
perturbed=0                 : double        # perturbation in trial? [1/0]
spurious_targ=0             : double        # target was misplaced? [1/0]

leye_horpos=0               : longblob      # left eye hor. position [deg]
leye_verpos=0               : longblob      # left eye ver. position [deg]
leye_torpos=0               : longblob      # left eye tors. position [deg]
reye_horpos=0               : longblob      # right eye hor. position [deg]
reye_verpos=0               : longblob     	# right eye ver. position [deg]
reye_torpos=0               : longblob      # right eye tors. position [deg]
pupildia=0                  : longblob      # pupil diameter [a.u]
head_horpos=0               : longblob      # head hor. position [deg]
head_verpos=0               : longblob      # head ver. position [deg]
head_torpos=0               : longblob      # head tors. position [deg]
joy_linvel=0                : longblob      # forward velocity [cm/s]
joy_angvel=0                : longblob      # angular velocity [deg/s]
firefly_x=0                 : longblob      # firefly x position [cm]
firefly_y=0                 : longblob      # firefly y position [cm]
monkey_x=0                  : longblob      # monkey x position [cm]
monkey_y=0                  : longblob      # monkey y position [cm]
monkey_xtraj=0              : longblob      # monkey smooth x position [cm]
monkey_ytraj=0              : longblob      # monkey smooth y position [cm]
monkey_phitraj=0            : longblob      # monkey smooth orientation [deg]
dist2firefly_x=0            : longblob      # x distance to firefly [cm]
dist2firefly_y=0            : longblob      # y distance to firefly [cm]
dist2firefly_r=0            : longblob      # distance to firefly [cm]
dist2firefly_th=0           : longblob      # angle to firefly [deg]
hand_x=0                    : longblob      # monkey hand x position [pixels]
hand_y=0                    : longblob      # monkey hand y position [pixels]
behv_time=0                 : longblob      # time index [s]

behv_tbeg=0                 : tinyblob      # time when target appeared
behv_tmove=0                : tinyblob      # time when movement started
behv_tstop=0                : tinyblob      # time when movement ended
behv_trew=0                 : tinyblob      # time when reward delivered
behv_tend=0                 : tinyblob      # time when trial ended
behv_tptb=0                 : tinyblob      # time when perturbation started
behv_tsac=0                 : longblob      # time when saccade was made
%}

classdef TrialBehaviour < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            behv_data = fetch(firefly.Behaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            event_data = fetch(firefly.Event &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            stimulusprs = fetch(firefly.StimulusParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            
            trials = SegmentBehaviouralData(behv_data,event_data,analysisprs,stimulusprs);
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