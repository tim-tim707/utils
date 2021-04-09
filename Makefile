# Attempt at a somewhat automatic Makefile
# make init to create directories

CC := gcc
CFLAGS := -std=c99 -g -Wall -Wextra -fsanitize=address
LDFLAGS :=

FLAGS := $(CFLAGS) $(LDFLAGS)

EXEC := main
SOURCEDIR := src
HEADERDIR := headers
OBJECTSDIR := obj


SOURCES := $(shell find $(SOURCEDIR) -name '*.c' 2>&1)
OBJECTS := $(patsubst $(SOURCEDIR)/%.c, $(OBJECTSDIR)/%.o, $(SOURCES))


.PHONY: all clean remake init
.DELETE_ON_ERROR:

all: $(EXEC)

$(EXEC): $(OBJECTSDIR)/$(OBJECTS)
	$(CC) $(FLAGS) -I$(HEADERDIR) -I$(SOURCEDIR) $(OBJECTS) -o $(EXEC)

$(OBJECTSDIR)/%.o: $(SOURCEDIR)/%.c
	$(CC) $(FLAGS) -I$(HEADERDIR) -I$(SOURCEDIR) -c $< -o $@

list:
	@echo $(SOURCES)
	@echo $(OBJECTS)
clean:
	$(RM) -r $(OBJECTSDIR)/* $(EXEC)

remake:
	clean all

init:
	@mkdir -p $(SOURCEDIR) $(HEADERDIR) $(OBJECTSDIR)
