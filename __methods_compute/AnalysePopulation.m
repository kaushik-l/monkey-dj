function stats = AnalysePopulation(population,trialsbehv,analysisprs)

duration_zeropad = analysisprs.duration_zeropad;
duration_nanpad = analysisprs.duration_nanpad;
timewindow_path = [[population.neuron_tbeg]' [population.neuron_tstop]'];

Yt = cell2mat({population.spike_counts}');
Yt = SmoothSpikes(Yt,analysisprs.neuralfiltwidth);

[loading, score, vars] = pca(Yt);