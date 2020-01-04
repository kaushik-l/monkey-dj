function [paramnames,paramvals] = PrepareLogData(filepath)

cd(filepath);

flist_log=dir('*.log'); 
nblocks = length(flist_log);

fieldvalues = @(MyStruct)(cellfun(@(fieldName)(double(MyStruct.(fieldName))),fieldnames(MyStruct)));
for j=1:nblocks
    trials{j} = AddLOGData(flist_log(j).name); 
    paramnames{j} = [fieldnames(trials{j}(1).prs) ; fieldnames(trials{j}(1).logical)];
    paramvals{j} = cell2mat(arrayfun(@(k) [fieldvalues(trials{j}(k).prs) ; fieldvalues(trials{j}(k).logical)],...
        1:numel(trials{j}),'UniformOutput',false));
    %% rename the paramnames to match with attributes of Stimulus table
    paramnames{j}{strcmp(paramnames{j},'floordensity')} = 'floor_den';
    paramnames{j}{strcmp(paramnames{j},'ptb_linear')} = 'ptb_linvel';
    paramnames{j}{strcmp(paramnames{j},'ptb_angular')} = 'ptb_angvel';
    paramnames{j}{strcmp(paramnames{j},'ptb_delay')} = 'ptb_delay';
    paramnames{j}{strcmp(paramnames{j},'intertrial_interval')} = 'intertrial_int';
    paramnames{j}{strcmp(paramnames{j},'stop_duration')} = 'stop2feedback_int';
    paramnames{j}{strcmp(paramnames{j},'landmark_distance')} = 'landmark_lin';
    paramnames{j}{strcmp(paramnames{j},'landmark_angle')} = 'landmark_ang';
    paramnames{j}{strcmp(paramnames{j},'firefly_fullON')} = 'firefly_on';
    paramnames{j}{strcmp(paramnames{j},'landmark_fixedground')} = 'landmark_ground';
    paramnames{j}{strcmp(paramnames{j},'v_max')} = 'v_max';
    paramnames{j}{strcmp(paramnames{j},'w_max')} = 'w_max';
    paramnames{j}{strcmp(paramnames{j},'replay')} = 'replay';
    paramnames{j}{strcmp(paramnames{j},'reward_duration')} = 'reward_duration';
end