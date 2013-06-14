#include  <iostream>
#include  <cmath>
#include  <cassert>
#include  <cstdlib>
#include  <cstring>

#include  "emd.h"
#include  "mex.h"

/* DISTANCE_TYPE_p is taken as infinity if it is greater than 100 */
double DISTANCE_TYPE_p = 2;
feature_t Fmax;

inline double dist_p(feature_t *F1, feature_t *F2)
{
  assert(F1->size == F2->size && F2->size == Fmax.size);
  double d = 0, diff = 0;

  if(DISTANCE_TYPE_p>300)
    DISTANCE_TYPE_p = 300;

  if(DISTANCE_TYPE_p == 0)
  {
    for(int n = 0; n < F1->size; ++n)
      if (F1->x[n] != F2->x[n])
        ++d;
  } else if(DISTANCE_TYPE_p == 300)                       /* MAX or L_inf */
  {
    for(int n = 0; n < F1->size; ++n)
    {
      diff = fabs(F1->x[n] - F2->x[n]);
      if (Fmax.x[n]>0 && diff > Fmax.x[n] - diff + 1) /* Periodic */
        diff = Fmax.x[n] - diff + 1;
      if (d < diff) d = diff;
    }
  } else if(DISTANCE_TYPE_p == 1)
  {
    for(int n = 0; n < F1->size; ++n)
    {
      diff = fabs(F1->x[n]-F2->x[n]);
      if (Fmax.x[n]>0 && diff > Fmax.x[n] - diff + 1) /* Periodic */
        diff = Fmax.x[n] - diff + 1;
      d += diff;
    }
  } else if(DISTANCE_TYPE_p == 2)
  {
    for(int n = 0; n < F1->size; ++n)
    {
      diff = fabs(F1->x[n]-F2->x[n]);
      if (Fmax.x[n]>0 && diff > Fmax.x[n] - diff + 1) /* Periodic */
        diff = Fmax.x[n] - diff + 1;
      d += diff*diff;
    }
    d = sqrt(d);
  } else
  {
    for(int n = 0; n < F1->size; ++n)
    {
      diff = fabs(F1->x[n]-F2->x[n]);
      if (Fmax.x[n]>0 && diff > Fmax.x[n] - diff + 1) /* Periodic */
        diff = Fmax.x[n] - diff + 1;
      d += pow(diff, DISTANCE_TYPE_p);
    }
    d = pow(d, 1/DISTANCE_TYPE_p);
  }

  //  std::cerr << d << ' ' << std::fflush;
  return d;
}


/* The gateway routine */
void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{

  double *c1, *w1, *c2, *w2, d, *pr;
  int n1, n2, ndims, nflow;
  feature_t *f1, *f2;
  flow_t *pf;

  if (nrhs < 4) 
    mexErrMsgTxt("Usage: [dist,flow] = emd(Centroid1, Weight1, Centroid2, weight2, <domain_size>, <distance_type>)\n Non-zero domain size in any dimension means that dimension is periodic.\n");

  c1 = mxGetPr(prhs[0]);
  w1 = mxGetPr(prhs[1]);
  c2 = mxGetPr(prhs[2]);
  w2 = mxGetPr(prhs[3]);
  if (nrhs > 5) {
    DISTANCE_TYPE_p = mxGetScalar(prhs[5]);
  } else
    DISTANCE_TYPE_p = 2;      /* Default distance = L_2 (Euclidean) */

  ndims = mxGetM(prhs[0]);      /* Number of rows */
  if (ndims != mxGetM(prhs[2]))
    mexErrMsgTxt("Both signatures should have the same dimension\n");
  if (nrhs > 4) {
    if (ndims != mxGetM(prhs[4]))
      mexErrMsgTxt("Signature max size vector has wrong dimension\n");
    Fmax.x = mxGetPr(prhs[4]);
    Fmax.size = ndims;
  } else {
    Fmax.allocate(ndims);      /* Default non-periodic*/  
    for(int i=0; i<ndims; ++i)
      Fmax.x[i] = 0;
  }

  /* Signature lengths */
  n1 = mxGetN(prhs[0]);
  n2 = mxGetN(prhs[2]);

  if (mxGetNumberOfElements(prhs[1]) != n1 || mxGetNumberOfElements(prhs[3])
      != n2)
    mexErrMsgTxt("Length of weight vector != Length of signature vector");

  if( n1 > MAX_SIG_SIZE || n2 > MAX_SIG_SIZE )
  {
    char err[100] = "Signature size should be less than ";
    mexErrMsgTxt(strcat(err, mxArrayToString(mxCreateDoubleScalar(
              MAX_SIG_SIZE))));
  }

  f1 = new feature_t[n1];
  f2 = new feature_t[n2];

  for (int i=0; i<n1; ++i) {
    f1[i].size = ndims;
    f1[i].x = c1 + ndims*i;
    //   for (int j=0; j<ndims; ++j)
    //     std::cout << f1[i].x[j] << ' ';
    //   std::cout << std::endl << std::fflush;
  }

  for (int i=0; i<n2; ++i) {
    f2[i].size = ndims;
    f2[i].x = c2 + ndims*i;
    //    for (int j=0; j<ndims; ++j)
    //      std::cout << f1[i].x[j] << ' ';
    //    std::cout << std::endl << std::fflush;
  }

  // Make sure all points are inside the domain for periodic distances
  for (int i=0; i<ndims; ++i)
  {
    if (Fmax.x[i]==0) continue;
    for (int j=0; j<n1; ++j)
      if(f1[j].x[i] < 0 || f1[j].x[i] > Fmax.x[i])
        mexErrMsgTxt("Point outside domain in signature 1");
    for (int j=0; j<n2; ++j)
      if(f2[j].x[i] < 0 || f2[j].x[i] > Fmax.x[i])
        mexErrMsgTxt("Point outside domain in signature 2");
  }

  signature_t s1 = {n1, f1, w1}, s2 = {n2, f2, w2};

  if (nlhs>1) {

    pf = new flow_t[n1+n2-1];

    d = emd(&s1, &s2, dist_p, pf, &nflow);

    plhs[1] = mxCreateDoubleMatrix(n1,n2,mxREAL);
    pr = mxGetPr(plhs[1]);
    for (int i=0; i<nflow; ++i)
      pr[ pf[i].from + pf[i].to * n1 ] = pf[i].amount;
    delete []pf;

  } else {
    d = emd(&s1, &s2, dist_p, NULL, NULL);
  }

  plhs[0] = mxCreateDoubleScalar(d);
} 
