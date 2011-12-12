function T = lshins(T,x,ind)
% T = lshins(T,X)
%
%     insert data (columns of X) into T
% 
% NOTE: LSH will only index the data - not store it! You need to keep
% around the original data, in order to go back from indices to actual
% points, if that's what you want to do.
%
% T = lshins(T,X,IND)
%   instead of assuming that columns of X have indices 1..size(X,2), uses IND
%    
%
% (C) Greg Shakhnarovich, TTI-Chicago (2008)


% fields of T:
% buckets : bukets(j,:) is the hash key of bucket j
% Index : Index{j} contains indices of data in bucket j
% count : count(j) contains the size of bucket j

if (nargin < 3 | isempty(ind))
  ind=1:size(x,2);
end

% insert in each table
for j=1:length(T)
  
  % the # of buckets before new data
  oldBuckets=size(T(j).buckets,1);
  
  % find, for each data point, the corresp. bucket
  % bucket numbers are represented as arrays of uint8
  buck = findbucket(T(j).type,x,T(j).I);
  % now x(:,n) goes to bucket with key uniqBuck(bID(n))
    
  [uniqBuck,ib,bID] = unique(buck,'rows');
  keys = lshhash(uniqBuck);
  
  if (T(j).verbose > 0)
    fprintf(2,'%d distinct buckets\n',length(ib));
  end
  
  % allocate space for new buckets -- possibly excessive
  T(j).buckets=[T(j).buckets; zeros(length(ib),T(j).I.k,'uint8')];
  
  newBuckets=0;
  
  for b=1:length(ib)
    % find which data go to bucket uniqBuck(b)
    thisBucket = find(bID==bID(ib(b)));
    
    % find out if this bucket already has anything
    % first, which bucket is it?
    ihash = T(j).bhash{keys(b)}; % possible matching buckets
    if (isempty(ihash)) % nothing matches
      isb = [];
    else % may or may not match
      isb = ihash(find(all(bsxfun(@eq,uniqBuck(b,:),T(j).buckets(ihash,:)),2)));
    end
    
    % note: this search is the most costly operation
    %isb = find(all(bsxfun(@eq,uniqBuck(b,:),T(j).buckets),2));
    
    if (~isempty(isb)) 
      % adding to an existing bucket.
      oldcount=length(T(j).Index{isb}); % # elements in the bucket prior
                                        % to addition
      newIndex = [T(j).Index{isb}  ind(thisBucket)];
    else
      % creating new bucket
      newBuckets=newBuckets+1;
      oldcount=0;
      isb = oldBuckets+newBuckets;
      T(j).buckets(isb,:)=uniqBuck(b,:);
      T(j).bhash{keys(b)} = [T(j).bhash{keys(b)}; isb];
      newIndex = ind(thisBucket);
    end
    
    % if there is a bound on bucket capacity, and the bucket is full,
    % keep a random subset of B elements (note: we do this rather than
    % simply skip the new elements since that could introduce bias
    % towards older elements.)
    % There is still a bias since older elements have more chances to get
    % thrown out.
    if (length(newIndex) > T(j).B)
      rp=randperm(length(newIndex));
      newIndex = newIndex(rp(1:T(j).B));
    end
    % ready to put this into the table
    T(j).Index{isb}= newIndex;
    % update distinct element count
    T(j).count = T(j).count + length(newIndex)-oldcount;
    
  end
  % we may not have used all of the allocated bucket space
  T(j).buckets=T(j).buckets(1:(oldBuckets+newBuckets),:);
  if (T(j).verbose > 0)
    fprintf(2,'Table %d adding %d buckets (now %d)\n',j,newBuckets,size(T(j).buckets,1));
    fprintf(2,'Table %d: %d elements\n',j,T(j).count);
  end
end



