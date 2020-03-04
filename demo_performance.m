data_event = fetch(firefly.Event & 'monk_name="Bruno"' & 'session_id = 41','*');
data_behv = fetch(firefly.TrialBehaviour & 'monk_name="Bruno"' & 'session_id = 41','*');

% compute distance to firefly
error_x = cellfun(@(x) x(~isnan(x)), {data_behv.dist2firefly_x},'UniformOutput',false); % remove nans
error_x = cellfun(@(x) x(end), error_x); % just get the final datapoint
error_y = cellfun(@(y) y(~isnan(y)), {data_behv.dist2firefly_y},'UniformOutput',false); % remove nans
error_y = cellfun(@(y) y(end), error_y); % just get the final datapoint
dist2firefly = sqrt(error_x.^2 + error_y.^2);

% detect attenmpted trials
indx = find([data_behv.attempted]);

% plot as a function of time
figure; plot(data_event.tbeg(indx), dist2firefly(indx),'.k');
xlabel('Time since start of session (s)'); ylabel('Distance to target (cm)');

% plot as a function of trial number
figure; plot(indx, dist2firefly(indx),'.k');
xlabel('Trial number #'); ylabel('Distance to target (cm)');