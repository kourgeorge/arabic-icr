function [label, energy, index] = kmedoidsL1(X,k,Replications)
% X: d x n data matrix
% k: number of cluster

energy = [];
for i=1:Replications
    [label_i, energy_i, index_i] = kmedoids_inner(X,k);
    res(i).label = label_i;
    energy(i) = energy_i; 
    res(i).index = index_i;
end
[~,ind] = min (energy);

label = res(ind).label;
index = res(ind).index;


function [label, energy, index] = kmedoids_inner(X,k)
D = mandist(X); 
n = size(X,2);
[~, label] = min(D(randsample(n,k),:));
last = 0;
while any(label ~= last)
    [~, index] = min(D*sparse(1:n,label,1,n,k,n));
    last = label;
    [val, label] = min(D(index,:),[],1);
end
energy = sum(val);
