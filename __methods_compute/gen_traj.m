function [mu_xt, mu_yt, mu_phit] = gen_traj(mu_w, mu_v, ts, startpos)

% generates trajectory given w,v,x,y
% linear speed mean (mu_v)
% angular speed mean (mu_w)
% initial positions (x0/y0)
% outputs: mu_xt, mu_yt, mu_x, mu_y 

% if v<0, then sign of w needs to be inverted because of Jian.
mu_w = mu_w.*sign(mu_v);

% sampling rate
dt = median(diff(ts)); % needs to match downsampling rate

% select first dimension
nt = length(mu_v);

% initialize
mu_xt = zeros(nt,1);
mu_yt = zeros(nt,1);
mu_phit = zeros(nt,1);
mu_xt(1) = startpos(1);
mu_yt(1) = startpos(2);
mu_phit(1) = startpos(3);

% construct trajectory
for j=1:nt
    vt_x = mu_v(j).*sin(mu_phit(j));
    vt_y = mu_v(j).*cos(mu_phit(j));
    mu_xt(j+1) = mu_xt(j) + vt_x*dt;
    mu_yt(j+1) = mu_yt(j) + vt_y*dt;
    mu_phit(j+1) = mu_phit(j) + (mu_w(j)*pi/180)*dt;
    mu_phit(j+1) = (mu_phit(j+1)>-pi & mu_phit(j+1)<=pi).*mu_phit(j+1) + ...
        (mu_phit(j+1)>pi).*(mu_phit(j+1) - 2*pi) + ...
            (mu_phit(j+1)<=-pi).*(mu_phit(j+1) + 2*pi);
end

%truncate to original length
mu_xt = mu_xt(1:nt);
mu_yt = mu_yt(1:nt);
mu_phit = mu_phit(1:nt); mu_phit = mu_phit*180/pi; % convert to degrees