%{
# Beta LFP across all trials (evoked potential, spectrum, spectrogram)
-> firefly.Lfp
-> firefly.Event
-> firefly.AnalysisParam
---
# add additional attributes
mta_amplitude                   : longblob
mta_power                       : longblob
mta_time                        : longblob

fta_amplitude                   : longblob
fta_power                       : longblob
fta_time                        : longblob

sta_amplitude                   : longblob
sta_power                       : longblob
sta_time                        : longblob

rta_amplitude                   : longblob
rta_power                       : longblob
rta_time                        : longblob

spectrum_psd                    : longblob
spectrum_freq                   : longblob
tfspectrum_mtpsd                : longblob
tfspectrum_ftpsd                : longblob
tfspectrum_stpsd                : longblob
tfspectrum_rtpsd                : longblob
tfspectrum_time                 : longblob
tfspectrum_freq                 : longblob

tuning_v                        : longblob
tuning_w                        : longblob
tuning_vw                       : longblob
tuning_vfreq                    : longblob
tuning_wfreq                    : longblob
tuning_vwfreq                   : longblob
pval_vfreq                      : longblob
pval_wfreq                      : longblob
tuning_vpower                   : longblob
tuning_wpower                   : longblob
tuning_vwpower                  : longblob
pval_vpower                     : longblob
pval_wpower                     : longblob
%}

classdef StatsLfpbetaAll < dj.Computed
    methods(Access=protected)
        function makeTuples(self,key)
            trialslfp = fetch(firefly.TrialLfpbeta &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'] &...
                ['channel_id = ' num2str(key.channel_id)],'*');            
            analysisprs = fetch(firefly.AnalysisParam,'*');
            
            % select attempted trials
            trialsbehv = fetch(firefly.TrialBehaviour &...
                ['session_id = ' num2str(key.session_id)] & ['monk_name = ' '"' key.monk_name '"'],'*');
            attempted = logical([trialsbehv.attempted]); 
            trialslfp = trialslfp(attempted); trialsbehv = trialsbehv(attempted);
            
            % analyse
            stats = AnalyseLfp(trialslfp,trialsbehv,analysisprs);
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