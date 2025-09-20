# Apollo Vampire 68080 Project Makefile

# Toolchain configuration
CC = m68k-amigaos-gcc
LD = m68k-amigaos-ld
AS = m68k-amigaos-as
OBJCOPY = m68k-amigaos-objcopy

# Apollo-specific compiler flags
CFLAGS = -m68080 -O2 -fomit-frame-pointer -Wall
CFLAGS += -noixemul -mcrt=nix13
CFLAGS += -I$(APOLLO_SDK)/ndk/include
CFLAGS += -I$(APOLLO_SDK)/apollo/include
CFLAGS += -DAPOLLO_68080

# Linker flags
LDFLAGS = -noixemul -mcrt=nix13
LDFLAGS += -L$(APOLLO_SDK)/ndk/lib

# Source and target
SOURCES = main.c
TARGET = hello-apollo

# Build rules
all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET) *.o

install: $(TARGET)
	@echo "Copy $(TARGET) to your Apollo/Amiga system"

.PHONY: all clean install