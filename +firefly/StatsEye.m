%{
# Eye movement across different trial types (tracking index, saccades)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
trial_type                          : varchar(128)
---
# add additional attributes
saccade_trueval=0                   : longblob       
saccade_truedir=0                   : longblob  
saccade_predval=0                   : longblob
saccade_preddir=0                   : longblob  
saccade_time=0                      : longblob       

eyebehvcorr_r=0                     : double
eyebehvcorr_pval=0                  : double       
eyepos_err=0                        : longblob
stoppos_err=0                       : longblob       

ver_pred=0                          : longblob
hor_pred=0                          : longblob
verdiff_pred=0                      : longblob
hordiff_pred=0                      : longblob
ver_true=0                          : longblob
hor_true=0                          : longblob
verdiff_true=0                      : longblob
hordiff_true=0                      : longblob

ver_xcorr=0                         : longblob
ver_xcorrlag=0                      : longblob
ver_xcorrshuf=0                     : longblob
hor_xcorr=0                         : longblob
hor_xcorrlag=0                      : longblob
hor_xcorrshuf=0                     : longblob

ver_rfix=0                          : longblob
ver_pvalfix=0                       : longblob
hor_rfix=0                          : longblob
hor_pvalfix=0                       : longblob
verdiff_rfix=0                      : longblob
verdiff_pvalfix=0                   : longblob
hordiff_rfix=0                      : longblob
hordiff_pvalfix=0                   : longblob

cossim_meanfix=0                    : longblob
cossim_semfix=0                     : longblob
cossim_meanshuffix=0                : longblob
cossim_semshuffix=0                 : longblob
cossimgrouped_fix=0                 : longblob

varexp_meanfix=0                    : longblob
varexp_semfix=0                     : longblob
varexp_meanshuffix=0                : longblob
varexp_semshuffix=0                 : longblob
varexpgrouped_fix=0                 : longblob
varexpbound_fix=0                   : longblob
sqerr_fix=0                         : longblob
var_pred_fix=0                      : longblob
var_true_fix=0                      : longblob

ver_rstop=0                         : longblob
ver_pvalstop=0                      : longblob
hor_rstop=0                         : longblob
hor_pvalstop=0                      : longblob
verdiff_rstop=0                     : longblob
verdiff_pvalstop=0                  : longblob
hordiff_rstop=0                     : longblob
hordiff_pvalstop=0                  : longblob

cossim_meanstop=0                   : longblob
cossim_semstop=0                    : longblob
cossim_meanshufstop=0               : longblob
cossim_semshufstop=0                : longblob
cossimgrouped_stop=0                : longblob

varexp_meanstop=0                   : longblob
varexp_semstop=0                    : longblob
varexp_meanshufstop=0               : longblob
varexp_semshufstop=0                : longblob
varexpgrouped_stop=0                : longblob
varexpbound_stop=0                  : longblob
sqerr_stop=0                        : longblob
var_pred_stop=0                     : longblob
var_true_stop=0                     : longblob
%}

classdef StatsEye < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            stimulusprs = fetch(firefly.StimulusParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            %% all attempted trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "all"','*');
            stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'all';
            self.insert(key);
            fprintf('Populated eyemovement stats across all trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% density 0.005 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'floor_den=0.005','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "density1"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density1';
                self.insert(key);
                fprintf('Populated eyemovement stats across density 0.005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across density 0.005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'floor_den=0.001','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "density2"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);                
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density2';
                self.insert(key);
                fprintf('Populated eyemovement stats across density 0.001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across density 0.001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.0005 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'floor_den=0.0005','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "density3"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density3';
                self.insert(key);
                fprintf('Populated eyemovement stats across density 0.0005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across density 0.0005 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.0001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'floor_den=0.0001','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "density4"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density4';
                self.insert(key);
                fprintf('Populated eyemovement stats across density 0.0001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across density 0.0001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% density 0.000001 trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'floor_den=0.000001','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "density5"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'density5';
                self.insert(key);
                fprintf('Populated eyemovement stats across density 0.000001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across density 0.000001 trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 1x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'v_gain=1','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "gain1"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain1';
                self.insert(key);
                fprintf('Populated eyemovement stats across gain 1x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across gain 1x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 1.5x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'v_gain=1.5','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "gain2"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain2';
                self.insert(key);
                fprintf('Populated eyemovement stats across gain 1.5x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across gain 1.5x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% gain 2x trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'v_gain=2','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "gain3"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'gain3';
                self.insert(key);
                fprintf('Populated eyemovement stats across gain 2x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across gain 2x trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% firefly off trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'firefly_on=0','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "fireflyoff"','*');
            stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'fireflyoff';
            self.insert(key);
            fprintf('Populated eyemovement stats across invisible firefly trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% firefly on trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'firefly_on=1','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "fireflyon"','*');
            stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'fireflyon';
            self.insert(key);
            fprintf('Populated eyemovement stats across visible firefly trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% unrewarded trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'rewarded=0','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "unrewarded"','*');
            stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'unrewarded';
            self.insert(key);
            fprintf('Populated eyemovement stats across unrewarded trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% rewarded trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'rewarded=1','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "rewarded"','*');
            stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            key.trial_type = 'rewarded';
            self.insert(key);
            fprintf('Populated eyemovement stats across rewarded trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
            %% unperturbed trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'perturbed=0','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "unperturbed"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'unperturbed';
                self.insert(key);
                fprintf('Populated eyemovement stats across unperturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across unperturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
            %% perturbed trials
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'perturbed=1','*');
            stats = fetch(firefly.StatsBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] & 'trial_type = "perturbed"','*');
            if numel(trials) >= analysisprs.mintrialsforstats
                stats = AnalyseEyemovement(trials,stats,analysisprs,stimulusprs);
                selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
                for i=1:length(selfAttributes)
                    if any(strcmpi(fields(stats),selfAttributes{i}))
                        key.(selfAttributes{i}) = stats.(selfAttributes{i});
                    end
                end
                key.trial_type = 'perturbed';
                self.insert(key);
                fprintf('Populated eyemovement stats across perturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            else
                fprintf('Not enough trials to populate eyemovement stats across perturbed trials for experiment done on %s with monkey %s \n',...
                    key.session_date,key.monk_name);
            end
        end
    end
end