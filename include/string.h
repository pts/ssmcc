#ifndef _STRING_H
#define _STRING_H

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

void *memcpy _LIBCP((void *_t, const void *_s, unsigned _length));
void *memset _LIBCP((void *_s, int _c, unsigned _nbytes));
int strcmp _LIBCP((const char *_s1, const char *_s2));
char *strcpy _LIBCP((char *_target, const char *_source));
char *strcat _LIBCP((char *_target, const char *_source));
unsigned strlen _LIBCP((const char *_s));
char *strrchr _LIBCP((const char *_s, int _c));
int strncmp _LIBCP((const char *_s1, const char *_s2, unsigned _nbytes));
int memcmp _LIBCP((const void *_s1, const void *_s2, unsigned _nbytes));

#undef _LIBCP
#endif  /* _STRING_H */
