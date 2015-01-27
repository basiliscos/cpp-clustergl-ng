#ifndef _EXCEPTION_H
#define _EXCEPTION_H

#include <exception>
#include <string>

class Exception: public std::exception {
 private:
  const std::string _reason;
 public:
  Exception(const char* reason);
  virtual ~Exception() throw();
  const char* what();
};

#endif /* _EXCEPTION_H */
