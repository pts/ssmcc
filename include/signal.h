#ifndef _SIGNAL_H
#define _SIGNAL_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#ifdef __MINIX__
#  define _NSIG 17  /* highest signal number, plus 1 */
#  define NSIG _NSIG
#  define SIGHUP      1
#  define SIGINT      2
#  define SIGQUIT     3
#  define SIGILL      4
#  define SIGTRAP     5
#  define SIGABRT     6
#  define SIGIOT      6
#  define SIGUNUSED   7
#  define SIGFPE      8
#  define SIGKILL     9
#  define SIGUSR1    10
#  define SIGSEGV    11
#  define SIGUSR2    12
#  define SIGPIPE    13
#  define SIGALRM    14
#  define SIGTERM    15
#  define SIGSTKFLT  16

#  define SIGEMT      7
#  define SIGBUS     10

  /* Defined but not supported. */
#  define SIGCHLD    17
#  define SIGCONT    18
#  define SIGSTOP    19
#  define SIGTSTP    20
#  define SIGTTIN    21
#  define SIGTTOU    22
#endif

#ifdef __ELKS__
#  define _NSIG 32  /* highest signal number, plus 1 */
#  define NSIG _NSIG
#  define SIGHUP      1
#  define SIGINT      2
#  define SIGQUIT     3
#  define SIGILL      4
#  define SIGTRAP     5
#  define SIGABRT     6
#  define SIGIOT      6
#  define SIGBUS      7
#  define SIGFPE      8
#  define SIGKILL     9
#  define SIGUSR1    10
#  define SIGSEGV    11
#  define SIGUSR2    12
#  define SIGPIPE    13
#  define SIGALRM    14
#  define SIGTERM    15
#  define SIGSTKFLT  16
#  define SIGCHLD    17
#  define SIGCONT    18
#  define SIGSTOP    19
#  define SIGTSTP    20
#  define SIGTTIN    21
#  define SIGTTOU    22
#  define SIGURG     23
#  define SIGXCPU    24
#  define SIGXFSZ    25
#  define SIGVTALRM  26
#  define SIGPROF    27
#  define SIGWINCH   28
#  define SIGIO      29
#  define SIGPOLL    SIGIO
/*#  define SIGLOST 29 */
#  define SIGPWR     30
#  define SIGUNUSED  31
#endif

typedef void (*sighandler_t) _LIBCP((int));

#if __STDC__
#  define SIG_DFL ((void (*)(int)) 0)
#  define SIG_IGN ((void (*)(int)) 1)
#  define SIG_ERR ((void (*)(int)) -1)
#else
#  define SIG_DFL ((void (*)()) 0)
#  define SIG_IGN ((void (*)()) 1)
#  define SIG_ERR ((void (*)()) -1)
#endif

void (*signal _LIBCP((int _sig, void (*_handler)(int)))) _LIBCP((int));

#undef _LIBCP
#endif  /* _SIGNAL_H */
