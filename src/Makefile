UNAME := $(shell uname -s)

NAME=cglng

#files
SOURCES := $(wildcard *.cpp)
OBJS := $(patsubst %.cpp, %.o, $(SOURCES)) 

OBJS_SHARED := $(patsubst mod_app_dummy.o,,$(OBJS)) 
OBJS_APP := $(patsubst mod_app.o,,$(OBJS)) 
DEPS := $(wildcard include/*.h) 

CXXFLAGS=$(ARCH) -I/opt/local/include/ -Iinclude -O3 -Wextra -g -fPIC -fvisibility-inlines-hidden 
LDFLAGS=-lconfuse -llzo2 -lz `sdl-config --cflags --libs` -lSDL_net -lconfuse -lGLEW 
LINUX_LDFLAGS=-lGL -lGLU

all: $(OBJS) $(NAME)

Interceptor.o: Interceptor.cpp capture.cpp

gl.h.xml: /usr/include/GL/gl.h
	cscan --xml $^ > $@

capture.cpp: ../code-gen.pl
	../code-gen.pl -r capture > capture.cpp

$(NAME): $(OBJS)
#	$(CXX) -o ../runtime/$@-render $(OBJS_APP) $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)
	$(CXX) -shared -o ../runtime/lib$@-capture.so $(OBJS_SHARED) $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)

clean:
	rm -f *.o
	rm -f ../runtime/$(NAME)
	rm -f ../runtime/lib$(NAME).so.1
	rm -r capture.*
