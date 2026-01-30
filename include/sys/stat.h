#ifndef _SYS_STAT_H
#define _SYS_STAT_H

#include <sys/types.h>

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

#ifdef __MINIX__  /* Correct struct stat in Minix 1.5.10. */
  struct stat {
    dev_t st_dev;        /* major/minor device number */
    ino_t st_ino;        /* i-node number */
    mode_t st_mode;      /* file mode, protection bits, etc. */
    short int st_nlink;  /* # links; TEMPORARY HACK: should be nlink_t*/
    uid_t st_uid;        /* uid of the file's owner */
    short int st_gid;    /* gid; TEMPORARY HACK: should be gid_t */
    dev_t st_rdev;
    off_t st_size;       /* file size */
    time_t st_atime;     /* time of last access */
    time_t st_mtime;     /* time of last data modification */
    time_t st_ctime;     /* time of last file status change */
  };
  typedef char _LIBC_assert_sizeof_struct_stat[sizeof(struct stat) == 30 ? 1 : -1];  /* No padding bytes for alignment. */
#endif

#ifdef __ELKS__  /* Correct struct stat in ELKS Dev86 0.6.21. */
  struct stat {
    dev_t st_dev;  /* 16 bits in ELKS 0.2.0--0.8.1. */
    ino_t st_ino;  /* 32 bits in ELKS 0.2.0, but in ELKS 0.2.0 it was 16 bits, even in `struct stat'. The libc functions stat(...), fstat(...) and lstat(...) always use 32 bits. */
    mode_t st_mode;  /* 16 bits in ELKS 0.2.0--0.8.1. */
    nlink_t st_nlink;
    uid_t st_uid;
    gid_t st_gid;
    dev_t st_rdev;
    off_t st_size;
    time_t st_atime;
    time_t st_mtime;
    time_t st_ctime;
  };
  typedef char _LIBC_assert_sizeof_struct_stat[sizeof(struct stat) == 32 ? 1 : -1];  /* No padding bytes for alignment. */
#endif

/* mode_t */ int umask _LIBCP((int _cmask));
int chmod _LIBCP((const char *_path, int _mode));
int fstat _LIBCP((int _fd, struct stat *_statbuf));

#undef _LIBCP
#endif  /* _SYS_STAT_H */
