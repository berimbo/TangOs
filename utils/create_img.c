#include <stdio.h>
#include <stdlib.h>

#define ARG_NUM 5
#define BYTES_PER_SECTOR 512
#define NULL_BYTE 0x00

FILE *open_file(const char *file_name, const char *mode)
{
	FILE *file = fopen(file_name, mode);
	if (file == NULL) {
		fprintf(stderr, "Failed to open file %s\n", file_name);
		exit(EXIT_FAILURE);
	}
	return file;
}

void close_file(FILE *file_fp)
{
	if (file_fp != NULL)
		fclose(file_fp);
}

u_int16_t copy_file_to_file(const char *input, const char *output, const char *mode)
{
	u_int16_t n = 0;
	FILE *input_fp = open_file(input, "rb");
	FILE *output_fp = open_file(output, mode);
	int c;
	while ((c = getc(input_fp)) != EOF) {
		putc(c, output_fp);
		++n;
	}
	close_file(output_fp);
	close_file(input_fp);
	return n;
}

void write_null_bytes(const char *output, const size_t num)
{
	FILE *output_fp = open_file(output, "ab");
	for (size_t i = 0; i < num; ++i) {
		if (putc(NULL_BYTE, output_fp) == EOF) {
			fprintf(stderr, "Failed to write null byte to %s\n", output);
		}
	}
	close_file(output_fp);
}

int main(int argc, char *argv[])
{
	if (argc != ARG_NUM) {
		fprintf(stderr, "4 arguments should be given\n");
		return EXIT_FAILURE;
	}
	const char *output_file = argv[1];
	const char *boot_sector = argv[2];
	const char *kernel = argv[3];
	const int sector_count = atoi(argv[4]);
	u_int16_t n = 0;
	const u_int16_t total = sector_count * BYTES_PER_SECTOR;
	n += copy_file_to_file(boot_sector, output_file, "wb");
	n += copy_file_to_file(kernel, output_file, "ab");
	const u_int16_t bytes_left = total - n;
	write_null_bytes(output_file, bytes_left);
	return EXIT_SUCCESS;
}
