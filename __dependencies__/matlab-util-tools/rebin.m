function x2 = rebin(t,x,nbins)

t2 = linspace(t(1),t(end),nbins+1);
for i=1:length(t2)-1
    x2(i) = nanmean(x(t>=t2(i) & t<t2(i+1)));
end
t2 = t2(1:end-1)+mean(diff(t2));