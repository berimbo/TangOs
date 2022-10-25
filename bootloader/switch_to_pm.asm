[bits 16]

switch_to_pm:
	cli
	lgdt [gdt_descriptor]	; Load global descriptor table
				; Which defines the protected mode segments

	; Set the first bit of register cr0 to make the switch to PM
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODE_SEG:init_pm	; Move IP to the code segment location

[bits 32]

init_pm:
	; We move data registers to the data segment
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; set the stack safely away
	mov ebp, 0x90000
	mov esp, ebp

	call BEGIN_PM ; call our first PM function
