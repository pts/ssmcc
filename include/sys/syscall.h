#ifndef _SYS_SYSCALL_H
#define _SYS_SYSCALL_H

#ifdef __ELKS__   /* Correct values for ELKS Dev86 0.6.21. */
/* #define __NR__exit 1 */  /* Only the SYS_... variants are defined. */

/* '.' = Ok, with comment
 * '*' = Needs libc code (Prefix __)
 * '-' = Obsolete/not required
 * '@' = May be required later
 * '=' = Depends on stated config variable
 *
 * The first number in the comment is the number of arguments.
 *
 * The commented-out numbers are not implemented in the kernel.
 */
#  define   SYS_exit		1	/* 1	* c exit does stdio, _exit in crt0 */
#  define   SYS_fork		2	/* 0 */
#  define   SYS_read		3	/* 3 */
#  define   SYS_write		4	/* 3 */
#  define   SYS_open		5	/* 3 */
#  define   SYS_close		6	/* 1 */
#  define   SYS_wait4		7	/* 4 */
/* #  define   SYS_creat	8 */	/* 0	- Not needed alias for open */
#  define   SYS_link		9	/* 2 */
#  define   SYS_unlink		10	/* 1 */
#  define   SYS_execve		11	/* 3	* execve minix style */
#  define   SYS_chdir		12	/* 1 */
/* #  define   SYS_time		13 */	/* 1	- Use settimeofday */
#  define   SYS_mknod		14	/* 3 */
#  define   SYS_chmod		15	/* 2 */
#  define   SYS_chown		16	/* 3 */
#  define   SYS_brk		17	/* 1	* This is only to tell the system */
#  define   SYS_stat		18	/* 2 */
#  define   SYS_lseek		19	/* 3	* nb 2nd arg is an io ptr to long not a long. */
#  define   SYS_getpid		20	/* 1	* this gets both pid & ppid */
#  define   SYS_mount		21	/* 5 */
#  define   SYS_umount		22	/* 1 */
#  define   SYS_setuid		23	/* 1 */
#  define   SYS_getuid		24	/* 1	* this gets both uid and euid */
/* #  define   SYS_stime	25 */	/* 2	- this must not exist - even as a libc. */
/* #  define   SYS_ptrace	26 */	/* 4	@ adb/sdb/dbx need this. */
/* #  define   SYS_alarm	27 */	/* 2 */
#  define   SYS_fstat		28	/* 2 */
/* #  define   SYS_pause	29 */	/* 0 */
#  define   SYS_utime		30	/* 2 */
#  define   SYS_chroot		31	/* 1 */
#  define   SYS_vfork		32	/* 0 */
#  define   SYS_access		33	/* 2 */
/* #  define   SYS_nice		34 */	/* 1 */
/* #  define   SYS_sleep	35 */	/* 1 */
#  define   SYS_sync		36	/* 0 */
#  define   SYS_kill		37	/* 2 */
#  define   SYS_rename		38	/* 2 */
#  define   SYS_mkdir		39	/* 2 */
#  define   SYS_rmdir		40	/* 1 */
#  define   SYS_dup		41	/* 1	. There is a fcntl lib function too. */
#  define   SYS_pipe		42	/* 1 */
#  define   SYS_times		43	/* 2	* 2nd arg is pointer for long ret val. Is it implemented in the kernel?? */
/* #  define   SYS_profil	44 */	/* 4	@ */
#  define   SYS_dup2		45	/* 2 */
#  define   SYS_setgid		46	/* 1 */
#  define   SYS_getgid		47	/* 1	* this gets both gid and egid. Is it implemented in the kernel?? */
#  define   SYS_signal		48	/* 2	* have put the despatch table in user space. */
/* #  define   SYS_getinfo	49 */	/* 1	@ possible? gets pid,ppid,uid,euid etc */
#  define   SYS_fcntl		50	/* 3 */
/* #  define   SYS_acct		51 */	/* 1	@ Accounting to named file (off if null) */
/* #  define   SYS_phys		52 */	/* 3	- Replaced by mmap() */
/* #  define   SYS_lock		53 */	/* 1	@ Prevent swapping for this proc if flg!=0 */
#  define   SYS_ioctl		54	/* 3	. make this and fcntl the same ? */
#  define   SYS_reboot		55	/* 3	. the magic number is 0xfee1,0xdead,... */
/* #  define   SYS_mpx		56 */	/* 2	- Replaced by fifos and select. */
#  define   SYS_lstat		57	/* 2 */
#  define   SYS_symlink		58	/* 2 */
#  define   SYS_readlink	59	/* 3 */
#  define   SYS_umask		60	/* 1 */
#  define   SYS_settimeofday	61	/* 2 */
#  define   SYS_gettimeofday	62	/* 2 */
#  define   SYS_select		63     /* 5	. 5 paramaters is possible */
#  define   SYS_readdir		64	/* 3	* */
/* #  define   SYS_insmod	65 */	/* 1	- Removed support for modules */
#  define   SYS_fchown		66	/* 3 */
#  define   SYS_dlload		67	/* 2 */
#  define   SYS_setsid		68	/* 0 */
#  define   SYS_socket		69	/* 3 */
#  define   SYS_bind		70	/* 3 */
#  define   SYS_listen		71	/* 2 */
#  define   SYS_accept		72	/* 3 */
#  define   SYS_connect		73	/* 3 */
#  define   SYS_knlvsn		+74     /* 1	= CONFIG_SYS_VERSION */
#endif  /* __ELKS__ */

#endif  /* _SYS_SYSCALL_H */
