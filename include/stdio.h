#ifndef _STDIO_H
#define _STDIO_H

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

/* None of ...printf(...), ...scanf(...), fopen(...) etc. has been implemented so far. */

int remove _LIBCP((const char *_path));  /* Same as unlink(...) in <unistd.h>. */
int rename _LIBCP((const char *_oldpath, const char *_newpath));

#undef _LIBCP
#endif  /* _STDIO_H */
