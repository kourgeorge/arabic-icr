function I = lshfunc(type,l,k,d,varargin)
% I = lshfunc(TYPE,L,K,D)
%   
% Creates a random set of locality-sensitive hash functions. 
%    
% Input:
%    TYPE : type of hashing, can be 'lsh'/'e2lsh'
%           (see README and lsh.m for explanation)
%    L : number of functions (i.e., of hash tables)
%    K : number of bits in a function (i.e., length of a key)
%    D : is the dimension of the data.
%
% 
% Output:
%  I(j) is the function for the j-th table. It's a struct with the
%  following fields, that depend on the choice of hashing scheme:
%    'lsh':  d - the vector of k dimensions
%            t - the vector of k thredholds
%
%    'e2lsh' : W - the width of intervals on random projection line
%              A - projection matrix (D x k)
%              b - random shifts (1 x k)
%
%  I = lshfunc(...,'exclude',EXCL)
%    will exclude the dimensions listed in vector EXCL (i.e., those
%    dimensions will not be used at all in calculating the hash). 
%    Default is to include all dimensions.
%
%  I = lshfunc(...,'range',RNG)
%    will assume that the range of the data is given by RNG. which can be:
%      a scalar, meaning each dimension range is [0,RNG]
%      a 1 x D vector, meaning dimension i has range [0,RNG(i)]
%      a 2 x D matrix, with the range for i-th dimension given by RNG(:,i)
%    Default for RNG is 1.
% 
%  I = lshfunc(...,'W',W)
%    provides a value for parameter W in e2lsh scheme. W is a scalar
%    specifying the width of an interval on the projection line
%    corresp. to a single hash value. 
%    If W is negative, its abs. value is interpreted as the number of intervals.
%    Default for W is to partition the range into 16 intervals.
% 
% 
% (C) Greg Shakhnarovich, TTI-Chicago (2008)


exclude=[];
range=[];
w=[];

% parse the optional arguments
for a=1:2:length(varargin)
  eval(sprintf('%s=varargin{a+1};',lower(varargin{a})));
end

% convert the range to 
range = processRange(d,range);


switch type, % different algorithms

  case 'lsh',  % optimal for Hamming spaces
  
   include=setdiff(1:d,exclude);   
   for j=1:l
     % select random dimensions
     I(j).d = include(unidrnd(length(include),1,k));
     % for each dimension select a threshold
     % hash key = [[ x(:,d)' >= t ]]
     t = unifrnd(0,1,1,k).*(range(2,I(j).d)-range(1,I(j).d));
     I(j).t = range(1,I(j).d)+t;
     I(j).k = k;
   end


 case 'e2lsh',
  
  % set up interval width if necessary
  if (isempty(w))
    w=-16;
  end
  if (w < 0)
    % a rough estimate of the range of the projection
    % We have a sum of d normal RVs multiplied by the range of the data
    % (GS: this could be improved...)
    limits = max(abs(range(1,:)),abs(range(2,:)));
    rangeAct=mean(diff([-limits; limits]*2*sqrt(d)));
    n=abs(w);
    w = rangeAct/n;
  end
  
  
  for j=1:l
    % there are k functions determined by random vectors + random shifts
    % hash key: floor((A'*x-b)/W)
    I(j).W = w;
    I(j).A = randn(d,k);
    I(j).b = unifrnd(0,w,1,k);
    I(j).k = k;
  end
   
end
