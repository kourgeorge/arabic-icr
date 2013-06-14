/** @author Sameer Sheorey
 */ 
#ifndef _WEMDDES_H
#define _WEMDDES_H

#include  <vector>
using std::vector;
#include  <map>
using std::map;
#include  <string>
using std::string;
#include  <utility>
using std::pair;

#include  "blitz\array.h"
#include  "sparse.h"
#include  "lift.h"

using namespace blitz;

/** Wavelet EMD descriptor. Compute L_1 norm of the difference of two
 * descriptors to to get wavelet EMD.
 *
 * @param H Vector of input histograms.
 * @param wd vector of WEMD descriptors. 
 * @param isperiodic Are the histograms periodic along a particular dimension
 * ? default = false for all dimensions.
 * @param s Ground distance = Euclidean^s [0<s<=1] default = 1
 * @param C0 Approx coeff weight. default = 0
 * @param tper WT coeff Thresholding parameter. If |coeff| < tper *
 * mean(|coeff|), it is set to zero. default = 0.01
 * @param wname Wavelet to be used. default = coif2
 * @return Number of elements (including zeros) in WEMD descriptor
 *
 * Suggested wavelets: sym5, coif1, coif2
 */
template <typename T, size_t ndims>
unsigned wemddes(vector<Array<T, ndims> > &H, 
    vector<pair<vector<unsigned>, vector<T> > > &wd, 
    const TinyVector<bool, ndims> isperiodic = false, const float s = 1,
    const T C0 = 0, const float tper=0.01, const string wname = "coif2");

/** Best partial match. 
 */
template <typename T>  //TODO convert to pair<>
T bpm(const map<unsigned, T> &u, const map<unsigned, T> &v);

/** Best partial match. 
 */
template <typename T> 
T bpm(const Array<T, 1> &u, const Array<T, 1> &v);

#include  "wemd_impl.h"

#endif
