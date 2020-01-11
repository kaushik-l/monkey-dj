function sMarkers = RemoveShortEpochs(data, minepochduration, dt)

minepochsamples = round(minepochduration/dt);
diffdata = diff(data);
risingEdges = find(diffdata == 1);
fallingEdges = find(diffdata == -1);
if ~isempty(risingEdges) && ~isempty(fallingEdges)
    if fallingEdges(1) < risingEdges(1), fallingEdges(1) = []; end
    if risingEdges(end) > fallingEdges(end), risingEdges(end) = []; end
    shortEpochIndx = (fallingEdges - risingEdges) < minepochsamples;
    risingEdges(shortEpochIndx) = [];
    fallingEdges(shortEpochIndx) = [];
    sMarkers = [risingEdges(:) fallingEdges(:)]*dt;
else
    sMarkers = [];
end