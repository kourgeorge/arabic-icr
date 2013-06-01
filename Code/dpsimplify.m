function [ps,ix] = dpsimplify (p,tol)
%MYDSIMPLIFY Simplify a sequence given the tolerance parameter using the
%Ramer–Douglas–Peucker simplification algorithm.
%   Detailed explanation goes here

ixe     = size(p,1);
ixs     = 1;

% logical vector for the vertices to be retained
I   = true(ixe,1);

% call recursive function
p   = mydsimplifyrec(p,tol,ixs,ixe);
ps  = p(I,:);
if nargout == 2;
    ix  = find(I);
end
% _________________________________________________________
function p  = mydsimplifyrec(p,tol,ixs,ixe)
pt = bsxfun(@minus,p(ixs+1:ixe,:),p(ixs,:));

% end point
a = pt(end,:)';

beta = (a' * pt')./(a'*a);
b    = pt-bsxfun(@times,beta,a)';

d    = hypot(b(:,1),b(:,2));

% identify maximum distance and get the linear index of its location
[dmax,ixc] = max(d);
ixc  = ixs + ixc;

% if the maximum distance is smaller than the tolerance remove vertices
% between ixs and ixe
if dmax <= tol;
    if ixs ~= ixe-1;
        I(ixs+1:ixe-1) = false;
    end
    % if not, call simplifyrec for the segments between ixs and ixc (ixc
    % and ixe)
else
    p   = mydsimplifyrec(p,tol,ixs,ixc);
    p   = mydsimplifyrec(p,tol,ixc,ixe);
    
end
end
end


