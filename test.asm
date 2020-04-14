; (369 - 3856) + x / (y * 336)

include intio.inc

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
input_number proc

	;Проверяем первый символ введённого числа
	input_chr
	cmp al, 2dh ; Сравниваем с '-'
	jne plus ; Если не '-' то это цифра
	mov sign, 1 ; Индикатор знака
	input_chr ; Следующий символ уж точно число, считываем

	plus:

	sub al, 30h ; Получаем из символа цифру числа
	cbw ; Очищаем ah от мусора
	mov cx, ax ; Перемещаем первую цифру в сх

	loop1:
		input_chr
		cmp al, 0dh
		je end1
		sub al, 30h
		cbw ; до этого момента всё то же самое что и для первой цифры
		xchg ax, cx ; Меняем ах и сх чтобы умножить первую цифру
		mul bx ; Умножаем на 10
		add cx, ax ; добавляем вторую цифру
		jmp loop1 ; повторяем
	end1:
		cmp sign, 1 ; Если число отрицательное, негейтим его
		jne notsign
		neg cx
		mov sign, 0
	notsign:
		ret

input_number endp

start:
mov ax, @data
mov ds, ax

mov bx, 10 ; для Горнера

;Вводим x
output_msg msg1

call far ptr input_number
mov x, cx

;Вводим y
output_msg msg2

call far ptr input_number
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

mov dx, 0 ; очищаем dx
mov bx, 0 ; наш счетчик
mov cx, 10 ; десятка для деления

;Узнаем длину числа
loop4:
	cmp ax, 0 ; если в ах 0, то выходим из цикла
	je end4
	idiv cx ; делим число на 10

	mov dx, 0 ; так как мы делим dx:ax на регистр,
		  ; то чтобы не возник бесконечный цикл, очищаем dx
	inc bx ; увеличиваем значение счётчика на 1
	jmp loop4 ; повторяем
end4:
	mov len, bl ; записываем длину числа в память

	mov ax, result ; возвращаем в регистр ах результат,
		       ; который был утерян в ходе вычисления длины числа

;Выводим число

mov number+bx, '$' ; засовываем в конец строки знак доллара,
		   ; чтобы прерывание выводило ТОЛЬКО наше число
loop5:
	cmp bx, 0 ; проверяем закончилось ли наше число, если да то выходим из цикла
	je end5
	dec bx ; уменьшаем счётчик на 1
	idiv cx ; делим число на 10
	add dx, 30h ; добавляем к цифре код символа, чтобы вывести
	mov number+bx, dl ; заносим уже символ в нужное место в строке
	mov dx, 0 ; очищаем dx снова
	jmp loop5 ; повторяем
end5:
	cmp sign, 1 ; если знак не отрицательный то сразу выводим число
	jne output
minus:
	mov ah, 02h ; прерывание для вывода одного символа
	mov dl, '-'
	int 21h
output:
	output_msg number ; выводим число

mov ah, 4ch
int 21h
end start
