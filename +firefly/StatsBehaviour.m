%{
# Behaviour across different trial types (bias, variance, ROC)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
trial_type                  : varchar(128)
---
# add additional attributes
firefly_x=0                 : longblob       
firefly_y=0                 : longblob  
firefly_r=0                 : longblob
firefly_th=0                : longblob  

monkey_xf=0                 : longblob       
monkey_yf=0                 : longblob
monkey_rf=0                 : longblob       
monkey_thf=0                : longblob

dist2firefly=0              : longblob       
dist2firefly_shuffled=0     : longblob

m1_beta_r=0                 : double
m1_betaci_r=0               : blob
m1_beta_th=0                : double
m1_betaci_th=0              : blob

m2_beta_r=0                 : double
m2_betaci_r=0               : blob
m2_beta_th=0                : double
m2_betaci_th=0              : blob
m2_alpha_r=0                : double
m2_alphaci_r=0              : blob
m2_alpha_th=0               : double
m2_alphaci_th=0             : blob

m3_r=0                      : blob
m3_betalocal_r=0            : blob
m3_th=0                     : blob
m3_betalocal_th=0           : blob

corr_r=0                    : double
pval_r=0                    : double
corr_th=0                   : double
pval_th=0                   : double

roc_rewardwin=0             : blob
roc_pcorrect=0              : blob
roc_pcorrect_shuffled=0     : blob
auc=0                       : double
auc_rbin=0                  : blob
auc_r=0                     : blob
auc_thbin=0                 : blob
auc_th=0                    : blob

spatial_x=0                 : longblob
spatial_y=0                 : longblob
spatial_xerr=0              : longblob
spatial_yerr=0              : longblob
spatial_xstd=0              : longblob
spatial_ystd=0              : longblob
%}

classdef StatsBehaviour < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            stimulusprs = fetch(firefly.StimulusParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            %% all attempted trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1','*');
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
                'attempted=1' & 'floor_den=0.005','*');
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
                'attempted=1' & 'floor_den=0.001','*');
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
                'attempted=1' & 'floor_den=0.0005','*');
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
                'attempted=1' & 'floor_den=0.0001','*');
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
                'attempted=1' & 'floor_den=0.000001','*');
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
                'attempted=1' & 'v_gain=1','*');
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
                'attempted=1' & 'v_gain=1.5','*');
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
                'attempted=1' & 'v_gain=2','*');
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
                'attempted=1' & 'firefly_on=0','*');
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
                'attempted=1' & 'firefly_on=1','*');
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
                'attempted=1' & 'rewarded=0','*');
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
                'attempted=1' & 'rewarded=1','*');
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
                'attempted=1' & 'perturbed=0','*');
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
                'attempted=1' & 'perturbed=1','*');
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
        end
    end
end