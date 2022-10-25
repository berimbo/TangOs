#include "driver/screen.h"
#include "io.h"

uint16 cursor_x;
uint16 cursor_y;
uint16 *video_memory = (uint16 *) VGA_ADDRESS;

void disable_cursor()
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

void enable_cursor(uint8 cursor_start, uint8 cursor_end)
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | cursor_start);
	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | cursor_end);
}

/*
 * Shift right because outb takes data on 8 bits
 * The 0X00FF bitmask is optionnal but helps to understand
 */
static void move_cursor()
{
	uint16 cursorLocation = cursor_y * VGA_WIDTH + cursor_x;
	outb(0x3D4, 14); // Tell the VGA board we are setting the high cursor byte.
	outb(0x3D5, (cursorLocation >> 8) & 0x00FF); // Send the high cursor byte.
	outb(0x3D4, 15); // Tell the VGA board we are setting the low cursor byte.
	outb(0x3D5, cursorLocation & 0x00FF); // Send the low cursor byte.
}

// Scrolls the text on the screen up by one line.
static void scroll()
{
	// Get a space character with the default colour attributes.
	uint8 attributeByte = (BLACK << 4) | (WHITE & 0x0F);
	uint16 blank = 0x20 | (attributeByte << 8);

	// Row 25 is the end, this means we need to scroll up
	if(cursor_y >= VGA_HEIGHT) {
		// Move the current text chunk that makes up the screen
		// back in the buffer by a line
		int i;
		for (i = 0*80; i < 24*80; i++) {
			video_memory[i] = video_memory[i+80];
		}

		// The last line should now be blank. Do this by writing
		// 80 spaces to it.
		for (i = 24*80; i < 25*80; i++) {
			video_memory[i] = blank;
		}
		// The cursor should now be on the last line.
		cursor_y = 24;
	}
}

/*
 * Writes a single character out to the screen.
 */
void monitor_put(char c)
{
	uint8 backColour = BLACK;
	uint8 foreColour = GREEN;

	/* BG (up) | FG (low) */
	uint8  attributeByte = (backColour << 4) | (foreColour & 0x0F);

	/* VGA board: attributeByte (up) */
	uint16 attribute = attributeByte << 8;
	uint16 *location;

	if (c == BACKSPACE && cursor_x)
		--cursor_x;
	/* Handle a tab by increasing the cursor's X, but only to a point where
	 * it is divisible by 8. */
	else if (c == TAB)
		cursor_x = (cursor_x+8) & ~(8-1);

	else if (c == '\r')
		cursor_x = 0;

	else if (c == '\n') {
		cursor_x = 0;
		++cursor_y;
	}

	/* Handle any other printable character. */
	else if(c >= 0x20) {
		location = video_memory + (cursor_y * VGA_WIDTH + cursor_x);
		*location = attribute | c;
		++cursor_x;
	}

	// Check if we need to insert a new line because we have reached the end
	// of the screen.
	if (cursor_x >= VGA_WIDTH) {
		cursor_x = 0;
		++cursor_y;
	}

	// Scroll the screen if needed.
	scroll();
	// Move the hardware cursor.
	move_cursor();
}

/*
 * Clears the screen, by copying lots of spaces to the framebuffer.
 */
void monitor_clear()
{
	// Make an attribute byte for the default colours
	uint8 attributeByte = (0 /*black*/ << 4) | (15 /*white*/ & 0x0F);
	uint16 blank = 0x20 /* space */ | (attributeByte << 8);

	int i;
	for (i = 0; i < 80*25; i++)
		video_memory[i] = blank;

	// Move the hardware cursor back to the start.
	cursor_x = 0;
	cursor_y = 0;
	move_cursor();
}

/*
 * Outputs a null-terminated ASCII string to the monitor.
 */
void monitor_write(char *c)
{
	int i = 0;
	while (c[i])
		monitor_put(c[i++]);
}

/* TODO determine the size without telling it*/
void monitor_write_hex(uint32 n, size_t size)
{
	int i = (size == 32) ? 8 : 6;
	char *to_render;
	*(to_render + 1) = '0';
	*(to_render + 2) = 'X';
	while (i != 2) {
		uint8 c = n & 0x000F;
		c += 48;
		*(to_render + i) = c;
		--i;
		n = n >> 4;
	}
	monitor_write(to_render);
}

void monitor_write_dec(uint32 n)
{
}
