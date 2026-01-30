;
; ssmcc.asm: very small libc and start code in OpenWatcom v2 assembly (WASM) syntax, targeting Minix i86 and ELKS
; by pts@fazekas.hu at Thu Jan 29 06:32:16 CET 2026
;
; The OpenWatcom __cdecl i86 calling convention (similar to the Minix 1.5.10 i86 calling convention) is the following:
;
; * Upon each function entry and exit: ES == DS == SS.
; * Upon each function entry and exit: DF == 0. (This is only the convention of this libc. The default Minix libc doesn't have it.)
; * Please note that the callee can use BX as a scratch register, in addition to the usual AX, CX and DX in cdecl. (In the i386 calling convention, the caller has to restore EBX.)
; * The following assumes that all function arguments and return values are 1 byte (char, unsigned char) or 2 bytes (e.g. int, unsigned, pointer) or long (4 bytes) or unsigned long (4 bytes).
; * The caller pushes arguments starting with the last (sign-extended or zero-extended if needed first), one word a at a time, does a `call', and then pops the arguments.
; * The callee can use AX, BX, CX, DX, ES and FLAGS as scratch registers (but must set DF := 0). It must restore all other registers (including SI, DI, BP, DS). The Minix 1.5.10 i86 calling convention is different: there, the callee must restore ES.
; * The callee returns the value in AX (sign-extended or zero-extended if needed), it returns long and unsigned long values in DX:AX.
; * ES can be anything before each function call. The Minix 1.5.10 i86 calling convention is different: there, the callee can assume that ES == .data.
;

; --- Segment setup.

DOSSEG  ; Equivalent to `wlink op d'. It makes a difference.

.errndef __SSMCC__  ; Assemble it using the ssmcc tool.
IFDEF __MINIX__
  .errdef __ELKS__  ; It's an error if both are defined.
ELSE
  .errndef __ELKS__  ; It's an error if neither is defined.
  .errdef __ELKS__  ; !! TODO(pts): Implement ELKS libc.
ENDIF

DGROUP GROUP CONST, CONST2, _DATA, _BSS, STACK  ; These (plus _TEXT) are the standard segment names used by the OpenWatcom v2 C compiler (wcc). Also they are the DOSSEG segments used by the OpenWatcom v2 linker (WLINK).
_TEXT  SEGMENT BYTE PUBLIC USE16 'CODE'  ; Make DGROUP happy.
_TEXT  ENDS
CONST  SEGMENT WORD PUBLIC USE16 'DATA'  ; Make DGROUP happy.
CONST  ENDS
CONST2 SEGMENT WORD PUBLIC USE16 'DATA'  ; Make DGROUP happy.
CONST2 ENDS
_DATA  SEGMENT WORD PUBLIC USE16 'DATA'  ; Make DGROUP happy.
_DATA  ENDS
_BSS   SEGMENT WORD PUBLIC USE16 'BSS'  ; Make DGROUP happy.
_BSS   ENDS
STACK  SEGMENT BYTE PUBLIC USE16 'STACK'  ; Make DGROUP happy.
;db 1 dup (?) ; `wlink op stack=1' takes care of populating it.
STACK  ENDS

BDS    SEGMENT PARA PUBLIC USE16 'BEGDATA'  ; Paragraph alignment is important.
BDS    ENDS

; This would be put after _TEXT.
;CEND SEGMENT BYTE PUBLIC USE16 'CODE'
;PUBLIC _etext
;_etext:
;CEND ENDS

; --- Global variables and constants.

BDS SEGMENT PARA PUBLIC USE16 'BEGDATA'  ; Paragraph alignment is important.
nullptr_target: dd 0  ; Make sure that a NULL pointer doesn't point to valid data, but here.
BDS ENDS

_DATA SEGMENT WORD PUBLIC USE16 'DATA' 
IFDEF U_brk
IFNDEF U_brksize
U_brksize =
ENDIF
ENDIF
IFDEF U_sbrk
IFNDEF U_brksize
U_brksize =
ENDIF
ENDIF
IFDEF U_brksize
EXTRN __end:BYTE
PUBLIC _brksize
_brksize: dw offset __end  ; The OpenWatcom v2 linker (WLINK) puts the symbol __end to the end of _BSS.
ENDIF
_DATA ENDS

_BSS SEGMENT WORD PUBLIC USE16 'BSS'
PUBLIC __M
__M: db 24 dup (?)  ; No COMMON in OpenWatcom v2 C. We could use the `COMMON' directive here.
_BSS ENDS

; See <minix/com.h> for C definitions
;SEND = 1
;RECEIVE = 2
BOTH equ 3
SYSVEC equ 32  ; int 20h ; int $20

_TEXT SEGMENT BYTE PUBLIC USE16 'CODE'
ASSUME DS:DGROUP, ES:DGROUP, SS:DGROUP  ; Without this line, the OpenWatcom v2 assembler (WASM) would generate incorrect relocations for all of `mov byte ptr [__M+2], ...' etc.

; --- Startup and syscalls.

; This is the C run-time start-off routine.  It's job is to take the
; arguments as put on the stack by EXEC, and to parse them and set them up the
; way _main expects them.
PUBLIC _cstart_
EXTRN main_:NEAR
_cstart_:
EXTRN __edata:BYTE
IF 1  ; This will generate the 1st few bytes of the program image (DOS MZ .exe offset 0x20, right after the DOS MZ .exe header). We are at the beginning of _TEXT.
	dw offset __edata  ; The OpenWatcom v2 linker (WLINK) generates the __edata symbol. These 2 bytes will be replaced with `cld ++ pop cx' during post-linking.
ELSE
	cld  ; Will be put back during post-linking.
	pop cx  ; CX := argc. Will be put back during post-linking.
ENDIF
	;sub bp, bp  ; clear for backtrace of core files
	mov bx, sp  ; BX := argv.
	;push ax  ; push environ (don't)
PUBLIC __argc  ; The OpenWatcom C compiler generates this as an unused dependency of main(...).
__argc:  ; Actual symbol value doesn't matter.
	push bx  ; push argv
	push cx  ; push argc
	;call _main
	pop ax  ; argc for __watcall.
	pop dx  ; argv for __watcall.
	call main_  ; It's always __watcall. (!! Change it?)
	;add sp, 6  ; Not needed, we are exiting soon anyway.
	push ax  ; push exit status
	push ax  ; Fake return address for _exit.
	; Fall through to _exit.
;
; void exit(int exit_code)
IFDEF U_exit
PUBLIC _exit
ENDIF
_exit:
; PUBLIC void exit(exit_code)
; int exit_code;
; {
;   *(char*)&_M.m_type = EXIT;
;   _M.m1_i1 = exit_code;
;   callx();
; }
	pop ax  ; Return address. Won't be used.
	pop [__M+4]  ; exit_code.
	mov byte ptr [__M+2], 1  ; *(char*)&_M.m_type = EXIT;
	; Fall through to _callx.
;
; Send a message and get the response.  The '_M.m_type' field of the
; reply contains a value (>=0) or an error code (<0).
IFDEF U_callx  ; Typically false.
PUBLIC _callx
ENDIF
_callx:
; PRIVATE int callx()
; {
;   int k;
; #IFDEF DEBUG_MALLOC  /* Always false. */
;   k = _M.m_type;  /* syscall number. */
;   k = (k >= READ && k <= CREAT) ;; k == IOCTL;  /* MM (== 0) or FS (== 1). */
; #ELSE
;   k = (_M.m_type & 17) != 1;  /* _M.m_type is syscall number. */  /* MM (== 0) or FS (== 1). */  /* This works for EXIT (MM), READ, WRITE, OPEN, CLOSE, CREAT, BRK (MM) and IOCTL. */
; #ENDIF
;   k = sendrec(k, &_M);
;   if (k != 0) return(k);  /* send itself failed */
;   if (_M.m_type < 0) {
; #IFDEF ERRNO  /* Always false. */
;     errno = -_M.m_type;
; #ENDIF
;     return(-1);
;   }
;   return(_M.m_type);
; }
	mov ax, word ptr [__M+2]  ; syscall number.
	and al, 15
	dec ax
	jz callxmmfs  ; Keep AX == MM (== 0).
	mov al, 1  ; AX := FS (== 1).
callxmmfs:
	; Now AX is either MM (== 0) or FS (== 1), depending on the syscall number.
	mov bx, offset __M
	mov cx, BOTH  ; sendrec(srcdest, ptr)
	int SYSVEC  ; trap to the kernel; ruins AX, BX and CX, keeps DX.
	test ax, ax
	jnz callxret  ; sendrec(...) itself has failed.
	or ax, word ptr [__M+2]  ; Syscall result or -errno.
	mov byte ptr [__M+3], 0  ; Set high byte of next syscall to 0.
	jns callxret
	; Here, if ERRNO is defined, we should set:
	;neg ax
	;mov [_errno], ax
	mov ax, -1  ; Return value to indicate syscall error.
callxret:
	ret

; int read(int fd, char *buffer, unsigned nbytes);
IFDEF U_read
PUBLIC _read
_read:
	mov byte ptr [__M+2], 3  ; *(char*)&_M.m_type = READ;
readwrite:
	mov bx, sp
	mov ax, word ptr [bx+2]  ; Argument fd.
	mov word ptr [__M+4], ax  ; _M.m1_i1.
	mov ax, word ptr [bx+4]  ; Argument buffer.
	mov word ptr [__M+10], ax  ; _M.m1_p1.
	mov ax, word ptr [bx+6]  ; Argument nbytes.
	mov word ptr [__M+6], ax  ; _M.m1_i2.
	jmp _callx  ; WASM is smart enough to generate a `jmp short' if the target is close enough.
ENDIF

; int write(int fd, const char *buffer, unsigned nbytes);
IFDEF U_write
PUBLIC _write
_write:
	mov byte ptr [__M+2], 4  ; *(char*)&_M.m_type = WRITE;
IFDEF U_read
	jmp readwrite
ELSE
	mov bx, sp
	mov ax, word ptr [bx+2]  ; Argument fd.
	mov word ptr [__M+4], ax  ; _M.m1_i1.
	mov ax, word ptr [bx+4]  ; Argument buffer.
	mov word ptr [__M+10], ax  ; _M.m1_p1.
	mov ax, word ptr [bx+6]  ; Argument nbytes.
	mov word ptr [__M+6], ax  ; _M.m1_i2.
	jmp _callx
ENDIF
ENDIF

; int close(int fd);
IFDEF U_close
PUBLIC _close
_close:
	mov byte ptr [__M+2], 6  ; *(char*)&_M.m_type = CLOSE;
	; Argument fd will be copied to _M.m1_i1.
	; Fall through to callxarg1.
IFNDEF DO_callxarg1
DO_callxarg1 =
ENDIF
ENDIF
IFDEF U_mask
DO_callxarg1 =
ENDIF
IFDEF U_fstat
IFNDEF DO_callxarg1
DO_callxarg1 =
ENDIF
ENDIF
;
IFDEF DO_callxarg1
callxarg1:
	mov bx, sp
	mov ax, word ptr [bx+2]  ; Argument 1.
	mov word ptr [__M+4], ax  ; _M.m1_i1.
	jmp _callx
ENDIF

; mode_t umask(mode_t complmode);
IFDEF U_umask
PUBLIC _umask
_umask:
; PUBLIC mode_t umask(complmode) mode_t complmode {
;   return((mode_t)callm1(FS, UMASK, (int)complmode, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
; }
	mov byte ptr [__M+2], 60  ; *(char*)&_M.m_type = UMASK;
	jmp callxarg1  ; Argument complmode will be copied to _M.m1_i1.
ENDIF

; int fstat(int fd, struct stat *buffer);
IFDEF U_fstat
PUBLIC _fstat
_fstat:
; PUBLIC int fstat(fd, buffer)
; int fd;
; struct stat *buffer;
; {
;   return(callm1(FS, FSTAT, fd, 0, 0, (char *)buffer, NIL_PTR, NIL_PTR));
; }
	mov byte ptr [__M+2], 28  ; *(char*)&_M.m_type = FSTAT;
	mov bx, sp
	mov ax, [bx+4]  ; Argument buffer.
	mov word ptr [__M+10], ax  ; _M.m1_p1.
	jmp callxarg1  ; Argument fd will be copied to _M.m1_i1.
ENDIF

; int open(const char *_path, int _oflag, ...);  /* ... is `mode_t _mode' or `unsigned _mode'. */
IFDEF U_open
PUBLIC _open
_open:
	mov byte ptr [__M+2], 5  ; *(char*)&_M.m_type = OPEN;
	mov bx, sp
	mov ax, [bx+4]  ; AX := _oflag.
	mov word ptr [__M+6], ax  ; _M.m1_i2 = _oflag;  ; _M.m3_i2 = _oflag;
	test ax, 100q  ; O_CREAT.
IFNDEF DO_callm3
DO_callm3 =
ENDIF
	jz callm3  ; return(callm3(FS, OPEN, _oflag, _path));  /* Ignores _mode. */
	; Now do return callm1(FS, OPEN, strlen(_path) + 1, _oflag, mode, (char *)_path, NIL_PTR, NIL_PTR);
	mov ax, [bx+6]  ; Argument _mode.
	mov word ptr [__M+8], ax  ; _M.m1_i3 = mode;
	mov ax, [bx+2]  ; Argument _oflag.
	mov word ptr [__M+10], ax  ; _M.m1_p1 = (char *) _path;
	push ax  ; Argument _path.
IFNDEF U_strlen
U_strlen =
ENDIF
	call _strlen  ; AX := strlen(_path). Ruins BX, CX, DX (and ES etc.).
	pop cx  ; Clean up argument of _strlen above.
	inc ax  ; AX := strlen(_path) + 1.
	mov word ptr [__M+4], ax  ; _M.m1_i1 = strlen(_path) + 1;
	jmp _callx
ENDIF

; int open00(const char *_path);
; Same as open(_path, 0). Same as open(_path, O_RDONLY).
IFDEF U_open00
PUBLIC _open00
_open00:
	mov byte ptr [__M+2], 5  ; *(char*)&_M.m_type = OPEN;
	xor ax, ax  ; AX (_oflag) := 0. We ignore _mode, because it's not needed when _oflag == 0 == O_RDONLY. */
	; _M.m3_i2 := _oflag.  ; Fall through to callm3ax.
IFNDEF DO_callm3ax
DO_callm3ax =
ENDIF
ENDIF
IFDEF U_creat
IFNDEF DO_callm3ax
DO_callm3ax =
ENDIF
ENDIF
;
IFDEF DO_callm3ax
callm3ax:
	mov word ptr [__M+6], ax  ; _M.m3_i2 = _oflag;
	; Fall through to callm3.
IFNDEF DO_callm3
DO_callm3 =
ENDIF
ENDIF
;
; int callm3(const char *name);
;
; This form of system call is used for those calls that contain at most
; one integer parameter along with a string.  If the string fits in the
; message, it is copied there.  If not, a pointer to it is passed.
IFDEF DO_callm3
callm3:
; PUBLIC int callm3(name) _CONST char *name; {
;   register unsigned k;
;   register char *rp;
;   k = strlen(name) + 1;
;   _M.m3_i1 = k;
;   _M.m3_p1 = (char *) name;
;   rp = &_M.m3_ca1[0];
;   if (k <= M3_STRING) {  /* 14. */
;     while (k--) { *rp++ = *name++; }
;   }
;   return callx();
; }
	push si  ; Save.
	mov si, sp
	mov si, [si+4]  ; Argument name.
	mov word ptr [__M+8], si  ; _M.m3_p1 = (char *) name;
	push si  ; Argument name.
ifndef U_strlen
U_strlen =
endif
	call _strlen
	pop cx  ; Clean up argument of _strlen above.
	inc ax  ; k := strlen(name) + 1.
	mov word ptr [__M+4], ax  ; _M.m3_i1 = k;
	cmp ax, 14  ; if (k <= M3_STRING)
	ja callm3skip
	xchg cx, ax  ; CX := AX (k); AX := junk.
	xchg di, ax  ; Save DI to AX.
	mov di, offset __M+10  ; rp = &_M.m3_ca1[0];
	rep movsb
	xchg di, ax  ; Restore DI from AX. AX := junk.
callm3skip:
	pop si  ; Restore.
	jmp _callx
ENDIF

; int creat(const char *name, mode_t mode);
IFDEF U_creat
PUBLIC _creat
_creat:
	mov byte ptr [__M+2], 8  ; *(char*)&_M.m_type = CREAT;
	; Fall through to callm3arg2.
IFNDEF DO_callm3arg2
DO_callm3arg2 =
ENDIF
ENDIF
IFDEF U_chmod
IFNDEF DO_callm3arg2
DO_callm3arg2 =
ENDIF
ENDIF
;
IFDEF DO_callm3arg2
callm3arg2:
	mov bx, sp
	mov ax, [bx+4]  ; Argument mode.
	jmp callm3ax  ; _M.m3_i2 = mode.
ENDIF

; int chmod(const char *name, mode_t mode);
IFDEF U_chmod
PUBLIC _chmod
_chmod:
; PUBLIC int chmod(name, mode)
; _CONST char *name;
; mode_t mode;
; {
;   return(callm3(FS, CHMOD, mode, name));
; }
	mov byte ptr [__M+2], 15  ; *(char*)&_M.m_type = CHMOD;
	jmp callm3arg2
ENDIF

; int isatty(int fd);
IFDEF U_isatty
PUBLIC _isatty
_isatty:
; int isatty(fd) int fd; {  /* Minix 1.5--1.7.2. */
;   _M.TTY_REQUEST = 0x7408;  /* TIOCGETP == 0x7408 on Minix 1.5.10. */  /* #define TTY_REQUEST m2_i3 */
;   _M.TTY_LINE = fd;  /* #define TTY_LINE m2_i1 */
;   return(callx(FS, IOCTL) >= 0);  /* FS == 1; IOCTL == 54. */
; }
; int isatty(fd) int fd; {  /* Minix 1.7.4--2.0.4--3.2.0, merged isatty(...), tcgetattr(...) and ioctl(...) */
;  struct termios dummy;  /* sizeof(struct termios) == 36 == 0x24 on i386, == 32 == 0x20 on i86. */
;  m.TTY_REQUEST = (unsigned) (0x80245408L & ~(unsigned) 0);  /* TCGETS == (int) 0x80245408L on Minix 2.0.4 */  /* #define TTY_REQUEST COUNT */  /* #define COUNT m2_i3 */
;  m.TTY_LINE = fd;  /* #define TTY_LINE DEVICE */  /* #define DEVICE m2_i1 */
;  m.ADDRESS = (char *) &dummy;  /* #define ADDRESS m2_p1 */ 
;  return((callx(FS, IOCTL) >= 0);  /* FS == 1; IOCTL == 54. */  /* Actually, Minix does (...) == 0. */
; }
; int isatty(fd) int fd; {  /* Our implementation below, compatible with Minix 1.5--2.0.4--3.2.0. */
;   char dummy[sizeof(int) == 2 ? 32 : 36];  /* struct termios dummy; */  /* For compatibility with Minix 1.7.4--2.0.4--3.2.0. */
;   _M.TTY_REQUEST = 0x7408;  /* TIOCGETP; */
;   _M.TTY_LINE = fd;
;   if (callx(FS, IOCTL) >= 0) goto found_tty;  /* Minix 1.5--1.7.2. */
;   _M.TTY_REQUEST = (unsigned) (0x80245408L & ~(unsigned) 0);  /* TCGETS. */
;   _M.TTY_LINE = fd;
;   _M.ADDRESS = dummy;
;   if (callx(FS, IOCTL) < 0) return 0;  /* Minix 1.7.4--2.0.4--3.2.0. */
;  found_tty:
;   return(1);
; }
	; First try: Minix 1.5--1.7.2.
	mov byte ptr [__M+2], 54  ; *(char*)&_M.m_type = IOCTL;
	mov word ptr [__M+8], 7408h  ; _M.TTY_REQUEST = Minix_1_5_TIOCGETP;
	mov bx, sp
	mov ax, [bx+2]  ; Argument fd.
	mov word ptr [__M+4], ax  ; _M.TTY_LINE = fd;
	call _callx  ; if (callx() >= 0) goto isattydone;
	test ax, ax
	jns isattydone  ; Jump iff found a TTY.
	; Not found a TTY for the first try. Second try: Minix 1.7.4--2.0.4--3.2.0.
	mov word ptr [__M+8], 5408h  ; _M.TTY_REQUEST = Minix_1_7_2_TIOCGETP;
	mov bx, sp
	mov ax, [bx+2]  ; Argument fd.
	mov word ptr [__M+4], ax  ; _M.TTY_LINE = fd;
	sub sp, 32  ; struct termios &dummy;
	mov word ptr [__M+18], sp  ; _M.ADDRESS = &dummy.  ; m2_p1.
	call _callx  ; if (callx() >= 0) goto isattydone;
	add sp, 32  ; Pop the dummy.
isattydone:  ; return callx() >= 0;
	; This would be 1 byte longer.
	;test ax, ax
	;mov ax, 1
	;jns isattyret
	;dec ax  ; AX := 0.
	rol ax, 1
	not ax
	and ax, 1
;isattyret:
	ret
ENDIF

; off_t lseek(int fd, off_t offset, int whence);
IFDEF U_lseek
PUBLIC _lseek
_lseek:
; PUBLIC off_t lseek(fd, offset, whence)
; int fd;
; off_t offset;
; int whence;
; {
;   int k;
;   *(char*)&_M.m_type = LSEEK;
;   _M.m2_i1 = fd;
;   _M.m2_l1 = offset;
;   _M.m2_i2 = whence;
;   if ((k = callx()) != 0) return((off_t) k);
;   return((off_t) _M.m2_l1);
; }
	mov bx, si  ; Save SI to BX.
	mov si, sp
	lodsw  ; SI += 2; AX := junk.
	mov byte ptr [__M+2], 19  ; *(char*)&_M.m_type = LSEEK;
	lodsw  ; Argument fd.
	mov word ptr [__M+4], ax
	lodsw  ; Low  word of argument offset.
	mov word ptr [__M+10], ax
	lodsw  ; High word of argument offset.
	mov word ptr [__M+12], ax
	lodsw  ; Argument whence.
	mov si, bx  ; Restore SI from BX.
	mov word ptr [__M+6], ax
	call _callx
	test ax, ax  ; if ((k = callx()) != 0)
	jz lseekcopyofs
	cwd  ; return((off_t) k);
	jmp lseekret
lseekcopyofs:
	mov ax, word ptr [__M+10]
	mov dx, word ptr [__M+12]  ; return((off_t) _M.m2_l1);
lseekret:
	ret  ; Return result in DX:AX.
ENDIF

; char *sbrk(int incr);
IFDEF U_sbrk
PUBLIC _sbrk
_sbrk:
; extern char *brksize;
; PUBLIC char *sbrk(incr) int incr; {
;   char *newsize, *oldsize;
;   oldsize = brksize;
;   newsize = brksize + incr;
;   if (incr > 0 && newsize < oldsize || incr < 0 && newsize > oldsize)	return((char *) -1);
;   if (brk(newsize) == 0) return(oldsize);  /* This changes brksize on success. */
;   return((char *) -1);
; }
	push si  ; Save.
	mov bx, sp
	mov bx, word ptr [bx+4]  ; Argument incr.
	mov si, [_brksize]  ; SI (oldsize) := _brksize.
	test bx, bx  ; incr.
	lea bx, [si+bx]  ; BX (newsize) := SI (_brksize, oldsize) + incr (BX). It doesn't change the flags.
	;jz sbrkinrange  ; The logic is correct even without this.
	js sbrknegative
	cmp bx, si  ; BX (newsize) < SI (oldsize).
	jb sbrkerror
	jmp sbrkinrange
sbrknegative:
	cmp bx, si  ; BX (newsize) > SI (oldsize).
	ja sbrkerror
sbrkinrange:
	push bx  ; newsize.
IFNDEF U_brk
U_brk =
ENDIF
	call _brk  ; Ruins BX, CX, DX (and ES etc.). It's important that it keeps SI (== oldsize).
	pop bx  ; Clean up argument of _brk above.
	xchg ax, si  ; AX := oldsize; SI := result of brk(newsize).
	test si, si  ; if (brk(newsize) == 0)  /* This changes brksize on success. */
	jz sbrkret  ; return(oldsize);
sbrkerror:
	mov ax, -1
sbrkret:
	pop si  ; Restore.
	ret
ENDIF

; char *brk(char *addr);
IFDEF U_brk
PUBLIC _brk
_brk:
; PUBLIC char *brk(addr) char *addr; {
;   *(char*)&_M.m_type = BRK;
;   _M.m1_p1 = addr;
;   if (callx() == 0) {
;     brksize = _M.m2_p1;
;     return((char*) 0);
;   } ELSE {
;     return((char *) -1);
;   }
; }
	mov byte ptr [__M+2], 17  ; *(char*)&_M.m_type = BRK;
	mov bx, sp
	mov bx, [bx+2]  ; Argument addr.
	mov word ptr [__M+10], bx
	call _callx
	test ax, ax
	jnz brkerror
	mov bx, word ptr [__M+18]  ; _M.m2_p1.
	mov [_brksize], bx  ; brksize = _M.m2_p1;
	jmp brkret
brkerror:
	mov ax, -1  ; return((char *) -1);
brkret:
	ret
ENDIF

; --- OpenWatcom v2 C compiler (wcc) integer operation helpers.

; Divides signed 32-bit long by signed 32-bit long.
; Called by code generated by the OpenWatcom C compiler wcc.
IFDEF U__I4D
PUBLIC __I4D
IFNDEF U__U4D
U__U4D =  ; Make `IFDEF U__U4D' be true below.
ENDIF
__I4D:
	or dx, dx
	js loc1
	or cx, cx
	jns __U4D
	neg cx
	neg bx
	sbb cx, 0
	call __U4D
	jmp loc17
loc1:
	neg dx
	neg ax
	sbb dx, 0
	or cx, cx
	jns loc2
	neg cx
	neg bx
	sbb cx, 0
	call __U4D
	neg cx
	neg bx
	sbb cx, 0
	ret
loc2:
	call __U4D
	neg cx
	neg bx
	sbb cx, 0
loc17:
	neg dx
	neg ax
	sbb dx, 0
	ret
ENDIF

; Divides unsigned 32-bit long by unsigned 32-bit long.
; Called by code generated by the OpenWatcom C compiler wcc.
IFDEF U__U4D
PUBLIC __U4D
__U4D:
	or cx, cx
	jne loc5
	dec bx
	je loc4
	inc bx
	cmp bx, dx
	ja loc3
	mov cx, ax
	mov ax, dx
	sub dx, dx
	div bx
	xchg ax, cx
loc3:
	div bx
	mov bx, dx
	mov dx, cx
	sub cx, cx
loc4:
	ret
loc5:
	cmp cx, dx
	jb loc7
	jne loc6
	cmp bx, ax
	ja loc6
	sub ax, bx
	mov bx, ax
	sub cx, cx
	sub dx, dx
	mov ax, 1
	ret
loc6:
	sub cx, cx
	sub bx, bx
	xchg ax, bx
	xchg dx, cx
	ret
loc7:
	push bp
	push si
	sub si, si
	mov bp, si
loc8:
	add bx, bx
	adc cx, cx
	jb loc11
	inc bp
	cmp cx, dx
	jb loc8
	ja loc9
	cmp bx, ax
	jbe loc8
loc9:
	clc
loc10:
	adc si, si
	dec bp
	js loc14
loc11:
	rcr cx, 1
	rcr bx, 1
	sub ax, bx
	sbb dx, cx
	cmc
	jb loc10
loc12:
	add si, si
	dec bp
	js loc13
	shr cx, 1
	rcr bx, 1
	add ax, bx
	adc dx, cx
	jae loc12
	jmp loc10
loc13:
	add ax, bx
	adc dx, cx
loc14:
	mov bx, ax
	mov cx, dx
	mov ax, si
	xor dx, dx
	pop si
	pop bp
	ret
ENDIF

; Multiplies unsigned 32-bit long by unsigned 32-bit long.
; Called by code generated by the OpenWatcom C compiler wcc.
IFDEF U__U4M
PUBLIC __U4M
__U4M:
	; Falls through to __I4M.
IFNDEF DO_I4M
DO_I4M =
ENDIF
ENDIF
;
; Multiplies signed 32-bit long by signed 32-bit long.
; Called by code generated by the OpenWatcom C compiler wcc.
IFDEF U__I4M
PUBLIC __I4M
__I4M:
IFNDEF DO_I4M
DO_I4M =
ENDIF
ENDIF
IFDEF DO_I4M
	xchg ax, bx
	push ax
	xchg ax, dx
	or ax, ax
	je loc15
	mul dx
loc15:
	xchg ax, cx
	or ax, ax
	je loc16
	mul bx
	add cx, ax
loc16:
	pop ax
	mul bx
	add dx, cx
	ret
ENDIF

; --- C library string functions (str...(3) and mem...(3)).

; void *memcpy(void *s1, const void *s2, size_t n);
;
; Copies n characters from the object pointed to by s2 into the
; object pointed to by s1.  Copying takes place as if the n
; characters pointed to by s2 are first copied to a temporary
; area and then copied to the object pointed to by s1.
; Returns s1.
;
; Per X3J11, memcpy may have undefined results if the objects
; overlap; since the performance penalty is insignificant, we
; use the safe memmove code for it as well.
IFDEF U_memcpy
PUBLIC _memcpy
_memcpy:
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov di, sp
	mov cx, [di+6]  ; Argument n.
	mov si, [di+4]  ; Argument s2.
	mov di, [di+2]  ; Argument s1.
	mov ax, di  ; Save a copy of s1, for returning.
	rep movsb
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
ENDIF

; void *memset(void *s, int c, size_t n);
;
; Copies the value of c (converted to unsigned char) into the
; first n locations of the object pointed to by s.
; Returns s.
IFDEF U_memset
PUBLIC _memset
_memset:
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov dx, di  ; Save DI to DX.
	mov di, sp
	mov cx, [di+6]  ; Argument n.
	mov al, [di+4]  ; Argument c.
	mov di, [di+2]  ; Argument s.
	mov bx, di  ; Save a copy of s, for returning.
	rep stosb  ; Uses ES. Must be same as DS.
	xchg ax, bx  ; AX := s; BX := junk.
	mov di, dx  ; Restore DI. DX is now junk.
	ret
ENDIF

; int strcmp(const char *s1, const char *s2);
;
; Compares the strings pointed to by s1 and s2.  Returns zero if
; strings are identical, a positive number if s1 greater than s2,
; and a negative number otherwise.
IFDEF U_strcmp
PUBLIC _strcmp
_strcmp:
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov si, sp
	mov di, [si+4]  ; Argument s2.
	mov si, [si+2]  ; Argument s1.
strcmpnext:
	lodsb
	scasb  ; Uses ES. Must be same as DS.
	jne strcmpdiff
	cmp al, 0
	jne strcmpnext
	xor ax, ax
	jmp strcmpdone
strcmpdiff:
	sbb ax, ax
	or al, 1
strcmpdone:
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
ENDIF

; char *strcpy(char *s1, const char *s2);
;
; Copy the string pointed to by s2, including the terminating null
; character, into the array pointed to by s1.  Returns s1.
IFDEF U_strcpy
PUBLIC _strcpy
_strcpy:
IFDEF U_strcat
	call strcpysetup
ELSE
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov di, sp
	mov si, [di+4]  ; Argument s2.
	mov di, [di+2]  ; Argument s1.
	mov cx, di  ; Save a copy of s1, for returning.
ENDIF
strcpynext:
	lodsb
	stosb  ; Uses ES. Must be same as DS.
	test al, al
	jnz strcpynext
	xchg ax, cx  ; AX := s1; CX := junk.
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
IFDEF U_strcat
strcpysetup:  ; Code shared by _strcpy and _strcat.
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov di, sp
	mov si, [di+6]  ; Argument s2.
	mov di, [di+4]  ; Argument s1.
	mov cx, di  ; Save a copy of s1, for returning.
	ret
ENDIF
ENDIF

; char *strcat(char *s1, const char *s2)
;
; Concatenates the string pointed to by s2 onto the end of the
; string pointed to by s1.  Returns s1.
IFDEF U_strcat
PUBLIC _strcat
_strcat:
IFDEF U_strcpy
	call strcpysetup
ELSE
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov di, sp
	mov si, [di+4]  ; Argument s2.
	mov di, [di+2]  ; Argument s1.
	mov cx, di  ; Save a copy of s1, for returning.
ENDIF
	mov al, 0
strcatnext:
	scasb  ; Uses ES. Must be same as DS.
	jne strcatnext
	dec di  ; Undo the skipping over the last NUL.
IFDEF U_strcpy
	jmp strcpynext
ELSE
strcatcopynext:
	lodsb
	stosb  ; Uses ES. Must be same as DS.
	test al, al
	jnz strcatcopynext
	xchg ax, cx  ; AX := s1; CX := junk.
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
ENDIF
ENDIF

; size_t strlen(const char *s);
;
; Returns the length of the string pointed to by s.
IFDEF U_strlen
PUBLIC _strlen
_strlen:
	mov bx, ds
	mov es, bx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, di  ; Save DI.
	mov di, sp
	mov di, [di+2]  ; Argument s.
	mov cx, -1
	xor al, al  ; Also sets ZF := 1, which is needed below for the emptry string.
	repne scasb  ; Uses ES. Must be same as DS.
	not cx  ; Silly trick gives length (including the NUL byte).
	dec cx  ; Forget about the NUL byte.
	xchg ax, cx  ; AX := result; CX := junk.
	mov di, bx  ; Restore DI. BX is now junk.
	ret
ENDIF

; char *strrchr(const char *s, int c);
;
; Locates final occurrence of c (as unsigned char) in string s.
IFDEF U_strrchr
PUBLIC _strrchr
_strrchr:
	mov bx, si  ; Save SI.
	mov si, sp
	mov ah, [si+4]  ; Argument c.
	mov si, [si+2]  ; Argument s.
	xor dx, dx  ; Initial return value of NULL.
strrchrnext:
	lodsb
	cmp al, ah
	jne strrchrdiff
	mov dx, si
	dec dx  ; Make DX point to the last occurrence c, not after it.
strrchrdiff:
	test al, al
	jnz strrchrnext
	xchg ax, dx  ; AX := pointer to last match; DX := junk.
	mov si, bx  ; Restore SI. BX is now junk.
	ret
ENDIF

; int strncmp(const char *s1, const char *s2, size_t n);
;
; Compares up to n characters from the strings pointed to by s1
; and s2.  Returns zero if the (possibly null terminated) arrays
; are identical, a positive number if s1 is greater than s2, and
; a negative number otherwise.
IFDEF U_strncmp
PUBLIC _strncmp
_strncmp:
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov si, sp
	mov cx, [si+6]  ; Argument n.
	jcxz strncmpequal
	mov di, [si+4]  ; Argument s2.
	mov si, [si+2]  ; Argument s1.
strncmpnext:
	lodsb
	scasb  ; Uses ES. Must be same as DS.
	je strncmpsame
	sbb ax, ax
	sbb ax, -1  ; With the previous instruction: AX := (CF ? -1 : 1).
	jmp strncmpret
strncmpsame:
	test al, al
	jz strncmpequal
	loop strncmpnext
strncmpequal:
	xor ax, ax
strncmpret:
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
ENDIF

; int memcmp(const void *s1, const void *s2, size_t n)
;
; Compares the first n characters of the objects pointed to by
; s1 and s2.  Returns zero if all characters are identical, a
; positive number if s1 greater than s2, a negative number otherwise.
IFDEF U_memcmp
PUBLIC _memcmp
_memcmp:
	mov dx, ds
	mov es, dx  ; ES := DS. This is needed even with `wcc -r', because the code generated by the OpenWatcom C compiler (wcc) for a switch--case may ruin ES.
	mov bx, si  ; Save SI to BX.
	mov dx, di  ; Save DI to DX.
	mov si, sp
	mov cx, [si+6]  ; Argument n.
	mov di, [si+4]  ; Argument s2.
	mov si, [si+2]  ; Argument s1.
	xor ax, ax  ; Also sets ZF := 1, which is needed below for the emptry string.
	repe cmpsb  ; Continue while equal. Uses ES. Must be same as DS.
	je memcmpret
	inc ax
	jnc memcmpret
	neg ax
memcmpret:
	mov di, dx  ; Restore DI. DX := junk.
	mov si, bx  ; Restore SI. BX := junk.
	ret
ENDIF

_TEXT ENDS

END _cstart_  ; _cstart_ will be the program entry point.
