# ssmcc: simple small-model C compiler for i86 Unix-like, using OpenWatcom v2

ssmcc is a simple C compiler toolchain using the small memory model (at most
64 KiB of code per program, at most 64 KiB of data per program) in the
generted code, targeting the 16-bit Intel x86 and the operating systems
Minix i86 and ELKS, ssmcc is a cross-compiler: you compile your C program on
Linux i386 or amd64, and you run them on Minix i86 or ELKS.

ssmcc is designed to run on any modern Linux i386 or Linux amd64 system
out-of-the-box (it doesn't matter which distro). It's self-contained: the
repository has all the programs it needs precompiled and saved to the the
tools/ directory.


Quick try on Linux (run the commands without the leading `$`):

```
$ git clone https://github.com/pts/ssmcc
...
$ cd ssmcc
$ echo 'int main() { return write(1, "Hello, World!\n", 14) != 14; }' >hw.c
$ ./ssmcc -belks -Os -Wno-n131 -o hwe hw.c
$ ls -l hwe
-rwxrwxr-x 1 user group 131 Jan 31 16:35 hwe
$ ./ssmcc --elksemu ./hwe
Hello, World!
$ _
```

Some other examples:

```
$ ssmcc -bminix -Os -W -Wall -o myprog.mx myprog.c  # Targets Minix i86.
$ ssmcc -belks  -Os -W -Wall -o myprog.lk myprog.c  # Targets ELKS.
```

ssmcc accepts the same command-line arguments as owcc (the OpenWatcom v2
C compiler Unix driver), which is similar to GCC and Clang.

Use ssmcc to compile some real code (the
[mininasm](https://github.com/pts/mininasm) assembler):

```
$ git clone https://github.com/pts/mininasm
# cd mininasm
$ gcc -s -O2 -W -Wall -o mininasm mininasm.c
$ ./mininasm -O9 -o minnnasm.com.host minnnasm.nasm
$ ls -l minnnasm.com.host
-rw-r--r-- 1 user group 20904 Jan 31 16:56 minnnasm.com.host
$ ../ssmcc -belks -s -O2 -W -Wall -o mininasm.lk mininasm.c
$ ls -l mininasm.lk
-rwxrwxr-x user group 23517 Jan 31 16:56 mininasm.lk
$ ../ssmcc --elksemu ./mininasm.lk -O9 -o minnnasm.com.lk minnnasm.nasm
$ cmp minnnasm.com.host minnnasm.com.lk && echo OK
OK
$ _
```

Another real-world example ssmcc can compile (for both Minix i86 and ELKS)
is the [minixbcc](https://github.com/pts/minixbcc) C compiler targeting
Minix i86 and i386. See the documentation there on which `ssmcc` commands to
run.

Explanation of the commands above:

1. We compile the assembler using the host GCC.
2. We assemble the test file *minnnasm.nasm* to *minnnasm.com.host* using
   the host-compiled assembler.
3. We compile the assembler targeting ELKS using ssmcc.
4. We assemble the test file *minnnasm.nasm* to *minnnasm.com.lk* using
   the ELKS-targeted assembler, in the ELKS emulator.
5. We compare that the assembly outputs are the same.

What's included in ssmcc:

* C compiler frontend command (custom shell script in [ssmcc](ssmcc));
  this is original contribution by pts
* C compiler targeting 16-bit Intel x86 (a copy of OpenWatcom v2 *wcc*;
  it includes preprocessor, frontend and backend)
* assembler targeting 16-bit Intel x86 etc. (a copy of OpenWatcom v2 *wasm*)
* linker (a copy of OpenWatcom v2 *wlink* and binary patcher tool to change
  the DOS MZ .exe output if *wlink* to an i86 a.out executable)
* a small C library, libc with >58 functions implemented
  (custom i86 assembly code in [ssmcc.asm](ssmcc.asm)); most of this is
  original contribution by pts
* C library headers (`#include` files)

Limitations of ssmcc:

* The most important limitation of the target systems supported by ssmcc is
  the memory limit: 64 KiB for the code (actually, for [Minix
  i86](https://www.minix3.org/) it's only 0xff00 bytes), and 64 KiB
  (independently) for the data (actually, for
  [ELKS](https://en.wikipedia.org/wiki/Embeddable_Linux_Kernel_Subset) it's
  only 0xfff0 bytes). This memory limit is because pointers are stored in
  16-bit registers. On other systems for i86 (such as ELKS (and DOS), it's
  possible to use segment registers (and e.g. the large memory model) to use
  up to 635 KiB of memory in a single process. ssmcc doesn't support these.
  The bundled C library (libc) has only >50 functions. For example, most of
  stdio (including printf(...) and scanf(...)) is missing. However,
  malloc(...), realloc(...) and free(...) are included. ssmcc is a bit
  slower than needed, because it compiles each C file twice (in the first
  pass it just discovers the libc function dependencies). It would be faster
  if the object files were reused between the two compile runs. ssmcc is a
  bit slower than needed, because the tool executables are compressed with
  UPX, and they get decompressed to memory each time a tool is invoked. For
  example, the C compiler executable program (wcc) is run (and thus gets
  decompressed) separately for each C source file. The target system has to
  be chosen at compile time. (It would be possible to create unified i86
  a.out executable program files, which detect Minix i86 vs ELKS at startup
  time.)

It would be possible to overcome these limitations, but that would take much
more effort than a small hobby project, and it would make the implementation
much larger.

## How does it work?

Most of the heavy lifting is done by the OpenWatcom v2 C compiler targeting
i86 (16-bit Intel x86). ssmcc includes an unmodified copy of a few
OpenWatcom v2 tools (owcc, wasm, wcc and wlink) precompiled for Linux i386.
However, OpenWatcom v2 doesn't support either Minix i86 or ELKS as a target.
The a.out executable file format for these system is generated by asking the
OpenWatcom v2 linker to produce a small-model DOS MZ .exe program file, and
some post-processing (28 lines of Perl code) is done to convert this file to
the relevant a.out format. Actually, thanks to the versatily configurability
of the OpenWatcom v2 tools, if the program is compiled with a carefully
crafted set of options, it's possible to change the first 0x20 bytes only:
i.e. to replace the DOS MZ .exe header with the relevant a.out header.

Some more details of generating the correct a.out header values:

* We are lucky, because the layout of the executable image after the header
  is the same for DOS MZ .exe and a.out: code (segment _TEXT), then data
  (segments CONST, CONST2 and _DATA). The OpenWatcom v2 C compiler,
  assembler and linker had to be configured to procuce the correct number of
  alignment bytes and count them properly.
* Most of the a.out executable header fileds are constants, except for
  a_text (sice of segment _TEXT), a_data (total size of segments CONST,
  CONST2 and _DATA) and a_bss (total size of segment _BSS). We can get the
  sum of a_text and a_data by looking at the DOS MZ .exe file size and
  subtracting the size of the header. We can get the sum of a_text, a_data
  and a_bss by looking at the stack pointer (and stack segment) value in the
  DOS MZ .exe header. (That's because the stack starts after _BSS, and this
  calculation includes both code and data.) To get a_data, we generate it
  from assembly code: we put a label to the end of _DATA, then we add a *dw*
  value to the beginning of the program image containing the offset of that
  label, and when doing the post-processing, after extracting a_data, we
  replace these 2 bytes in the file with (constant) machine code bytes. So,
  in fact, we change the first 34 bytes of the file.
* We do the alignment calculations carefully, always being aware whether a
  size value is aligned or not.

Since the code size per process is limited to 64 KiB, an optimizing C
compiler is used (OpenWatcom v2 is quite good when targeting i86), and the
functions in the C library are also written with limited code space in mind.
Actually, they are written in i86 assembly, most functions manually
optimized for size.

To reduce code size, a simple smart linking mechanism has also been added.
It works like this:

* The program source files are compiled twice, and the libc library files
  are omitted on purpose in think phase of the first pass.. The error
  messages of the linker are analyzed to figure out which symbols are
  missing. Typically these are the libc functions the program wants to use.
* The list of missing symbols are converted a list of definition
  command-line flags (for example, `-dU_open -dU_read -dU_close`), and
  passed to the assembler in pass 2. The libc source file
  [ssmcc.asm](ssmcc.asm) is full of ifdef()s (e.g. `ifdef U_read`), and when
  the OpenWatcom v2 assembler compiles it, it will emit code only for the
  functions actually used.
* In addition to omitting the implementation of unused library functions
  (which any reasonably linker already does), this smart linking mechanism
  makes a few cool optimizations possible, because it has a full list of all
  undefined symbols. One such optimization is that if only malloc(...) is
  used in the program (but not realloc(...) or free(...)), then a much
  simpler memory allocator implementation is emitted, which also uses less
  memory, because it doesn't have to track allocated blocks.
* It's also possible to (manually) merge parts of function bodies if more
  than one if them is used in the program. For example, if both memcpy(...)
  and memmove(...) are used, then memcpy(...) can be aliased to
  memmove(...), but if only memcpy(...) is used, a shorter implementation
  can be emitted. ssmcc does these merges to a small extent for Minix i86
  syscall wrappers, which are someimes quite long and repetitive.
* This technique is not smart enough to detect unused printf(...) format
  specifiers (e.g. no need to implement `'l'` if a *long* value is never
  passed to printf(....), and the OpenWatcom v2 C compiler doesn't provide
  the relevant hints.

## Historical significance

The 64 KiB limitation goes all the way back to
[PDP-11](https://en.wikipedia.org/wiki/PDP-11) minicomputer (introduced in
1970). The CPU in the first few iterations of this computer was able to
address 64 KiB of memory in total. Later iterations over the decade
increased this to 4 MiB, and also the per-process virtual memory limit to 64
KiB of code plus 64 KiB of data (this is the famous *separate I&D* bit in
the a.out header). To use more memory in a process directly, a new
architecture was needed. The [VAX](https://en.wikipedia.org/wiki/VAX) was
one of the famous first ones doing so. Its general-purpose registers were 32
bits, and they could be used as pointers.

The first few Intel x86 CPUs (e.g. 8086, 186, 286) starting in 1978 had the
same 64 KiB limitation, which was overcome by the 32-bit addresses in the
Intel 386 CPU introduced in 1985. However, even the 8086 was able to address
1 MiB of memory, using segment registers. This has lead to different memory
models (such as the small model for 16-bit code and 16-bit data, and the
large model where code and data together can fill the 1 MiB), and quite a
bit of inconvenience in assembly programming.

Minix on x86 (since 1987) until version 1.7.0 (released on 1995-05-30)
allowed only the small memory model for its processes. Other Unix systems in
the 1980s (such as Venix, PC-ix and Coherent) on x86 also had the
limitations of the small model. Microsoft Xenix was one of the first ones
supporting large-model processes.

Thus, until about 1990 it was imprtant to split larger Unix software to
executables with less than 64 KiB of code. That explains why C compilers in
the 1980s were split to 6 parts (driver, preprocessor, frontend, backend,
assembler, linker).

ELKS and Minix (up to version 2.0.4) are free and open source Unix-like
operating systems still usable in 2026 which still run on the i86
architecture. Thus they provide an excellent playground for C and assembly
programmers to improve there skills of squeezing more functionality into a
small code size.
