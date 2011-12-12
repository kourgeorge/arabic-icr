function T = lshprep(type,Is,B,varargin)
% T = lshprep(TYPE,I,B,...)
%
%    Prepares the set of hash tables T using LSH functions I.
%    The data is converted to unary encoding *implicitly*
%    B is the max. number of items to look at in the union of buckets;
%    default is B=inf (i.e., no limit)
%
%    On return, the hash table T{j} has following fields:
%      type - the LSH scheme used
%      buckets - the identities of non-empty buckets;
%        buckets(i,:) is the key of the i-th bucket
%      bhash - the secondary hash table used to map the buckets;
%        it's a sparse vector, with bhash{i} = j 
%      Index - indices within the full data set; 
%        Index{i} is a vector with indices of elements in i-th bucket
%      I - the functions produced by lshfunc
%      Args - whatever was passed in additional args to lshprep
%      B - the requested maximal number of elements in a single bucket (may be inf)
%      count - the # of indexed elements    
%
% (C) Greg Shakhnarovich, TTI-Chicago  (2008)

if (nargin < 3)
  B = inf;
end

l = length(Is);  % # of HT
k = Is(1).k;


if (isinf(B))
  fprintf(2,' B UNLIMITED');
else
  fprintf(2,'B=%d,',B);
end
fprintf(2,' %d keys %d tables\n',k,l);


% values used in bucket hashing

for j=1:l
  T(j).type = type;
  T(j).Args = varargin;
  T(j).I = Is(j);
  T(j).B = B;
  T(j).count = 0;
  T(j).buckets = [];
  % prepare T's table
  T(j).Index = {};
  T(j).verbose=1;

  % set up secondary hash table for buckets
  % max. index can be obtained by running lshhash on max. bucket
  T(j).bhash = cell(lshhash(ones(1,k)*255),1);
  
end


