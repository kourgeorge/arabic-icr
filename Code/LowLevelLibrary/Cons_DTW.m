function Diff = Cons_DTW( X1,X2,r )
%CONS_DTW Summary of this function goes here
%   Detailed explanation goes here

[L1,~] = size(X1);
[L2,~] = size(X2);

Mx = mean(X1);
MRep = repmat(Mx,L1,1);
X1= X1 - MRep ;

Mx = mean(X2);
MRep = repmat(Mx,L2,1);
X2= X2 - MRep ;

D = NaN(L1,L2);
D(1,1) = 0;
for i = 2:L1
    for j=max(2, i-r):min(L2, i+r)
        Cost = ComputeDist(X2(j,:),X1(i,:));
        [dmax] = min([D(i, j-1), D(i-1, j), D(i-1, j-1)]);
        D(i,j) = dmax+Cost;
    end
end

Diff = D(L1,L2)/((L1+L2)/2);

