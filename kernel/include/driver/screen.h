#ifndef SCREEN_H
#define SCREEN_H

#include "common.h"

#define VGA_ADDRESS 0XB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define BACKSPACE 0x08
#define TAB 0x09

enum color {
	BLACK,
	BLUE,
	GREEN,
	CYAN,
	RED,
	PURPLE,
	BROWN,
	GRAY,
	DARK_GRAY,
	LIGHT_BLUE,
	LIGHT_GREEN,
	LIGHT_CYAN,
	LIGHT_RED,
	LIGHT_PURPLE,
	YELLOW,
	WHITE
};

static void disable_cursor();

static void enable_cursor(uint8 , uint8);

static void move_cursor();

static void scroll();

static void monitor_put(char c);

void monitor_clear();

void monitor_write(char *c);

void monitor_write_hex(uint32, size_t);

void monitor_write_dec(uint32);

#endif

