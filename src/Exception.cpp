#include "Exception.h"

Exception::Exception(const char* reason):_reason(reason) {
}

const char* Exception::what() {
  return _reason.c_str();
}

Exception::~Exception() throw() {
}
