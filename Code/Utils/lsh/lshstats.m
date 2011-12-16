function [mi,ma,me]=lshstats(T,B,xref,xtst,minNN)
%  [MI,MA,ME] = HTSTATS(T)
%
%  prints statistics of a set of LSH tables
%  returns:
%  mi - minimum size of a bin for each table
%  ma - maximum
%  me - mean
%
% Prints, for each table:
%  # of buckets
%  # median bucket occupancy
%  # maximum bucket occupancy
%  # expected number of bucket co-habitants (i.e., what's the expected
%    number of elements in the same bucket for a randomly selected example
%    in the database).
%
% ... = HTSTATS(T,B)
%
% also prints for each table the number of buckets with at least B
% elements, and the total number of data occupying these buckets.
%
% ... = HSTATS(T,'test',Xref,Xtst)
% 
% performs the following leave-one-out estimate: for each data point x0 in
% Xtst, look up x0 in T (with Xref being the data indexed by T), and note
% the number of "candidate examples", i.e., the total occupancy of
% buckets that match x0 in all tables. 
% Then, the mean and max number of candidates is printed.
%
% ... = HSTATS(T,'test',Xref,Xtst,minNN)
% will also print the number of failures: cases in which fewer than minNN
% matches were found for a test example.
%
% (C) Greg Shakhnarovich, TTI-Chicago (2008)

l=length(T);
k = T(1).I.k;

fprintf(2,'%d tables, %d keys\n',l,k);

allind = [];

for i=1:l
  b(i)=size(T(i).buckets,1); % # of bins in i-th table
  bl=cellfun('length',T(i).Index); % # of el. in m-th bin 
  ind = cell2mat(T(i).Index);  % collect all indexed examples
  fprintf('Table %d: %d in %d bkts, med %d, max %d, avg %.2f',i,length(ind),b(i),median(bl), ...
	  max(bl),sum((bl/sum(bl)).*bl));
  if (nargin >= 2 & ~ischar(B))
    fprintf(2,', %d (%d)> %d',sum(bl>B),sum(bl(find(bl>B))),B);
  end
  fprintf(2,'\n');
  allind = union(allind,ind);
end
fprintf('Total %d elements\n',length(allind));


if (nargin >= 4 & ischar(B) & strcmp(B,'test')) % run leave-one-out
  fprintf(2,'  Running test...');
  p = 0;
  if (nargin < 5)
    minNN = inf;
  end
  cand=zeros(1,size(xtst,2));
  fail=zeros(1,size(xtst,2));
  for n=1:size(xtst,2) % find 2-NN for x0 = x(:,n)
    [nn,cand(n)] = lshlookup(xtst(:,n),xref,T,'k',2);
    fail(n) = length(nn) < minNN;
    if (floor(n*10/size(xtst,2)) > p)
      p = p+1;
      fprintf(2,'%d%% ',p*10);
    end
  end
  fprintf(2,'\n  # of comparisons: mean %.2f, max %d',mean(cand),max(cand));
  if (minNN < inf)
    fprintf(2,', failures: %d',sum(fail));
  end
  fprintf(2,'\n');
end
