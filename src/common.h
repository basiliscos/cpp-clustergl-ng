#ifndef _COMMON_H
#define _COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <sys/uio.h>

#include <string>
#include <iterator>
#include <vector>
  
using std::vector;
using std::string;

#define LOG printf("[\e[32m%28s:%5d\e[m]\t", __FILE__, __LINE__); printf

#endif /* _COMMON_H */
