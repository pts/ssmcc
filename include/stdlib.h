#ifndef _STDLIB_H
#define _STDLIB_H

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

#ifdef __WATCOMC__
__declspec(noreturn)
#endif
    void exit _LIBCP((int _status));
void *malloc _LIBCP((unsigned _nbytes));
#define _LIBC_HAVE_MALLOC_UNALIGNED 1
void *malloc_unaligned _LIBCP((unsigned _nbytes));  /* Nonstandard. */
void *realloc _LIBCP((void *_ptr, unsigned _nbytes));
void free _LIBCP((void *_ptr));

#undef _LIBCP
#endif  /* _STDLIB_H */
