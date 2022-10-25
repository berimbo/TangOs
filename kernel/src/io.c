#include "io.h"

/*
 * Ports are addressed on 16 bits
 * I/O bus use values on 8 bits (data)
 */

/*
 * Write 1 byte to the specified port
 * NASM: out dx, al
 */
void outb(uint16 port, uint8 data)
{
	__asm__("out %%al, %%dx" : : "a" (data), "d" (port));
}

/*
 * Read 1 byte from the specified port
 * NASM: in al, dx
 */
uint8 inb(uint16 port)
{
	uint8 res;
	__asm__("in %%dx, %%al" : "=a" (res) : "d" (port));
	return res;
}

/*
 * Write 2 bytes from the specified port
 * NASM: out dx, ax
 */
void outw(uint16 port, uint16 data)
{
	__asm__("out %%ax , %%dx" : : "a" (data), "d" (port));
}

/*
 * Read 2 bytes from the specified port
 * NASM: in ax, dx
 */
uint16 inw(uint16 port)
{
	uint16 res;
	__asm__("in %%dx , %%ax" : "=a" (res) : "d" (port));
	return res;
}
