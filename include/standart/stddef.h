#ifndef _STDDEF_H
#define _STDDEF_H

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
typedef unsigned int size_t;
#endif

typedef int ptrdiff_t;

typedef unsigned int wchar_t;

#define offsetof(type, member) ((size_t)&((type *)0)->member)

#endif /* _STDDEF_H */
