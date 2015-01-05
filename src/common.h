#ifndef _COMMON_H
#define _COMMON_H

#include <stdio.h>
#define LOG printf("[\e[32m%20s:%5d\e[m]\t", __FILE__, __LINE__); printf

#endif /* _COMMON_h */
