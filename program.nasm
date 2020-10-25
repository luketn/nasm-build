;name: program.nasm
;
;description: The program reads some input from stdin and writes it to stdout.
;
;build: nasm -felf64 program.nasm
;       ld program.o -o program
;
; Thanks to inspiration from:
; https://www.linuxnasm.be/examples/terminal-based/43-get-input-from-commandline

bits 64

%define  buffer_size    255

%define stdin 0
%define stdout 1
%define stderr 2

%define sys_read 0
%define sys_write 1
%define sys_exit 60

global _start

section .bss
    buffer:
    .start: resb    buffer_size
    .dummy: resb    1            ; help buffer to clear STDIN on buffer overflow
    .length equ     $-buffer.start

section .rodata
    question:
    .start:   db      "Enter some text (max 255 characters): "
    .length   equ     $-question.start

section .text

_start:
    ;print the QUESTION
    mov     rsi,question            ;start of message
    mov     rdx,question.length                 ;the length of the message to display
    call    Write
    ;read the answer
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, buffer
    mov rdx, buffer.length
    syscall
    push    rax                                 ;save bytes read
    ;check if more characters are given than the length of the buffer
    cmp     rax,buffer.length                   ;are there more characters than allowed?
    jl      WriteAnswer                         ;no, so write buffercontent to STDOUT
    cmp     byte[rsi+rdx-1],10                  ;last character is EOL?
    je      WriteAnswer                         ;yes, also write the buffercontent to STDOUT
    mov     byte[rsi+rdx-1],13                  ;no, put carriage-return in place
clearSTDIN:                                     ;Check for extra characters in the buffer
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, buffer.dummy
    mov rdx, 1
    syscall                                     ;read next byte from buffer
    cmp     byte[rsi],10                        ;is it EOL?
    jne     clearSTDIN                          ;no continue with the next
    ;at this point we've read all the remaining bytes
WriteAnswer:
    mov     rsi,buffer
    mov     rdx,buffer.length
    call    Write
    mov rax, sys_exit
    mov rdi, 0
    syscall
Write:
    ;rsi and rdx contains the pointer to the string and his length respectively
    mov rax, sys_write
    mov rdi, stdout
    syscall
    ret
