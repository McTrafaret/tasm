; F = y/a + x - b

include intio.inc

masm
.model small

.stack 100h

.data
a	db	24
b	db	64
x	dw	(?)
y	db	(?)
result	dw	(?)
msg_x	db	"Input x(0-65535): $"
msg_y	db	"Input y(0-255): $"
even_	db	"The result is even and $"
odd	db	"The result is odd and $"
nega	db	"negative.$"
posi	db	"positive.$"
sgn_msk	dw	1000000000000000b
odd_msk	dw	1b
sign	db	0


.code
input_number proc

	input_chr
	sub al, 30h
	mov ah, 0
	mov cx, ax
	mov bx, 10

	while_not_enter:
		input_chr
		cmp al, 0dh
		je end_of_number
		sub al, 30h
		mov ah, 0
		xchg ax, cx
		mul bx
		add cx, ax
		jmp while_not_enter

	end_of_number:
		ret

input_number endp

start:
mov ax, @data
mov ds, ax


output_msg msg_x
call input_number
mov x, cx

output_msg msg_y
call input_number
mov y, cl


mov ax, x
mov bl, b
sub ax, bx
mov cx, ax
xor bx, bx
xor ax, ax

mov al, y
mov bl, a
div_while_not_zero:

	shr ax, 1
	shr bx, 1
	cmp bx, 1
	je end_of_div
	jmp div_while_not_zero

end_of_div:

add cx, ax ; y/24 + x - 64
jns pos_result
mov sign, 1
neg cx
push dx
push ax
mov dl, 2dh
mov ah, 02h
int 21h
pop ax
pop dx

pos_result:
mov result, cx
mov cx, -1
push cx
mov ax, result
mov dx, 0
mov bx, 10
cmp ax, 0
jne get_remainders
mov ah, 02h
mov dl, 30h
int 21h
jmp end1
get_remainders:
	idiv bx
	add dx, 30h
	push dx
	mov dx, 0
	cmp ax, 0
	jne get_remainders

output_number:
	pop dx
	cmp dx, -1
	je end_output
	mov ah, 02h
	int 21h
	jmp output_number

end_output:
	mov dl, 0ah
	mov ah, 02h
	int 21h

mov ax, result

test ax, odd_msk
jne print_odd
output_msg even_
jmp pos_or_neg

print_odd:
output_msg odd

mov al, sign

pos_or_neg:
test al, 1
jne print_negative
output_msg posi
jmp end1

print_negative:
output_msg nega

end1:
mov ah, 4ch
int 21h
end start
