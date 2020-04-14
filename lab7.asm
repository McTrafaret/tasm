; заполненный массив размерностью n типа char(signed)
; вычислить сумму всех элементов расположенных после максимального

masm
.model small
.stack 100h
.data
len	equ	7
array	db	10, 17, 0, -7, -6, -7, -2
string	db	3 dup (?)
minus	db	2dh

.code
start:
mov ax, @data
mov ds, ax

mov ah, array
mov bx, 0
mov cx, len
cld
lea si, array
find_index:
	lods array
	cmp ah, al
	jns not_max
	mov al, ah
	mov bx, si
not_max:
	loop find_index

cmp bx, 0
jne not_first
inc bx
not_first:
cmp bx, len
je exit
mov cx, len
sub cx, bx
mov si, bx
mov bx, 0
find_sum:
	lods array
	cbw
	add bx, ax
	loop find_sum

cmp bx, 0
jns pos_result
neg bx
push dx
push cx
push bx
push ax
mov ah, 40h
mov bx, 01h
lea dx, minus
mov cx, 1
int 21h
pop ax
pop bx
pop cx
pop dx

pos_result:
mov ax, bx
mov dx, -1
push dx
mov dx, 0
mov cx, 10

get_remainders:
	idiv cx
	add dx, 30h
	push dx
	mov dx, 0
	cmp ax, 0
	jne get_remainders

mov si, 0
load_to_string:
	pop dx
	cmp dx, -1
	je output
	mov string[si], dl
	inc si
	jmp load_to_string

output:
mov ah, 40h
mov bx, 01h
lea dx, string
mov cx, si
int 21h

exit:
mov ah, 4ch
int 21h
end start
