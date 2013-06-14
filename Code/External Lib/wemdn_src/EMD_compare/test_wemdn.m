wname = 'sym5';
n_test = 50;
sz = [16 16 16];
s = 1;
C0 = 0;
tper = 0;
S = 0.5;      % Max nnz/numel in histogram (sparsity of histograms)

% rand('state',0);
r_emd = zeros(n_test,1);
w_emd = zeros(n_test,1);
tr = 0;
tw = 0;

H = cell(n_test, 1);
fprintf(['Generate %d random histogram pairs of size [%d %d %d] and compute'...
'EMD\n'], n_test, sz);
fprintf('The histograms progressively have more non-zeros, so EMD time will increase.\n');
for k=1:n_test
  H{k} = sprand(prod(sz), 1, S*k/n_test);
  H{k}(H{k}>0) = H{k}(H{k}>0)-sum(H{k}(:))/nnz(H{k});
  if length(sz) > 2
    H{k} = reshape(full(H{k}), sz);
  else
    H{k} = reshape(H{k}, sz);
  end
  % Multiply r_emd by total flow, if it is not 1
  tic;
  r_emd(k) = emd_r(max(H{k},0), max(-H{k},0)) * sum(max(H{k}(:),0));
  H{k} = full(H{k});
  tr = tr + toc;
  fprintf('.');
end
tr = tr/n_test;

fprintf('\nCompute WEMD\n');
tic;
wd = wemdn(H, [false false], s, C0, tper, wname);
w_emd = full(sum(abs(wd)))';
tw = toc/n_test;

sw_emd = w_emd*sum(r_emd)./sum(w_emd);
we_max = nanmax([r_emd./sw_emd; sw_emd./r_emd]);
we_rms = nanstd(sw_emd./r_emd - 1);
fprintf(['%s EMD time = %0.4e WEMD time = %0.4e MAX error = %0.4g RMS '...
'error = %0.4g\n'], wname, tr, tw, we_max, we_rms);

figure(1); plot(w_emd, r_emd, 'ro');
ylabel('EMD by Rubner''s code');
xlabel('EMD using wavelets(red)');
