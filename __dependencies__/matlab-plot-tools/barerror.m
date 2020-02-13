function barerror(data, varargin)
% function barerror(data, varargin)
% Plots bars for each row with error bars computed as range of data

% USAGE:
% Pass in matrix of data arranged with repeated measurements in columns,
% with rows containing individual types
%           -OR-
% A cell array of these data matrices, for plotting multiple adjacent bars with
% unique colors.
%
% The rest of the stuff it expects goes as follows:
% 1) barlabels:  cell array of strings to label the ROWS of data
% 2) grouplabels: cell array of strings to label the matrix/matrices of data 
% 3) colors: the sequence of color characters for labeling bars
%
% Jonathan Scholz,  GaTech, October 15 2009

% Example:
% data = {diag(sin(1:5)) * rand(5,5),diag(cos(1:5)) * rand(5,5)};
% barerror(data,{'Trial 1','Trial 2','Trial 3','Trial 4','Trial 5'},{'Sin','Cos'});

if iscell(data)
    ntypes = size(data,2);
    nbars = length(data{1});
else
    ntypes = 1;
    nbars = length(data);
end

if nargin >=2
    method = varargin{1};
else
    method = 1; % default to range-based error bars
end

if nargin >= 3
    barlabels = varargin{2};
else
    for i=1:nbars
        barlabels{i}=sprintf('%d',i);
    end
end

if nargin >= 4
    grouplabels = varargin{3};
else
        for i=1:nbars
        grouplabels{i}=sprintf('Class %d',i-1);
    end
end

if nargin >= 5
    colors = varargin{4};
else
    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'];
end

clf;
hold on;
barhandles=[];
for i=1:ntypes
    if iscell(data)
        d=data{i};
    else
        d=data;
    end

    % data stuff
    means = mean(d')';
    mins = min(d')';
    maxs = max(d')';
    if method == 1
        L = means-mins;
        U = means-maxs;
    else
        Z = 1.96; % for 0.95 CI
        stdev = std(d'); % std returns stdev of COLUMNS
        sem = stdev/sqrt(length(d(1,:)));
        L = - Z*sem';
        U = Z*sem';
    end

    % plot control stuff
    xrange = 1:nbars;
    offsets = fix(-ntypes/2):fix(ntypes/2);
    smooshFactor = 0.8;
    barOrigins = xrange+smooshFactor*(offsets(i)/ntypes);
    barwidth = smooshFactor/ntypes;

    b = bar(barOrigins, means, barwidth, colors(mod(i,length(colors))));
    barhandles=[barhandles b]; % is there a better way to fix this???
    errorbar(barOrigins,means,L,U,'LineStyle','none','color','black');
end

title_str = 'title';
xlabel_str = 'x axis';
ylabel_str = 'y axis';

set(gca,'XTickLabel',barlabels);
set(gca,'FontSize',16)

title(title_str);
h = get(gca, 'title');
set(h,'FontSize',16);

xlabel(xlabel_str);
h = get(gca, 'xlabel');
set(h,'FontSize',24);

ylabel(ylabel_str);
h = get(gca, 'ylabel');
set(h,'FontSize',24);

legend(barhandles, grouplabels);
