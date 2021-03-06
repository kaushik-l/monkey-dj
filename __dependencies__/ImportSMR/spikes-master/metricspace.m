function [mout, vals]=metricspace(data,sv,family)
global X

hwait=waitbar(0,'Metric Space data loading');
pos=get(hwait,'Position');
set(hwait,'Position',[0 0 pos(3) pos(4)]);
opts.clustering_exponent = -2;
opts.unoccupied_bins_strategy = 0;
if ~exist('family','var')
	family = 0; %spike family IIRC? 1=Interval
end
opts.metric_family = family;
opts.parallel = 1;
opts.possible_words = 'unique';
opts.entropy_estimation_method = {'plugin','tpmc','jack'};
%opts.tpmc_possible_words_strategy = 0;
opts.shift_cost = [0 2.^(-2:10)];
%margins = 0.05;

if isfield(data, 'cell1raws') && ~isfield(data,'zipload')
	if ~exist('sv','var');	sv = []; end
	data.matrixtitle = data.cell1.matrixtitle;
end

X=makemetric(data,sv);

opts.start_time = min([X.categories(1).trials(:).start_time]);
opts.end_time = max([X.categories(1).trials(:).end_time]);

if isfield(sv,'mint') && sv.mint/1000 > opts.start_time
	opts.start_time = sv.mint/1000;
end

if isfield(sv,'maxt') && sv.maxt/1000 < opts.end_time
	opts.end_time = sv.maxt/1000;
end

waitbar(0.1,hwait,'Plotting Rasters');
clear out out_unshuf shuf out_unjk jk;
clear info_plugin info_tpmc info_jack info_unshuf info_unjk;
clear temp_info_shuf temp_info_jk;

h=figure;
set(h,'Color',[1 1 1]);
figpos(1,[1200 1200]);
set(h,'name','Metric Space Analysis');
p = panel(h);
p.margintop = 15;
p.fontsize = 12;
p.pack(2,2);

% h=figure;
% figpos(1,[],2);

%subplot_tight(2,2,1,margins,'Parent',h);
%set(gca,'FontName','georgia','FontSize',11);
p(1,1).select();
staraster(X,[opts.start_time opts.end_time]);
p(1,1).title('Raster plot');
grid on
box on

%%% Simple analysis
drawnow;
waitbar(0.2,hwait,'Performing Metric space measurement');
[out,opts_used] = metric(X,opts);

for q_idx=1:length(opts.shift_cost)
  info_plugin(q_idx) = out(q_idx).table.information(1).value;
  info_tpmc(q_idx) = out(q_idx).table.information(2).value;
  info_jack(q_idx) = out(q_idx).table.information(3).value;
end

drawnow
waitbar(0.4,hwait,'Plotting matrix and Information');

%subplot_tight(2,2,2,margins,'Parent',h);
p(1,2).select();
p(1,2).hold('on')
%set(gca,'FontName','georgia','FontSize',11);
[max_info,max_info_idx]=max(info_plugin);
imagesc(out(max_info_idx).d);
axis tight
grid on
box on
p(1,2).xlabel('Spike train index');
p(1,2).ylabel('Spike train index');
p(1,2).title('Distance matrix at maximum information');

%subplot_tight(2,2,3,margins,'Parent',h);
%set(gca,'FontName','georgia','FontSize',11);
p(2,1).select();
p(2,1).hold('on')
plot(1:length(opts.shift_cost),info_plugin);
plot(1:length(opts.shift_cost),info_tpmc,'--');
plot(1:length(opts.shift_cost),info_jack,'-.');
p(2,1).hold('off')
grid on
box on
set(gca,'xtick',1:length(opts.shift_cost));
set(gca,'xticklabel',opts.shift_cost);
set(gca,'xlim',[1 length(opts.shift_cost)]);
set(gca,'ylim',[-0.5 max(info_plugin)+1]);
xlabel('Temporal precision (1/sec)');
ylabel('Information (bits)');
legend('No correction','TPMC correction','Jackknife correction',...
       'location','best');

drawnow
waitbar(0.5,hwait,'Performing Shuffle');
%%% Shuffling

opts.entropy_estimation_method = {'plugin'};
rand('state',0);
S=10;
[out_unshuf,shuf,opts_used] = metric_shuf(X,opts,S);
shuf = shuf';
for q_idx=1:length(opts.shift_cost)
  info_unshuf(q_idx)= out_unshuf(q_idx).table.information.value;
  for s=1:S
    temp_info_shuf(s,q_idx) = shuf(s,q_idx).table.information.value;
  end
end
info_shuf = mean(temp_info_shuf,1);
info_shuf_std = std(temp_info_shuf,[],1);
info_shuf_sem = sqrt((S-1)*var(temp_info_shuf,1,1));

waitbar(0.7,hwait,'Performing JackKnife');
%%% leave-one-out Jackknife 
[out_unjk,jk,opts_used] = metric_jack(X,opts);
waitbar(0.9,hwait,'Final Calculations');
P_total = size(jk,1);
temp_info_jk = zeros(P_total,length(opts.shift_cost));
for q_idx=1:length(opts.shift_cost)
  info_unjk(q_idx)= out_unjk(q_idx).table.information.value;
  for pp=1:P_total
    temp_info_jk(pp,q_idx) = jk(pp,q_idx).table.information.value;
  end
end
info_jk_std = std(temp_info_jk,[],1);
info_jk_sem = sqrt((P_total-1)*var(temp_info_jk,1,1));

%%% Plot results

%subplot_tight(2,2,4,margins,'Parent',h);
%set(gca,'FontName','georgia','FontSize',11);
p(2,2).select();
areabar(1:length(opts.shift_cost),info_unjk,info_jk_sem,[.7 .7 .7],0.5,'k-o');
hold on;
areabar(1:length(opts.shift_cost),info_shuf,2*info_shuf_std,[.7 .5 .5],0.5,'k-o');
hold off;
set(gca,'xtick',1:length(opts.shift_cost));
set(gca,'xticklabel',opts.shift_cost);
set(gca,'xlim',[1 length(opts.shift_cost)]);
%set(gca,'ylim',[-0.5 3.5]);
xlabel('Temporal precision (1/sec)');
ylabel('Information (bits)');
legend('Original data (\pmSE via Jackknife)','Shuffled data (\pm2 SD)',...
       'location','best');

if family==0
	family='\fontname{georgia}\fontsize{12}D^{spike}';
else
	family='\fontname{georgia}\fontsize{12}D^{interval}';
end

p(1,1).title([family '\rightarrow' data.matrixtitle]);
close(hwait);

mout.X=X;
mout.shift_cost=opts.shift_cost;
mout.info_plugin=info_plugin;
mout.info_tpmc=info_tpmc;
mout.info_jack=info_jack;
mout.info_unjk=info_unjk;
mout.info_jk_sem=info_jk_sem;
mout.info_shuf=info_shuf;
mout.info_shuf_std=info_shuf_std;
mout.title=data.matrixtitle;

x=[opts.shift_cost;info_unjk;info_jk_sem;info_shuf;info_shuf_std];
midx=find(x(2,:)==max(x(2,:)), 1, 'last' ); %max information value
idx=[];
for i=1:length(opts.shift_cost)
	unjk=x(2,i);
	if unjk>(x(4,i)+(x(5,i)*2))
		idx=[idx i];
	end
end
idx=max(idx);
if isempty(idx) %nothing significantly over shuffle
	idx=1;
end
vals=[x(1,1) x(2,1) x(3,1) x(1,idx) x(2,idx) x(3,idx) x(1,midx) x(2,midx) x(3,midx)];
assignin('base','vals',vals);
assignin('base','mout',mout);
clipboard('Copy',sprintf('%.3g\t',vals));
	

