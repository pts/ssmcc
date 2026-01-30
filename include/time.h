#ifndef _TIME_H
#define _TIME_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#ifndef NULL
#  define NULL ((void*) 0)
#endif

#ifndef _SIZE_T
#  define _SIZE_T _SIZE_T
  typedef unsigned size_t;
#endif

#ifndef _TIME_T
#  define _TIME_T _TIME_T
  typedef unsigned time_t;
#endif

#undef _LIBCP
#endif  /* _TIME_H */
