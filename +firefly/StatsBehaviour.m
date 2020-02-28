%{
# Behaviour across different trial types (bias, variance, ROC)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
trial_type                  : varchar(128)      # type of trial ['all', ...
'density1', 'density2', 'density3', 'density5', 'density4', 'gain1', ...
'gain2', 'gain3', 'fireflyoff', 'fireflyon', 'unrewarded', 'rewarded',...
'unperturbed','perturbed', 'replay']
---
# add additional attributes
firefly_x=0                 : longblob          # firefly x position [cm]    
firefly_y=0                 : longblob          # firefly y position [cm]
firefly_r=0                 : longblob          # firefly radial distance [cm]
firefly_th=0                : longblob          # firefly angle [deg]

monkey_xf=0                 : longblob          # monkey stopping x position [cm]
monkey_yf=0                 : longblob          # monkey stopping y position [cm]
monkey_rf=0                 : longblob          # monkey stopping radial distance [cm]     
monkey_thf=0                : longblob          # monkey stopping angle [deg]

dist2firefly=0              : longblob          # dist between stopping pos and firefly
dist2firefly_shuffled=0     : longblob          # same as above, but shuffled estimate

m1_beta_r=0                 : doublees          # radial slope (regression without intercept) 
m1_betaci_r=0               : blob              # radial slope conf int
m1_beta_th=0                : double            # angular slope 
m1_betaci_th=0              : blob              # angular slope conf int

m2_beta_r=0                 : double            # radial slope (regression with intercept)  
m2_betaci_r=0               : blob              # radial slope conf int
m2_beta_th=0                : double            # angular slope  
m2_betaci_th=0              : blob              # angular slope conf int 
m2_alpha_r=0                : double            # radial intercept [cm]
m2_alphaci_r=0              : blob              # radial intercept conf int [cm]
m2_alpha_th=0               : double            # angular intercept [deg]
m2_alphaci_th=0             : blob              # angular intercept conf int [deg]

m3_r=0                      : blob              # target distance [cm] (local linear regression)
m3_betalocal_r=0            : blob              # stopping distance [cm]
m3_th=0                     : blob              # target angle [deg]
m3_betalocal_th=0           : blob              # stopping angle [deg]

corr_r=0                    : double            # corr(target dist, monk dist)
pval_r=0                    : double            # pval of radial corr
corr_th=0                   : double            # corr(target angle, monk angle)
pval_th=0                   : double            # pval of angular corr

roc_rewardwin=0             : blob              # ROC curve reward window-size
roc_pcorrect=0              : blob              # ROC curve percent correct
roc_pcorrect_shuffled=0     : blob              # ROC curve percent correct, shuffled estimate
auc=0                       : double            # area under ROC curve
auc_rbin=0                  : blob              # target distance bin
auc_r=0                     : blob              # AUC vs target distance bin
auc_thbin=0                 : blob              # target angle bin
auc_th=0                    : blob              # AUC vs target angle bin

spatial_x=0                 : longblob          # x coord of target [cm]
spatial_y=0                 : longblob          # y coord of target [cm]
spatial_xerr=0              : longblob          # stopping error in x [cm]
spatial_yerr=0              : longblob          # stopping error in y [cm]
spatial_xstd=0              : longblob          # stopping std dev in x [cm]
spatial_ystd=0              : longblob          # stopping std dev in x [cm]
%}

classdef StatsBehaviour < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            stimulusprs = fetch(firefly.StimulusParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            %% all attempted trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0','*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'all';
            self.insert(key);
            fprintf('Populated behavioural stats across all trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% density 0.005 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'floor_den=0.005','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density1';
                self.insert(key);
                fprintf('Populated behavioural stats across density 0.005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across density 0.005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'floor_den=0.001','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density2';
                self.insert(key);
                fprintf('Populated behavioural stats across density 0.001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across density 0.001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.0005 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'floor_den=0.0005','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density3';
                self.insert(key);
                fprintf('Populated behavioural stats across density 0.0005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across density 0.0005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.0001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'floor_den=0.0001','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density4';
                self.insert(key);
                fprintf('Populated behavioural stats across density 0.0001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across density 0.0001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.000001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'floor_den=0.000001','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density5';
                self.insert(key);
                fprintf('Populated behavioural stats across density 0.000001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across density 0.000001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 1x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'v_gain=1','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain1';
                self.insert(key);
                fprintf('Populated behavioural stats across gain 1x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across gain 1x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 1.5x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'v_gain=1.5','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain2';
                self.insert(key);
                fprintf('Populated behavioural stats across gain 1.5x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across gain 1.5x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 2x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'v_gain=2','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain3';
                self.insert(key);
                fprintf('Populated behavioural stats across gain 2x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across gain 2x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% firefly OFF trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'firefly_on=0','*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'fireflyoff';
            self.insert(key);
            fprintf('Populated behavioural stats across invisible firefly trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% firefly ON trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'firefly_on=1','*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'fireflyon';
            self.insert(key);
            fprintf('Populated behavioural stats across visible firefly trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% unrewarded trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'rewarded=0','*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'unrewarded';
            self.insert(key);
            fprintf('Populated behavioural stats across unrewarded trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% rewarded trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'rewarded=1','*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'rewarded';
            self.insert(key);
            fprintf('Populated behavioural stats across rewarded trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% unperturbed trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'perturbed=0','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'unperturbed';
                self.insert(key);
                fprintf('Populated behavioural stats across unperturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across unperturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% perturbed trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=0' & 'perturbed=1','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'perturbed';
                self.insert(key);
                fprintf('Populated behavioural stats across perturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across perturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% replay trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'replay=1','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'replay';
                self.insert(key);
                fprintf('Populated behavioural stats across replay trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate behavioural stats across replay trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
        end
    end
end