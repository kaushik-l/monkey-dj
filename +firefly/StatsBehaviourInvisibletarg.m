%{
# Behaviour across firefly_OFF trials (bias, variance, ROC)
-> firefly.Behaviour
-> firefly.Event
-> firefly.AnalysisParam
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

corr_r=0                    : double
pval_r=0                    : double
corr_th=0                   : double
pval_th=0                   : double

roc_rewardwin=0             : blob
roc_pcorrect=0              : blob
roc_pcorrect_shuffled=0     : blob
auc=0                       : double

spatial_x=0                 : longblob
spatial_y=0                 : longblob
spatial_xerr=0              : longblob
spatial_yerr=0              : longblob
spatial_xstd=0              : longblob
spatial_ystd=0              : longblob
%}

classdef StatsBehaviourInvisibletarg < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            trials = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                'attempted=1' & 'firefly_on=0','*');
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
            fprintf('Populated behavioural stats across invisible firefly trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end