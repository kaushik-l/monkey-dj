function [paramnames,paramvals] = PrepareLogData(filepath,ntrialevents)

cd(filepath);

flist_log=dir('*.log'); 
nblocks = length(flist_log);

paramvals = [];
fieldvalues = @(MyStruct)(cellfun(@(fieldName)(double(MyStruct.(fieldName))),fieldnames(MyStruct)));
for j=1:nblocks
    ntrials = ntrialevents(j);
    trials{j} = AddLOGData(flist_log(j).name);     
    vals = cell2mat(arrayfun(@(k) [fieldvalues(trials{j}(k).prs) ; fieldvalues(trials{j}(k).logical)],...
        1:numel(trials{j}),'UniformOutput',false));
    if size(vals,2) >= ntrials, paramvals = [paramvals vals(:,1:ntrials)];
    else
        nextratrials = ntrials - size(vals,2);
        paramvals = [paramvals vals vals(:,1:nextratrials)];
    end    
end

paramnames = [fieldnames(trials{1}(1).prs) ; fieldnames(trials{1}(1).logical)];
paramvals(end+1,:) = paramvals(strcmp(paramnames,'v_max'),:)/min(paramvals(strcmp(paramnames,'v_max'),:));
paramvals(end+1,:) = paramvals(strcmp(paramnames,'w_max'),:)/min(paramvals(strcmp(paramnames,'w_max'),:));
paramnames{end+1} = 'v_gain';
paramnames{end+1} = 'w_gain';

%% rename the paramnames to match with attributes of Stimulus table
paramnames{strcmp(paramnames,'floordensity')} = 'floor_den';
paramnames{strcmp(paramnames,'ptb_linear')} = 'ptb_linvel';
paramnames{strcmp(paramnames,'ptb_angular')} = 'ptb_angvel';
paramnames{strcmp(paramnames,'ptb_delay')} = 'ptb_delay';
paramnames{strcmp(paramnames,'intertrial_interval')} = 'intertrial_intv';
paramnames{strcmp(paramnames,'stop_duration')} = 'stop2feedback_intv';
paramnames{strcmp(paramnames,'landmark_distance')} = 'landmark_lin';
paramnames{strcmp(paramnames,'landmark_angle')} = 'landmark_ang';
paramnames{strcmp(paramnames,'firefly_fullON')} = 'firefly_on';
paramnames{strcmp(paramnames,'landmark_fixedground')} = 'landmark_ground';
paramnames{strcmp(paramnames,'v_max')} = 'v_max';
paramnames{strcmp(paramnames,'w_max')} = 'w_max';
paramnames{strcmp(paramnames,'replay')} = 'replay';
paramnames{strcmp(paramnames,'reward_duration')} = 'reward_duration';