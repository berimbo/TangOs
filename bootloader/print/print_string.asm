print_string:
	; bx stores a pointer to the string to render
	push ax         ; save
	push bx
loop:
	mov al, [bx]
	cmp al, 0
	je printf_end
	mov ah, 0x0e
	int 0x10
	inc bx
	jmp loop
printf_end:
	pop bx          ; restore
	pop ax
	ret

; ==============================================================================

print_hex:
  ; dx stores the value to print as hex
	pusha
	mov cx, 0           ; counter
hex_loop:
	cmp cx, 4
	je hex_end
	mov ax, dx          ; ax = 0x1234
	and al, 0x000f      ; ax = 0x0004
	add al, 0x30        ; convert 4 to his hex code
	cmp al, 0x39        ; add 7 to represent A-F if char > 9
	jle hex_write
	add al, 7 
hex_write:
	mov bx, HEX_OUT + 5 ; add the size of the string to the address
	sub bx, cx          ; decrement by the number of what we have done
	mov [bx], al
	inc ecx
	shr dx, 4           ; 0x1234 -> 0x0123 -> ...
	jmp hex_loop
hex_end:
	mov bx, HEX_OUT
	call print_string
	popa
	ret

; ==============================================================================

print_nl:
	push ax      ; save
	mov ah, 0x0e
	mov al, 0x0a ; newline char
	int 0x10
	mov al, 0x0d ; carriage return
	int 0x10
	pop ax       ; restore
	ret

; ==============================================================================

print_clear:
	push ax      ; save
	mov ah, 0x0  ; clear screen
	mov al, 0x03 ; 80x25 16 colors mode
	int 0x10
	pop ax       ; restore
	ret

; ==============================================================================

; global variables
HEX_OUT: db "0x0000", 0
