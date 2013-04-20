function [e,fl] = emd_r(H1, H2, isper, dtype)

% emd_r(H1, H2, isper, dtype)
%
% Computes EMD between histograms 2D H1 and H2 using Rubner's code.
% isper is a bool vector of length 2 indicating whether the histograms are 
% periodic in any dimension.
% The ground distance can be any real number dtype = p for using L_p 
% distances. For p>=300, L_inf is used

assert(all(size(H1)==size(H2)));
if ~exist('isper', 'var') || isempty (isper),
  isper = false;
end
if isscalar(isper),
  isper = repmat(isper, [1 ndims(H1)]);
end
hsize = size(H1)';
hsize(~isper) = 0;

idx1 = find(H1);
idx2 = find(H2);
w1 = H1(idx1);
w2 = H2(idx2);

switch ndims(H1)
case 1,
  f1 = idx1'; f2 = idx2';
case 2,
  [I J] = ind2sub(size(H1), idx1); f1 = [I J]';
  [I J] = ind2sub(size(H2), idx2); f2 = [I J]';
case 3,
  [I J K] = ind2sub(size(H1), idx1); f1 = [I J K]';
  [I J K] = ind2sub(size(H2), idx2); f2 = [I J K]';
case 4,
  [I J K L] = ind2sub(size(H1), idx1); f1 = [I J K L]';
  [I J K L] = ind2sub(size(H2), idx2); f2 = [I J K L]';
case 5,
  [I J K L M] = ind2sub(size(H1), idx1); f1 = [I J K L M]';
  [I J K L M] = ind2sub(size(H2), idx2); f2 = [I J K L M]';
end

if isempty(w1) || isempty(w2)
  e = 0; f = 0;
  return;
end
if exist('dtype', 'var') && ~isempty(dtype)
  if dtype >= 300, dtype = 300; end     % 300 and beyond is infinity  
  [e,fl] = emd_rub(f1, w1, f2, w2, hsize, dtype);
else
  [e,fl] = emd_rub(f1, w1, f2, w2, hsize);
end
