function [values,features] = PrepareLogData(filepath)

cd(filepath);

file_log=dir('*.log');
nlogfiles = length(file_log);

for j=1:nlogfiles, trials{j} = AddLOGData(file_log(j).name); end
trials = cell2mat(trials);

trialprs = [trials.prs];
values = [[trialprs.floordensity] ; [trialprs.ptb_linear]; [trialprs.ptb_angular]];
features = {'floor_den', 'ptb_linvel', 'ptb_angvel'};