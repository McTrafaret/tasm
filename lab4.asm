; (369 - 3856) + x / (y * 336)
.model small
.stack 100h

.data
x	db	(?)
y	db	(?)
result	dw	(?)
msg1	db	'Input x:', '$'
msg2	db	'Input y:', '$'
number  db	6 dup (?)
len	db	(?)
sign	db	(?)

.code
start:
mov ax, @data
mov ds, ax

mov bx, 10 ; для Горнера

;Вводим x
mov ah, 09h
mov dx, offset msg1
int 21h

mov ah, 01h
int 21h
sub al, 30h
cbw
mov cx, ax

loop1:
	mov ah, 01h
	int 21h
	cmp al, 0dh
	je end1
	sub al, 30h
	cbw
	xchg ax, cx
	mul bx
	add cx, ax
	jmp loop1
end1:
	mov x, cl

;Вводим y
mov ah, 09h
mov dx, offset msg2
int 21h

mov ah, 01h
int 21h
sub al, 30h
cbw
mov cx, ax

loop2:
	mov ah, 01h
	int 21h
	cmp al, 0dh
	je end2
	sub al, 30h
	cbw
	xchg ax, cx
	mul bx
	add cx, ax
	jmp loop2
end2:
	mov y, cl


;Вычисляем
mov bx, 369
sub bx, 3856
mov al, y ; перемещаем переменную(16 бит) в ax чтобы умножить
cbw
mov cx, 336
imul cx ; умножаем, результат в dx:ax (y * 336)
mov cx, ax ; перемещаем младшую часть произведения в cx
mov al, x ; x в al
cbw ; x в ax
cwd ; x в dx:ax
idiv cx ; делим dx:ax на cx, результат в ax
add ax, bx ; (369-3856) + x/(младшая часть y*336)

cmp ax, 0
jns positive

negative:
	mov sign, 1
	neg ax

positive:

mov result, ax ; Сохраняем результат

mov dx, 0
mov bx, 0 ; наш счетчик
mov cx, 10 ; десятка для деления

;Узнаем длину числа
loop4:
	cmp ax, 0
	je end4
	idiv cx
	mov dx, 0
	inc bx
	jmp loop4
end4:
	mov len, bl
	mov ax, result

;Выводим число
mov number+bx, '$'
loop5:
	cmp bx, 0
	je end5
	dec bx
	idiv cx
	add dx, 30h
	mov number+bx, dl
	mov dx, 0
	jmp loop5
end5:
	cmp sign, 1
	je minus
	jmp output
minus:
	mov ah, 02h
	mov dl, '-'
	int 21h
output:
	mov ah, 09h
	mov dx, offset number
	int 21h

mov ah, 4ch
int 21h
end start
