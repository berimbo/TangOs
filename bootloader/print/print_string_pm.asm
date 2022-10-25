[bits 32]

; Preprocessor, does not appear in code just like #define
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x02

; print a null terminated string pointed to by EDX
; ebx contains the string
print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY

print_string_pm_loop:
	mov al, [ebx]			; character
	mov ah, WHITE_ON_BLACK 		; Attributes
	cmp al, 0 			; al == 0 means null character
	je print_string_pm_done

	mov [2 * 2 * 80 + edx], ax	; stores character and
					; attributes at current character cell
					; (2 * y * 80) + Base address
					; screen is 80 wide x 25 high
					; *2 because each element is 2 bytes

	inc ebx				; next char in string
	add edx, 2			; next cell in vid memory
	jmp print_string_pm_loop

print_string_pm_done:
	popa
	ret
