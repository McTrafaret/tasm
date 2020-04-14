.model small
.stack 100h

.data
x	dw	0
y	dw	0
z	dw	0

.386
.code
start:
mov ax, @data
mov ds, ax

mov eax, 0FFFFFFFFh

mov bx, 3856h
add bx, x
add bx, y
mov cx, 369h
sub cx, bx
add cx, z
sub cx, 336h

mov ah, 4ch
int 21h
end start


