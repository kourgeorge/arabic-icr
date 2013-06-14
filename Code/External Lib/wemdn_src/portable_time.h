/** @author Sameer Sheorey */

#ifndef _PORTABLE_TIME_h
#define _PORTABLE_TIME_h

/*********************************************************************/
/*                                                                   */
/* current processor time in seconds                                 */
/* difference between two calls is processor time spent by your code */
/* needs: <sys/types.h>, <sys/times.h>                               */
/* depends on compiler and OS                                        */
/*                                                                   */
/*********************************************************************/

#ifdef WIN32

#include <time.h>
static double timer()
{
  return (double)clock()/CLOCKS_PER_SEC;
}

#else

#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

static double timer ()
{
  struct rusage r;
  getrusage(0, &r);
  return (double)(r.ru_utime.tv_sec+r.ru_utime.tv_usec/(double)1000000);
}

#endif
#endif
