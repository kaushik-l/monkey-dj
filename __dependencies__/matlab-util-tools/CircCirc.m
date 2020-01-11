function [Xout,Yout] = CircCirc(X1,Y1,R1,X2,Y2,R2)

nobs = numel(X1);
Xout = NaN(nobs,2); Yout = NaN(nobs,2);
for k=1:nobs
    [Xout(k,:),Yout(k,:)] = circcirc(X1(k),Y1(k),R1(k),X2(k),Y2(k),R2(k));
end