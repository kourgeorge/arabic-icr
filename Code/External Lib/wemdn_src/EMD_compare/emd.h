#ifndef _EMD_H
#define _EMD_H
/*
    emd.h

    Last update: 3/24/98

    An implementation of the Earth Movers Distance.
    Based of the solution for the Transportation problem as described in
    "Introduction to Mathematical Programming" by F. S. Hillier and 
    G. J. Lieberman, McGraw-Hill, 1990.

    Copyright (C) 1998 Yossi Rubner
    Computer Science Department, Stanford University
    E-Mail: rubner@cs.stanford.edu   URL: http://vision.stanford.edu/~rubner

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

    Modified by Sameer Shirdhonkar on 23 May 2006
*/


/* DEFINITIONS */
#define MAX_SIG_SIZE   1000
#define MAX_ITERATIONS 500
#define INFINITY       1e20
#define EPSILON        1e-6

/*****************************************************************************/
/* feature_t SHOULD BE MODIFIED BY THE USER TO REFLECT THE FEATURE TYPE      */
struct feature_t{
  double *x;
  int size;
  bool isAlloc;

  feature_t() {
    x = NULL;
    size = 0;
    isAlloc = false;
  };
    
  feature_t(int sz) {
    x = new double[sz];
    size = sz;
    isAlloc = true;
  };

  void allocate(int sz) {
    x = new double[sz];
    size = sz;
    isAlloc = true;
  }

  ~feature_t() {
    if(isAlloc)
      delete []x;
  }
  
};

/*****************************************************************************/


typedef struct
{
  int n;                /* Number of features in the signature */
  feature_t *Features;  /* Pointer to the features vector */
  double *Weights;       /* Pointer to the weights of the features */
} signature_t;


typedef struct
{
  int from;             /* Feature number in signature 1 */
  int to;               /* Feature number in signature 2 */
  double amount;         /* Amount of flow from "from" to "to" */
} flow_t;



double emd(signature_t *Signature1, signature_t *Signature2,
	  double (*func)(feature_t *, feature_t *),
	  flow_t *Flow, int *FlowSize);

#endif
