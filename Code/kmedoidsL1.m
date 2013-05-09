function [label, energy, index] = kmedoidsL1(X,k)
% X: d x n data matrix
% k: number of cluster

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
