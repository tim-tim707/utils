define HELP
An Attempt at a somewhat automated Makefile
Timothee Denizou

Customizable variables:
    Compiler and flags:

        CC: Compiler to use
        FLAGS: Custom flags are added here
        LINKFLAGS: Library flags are added here

    Project directories and files:
        EXEC: Name of the executable file.
              The executable file *MUST NOT* have a header file associated
        TEST: Name of the executable test file
        SOURCEDIR: Name of the directory containing the source files
        HEADERDIR: Name of the directory containing the header files,
                   can be the same as the source file
        TESTDIR: Name of the directory containing the test files

USAGE:
        make [COMMAND]

note: COMMAND can be blank. In this case, all is executed

Command list:
        all build b: Build the EXEC file.
        test t: Build the TEST file and runs it
        run r: Runs the EXEC file
        coverage cov: create code coverage.html using gcovr
        help h: Print this help message
        clean c: Clean up the executable file, the test file and the object directory
        remake: Clean and build
        list ls: List the source files, object files and test files
        prep: Internal command. Create the required directories

endef
# make prep to create directories, src/main.x is a mandatory file

# use packages with $(shell pkg-config --libs my_lib_name)
# Example 1: $(shell sdl2-config --libs --cflags)
# Example 2: $(shell pkg-config --libs SDL_image)
CC := g++
SANITIZE := -fsanitize=address -fsanitize=undefined -fsanitize=bounds
CFLAGS := -O0 -g -Wall -Wextra -Wpedantic

# coverage flags can be toggled when needed
COVERAGEFLAGS := -p --coverage -fPIC -O0

FLAGS := $(CFLAGS) $(COVERAGEFLAGS)
LINKFLAGS :=
DEBUGFLAGS := $(FLAGS) -g -O0 -DDEBUG

# using criterion for test suite
TESTFLAGS := $(FLAGS) -lcriterion

EXEC := main
TEST := test
SOURCEDIR := src
HEADERDIR := headers
OBJECTSDIR := obj
TESTDIR := tests

SOURCES := $(shell find $(SOURCEDIR) -name '*.c' -or -name '*.cpp' ! -name 'main.*' 2>&1) # main is excluded, no main.h
OBJECTS := $(patsubst $(SOURCEDIR)/%, $(OBJECTSDIR)/%.o, $(basename $(SOURCES)))
TESTS := $(shell find $(TESTDIR) -name '*.c' -or -name '*.cpp' 2>&1)

.PHONY: all build b test t run r help h clean c remake list ls prep coverage cov
.DELETE_ON_ERROR:

all build b: prep $(EXEC)

$(EXEC): $(OBJECTSDIR)/$(OBJECTS) $(OBJECTSDIR)/main.o
        $(CC) -I$(HEADERDIR) -I$(SOURCEDIR) $(OBJECTS) $(OBJECTSDIR)/main.o -o $@ $(FLAGS) $(LINKFLAGS)

$(OBJECTSDIR)/main.o: $(SOURCEDIR)/main.*
        $(CC) $(FLAGS) -c $< -o $@

$(OBJECTSDIR)/%.o: $(SOURCEDIR)/%.* $(HEADERDIR)/%.h
        $(CC) $(FLAGS) -c $< -o $@


test t: prep $(OBJECTS) $(TESTS)
        $(CC) $(TESTFLAGS) -I$(HEADERDIR) -I$(TESTDIR) $(OBJECTS) $(TESTS) $(LINKFLAGS) -o $(TEST)
        @./$(TEST)
        @make coverage


coverage cov:
        @gcovr -r . --html --html-details -o coverage.html


run r: $(EXEC)
        ./$(EXEC)


export HELP
help h:
        @echo "$$HELP"


clean c:
        $(shell find $(OBJECTSDIR) -type f -delete)
        $(RM) $(EXEC) $(TEST) coverage.* sandbox-gmon.* *.gcda *.gcno gmon.out latex/


remake:
        @make clean
        @make all


list ls:
        @echo $(SOURCES)
        @echo $(OBJECTS)
        @echo $(TESTS)



prep: $(SOURCEDIR)/ $(HEADERDIR)/ $(OBJECTSDIR)/ $(TESTSDIR)/
        @$(RM) $(OBJECTSDIR)/main.o
        @$(RM) $(OBJECTSDIR)/test.o
        @$(shell find $(SOURCEDIR) -type d | sed -e "s?$(SOURCEDIR)?$(OBJECTSDIR)?" | xargs mkdir -p )
        @$(shell find $(SOURCEDIR) -type d | sed -e "s?$(SOURCEDIR)?$(HEADERDIR)?" | xargs mkdir -p )

%/:
        @mkdir -p $@
