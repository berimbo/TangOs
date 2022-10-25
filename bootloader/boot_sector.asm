; We have ORG 0x7c00. This means all addresses are based from 0x7c00:address.
; Because the data segments are within the same code segment
[org 0x07c00]
[bits 16]

KERNEL_OFFSET equ 0x1000 ; Memory offset to which we will load our kernel

; BPB = BIOS Parameter Block
; GOAL: Describe the filesystem on the disk
boot:
	jmp main
	times 3-($-$$) db 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

	; Dos 4.0 EBPB 1.44MB floppy
	OEMname:           db    "mkfs.fat"    ; mkfs.fat is what OEMname mkdosfs uses
	bytesPerSector:    dw    512	       ; Indicates the number of bytes that represent a sector (must be a power of 2)
	sectPerCluster:    db    1	       ; 1 sector per cluster
	reservedSectors:   dw    1	       ; Numbers of sectors not part of FAT12 (= not part of the root dir)
					       ; 1 cluster == 1 sector
					       ; Set to 1 because the boot sector is not part of this root dir
	numFAT:            db    2	       ; Number of FAT (File allocation table) on the disk. FAT12 always has 2
	numRootDirEntries: dw    224	       ; Floppys have a max of 224 dirs in root dir
	numSectors:        dw    2880	       ; Floppys have 2880 sectors
	mediaType:         db    0xf0
	numFATsectors:     dw    9	       ; 9 sector per FAT
	sectorsPerTrack:   dw    18	       ; 18 sectors per track (track == circle line)
	numHeads:          dw    2	       ; 2 heads that represent a cylinder
	numHiddenSectors:  dd    0
	numSectorsHuge:    dd    0
	driveNum:          db    0	       ; The num of the drive is 0
	reserved:          db    0
	signature:         db    0x29	       ; DOS 4.0 signature
	volumeID:          dd    0x2d7e5a1a    ; It is overwritten (becomes time stamp) we can set anything
	volumeLabel:       db    "MOS FLOPPY " ; Indicates what is on the disk. MUST be 11 bytes
	fileSysType:       db    "FAT12   "    ; Same. MUST be 8 bytes

main:
	; Reset segments registers to 0
	xor ax, ax
	mov es, ax
	mov ds, ax
	mov ss, ax
	cli                      ; turn off interrupts for SS:SP update
				 ; to avoid a problem with buggy 8088 CPUs
	mov bp, 0x9000           ; Set the stack safely away
	mov sp, bp
	sti                      ; turn interrupts back on

	mov [driveNum], dl

	call print_clear

	mov bx, MSG_REAL_MODE
	call print_string
	call print_nl

	call load_kernel	; Load our kernel

	call switch_to_pm	; We never return from here

	jmp $ ; endless loop

%include "/print/print_string.asm"
%include "print/print_string_pm.asm"
%include "gdt.asm"
%include "switch_to_pm.asm" ; should be imported after print_string for some reason
%include "disk_load.asm"

[bits 16]

load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print_string
	call print_nl

	mov bx, KERNEL_OFFSET	; We will load the kernel at this address
	mov dh, 54		; read 54 sectors
	mov dl, [driveNum]
	call disk_load
	ret

[bits 32]

BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm

	call KERNEL_OFFSET ; KERNEL _start() call located at 0x1000

; global variables
MSG_REAL_MODE: db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE: db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL: db "Loading kernel into memory", 0

; padding
times 510-($-$$) db 0
; Magic number
dw 0xaa55
