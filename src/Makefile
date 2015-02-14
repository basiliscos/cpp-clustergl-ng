UNAME := $(shell uname -s)

OBJS_GENERATED := generated_packer.o generated_capturer.o generated_packed_dumper.o generated_function_names.o generated_packed_executor.o generated_serializer.o
SOURCES := $(wildcard *.cpp)
OBJS_HANDMADE := $(filter-out $(OBJS_GENERATED), $(patsubst %.cpp, %.o, $(SOURCES)) ) 
OBJS := $(OBJS_HANDMADE) $(OBJS_GENERATED)

OBJS_SHARED := $(filter-out Node.o, $(OBJS))
OBJS_NODE := $(filter-out generated_capturer.o generated_packer.o Interceptor.o NetOutputProcessor.o NetTierProcessor.o, $(OBJS))

CXXFLAGS=$(ARCH) -frtti -I/opt/local/include/ -Iinclude -Wextra -g -fPIC -fvisibility-inlines-hidden `sdl-config --cflags`
LDFLAGS=-lconfuse -ldl -llzo2 -lz `sdl-config --libs` -lconfuse -lGLEW
LINUX_LDFLAGS=-lGL -lGLU

all: ../runtime/libcglng-capture.so ../runtime/node

Interceptor.o: Interceptor.cpp

TextProcessor.o: TextProcessor.cpp generated.h

ExecProcessor.o: ExecProcessor.cpp generated.h

Deserializer.o: Deserializer.cpp generated.h

custom_commands.o: custom_commands.cpp custom_commands.h generated.h

NetOutputProcessor.o: NetOutputProcessor.cpp generated.h

sizes.o: sizes.cpp generated.h

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

generated_serializer.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r serializer -o .

generated_packed_executor.cpp: gl.h.cache generated.h
	PERL5LIB=../lib ../script/code-gen.pl -c gl.h.cache -r packed_executor -o .

../runtime/libcglng-capture.so: $(OBJS_SHARED)
	$(CXX) -shared -o $@ $^ $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)

../runtime/node: $(OBJS_NODE)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDFLAGS) $(LINUX_LDFLAGS)

clean:
	@rm -f $(OBJS) ../runtime/libcglng-capture.so ../runtime/node generated*
