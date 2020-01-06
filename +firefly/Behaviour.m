%{
# Behavioural data (stimulus parameters, continuous behavioural variables and discrete events)
-> firefly.Session
-> firefly.SessionList
-> firefly.DataAcquisitionParam
---
# add additional attributes
floor_den=0                 : longblob     # data as array
v_max=0                     : longblob     # data as array
w_max=0                     : longblob     # data as array
ptb_linvel=0                : longblob     # data as array
ptb_angvel=0                : longblob     # data as array
ptb_delay=0                 : longblob     # data as array
firefly_on=0                : longblob     # data as array
landmark_lin=0              : longblob     # data as array
landmark_ang=0              : longblob     # data as array
landmark_ground=0           : longblob     # data as array
replay=0                    : longblob     # data as array
stop2feedback_intv=0        : longblob     # data as array
intertrial_intv=0           : longblob     # data as array
reward_duration=0           : longblob     # data as array

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

behv_tblockstart=0          : longblob     # data as array (offset for event markers)
behv_tsac=0                 : longblob     # data as array
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
            [chdata,chnames,eventdata,eventnames,ntrialevents] = PrepareSMRData(filepath,prs,analysisprs);      % prepare SMR data
            [paramnames,paramvals] = PrepareLogData(filepath,ntrialevents);                                                  % prepare log data 
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
            fprintf('Populatedbehavioural data for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end