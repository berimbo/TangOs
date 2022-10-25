#ifndef IO_H
#define IO_H

#include "common.h"

void outb(uint16, uint8);

uint8 inb(uint16);

void outw(uint16, uint16);

uint16 inw(uint16);

#endif
