; 9 вариант
; квадратное уравнение

include intio.inc

.model small
.stack 100h
.data
msg_a	      db	'Input a:$'
msg_b	      db	'Input b:$'
msg_c	      db	'Input c:$'
a	      dw	(?)
b	      dw	(?)
c	      dw	(?)
msg_2r	      db	'There are 2 roots.$'
msg_re	      db	'There are 2 roots and they are equal.$'
msg_no	      db	'There are no roots.$'
sign	      db	0

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

mov bx, 10

output_msg msg_a
call input_number
mov a, cx

output_msg msg_b
call input_number
mov b, cx

output_msg msg_c
call input_number
mov c, cx

; b * b - 4 * a * c
mov dx, 0
mov ax, b
mul ax
mov cx, ax
mov ax, a
mov bx, c
mul bx
mov bx, 4
mul bx
sub cx, ax
js no_roots
jne two_roots
output_msg msg_re
jmp end_p

two_roots:
	output_msg msg_2r
	jmp end_p

no_roots:
	output_msg msg_no

end_p:

mov ah, 4ch
int 21h
end start
