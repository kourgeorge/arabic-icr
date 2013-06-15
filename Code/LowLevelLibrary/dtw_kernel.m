function kval = dtw_kernel(u,v)%,sigma,varargin)
%RDTW_KERNEL radial basis function kernel for SVM functions

% Copyright 2004-2008 The MathWorks, Inc.
if nargin < 3
    sigma = 1;
else
   if ~isscalar(sigma)
        error('Bioinfo:rbfkernel:SigmaNotScalar',...
            'Sigma must be a scalar.');
    end
    if sigma == 0
        error('Bioinfo:rbfkernel:SigmaZero',...
            'Sigma must be non-zero.');
    end
end
v = v';
kval = zeros(size(u,1),size(v,2));
for i=1:size(u,1)
    for j=i:size(v,2)
        %[p,q,D,Diff,WarpingPath] = Cons_DTW(u(i,:)',v(:,j), 5);
        %Diff = Cons_DTW(u(i,:)',v(:,j), 3);
        kval(i,j) = exp(-(1/(2*sigma^2))*Diff);
        kval(j,i) = kval(i,j);
    end
end
        
% 
% kval = exp(-(1/(2*sigma^2))*(repmat(sqrt(sum(u.^2,2).^2),1,size(v,1))...
%     -2*(u*v')+repmat(sqrt(sum(v.^2,2)'.^2),size(u,1),1)));