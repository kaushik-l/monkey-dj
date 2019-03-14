function [chdata,chnames] = PrepareSMRData(filepath,prs)

cd(filepath);

file_smr=dir('*.smr');
nsmrfiles = length(file_smr);
for j=1:nsmrfiles
    data=ImportSMR(file_smr(j).name);
    %% check channel headers
    nch = length(data);
    ch_title = cell(1,nch);
    hdr = {data.hdr};
    for i=1:nch
        if ~isempty(hdr{i})
            ch_title{i} = hdr{i}.title;
        else
            ch_title{i} = 'nan';
        end
    end
    
    %% channel titles
    chno.yle = find(strcmp(ch_title,'LDy')); chno.zle = find(strcmp(ch_title,'LDz'));
    chno.yre = find(strcmp(ch_title,'RDy')); chno.zre = find(strcmp(ch_title,'RDz'));
    chno.xfp = find(strcmp(ch_title,'FireflyX')); chno.yfp = find(strcmp(ch_title,'FireflyY'));
    chno.xmp = find(strcmp(ch_title,'MonkeyX')); chno.ymp = find(strcmp(ch_title,'MonkeyY'));
    chno.v = find(strcmp(ch_title,'ForwardV')); chno.w = find(strcmp(ch_title,'AngularV'));
    
    %% scale
    scaling.yle = data(chno.yle).hdr.adc.Scale; offset.yle = data(chno.yle).hdr.adc.DC;
    scaling.yre = data(chno.yre).hdr.adc.Scale; offset.yre = data(chno.yre).hdr.adc.DC;
    scaling.zle = data(chno.zle).hdr.adc.Scale; offset.zle = data(chno.zle).hdr.adc.DC;
    scaling.zre = data(chno.zre).hdr.adc.Scale; offset.zre = data(chno.zre).hdr.adc.DC;
    scaling.xfp = data(chno.xfp).hdr.adc.Scale; offset.xfp = data(chno.xfp).hdr.adc.DC;
    scaling.yfp = -data(chno.yfp).hdr.adc.Scale; offset.yfp = -data(chno.yfp).hdr.adc.DC;
    scaling.xmp = data(chno.xmp).hdr.adc.Scale; offset.xmp = data(chno.xmp).hdr.adc.DC;
    scaling.ymp = -data(chno.ymp).hdr.adc.Scale; offset.ymp = -data(chno.ymp).hdr.adc.DC;
    scaling.v = data(chno.v).hdr.adc.Scale; offset.v = data(chno.v).hdr.adc.DC;
    scaling.w = data(chno.w).hdr.adc.Scale; offset.w = data(chno.w).hdr.adc.DC;   
    
    %% define filter
    sig = prs.filtwidth; %filter width
    sz = prs.filtsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered
    
    %% load relevant channels
    chnames = fieldnames(chno); MAX_LENGTH = inf; dt = [];
    for i=1:length(chnames)
        ch.(chnames{i}) = double(data(chno.(chnames{i})).imp.adc)*scaling.(chnames{i}) + offset.(chnames{i});
        dt = [dt prod(data(chno.(chnames{i})).hdr.adc.SampleInterval)];
        MAX_LENGTH = min(length(ch.(chnames{i})),MAX_LENGTH);
    end
    if length(unique(dt))==1
        dt = dt(1);
    else
        error('channels must all have identical sampling rates');
    end
    
    %% filter position and velocity channels
    for i=1:length(chnames)
        if ~any(strcmp(chnames{i},{'yle','yre','zle','zre'}))
            ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
        end
    end
    ch.yle = ch.yle(1:MAX_LENGTH);
    ch.yre = ch.yre(1:MAX_LENGTH);
    ch.zle = ch.zle(1:MAX_LENGTH);
    ch.zre = ch.zre(1:MAX_LENGTH);
    %ch.v = ch.v(1:MAX_LENGTH);
    %ch.w = ch.w(1:MAX_LENGTH);
    
    %% create data
    chdata{j} = struct2array(ch)';
    
    %% rename the channels so chnames contains {'lefteye_horpos','lefteye_verpos',...}
    lefteye_horpos=ch.yle;
    lefteye_verpos=ch.zle;
    righteye_horpos=ch.yre;
    righteye_verpos=ch.zre;
    joy_linvel=ch.v;           
    joy_angvel=ch.w;             
end