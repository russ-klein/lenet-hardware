
GCC        = /usr/bin/gcc
CC         = /usr/bin/gcc

CFLAGS     = -O3

all: 	if_gen_axi if_gen_ahb if_gen


if_gen_ahb:
	@echo "CC      $@.c"
	@$(CC) $(CFLAGS) -o $@ $@.c 

if_gen_axi:
	@echo "CC      $@.c"
	@$(CC) $(CFLAGS) -o $@ $@.c

if_gen:
	@echo "CC      $@.c"
	@$(CC) $(CFLAGS) -o $@ $@.c

clean:
	@echo "Removing created files and cruft"
	@rm -rf if_gen_axi if_gen_ahb if_gen 
