//-------------------------------------------------------------------
// Mathematic functions library
//-------------------------------------------------------------------
// 30/10/98		3.0		Laurent Destailleur		Creation
//-------------------------------------------------------------------
// SolveCubic
// Cnm1 & Cnm2
//-------------------------------------------------------------------

#include <math.h>
#include <stdlib.h>

#include "math.h"


#ifndef M_PI
#define M_PI	3.14159
#endif

void SolveCubic(double a,double b,double c,double d,int *solutions,double *x)
//-------------------------------------------------------------------
// Input : a,b,c,d coeff du polynome ordre 3
// Ouput: solution = nbre de solutions
//        x = tableau contenant les solutions
//-------------------------------------------------------------------
{
      long double    a1 = b/a, a2 = c/a, a3 = d/a;
      long double    Q = (a1*a1 - 3.0*a2)/9.0;
      long double R = (2.0*a1*a1*a1 - 9.0*a1*a2 + 27.0*a3)/54.0;
      double    R2_Q3 = R*R - Q*Q*Q;
      double    theta;
      if (R2_Q3 <= 0) {
	    *solutions = 3;
	    theta = acos(R/sqrt(Q*Q*Q));
	    x[0] = -2.0*sqrt(Q)*cos(theta/3.0) - a1/3.0;
	    x[1] = -2.0*sqrt(Q)*cos((theta+2.0*M_PI)/3.0) - a1/3.0;
	    x[2] = -2.0*sqrt(Q)*cos((theta+4.0*M_PI)/3.0) - a1/3.0;
      }
      else {
	    *solutions = 1;
	    x[0] = pow(sqrt(R2_Q3)+fabs(R), 1/3.0);
	    x[0] += Q/x[0];
	    x[0] *= (R < 0.0) ? 1 : -1;
	    x[0] -= a1/3.0;
      }
}


unsigned long Cnm1(int n,int m)
//-------------------------------------------------------------------
// Compute C(n,m) = the number of combinations of n items, taken m at a time.
//
// The def of this function is:  C(n,m)  = n! / (m! * (n-m)!).
// Computing this formula can cause overflow for large values of n,
// even when C(n,m) would be defined.
// The Cnm1 version will not overflow if C(n,m) * (n-m+1) < ULONG_MAX.
// The Cnm2 version will not overflow if C(n,m) < ULONG_MAX, but
// is slightly more complex.
// Function domain: n >= 0,  0 <= m <= n.
//-------------------------------------------------------------------
{
unsigned long cnm = 1UL;
int i;
if (m*2>n) m=n-m;
for (i=1;i<=m;n--,i++) cnm = cnm * n / i;
return cnm;
}


unsigned long Cnm2(int n,int m)
//-------------------------------------------------------------------
// Compute C(n,m) = the number of combinations of n items, taken m at a time.
//
// The def of this function is:  C(n,m)  = n! / (m! * (n-m)!).
// Computing this formula can cause overflow for large values of n,
// even when C(n,m) would be defined.
// The Cnm1 version will not overflow if C(n,m) * (n-m+1) < ULONG_MAX.
// The Cnm2 version will not overflow if C(n,m) < ULONG_MAX, but
// is slightly more complex.
// Function domain: n >= 0,  0 <= m <= n.
//-------------------------------------------------------------------
{
unsigned long cnm = 1UL;
int i, f;
if (m*2 >n) m=n-m;
for (i=1 ; i <= m; n--, i++) {
  if ((f=n)%i == 0) f/=i;
  else  cnm /= i;
  cnm *= f;
  }
return cnm;
}


