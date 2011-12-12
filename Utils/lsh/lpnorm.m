function d = lpnorm(x1,x2,p,CHUNKSIZE)
% d = lpnorm(X1,X2,P)
%
% Computate distances between X1 and X2, using L_P norm (default P=1)
% Assumes that the data are in columns of x1 and x2, and 
% d(i)=dist(x1(:,i),x2(:,i).
% If x1 or x2 is a vector, it is repmat'ed appropriately - i.e., if x1 is
% a single column, d(i)=dist(x1,x2(:,i)).
%
% Returns a ROW-vector of distances.
%
% The following cases are accepted:
% x1 is a vector, x2 is a matrix (or vice versa)
% x1 is a vector, x2 is a cell array (or vice versa)
% x1 and x2 are both matrices of the same size
% x1 and x2 are cell arrays with matching cells.
%
% If x1 or x2 is a cell array, the cells are treated in order (this is useful
% if the entire x1 or x2 doesn't fit in contiguous memory).
% 
% Note: optimizes the computation for very large matrices but computing
% in chunks. Default chunk size is 100M; to change, call
% d=lpnorm(X1,X2,P,CHUNKSIZE)
%
% (C) 2007 Greg Shakhnarovich,  TTI-Chicago

if (nargin < 3)
  p=1;
end

if (nargin < 4)
  CHUNKSIZE = 40000000;
end

checkSizes(x1,x2);

% first treat the case of cell arrays
% The cell arrays are treated as a list of matrices, and the distance is
% ultimately computed using the code for matrices below.
if (iscell(x1))
  sz=0;
  for i=1:length(x1), sz=sz+size(x1{i},2); end
  d=zeros(1,sz);
  sz=0;
  for i=1:length(x1)
    % call recursively for that chunk
    if (iscell(x2))
      d(sz+1:sz+size(x1{i},2))=lpnorm(x1{i},x2{i},p);
    else
      d(sz+1:sz+size(x1{i},2))=lpnorm(x1{i},x2,p);
    end
    sz=sz+size(x1{i},2);
  end
  return;
end

if (iscell(x2))
  sz=0;
  for i=1:length(x2), sz=sz+size(x2{i},2); end
  d=zeros(1,sz);
  sz=0;
  for i=1:length(x2)
    % recursive call for that chunk
    if (iscell(x1))
      d(sz+1:sz+size(x2{i},2))=lpnorm(x1{i},x2{i},p);
    else
      d(sz+1:sz+size(x2{i},2))=lpnorm(x1,x2{i},p);
    end
    sz=sz+size(x2{i},2);
  end
  return;
end

% now treat the case of matrices. 


if (size(x1,2) == 1 & size(x2,2) > 1) % one to many
  % compute for chunks of x2, M at a time (M could be 100)
  % This is an optimization for very large data sets, for which Matlab
  % fails to allocate enough memory to do repmat.
  % at most use 100M
  M=round(CHUNKSIZE/(8*size(x1,1)));
  M=min(M,size(x2,2));
  
  d=zeros(1,size(x2,2));

  xx = double(repmat(x1,1,M));
  for k=1:M:size(x2,2)
    endk = min(size(x2,2),k+M-1);
    if (endk < k+M-1)
      xx = xx(:,1:endk-k+1);
    end
    d(k:endk)=sum(abs(xx-double(x2(:,k:endk))).^p,1).^(1/p);
  end
  
elseif (size(x1,2) > 1 & size(x2,2) == 1) % many to one
  M=round(CHUNKSIZE/(8*size(x1,1)));
  M=min(M,size(x1,2));
  
  d=zeros(1,size(x1,2));
  
  xx = double(repmat(x2,1,M));
  for k=1:M:size(x2,2)
    endk = min(size(x1,2),k+M-1);
    if (endk < k+M-1)
      xx = xx(:,1:endk-k+1);
    end
    d(k:endk) = sum(abs(double(x1(:,k:endk))-xx).^p,1).^(1/p);
  end

else  % column-by-column distance
  if (p==0)
    d=sum(x1~=x2,1);
  elseif (p==inf)
    d=max(abs(double(x1)-double(x2)),[],1);
  else
    d=sum(abs(double(x1)-double(x2)).^p,1).^(1/p);
  end
end





function checkSizes(x1,x2)
% verifies that the sizes are acceptable

if (iscell(x1))
  s1=[];
  for i=1:length(x1), s1=[s1 size(x1,2)]; end
else
  s1=size(x1,2);
end
if (iscell(x2))
  s2=[];
  for i=1:length(x2), s2=[s2 size(x2,2)]; end
else
  s2=size(x2,2);
end

if (length(s1)==1 & s1 == 1) % x1 is a vector 
  return;
elseif (length(s2)==1 & s2 == 1) % x2 is a vector
  return;
elseif (length(s1)==1 & length(s2)==1)
  if (s1==s2) % matching matrices
    return;
  else
    error('L_p: matrix size mismatch %d %d',s1,s2);
  end
else % cell arrays
  if (length(s1) ~= length(s2))
    error('L_p: cell array length mismatch %d ~= %d', ...
	  length(s1),length(s2));
  else
    f=find(s1 ~= s2);
    if (~isempty(f))
      f=f(1);
      error('L_p: cell size mismatch (%d) %d ~= %d',f,s1(f),s2(f));
    end
  end
end
