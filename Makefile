# Attempt at a somewhat automatic Makefile
# make prep to create directories, src/main.c is a mandatory file

CC := gcc
CFLAGS := -std=c99 -g -Wall -Wextra -fsanitize=address
LDFLAGS := -lm

FLAGS := $(CFLAGS)
LINKFLAGS := $(LDFLAGS)
DEBUGFLAGS := $(FLAGS) -g -O0 -DDEBUG
TESTFLAGS := $(FLAGS) -lcriterion

EXEC := main
TEST := test
SOURCEDIR := src
HEADERDIR := headers
OBJECTSDIR := obj
TESTDIR := tests

SOURCES := $(shell find $(SOURCEDIR) -name '*.c' ! -name 'main.c' 2>&1) # main.c is excluded, no main.h
OBJECTS := $(patsubst $(SOURCEDIR)/%.c, $(OBJECTSDIR)/%.o, $(SOURCES))
TESTS := $(shell find $(TESTDIR) -name '*.c' 2>&1)

.PHONY: all test clean remake prep
.DELETE_ON_ERROR:

all: prep $(EXEC)

$(EXEC): $(OBJECTSDIR)/$(OBJECTS) $(OBJECTSDIR)/main.o
        $(CC) -I$(HEADERDIR) -I$(SOURCEDIR) $(OBJECTS) $(OBJECTSDIR)/main.o -o $@ $(FLAGS) $(LINKFLAGS)

$(OBJECTSDIR)/main.o: $(SOURCEDIR)/main.c
        $(CC) -c $< -o $@ $(FLAGS) $(LINKFLAGS)

$(OBJECTSDIR)/%.o: $(SOURCEDIR)/%.c $(HEADERDIR)/%.h
        $(CC) -c $< -o $@ $(FLAGS) $(LINKFLAGS)


test t: prep $(TESTS)

$(TESTS): $(OBJECTS)
        $(CC) $(TESTFLAGS) -I$(HEADERDIR) -I$(TESTDIR) $(OBJECTS) $(TESTS) $(LINKFLAGS) -o $(TEST)


list ls:
        @echo $(SOURCES)
        @echo $(OBJECTS)
        @echo $(TESTS)


clean c:
        $(RM) -r $(OBJECTSDIR)/* $(EXEC) $(TEST)

remake: clean all

prep: $(SOURCEDIR)/ $(HEADERDIR)/ $(OBJECTSDIR)/ $(TESTSDIR)/
        @$(RM) $(OBJECTSDIR)/main.o
        @$(RM) $(OBJECTSDIR)/test.o

%/:
        @mkdir -p $@
