function v =findbucket(type,x,I)
% B = FINDBUCKET(TYPE,X,I)
%
% Find, for each point(column) in X, its hash bucket based on i
% 
%
% The bucket numbers are returned in *rows* of B, represented as
% character array. The underlying assumption that makes this possible:
% the value of each component is an integer between -128 and 127.
%
% 
% (C) Greg Shakhnarovich, TTI-Chicago  (2008)


switch type,
 case 'lsh',
  v = x(I.d,:)' <= repmat(I.t,size(x,2),1);
  
 case 'e2lsh',
  v = floor((double(x)'*I.A - repmat(I.b,size(x,2),1))/I.W);
  
end

% enforce the range so numbers are between 0 and 255
% note: 0/1 keys in LSH become 128/129
v = uint8(v+128);
