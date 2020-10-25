# Use this image to do linux Netwide Assembler (NASM) assembly language compilation.

# Mount the current at /code and compile program.nasm to program.o:
#    docker run -v $(pwd):/code nasm-build nasm -f elf64 program.nasm

# Link the program.o object file into an executable 'program':
#    docker run -v $(pwd):/code nasm-build ld program.o -o program

# Run the program!
#    docker run -it -v $(pwd):/code nasm-build ./program

FROM alpine
RUN apk add --no-cache binutils nasm
RUN mkdir /code
WORKDIR /code
SHELL ["/bin/busybox"]