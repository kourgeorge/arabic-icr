function C = processRange(D,C);
% C = processRange(D,C);
%
% Process range description C for a D-dimensional data set
%
% Manipulates C (if necessary), ensuring it is in a 2xD matrix format
% where dimension d has range [C(1,d) C(2,d)].
% Possible input formats for C, other than 2xD matrix:
%  a scalar c in which case C(1,d)=0, C(2,d)=c for all d
%  a vector c, in which case C(1,d)=0, C(2,d)=c(d) for all d
%  empty list [] in which case C(1,d)=0, C(2,d)=1 for all d
% 
% (C) Greg Shakhnarovich, TTI-Chicago (2008)

if (isempty(C))
  C=[zeros(1,D);ones(1,D)]; % given nothing - use default
elseif (size(C,1)==1 & size(C,2)==1) % given single max. value for all dim.
  C=[zeros(1,D);repmat(C,1,D)];
elseif (size(C,1)==1 & size(C,2)==D) % given max. for each dim.
  C=[zeros(1,D); C];
elseif (size(C,1)==2 & size(C,2)==1) % given single range for all dim.
  C=repmat(C,1,D);
elseif (size(C,1)==2 & size(C,2)==D) % given range for each dim
  % nothing - already have C
else
  error('Incorrect size for C');
end
