#ifndef _INTERCEPTOR_H
#define _INTERCEPTOR_H

class Interceptor
{
 private:
  int (*original_SDL_Init)(unsigned int flags);
 public:
	Interceptor();
    void intercept_sdl_init(unsigned int flags);
};

#endif /* _INTERCEPTOR_H */

