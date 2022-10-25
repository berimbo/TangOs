; int 0x13/AH=0x02 -> Reading sectors
; DL is the drive number
; DH number of sectors to read
; We write to ES:BX in RAM
disk_load:
	push dx

	mov ah, 0x02 ; BIOS read sector function
	mov al, dh   ; read dh sectors
	mov ch, 0x00 ; cylinder 0
	mov dh, 0x00 ; head 0
	mov cl, 0x02 ; start at sector 2 (we skip the boot sector)

	int 0x13     ; BIOS interrupt

	jc disk_error

	pop dx
	cmp dh, al   ; AL (sectors reads) != DH (sectors expected)
	jne disk_error
	ret

disk_error:
	mov bx,  DISK_ERROR_MSG
	call print_string
	jmp $

DISK_ERROR_MSG db "Disk read error!", 0
