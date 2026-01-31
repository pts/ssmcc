#ifndef _FCNTL_H
#define _FCNTL_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#ifndef NULL
#  define NULL ((void*) 0)
#endif

/* _oflag bitset for open(...). */
#define O_RDONLY  0
#define O_WRONLY  1
#define O_RDWR    2
#ifdef __MINIX__
#  define O_CREAT     00100  /* creat file if it doesn't exist */
#  define O_EXCL      00200  /* exclusive use flag */
#  define O_NOCTTY    00400  /* do not assign a controlling terminal */
#  define O_TRUNC     01000  /* truncate flag */
#  define O_APPEND    02000  /* set append mode */
#  define O_NONBLOCK  04000  /* no delay */
#endif

int creat _LIBCP((const char *_path, int _mode));
int open _LIBCP((const char *_path, int _oflag, ...));  /* ... is `mode_t _mode' or `unsigned _mode'. */
#define _LIBC_HAVE_OPEN00 1  /* So that the program source can check it with #ifdef */
int open00 _LIBCP((const char *_path));  /* Nonstandard equivalent of open(_path, O_RDONLY). */

#undef _LIBCP
#endif  /* _FCNTL_H */
