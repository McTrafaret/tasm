; Задание: подсчитать в каждой строке матрицы количество нечётных элементов

; считать матрицу из файла
; вывести на экран
; создать новый файл в первой строке которого
; записать имя файла с матрицей его дату и время создания
; в других строках написать матрицу и результат задания
; вывести на экран результат задания

include intio.inc

masm

.model small

.stack 100h

.data
n		db	(?)
m		db	(?)
len		db	(?)
matrix		db	9 dup (9 dup (?))
file		db	'matrix.txt', 0
name_len	db	$-file-1
f_ptr		dd	file
desc		dw	(?)
msg		db	"Success$"
buffer		db	(?)
b_ptr		dd	buffer
sign		db	0
odd		db	9 dup (?)
out_desc	dw	(?)
out_file	db	'output.txt', 0
o_ptr		dd	out_file


.386
.code
; считывает один символ из файла, сохраняет в переменной buffer
proc read_char

	push bx
	push cx
	push dx

	mov ah, 3fh
	mov bx, desc
	lds dx, b_ptr
	mov cx, 1
	int 21h

	pop dx
	pop cx
	pop bx

	ret

endp read_char

; на вводе в bx дескриптор файла в buffer символ который надо записать
proc write_char

	push ax
	push dx
	push cx
	mov ah, 40h
	lds dx, b_ptr
	mov cx, 1
	int 21h
	pop cx
	pop dx
	pop ax
	ret

endp write_char

; считывает матрицу из файла, сохраняет в массиве matrix
proc read_matrix

read:

	call read_char
	cmp ax, 0
	je end_read
	cmp buffer, 20h
	je write_number
	cmp buffer, 0ah
	je write_number
	cmp buffer, 2dh
	jne plus
	mov sign, 1
	jmp read
plus:
	mov al, buffer
	sub al, 30h
	xchg ax, cx
	xor dx, dx
	push bx
	mov bx, 10
	imul bx
	pop bx
	add cx, ax
	jmp read

write_number:
	cmp sign, 1
	jne positive
	neg cx
	mov sign, 0
positive:
	mov matrix[bx], cl
	xor cx, cx
	inc bx
	jmp read

end_read:
	ret

endp read_matrix

; на вводе в bx дескриптор файла
proc write_matrix

	push dx
	push cx
	push bx
	lds dx, b_ptr
	mov cx, 1
	while_not_eof:
		mov bx, desc
		mov ah, 3fh
		int 21h
		cmp ax, 0
		je eof
		pop bx
		mov ah, 40h
		int 21h
		push bx
		jmp while_not_eof

	eof:
	pop bx
	pop cx
	pop dx
	ret

endp write_matrix

proc matrix_pos

	push ax
	push bx
	push cx
	push dx

	mov ax, 4200h
	mov bx, desc
	xor cx, cx
	mov dx, 4 ; две цифры, отвечающие за размер, пробел и перевод строки
	int 21h
	jc exit

	pop dx
	pop cx
	pop bx
	pop ax

	ret

endp matrix_pos

proc create_file

	push bx
	push cx
	push dx

	mov ax, 6c00h
	mov bx, 1
	mov cx, 20h
	mov dx, 0012h
	lds si, o_ptr
	int 21h
	jc exit
	mov out_desc, ax

	pop dx
	pop cx
	pop bx

	ret

endp create_file

start:
mov ax, @data
mov ds, ax

; открываем файл
mov al, 0
mov ah, 3dh
lds dx, f_ptr
int 21h
jc exit

; считываем размер матрицы
mov desc, ax
call read_char
mov bl, buffer
sub bl, 30h
mov n, bl
call read_char
call read_char
mov bl, buffer
sub bl, 30h
mov m, bl
call read_char

xor dx, dx
mov al, n
mov bl, m
xor bh, bh
mul bx
mov len, al

; считываем матрицу
xor bx, bx
call read_matrix

; определяем количество нечётных элементов
xor bx, bx
mov cl, n ; внешний цикл
external2:
	push cx
	mov cl, m
	xor si, si
	xor dx, dx
	internal2:
		push bx
		mov ax, bx
		mov bl, m
		push dx
		xor dx, dx
		mul bx
		pop dx
		mov bx, ax
		mov al, matrix[bx][si]
		cbw
		pop bx
		test al, 1b
		jz not_odd
		inc dx
		not_odd:
		inc si
		dec cx
		cmp cx, 0
		jne internal2

	mov odd+bx, dl
	inc bx
	pop cx
	dec cx
	cmp cx, 0
	jne external2

; выводим на экран
call matrix_pos

mov bx, 01h

call write_matrix

; создаём файл
call create_file

; записываем имя файла с матрицей
mov ah, 40h
mov bx, out_desc
lds dx, f_ptr
mov cl, name_len
xor ch, ch
int 21h

mov buffer, ' '
call write_char

; записываем дату
; день
mov ah, 2ah
int 21h
xor ax, ax
mov al, dl
mov bl, 10
div bl
add ah, 30h
add al, 30h
mov buffer, al
mov bx, out_desc
call write_char
mov buffer, ah
call write_char

mov buffer, '.'
call write_char

; месяц
xor ax, ax
mov al, dh
mov bl, 10
div bl
add ah, 30h
add al, 30h
mov buffer, al
mov bx, out_desc
call write_char
mov buffer, ah
call write_char

mov buffer, '.'
call write_char

; год
mov ax, cx
xor dx, dx
mov bx, 10
mov cx, 4
year_digits:
div bx
add dx, 30h
push dx
xor dx, dx
loop year_digits

mov cx, 4
mov bx, out_desc
out_digits:
pop ax
mov buffer, al
call write_char
loop out_digits

mov bx, out_desc
mov buffer, ' '
call write_char

; записываем время
mov ah, 2ch
int 21h

; час
xor ax, ax
mov al, ch
mov bl, 10
div bl
add ah, 30h
add al, 30h
mov buffer, al
mov bx, out_desc
call write_char
mov buffer, ah
call write_char

mov buffer, ':'
call write_char

; минуты
xor ax, ax
mov al, cl
mov bl, 10
div bl
add ah, 30h
add al, 30h
mov buffer, al
mov bx, out_desc
call write_char
mov buffer, ah
call write_char

mov buffer, ':'
call write_char

; секунды
xor ax, ax
mov al, dh
mov bl, 10
div bl
add ah, 30h
add al, 30h
mov buffer, al
mov bx, out_desc
call write_char
mov buffer, ah
call write_char

mov buffer, 0ah
call write_char


; записываем матрицу в файл
mov bx, out_desc
call matrix_pos
call write_matrix


; выводим результат задания
xor cx, cx
mov cl, n
xor si, si
xor ax, ax
write_result:
mov al, odd[si]
add al, 30h

mov buffer, al
mov bx, 01h
call write_char
mov buffer, al
mov bx, out_desc
call write_char

mov buffer, 0ah
call write_char
mov bx, 01h
call write_char
inc si

loop write_result


; закрываем файл
mov bx, desc
mov ah, 3eh
int 21h
jc exit

; закрываем файл
mov bx, out_desc
mov ah, 3eh
int 21h
jc exit

; выводим на экран
;xor bx, bx
;mov cl, n ; внешний цикл
;external:
;	push cx
;	mov cl, m
;	xor si, si
;	internal:
;		push bx
;		push dx
;		mov ax, bx
;		mov bl, m
;		xor dx, dx
;		mul bx
;		mov bx, ax
;		mov al, matrix[bx][si]
;		cbw
;		pop dx
;		pop bx
;		test ax, 10000000b
;		jz stack_init
;		push dx
;		push ax
;		mov dl, 2dh
;		mov ah, 02h
;		int 21h
;		pop ax
;		pop dx
;		neg ax
;		stack_init:
;		mov dx, -1
;		push dx
;		number_output:
;			xor dx, dx
;			push bx
;			mov bx, 10
;			idiv bx
;			pop bx
;			add dx, 30h
;			push dx
;			cmp ax, 0
;			jne number_output
;		end_number:
;			pop dx
;			cmp dx, -1
;			je end_output
;			mov ah, 02h
;			int 21h
;			jmp end_number
;		end_output:
;			mov dl, 20h
;			mov ah, 02h
;			int 21h
;
;		inc si
;		loop internal
;	mov dl, 0ah
;	mov ah, 02h
;	int 21h
;	inc bx
;	pop cx
;	loop external



; записываем матрицу в файл

exit:
mov ah, 4ch
int 21h
end start
