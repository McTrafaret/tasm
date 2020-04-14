; (369 - 3856) + x / (y * 336)
.model small
.stack 100h

.data
x	dw	(?)
y	dw	(?)
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

;Проверяем первый символ введённого числа
mov ah, 01h
int 21h
cmp al, 2dh ; Сравниваем с '-'
jne plus ; Если не '-' то это цифра
mov sign, 1 ; Индикатор знака
mov ah, 01h ; Следующий символ уж точно число, считываем
int 21h

plus:

sub al, 30h ; Получаем из символа цифру числа
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
	cmp sign, 1 ; Если число отрицательное, негейтим его
	jne notsign
	neg cx
	mov sign, 0
notsign:
	mov x, cx

;Вводим y
mov ah, 09h
mov dx, offset msg2
int 21h

;Проверяем первый символ введённого числа
mov ah, 01h
int 21h
cmp al, 2dh ; Сравниваем с '-'
jne plus1 ; Если не '-' то это цифра
mov sign, 1 ; Индикатор знака
mov ah, 01h ; Следующий символ уж точно число, считываем
int 21h

plus1:

sub al, 30h ; Получаем из символа цифру числа
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
	cmp sign, 1 ; Если число отрицательное, негейтим его
	jne notsign1
	neg cx
	mov sign, 0
notsign1:
	mov y, cx


;Вычисляем
mov bx, 369
sub bx, 3856
mov ax, y ; перемещаем переменную(16 бит) в ax чтобы умножить
mov cx, 336
imul cx ; умножаем, результат в dx:ax (y * 336)
mov cx, ax ; перемещаем младшую часть произведения в cx
mov ax, x ; x в ax
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
