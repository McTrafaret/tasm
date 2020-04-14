; (369 - 3856) + x / (y * 336)

.model small
.stack 100h

.data
x	db	0
y	dw	588h
z	dw	0

.code
start:
mov ax, @data
mov ds, ax

mov bx, 369h
sub bx, 3856h
mov ax, y ; перемещаем переменную(16 бит) в ax чтобы умножить
mov cx, 8735h
imul cx ; умножаем, результат в dx:ax (y * 336)
mov cx, ax ; перемещаем младшую часть произведения в cx
mov al, x ; x в al
cbw ; x в ax
cwd ; x в dx:ax
idiv cx ; делим dx:ax на cx, результат в ax
add bx, ax ; (369-3856) + x/(младшая часть y*336)

mov ah, 4ch
int 21h
end start
