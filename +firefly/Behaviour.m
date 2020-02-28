%{
# Behavioural data (stimulus parameters, continuous behavioural variables and discrete events)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
---
# add additional attributes
floor_den=0                 : longblob     # density of the ground plane [a.u]
v_max=0                     : longblob     # maximum forward speed [cm/s]
w_max=0                     : longblob     # maximum angular speed [deg/s]
v_gain=0                    : longblob     # forward speed joystick gain
w_gain=0                    : longblob     # angular speed joystick gain
ptb_linvel=0                : longblob     # amplitude of forward perturbation [cm/s]
ptb_angvel=0                : longblob     # amplitude of angular perturbation [deg/s]
ptb_delay=0                 : longblob     # timing of ptb from max(targ onset, move onset) [s]
firefly_on=0                : longblob     # firefly on throughout the trial? [1/0]
landmark_lin=0              : longblob     # linear landmark (concentric circ on ground)? [1/0]
landmark_ang=0              : longblob     # angular landmark (mountainous bg)? [1/0]
landmark_ground=0           : longblob     # ground plane elements not refreshed? [1/0]
replay=0                    : longblob     # stimulus was replayed? [1/0]
stop2feedback_intv=0        : longblob     # interval between stopping and feedback [s]
intertrial_intv=0           : longblob     # interval between trials [s]
reward_duration=0           : longblob     # quantity of reward [ms]

leye_horpos=0               : longblob     # left eye hor. position [deg]
leye_verpos=0               : longblob     # left eye ver. position [deg]
leye_torpos=0               : longblob     # left eye tors. position [deg]
reye_horpos=0               : longblob     # right eye hor. position [deg]
reye_verpos=0               : longblob     # right eye ver. position [deg]
reye_torpos=0               : longblob     # right eye tors. position [deg]
pupildia=0                  : longblob     # pupil diameter [a.u]
head_horpos=0               : longblob     # head hor. position [deg]
head_verpos=0               : longblob     # head ver. position [deg]
head_torpos=0               : longblob     # head tors. position [deg]
joy_linvel=0                : longblob     # forward velocity [cm/s]
joy_angvel=0                : longblob     # angular velocity [deg/s]
firefly_x=0                 : longblob     # firefly x position [cm]
firefly_y=0                 : longblob     # firefly y position [cm]
monkey_x=0                  : longblob     # monkey x position [cm]
monkey_y=0                  : longblob     # monkey y position [cm]
hand_x=0                    : longblob     # monkey hand x position [pixels]
hand_y=0                    : longblob     # monkey hand y position [pixels]
behv_time=0                 : longblob     # time index [s]

behv_tblockstart=0          : longblob     # offset for event markers [s]
behv_tsac=0                 : longblob     # saccade times [s]
%}

classdef Behaviour < dj.Imported    
    methods(Access=protected)
        function makeTuples(self,key)
            % use primary keys of session to lookup folder name from SessionLog Table
            [folder,eyechannels] = fetchn(firefly.SessionList & ... % from table
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],... % restrict
                'folder','eyechannels'); % return attribute
            folder = folder{:}; eyechannels = eyechannels{:}; % unpack cell
            
            % create file path
            filepath = [folder '\behavioural data'];
            
            prs = fetch(firefly.DataAcquisitionParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*'); analysisprs.eyechannels = eyechannels;
            ntrialevents = CountSMREvents(filepath);
            % prepare log data 
            [paramnames,paramvals] = PrepareLogData(filepath,ntrialevents);
            % prepare SMR data 
            [chdata,chnames,eventdata,eventnames] = PrepareSMRData(filepath,prs,analysisprs,paramnames,paramvals);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmp(chnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = chdata(strcmp(chnames,selfAttributes{i}),:);
                elseif any(strcmp(eventnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = eventdata{strcmp(eventnames,selfAttributes{i})};
                elseif any(strcmp(paramnames,selfAttributes{i}))
                    key.(selfAttributes{i}) = paramvals(strcmp(paramnames,selfAttributes{i}),:);
                end
            end
            self.insert(key);
            fprintf('Populated behavioural data for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end