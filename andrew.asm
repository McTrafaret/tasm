.model small
.stack 1000h

.data

x       dw  (?)
y       dw  (?)
number	dd  (?)
out1    db  'Input x: ', '$'
out2    db  'Input y: ', '$'
result  db  11 dup (?)
len   db  (?)

.386
.code
start:

mov ax, @data
mov ds, ax

mov ah, 09h
mov dx, offset out1
int 21h

mov ah, 01h
int 21h
sub al, 30h
cbw
mov cx, ax


mov bx, 10
loop1:
    mov ah, 01h
    int  21h
    cmp al, 0dh
    je end1
    sub al, 30h
    cbw
    xchg ax, cx
    mul bx
    add cx, ax
    jmp loop1
end1:
    mov x, cx

mov ah, 09h
mov dx, offset out2
int 21h

mov ah, 01h
int 21h
sub al, 30h
cbw
mov cx, ax

loop2:
    mov ah, 01h
    int  21h
    cmp al, 0dh
    je end2
    sub al, 30h
    cbw
    xchg ax, cx
    mul bx
    add cx, ax
    jmp loop2
end2:
    mov y, cx

;(588 * 745) - x + (y / 12)
mov ax, y
xor dx, dx
mov bx, 12
idiv bx ; y / 12

sub ax, x
mov cx, ax ; y / 12 - x

mov ax, 588
mov bx, 745
imul bx
sub ax, cx
sbb dx, 0 ; dx:ax -- 588 * 745 - x + y / 12
mov word ptr number, ax
mov word ptr number+2, dx

mov dx, 0
mov bx, 0
mov ecx, 10

mov eax, number
loop3:
    cmp ax, 0
    je end3
    idiv ecx
    xor edx, edx
    inc bx
    jmp loop3
end3:
    mov len, bl
    mov eax, number

mov result + bx, '$'
mov ecx, 10
outputl:
    cmp bx, 0
    je end5
    dec bx
    idiv ecx
    add dl, 30h
    mov result + bx, dl
    mov edx, 0
    jmp outputl
end5:
    mov ah, 09h
    mov dx, offset result
    int 21h

mov ah, 4ch
int 21h
end start
