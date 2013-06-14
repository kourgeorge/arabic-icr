function wd = wemdn(H, varargin)

% wd = wemdn(H, periodic, s, C0, tper, wname);
% H can be a single array or cell array. If it is a cell array, all elements
% must be same data type and same size
% periodic = array of length = ndims(H). Is this dimension periodic ?
% A sparse matrix is returned. Each row is the WEMD descriptor for a
% histogram.

if(iscell(H))
  szh = size(H{1});
  if isa(H{1}, 'single') dt = 1;
  elseif isa(H{1}, 'double') dt = 2;
  else error('Only single and double histograms allowed.\n');
  end
  for k=2:length(H)
    if any(szh~=size(H{k}))
      error('Histograms must have the same size.\n');
    end
    if ~(dt==1 && isa(H{k}, 'single') || dt==2 && isa(H{k}, 'double'))
      error('All histograms must be the same datatype.\n');
    end
  end
end
wd = wemdn_mex(H, varargin{:});
