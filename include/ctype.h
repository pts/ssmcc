#ifndef _CTYPE_H
#define _CTYPE_H

#if __STDC__
#  define _LIBCP(x) x
#else
#  define _LIBCP(x) ()
#endif

/* For all these functions, the C standard requires that the input c is: c >= -1 && c <= 255. */
int isalnum  _LIBCP((int c));  /* int i = c & 255; return ((i >= 'A' && i <= 'Z') || (i >= 'a' && i <= 'z') || (i >= '0' && i <= '9')); */
int isalpha  _LIBCP((int c));  /* int i = c & 255; return ((i >= 'A' && i <= 'Z') || (i >= 'a' && i <= 'z')); */
int isascii  _LIBCP((int c));  /* int i = c & 255; return ((i) >= 0 && (i) <= 127); */
int isdigit  _LIBCP((int c));  /* int i = c & 255; return (i >= '0' && i <= '9'); */
int islower  _LIBCP((int c));  /* int i = c & 255; return (i >= 'a' && i <= 'z'); */
int isprint  _LIBCP((int c));  /* int i = c & 255; return ((i) >= 32 && (i) <= 126); */
int isspace  _LIBCP((int c));  /* int i = c & 255; return ((i >= 9 && i <= 13) || i == ' '); */
int isupper  _LIBCP((int c));  /* int i = c & 255; return (i >= 'A' && i <= 'Z'); */
int isxdigit _LIBCP((int c));  /* int i = c & 255; return ((i >= 'A' && i <= 'F') || (i >= 'a' && i <= 'f') || (i >= '0' && i <= '9')); */
int tolower  _LIBCP((int c));  /* int i = c & 255; return (i >= 'A' && i <= 'Z') ? i + 'a' - 'A' : c; */
int toupper  _LIBCP((int c));  /* int i = c & 255; return (i >= 'a' && i <= 'z') ? i + 'A' - 'a' : c; */

#undef _LIBCP
#endif  /* _CTYPE_H */
