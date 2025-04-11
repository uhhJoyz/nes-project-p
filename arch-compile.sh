#!/usr/bin/env sh

# assemble cart.s into an object file, which is not executable yet
# this is because we could have several object files that need to be
# linked together using the linker
ca65 ./src/cart.s -o ./obj/cart.o -t nes
# link the object files
ld65 ./obj/cart.o -o ./cart.nes -t nes
