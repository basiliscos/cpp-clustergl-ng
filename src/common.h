#ifndef _COMMON_H
#define _COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <vector>
#include <memory>
  
using std::vector;
using std::auto_ptr;

#define LOG printf("[\e[32m%20s:%5d\e[m]\t", __FILE__, __LINE__); printf

#endif /* _COMMON_H */
