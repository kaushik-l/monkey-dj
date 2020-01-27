function peakresp = EvaluatePeakresponse(spiketimes,timepoints,binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats)

preevent_nanflag = false;
postevent_nanflag = false;
ntrials = length(spiketimes);
if ntrials<mintrialsforstats % not enough trials for stats
    preevent_nanflag = true;
    postevent_nanflag = true;
else
    nt = numel(timepoints);
%     rate = zeros(nbootstraps,nt);
    
    %% obtain bootstrapped estimate of spike rates
    for i=1:nbootstraps
        trlindx = randsample(1:ntrials,ntrials,true); % sample with replacement
        spiketimes2 = spiketimes(trlindx);
        [rate(i,:),ts] = Spiketimes2Rate(spiketimes2,timepoints,binwidth);
    end
    rate_mu = mean(rate);
    
    %% detect peaks
    [peakVals,peakLocs]=findpeaks(rate_mu,'MinPeakProminence',minpeakprominence,'SortStr','descend'); % peaks > nearest_valley + minpeakprominence
    if length(peakLocs)>4 % consider only the four most prominent peaks
        peakVals = peakVals(1:4);
        peakLocs = peakLocs(1:4);
    end
    
    %% assess significance of peak response
    % define time-window to select peaks
    [~,preeventLoc] = min(abs(ts-peaktimewindow(1)));
    [~,eventLoc] = min(abs(ts-0));
    [~,posteventLoc] = min(abs(ts-peaktimewindow(2)));
    % evaluate the largest pre-event peak
    preeventpeakLocs = peakLocs(peakLocs>=preeventLoc & peakLocs<eventLoc);
    preeventpeakVals = peakVals(peakLocs>=preeventLoc & peakLocs<eventLoc);
    if ~isempty(preeventpeakLocs)
        [~,indx] = sort(preeventpeakVals,'descend');
        preevent.rate = preeventpeakVals(indx(1));
        preevent.time = ts(preeventpeakLocs(indx(1)));
        [~,preevent.pval] = ttest2(rate(:),rate(:,preeventpeakLocs(indx(1)))); % is P(r|t=t_preeventpeakindx) different from P(r)? need not be true!
    else
        preevent_nanflag = true; % not significant
    end
    % evaluate the largest post-event peak
    posteventpeakLocs = peakLocs(peakLocs>=eventLoc & peakLocs<posteventLoc);
    posteventpeakVals = peakVals(peakLocs>=eventLoc & peakLocs<posteventLoc);
    if ~isempty(posteventpeakLocs)
        [~,indx] = sort(posteventpeakVals,'descend');
        postevent.rate = posteventpeakVals(indx(1));
        postevent.time = ts(posteventpeakLocs(indx(1)));
        [~,postevent.pval] = ttest2(rate(:),rate(:,posteventpeakLocs(indx(1)))); % is P(r|t=t_posteventpeakindx) different from P(r)? need not be true!
    else
        postevent_nanflag = true; % not significant
    end
end

%% fill with nans if not significant
if preevent_nanflag
    preevent.pval = nan;
    preevent.rate = nan;
    preevent.time = nan;
end
if postevent_nanflag
    postevent.pval = nan;
    postevent.rate = nan;
    postevent.time = nan;
end

%% return result
peakresp.preevent = preevent;
peakresp.postevent = postevent;