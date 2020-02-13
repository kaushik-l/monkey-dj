%{
# Population of neurons (pca, canoncorr)
-> firefly.NeuronPopulation
-> firefly.AnalysisParam
---
# add additional attributes
pca_loadings                    : longblob
pca_variance                    : longblob
pca_score                       : longblob

%}

classdef StatsNeuronPopulationAll < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            population = fetch(firefly.NeuronPopulation &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            trialsbehv = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            
            % select attempted trials
            attempted = logical([trialsbehv.attempted]); 
            population = population(attempted); 
            trialsbehv = trialsbehv(attempted); 
            
            % analyse
            stats = AnalysePopulation(population,trialsbehv,analysisprs);
            selfAttributes = {self.header.attributes.name}; % think self.header.attributes.name is internal to dj
            for i=1:length(selfAttributes)
                if any(strcmpi(fields(stats),selfAttributes{i}))
                    key.(selfAttributes{i}) = stats.(selfAttributes{i});
                end
            end
            self.insert(key);
            fprintf('Populated lfp stats across all trials for experiment done on %s with monkey %s \n',...
                key.session_date,key.monk_name);
        end
    end
end