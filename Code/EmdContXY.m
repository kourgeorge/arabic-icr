  function [f,Diff] = EmdContXY(X1,X2)
% [p,q] = dp(M) 
%    Use dynamic programming to find a min-cost path through matrix M.
%    Return state sequence in p,q
% 2003-03-15 dpwe@ee.columbia.edu

% Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT
%Alighn X2 , Y2 to X1,Y1 
%wname = 'sym5';
% a = dlmread ('C:\OCRData\Features\ShapeContext\8.m');
% b= dlmread ('C:\OCRData\Features\ShapeContext\8A.m');
% [f,Diff] = EmdContXY(a,b);


C0 = 0;
tper = 0;
s = 0.5;      % Max nnz/numel in histogram (sparsity of histograms)

% rand('state',0);


tolerance =0.1;

[L1,t] = size(X1);
[L2,t] = size(X2);
Step=max(L1,L2);


% Mx = mean(X1);
% MRep = repmat(Mx,L1,1);
% X1= X1 - MRep ;
% 
% Mx = mean(X2);
% MRep = repmat(Mx,L2,1);
% X2= X2 - MRep ;

X2= ResampleContour(X2,Step);
X1= ResampleContour(X1,Step);

tolerance =0.1;


f=0;



%wd1 = wemdn(X1-X2, [false false], s, C0, tper,  'coef1');

wd1 = wemdn(X1', [false false], s, C0, tper,  'coef1');
wd2 = wemdn(X2', [false false], s, C0, tper,  'coef1');

%George: there is a problem here with the dimentions 
Diff = full(sum(abs(wd2-wd1)))';
%Diff = Diff + ComputeDist(X1,X2)/Step;

%w_emd2 = full(sum(abs(wd2)))';
%Diff = emd_r(X1,X2,0,1);
Diff = Diff/10;
%[T2,IX2] = dpsimplify( X2,tolerance);
%[T1,IX1] = dpsimplify(X1,tolerance);


% Uncomment for angs insted of XY


% costs
% for i=1:L1
%     f1(i,:)= X1(i,:);
%     w1(i) = 1/L1;
% end
% for i = 1:size(IX1,1)
%     w1(IX1(i))= 1/L1;
% end
% 
% for i=1:L2
%     f2(i,:)= X2(i,:);
%     w2(i) = 1/L2;
% end
% for i = 1:size(IX2,1)
%     w2(IX2(i))= 1/L2;
% end
 %[BH1,mean_dist_1]=sc_compute(Xk',zeros(1,nsamp1),mean_dist_global,nbins_theta,nbins_r,r_inner,r_outer,out_vec_1);
    
 
%  for i=1:Step
%         f1(i,:)= X1(i,:);
%         w1(i) = 1/Step;
% 
%         f2(i,:)= X2(i,:);
%         w2(i) = 1/Step;
% 
%     end
%  
% 
% [f, Diff ] = emd(f1, f2, w1, w2, @ComputeDist);
%Diff =abs (w_emd1-w_emd2);