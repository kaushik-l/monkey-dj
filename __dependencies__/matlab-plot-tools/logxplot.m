function logxplot(x,y,xlims)

plot(log10(abs(x(x<0))).*sign(x(x<0)) - 2*log10(min(abs(x(x<0)))).*sign(x(x<0)), y(x<0));
plot(log10(abs(x(x>0))).*sign(x(x>0)) - 2*log10(min(abs(x(x>0)))).*sign(x(x>0)), y(x>0));
plot(0,y(x==0),'.');
set(gca,'YScale','Log');

if nargin==3
    xmin = log10(abs(xlims(1))).*sign(xlims(1)) - 2*log10(min(abs(x(x<0)))).*sign(xlims(1));
    xmax = log10(abs(xlims(2))).*sign(xlims(2)) - 2*log10(min(abs(x(x>0)))).*sign(xlims(2));
    xlim([xmin xmax]);
end