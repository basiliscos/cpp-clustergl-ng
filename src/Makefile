UNAME := $(shell uname -s)

NAME=cglng

#files
SOURCES := $(wildcard *.cpp)
OBJS := $(patsubst %.cpp, %.o, $(SOURCES))

OBJS_SHARED := $(patsubst mod_app_dummy.o,,$(OBJS))
OBJS_APP := $(patsubst mod_app.o,,$(OBJS))
DEPS := $(wildcard include/*.h)

CXXFLAGS=$(ARCH) -I/opt/local/include/ -Iinclude -Wextra -g -fPIC -fvisibility-inlines-hidden `sdl-config --cflags`
LDFLAGS=-lconfuse -llzo2 -lz `sdl-config --libs` -lSDL_net -lconfuse -lGLEW
LINUX_LDFLAGS=-lGL -lGLU

all: $(OBJS) $(NAME)

Interceptor.o: Interceptor.cpp

TextProcessor.o: TextProcessor.cpp generated.h

ExecProcessor.o: ExecProcessor.cpp generated.h

custom_commands.o: custom_commands.cpp custom_commands.h generated.h

NetOutputProcessor.o: NetOutputProcessor.cpp generated.h

gl.h.xml: /usr/include/GL/gl.h
	cscan --xml $^ > $@

gl.h.cache: gl.h.xml
	PERL5LIB=../lib ../script/code-gen.pl -a $^ -f '^gl' -c $@

generated.h: gl.h.cache
	PERL5LIB=../lib ../script/code-gen.pl -c $^ -r declaration -o .

generated_packer.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r packer -o .

generated_capturer.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r capturer -o .

generated_packed_dumper.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r packed_dumper -o .

generated_function_names.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r function_names -o .

generated_packed_executor.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r packed_executor -o .


$(NAME): $(OBJS) generated_packer.o generated_capturer.o generated_packed_dumper.o generated_function_names.o generated_packed_executor.o
#	$(CXX) -o ../runtime/$@-render $(OBJS_APP) $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)
	$(CXX) -shared -o ../runtime/lib$@-capture.so $^ $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)

clean:
	@rm -f *.o ../runtime/$(NAME) ../runtime/lib$(NAME).so generated*
