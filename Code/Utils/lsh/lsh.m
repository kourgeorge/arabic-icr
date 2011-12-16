function T = lsh(type,l,k,d,x,varargin)
% T = LSH(TYPE,L,K,D,...)
% 
%   Initializes the LSH dat structure and returns it in T 
%   TYPE defines the LSH scheme to use: 'lsh' / 'e2lsh'
%   D is the dimension of the data
%   L,K - LSH params (# of tables and length of keys)
% 
% NOTE: LSH will only index the data - not store it! You need to keep
% around the original data, in order to go back from indices to actual
% points, if that's what you want to do.
%
% Optional args (pairs of name/value):
%  'B' - the maximum bucket capacity. If given (default is infinite
%    capacity), no bucket is allowed to contain more than B
%    elements. When indexing data, once B elements are inserted in a
%    bucket, any further elements that would be added to it are simply discarded.
%  'range' - range description (see below)
%  'W' - parameter of e2lsh scheme (see below)
%  'verb' - verbosity level (can be changed later)
%  'data' - if given, the columns of data will be inserted in the table.
%  'ind' - indices of the examples in data (only relevant if 'data'
%    argument is given). I.e., if the 'data' argument has 5 columns, and
%    'ind' is [1,2,8,10,55], then the index entered for the 4-th column
%    of data will be 10, for the 5-th it will be 55, etc.
%
% Output:
% a struct array T, with L tables, each with the following fields:
%   type: string (currently 'lsh' or 'e2lsh'
%   Args: arguments for hash function
%   I: struct containing hash functions (see lshfunc.m)
%   B: integer limit on maximum bucket capacity (could be inf)
%   count: # of distinct elements indexed by the table
%   buckets: matrix with hash keys (row per occupied bucket)
%   Index: for each bucket i, Index{i} contains indices of data occupying
%     the bucket
%   verbose: verbosity value 
%   bhash: secondary hash table used for quick access to buckets (see lshhash.m)
%
%
% The hashing works as follows for the two schemes (the description
% refers to a single hash table; each of the L tables is created
% independently)
% 
% **** 'LSH': 
% older algorithm, described in Gionis et al. paper
% http://theory.csail.mit.edu/~indyk/vldb99.ps
% For k=1,...,K, a single dimension of the data is chosen uniformly at random,
% and a single threshold value is drawn uniformly over the data range in
% that dimension. 
% 
% **** 'E2LSH':
% more recent algorithm, described in
% http://theory.lcs.mit.edu/~indyk/nips-nn.ps
% For each k, a random line is drawn (with independent, normally
% distributed coefficients); data are projected to the line, and shifted
% by a value drawn between 0 and W. Then, the range is divided into
% "cells" of width W; the hash value is determined by the cell into which
% a projected+shifted value falls.
% 
% (C) Greg Shakhnarovich, TTI-Chicago (2008)

b=inf;
range=[];
verb=0;
ind=1:size(x,2);

for a=1:2:length(varargin)
  eval(sprintf('%s = varargin{a+1};',lower(varargin{a})));
end

% make sure the range in a convenient, 2 x d format
range = processRange(d,range);

% create the LSH functions (functions that compute L K-bit hash keys)
Is = lshfunc(type,l,k,d,varargin{:});

% index the data in X using these LSH functions
T = lshprep(type,Is,b);

if (~isempty(x))
  T = lshins(T,x,ind);
end

for i=1:length(T)
  T(i).verbose=verb;
end
