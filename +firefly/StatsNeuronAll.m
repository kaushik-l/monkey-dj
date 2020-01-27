%{
# Neuron across all trials (tunings, psth, GAM fits, spike-LFP)
-> firefly.Neuron
-> firefly.Event
-> firefly.AnalysisParam
---
# add additional attributes
mta_rate                        : longblob
mta_time                        : longblob
mta_peakrate                    : blob
mta_peaktime                    : blob
mta_peakpval                    : blob

fta_rate                        : longblob
fta_time                        : longblob
fta_peakrate                    : blob
fta_peaktime                    : blob
fta_peakpval                    : blob

sta_rate                        : longblob
sta_time                        : longblob
sta_peakrate                    : blob
sta_peaktime                    : blob
sta_peakpval                    : blob

rta_rate                        : longblob
rta_time                        : longblob
rta_peakrate                    : blob
rta_peaktime                    : blob
rta_peakpval                    : blob

tuning_v                        : longblob
tuning_w                        : longblob
tuning_d                        : longblob
tuning_phi                      : longblob
tuning_r                        : longblob
tuning_theta                    : longblob
tuning_xy                       : longblob
tuning_eh                       : longblob
tuning_ev                       : longblob
tuning_evh                      : longblob
tuning_phase                    : longblob
tuning_vrate                    : longblob
tuning_wrate                    : longblob
tuning_drate                    : longblob
tuning_phirate                  : longblob
tuning_rrate                    : longblob
tuning_thetarate                : longblob
tuning_xyrate                   : longblob
tuning_ehrate                   : longblob
tuning_evrate                   : longblob
tuning_evhrate                  : longblob
tuning_phaserate                : longblob
tuning_vpval                    : longblob
tuning_wpval                    : longblob
tuning_dpval                    : longblob
tuning_phipval                  : longblob
tuning_rpval                    : longblob
tuning_thetapval                : longblob
tuning_ehpval                   : longblob
tuning_evpval                   : longblob
tuning_phasepval                : longblob

spiketrig_time                  : longblob
spiketrig_avg                   : longblob
spikefield_freq                 : longblob
spikefield_coh                  : longblob

%}

classdef StatsNeuronAll < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            trialsneuron = fetch(firefly.TrialNeuron &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                ['cluster_id = ' num2str(key.cluster_id)],'*');
            neuron = fetch(firefly.Neuron &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                ['cluster_id = ' num2str(key.cluster_id)],'*');
            analysisprs = fetch(firefly.AnalysisParam,'*');
            trialslfp = fetch(firefly.TrialLfp &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                ['channel_id = ' num2str(neuron.channel_id)],'*');
            trialsbehv = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            
            % select attempted trials
            attempted = logical([trialsbehv.attempted]); 
            trialsneuron = trialsneuron(attempted); 
            trialsbehv = trialsbehv(attempted); 
            trialslfp = trialslfp(attempted);
            
            % analyse
            stats = AnalyseUnit(trialsneuron,trialsbehv,trialslfp,analysisprs);
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