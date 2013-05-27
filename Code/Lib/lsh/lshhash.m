function [hkey,hpos] = lshhash(keys)
% hkey = lshhash(keys)
%
% Simple one-level hashing function to speed up bucket search in LSH.
% Input:
% keys(i,:) is an array representing an LSH key (bucket ID).
% 
% Output:
% hkey(i) is an integer key computed for keys(i,:)
% 
% hpos contains indices of key positions used to compued hkey, i.e., the
% values used are keys(:,hpos).
%
% (C) Greg Shakhnarovich, TTI-Chicago (2008)
%
% Inspired by http://www.mathworks.com/matlabcentral/fileexchange/15831

% identity plus some prime numbers
%P = [1 2 3 5 7 11 13 17 19 23];
P = [1 2 5 11 17 23 31 41 47 59];

[n,m]=size(keys);
M = min(length(P),m);

hpos = zeros(1,M); % indices of positions used to hash
for i=1:M
  if (mod(i,2)==1)
    hpos(i) = (i+1)/2;
  else
    hpos(i) = m-(i/2)+1;
  end
end

% now compute for each row the dot product of a sub-row with the primes
hkey = sum(bsxfun(@times,double(keys(:,hpos)),P(1:M)),2)+1;
