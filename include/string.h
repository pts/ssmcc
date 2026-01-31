#ifndef _STRING_H
#define _STRING_H

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

void *memcpy _LIBCP((void *_t, const void *_s, size_t _length));
void *memset _LIBCP((void *_s, int _c, size_t _nbytes));
int strcmp _LIBCP((const char *_s1, const char *_s2));
char *strcpy _LIBCP((char *_target, const char *_source));
char *strcat _LIBCP((char *_target, const char *_source));
size_t strlen _LIBCP((const char *_s));
char *strchr _LIBCP((const char *_s, int _c));
char *index _LIBCP((const char *_s, int _c));  /* Same as strchr(...). */
char *strrchr _LIBCP((const char *_s, int _c));
char *rindex _LIBCP((const char *_s, int _c));  /* Same as strrchr(...). */
int strncmp _LIBCP((const char *_s1, const char *_s2, size_t _nbytes));
int memcmp _LIBCP((const void *_s1, const void *_s2, size_t _nbytes));

#if 0
memchr  /* Not implemented yet. */
memmove  /* Not implemented yet. */
strcasecmp  /* Not implemented yet. */
strcspn  /* Not implemented yet. */
strdup  /* Not implemented yet. */
strncasecmp  /* Not implemented yet. */
strncat  /* Not implemented yet. */
strncpy  /* Not implemented yet. */
strspn  /* Not implemented yet. */
strstr  /* Not implemented yet. */
strtok  /* Not implemented yet. */
#endif

#undef _LIBCP
#endif  /* _STRING_H */
