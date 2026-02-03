#ifndef _SYS_TYPES_H
#define _SYS_TYPES_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#ifndef _SIZE_T
#  define _SIZE_T _SIZE_T
  typedef unsigned size_t;
#endif

#ifndef _SSIZE_T
#  define _SSIZE_T _SSIZE_T
  typedef int ssize_t;
#endif

#ifndef _OFF_T
#  define _OFF_T _OFF_T
  typedef long off_t;  /* offsets within a file */
#endif

#ifndef _TIME_T
#  define _TIME_T _TIME_T
  typedef long time_t;
#endif

#ifndef _PID_T
#  define _PID_T _PID_T
  typedef int pid_t;
#endif

#ifdef __MINIX__  /* Correct sizes for struct stat in Minix 1.5.10. */
  typedef unsigned short  dev_t;    /* holds (major|minor) device pair */
  typedef unsigned char   gid_t;    /* group id */
  typedef unsigned short  ino_t;    /* i-node number */
  typedef unsigned short  mode_t;   /* mode number within an i-node */
  typedef unsigned char   nlink_t;  /* number-of-links field within an i-node */
  typedef unsigned short  uid_t;    /* user id */
#endif

#ifdef __ELKS__  /* Correct sizes for struct stat in ELKS Dev86 0.6.21. */
  typedef unsigned short dev_t;
  typedef unsigned short gid_t;
  typedef unsigned long  ino_t;  /* !! since which version of ELKS was it increased from 16 bits? not in 0.2.0 yet */
  typedef unsigned short mode_t;
  typedef unsigned short nlink_t;
  typedef unsigned short uid_t;
#endif

#undef _LIBCP
#endif  /* _SYS_TYPES_H */
