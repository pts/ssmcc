#ifndef _SYS_IOCTL_H
#define _SYS_IOCTL_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif


#ifdef __ELKS__
  /* ioctl(...) request constants. */
#  define TCGETS  (('T' << 8) + 1)
#  define TCSETS  (('T' << 8) + 2)
#  define TCSETSW (('T' << 8) + 3)
#  define TCSETSF (('T' << 8) + 4)

  int ioctl _LIBCP((int _fd, unsigned _request, void *_arg));
#endif

#undef _LIBCP
#endif  /* _SYS_IOCTL_H */
