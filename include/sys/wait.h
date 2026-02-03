#ifndef _SYS_WAIT_H
#define _SYS_WAIT_H

#include <sys/types.h>

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#define WIFEXITED(s)	(((s) & 0377) == 0)
#define WEXITSTATUS(s)	(((s) >> 8) & 0377)

pid_t wait _LIBCP((int *_status_loc));

#undef _LIBCP
#endif
