%{
# Behaviour across all trials (bias, variance, ROC)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
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

classdef StatsBehaviourAll < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1','*');
            stimulusprs = fetch(firefly.StimulusParam,'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            stats = AnalyseBehaviour(trials,analysisprs,stimulusprs);
            
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            self.insert(key);
            fprintf('Populated behavioural stats across all trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end