#ifndef _UNISTD_H
#define _UNISTD_H

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

#ifndef _PID_T
#  define _PID_T _PID_T
  typedef int pid_t;
#endif

#define STDIN_FILENO   0  /* file descriptor for stdin */
#define STDOUT_FILENO  1  /* file descriptor for stdout */
#define STDERR_FILENO  2  /* file descriptor for stderr */

/* Values used for whence in lseek(fd, offset, whence). */
#define SEEK_SET 0  /* offset is absolute  */
#define SEEK_CUR 1  /* offset is relative to current position */
#define SEEK_END 2  /* offset is relative to end of file */

ssize_t read  _LIBCP((int _fd, char *_buf, size_t _nbytes));
ssize_t write _LIBCP((int _fd, const char *_buf, size_t _nbytes));
off_t lseek _LIBCP((int _fd, off_t _offset, int _whence));
int close _LIBCP((int _fd));
int isatty _LIBCP((int _fd));
int pipe(int _pipefd[2]);
int dup(int _oldfd);

int unlink _LIBCP((const char *_path));  /* Same as remove(...) in <stdio.h>. */

int brk _LIBCP((char *_addr));
char *sbrk _LIBCP((int _incr));

pid_t getpid _LIBCP((void));
pid_t fork _LIBCP((void));

int execv _LIBCP((char *_path, char *_argv[]));
int execve _LIBCP((char *_path, char *_argv[], char *_envp[]));

#undef _LIBCP
#endif  /* _UNISTD_H */
