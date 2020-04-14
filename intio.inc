output_msg macro msg

	mov ah, 09h
	mov dx, offset msg
	int 21h

endm

input_chr macro

	mov ah, 01h
	int 21h

endm


