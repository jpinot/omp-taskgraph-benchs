
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

const char* csv_filename = "/home/bsc/bsc477298/out.csv";
const char* local_csv_filename = "/tmp/out.csv";

static void ftoa_fixed(char *buffer, double value);
static void ftoa_sci(char *buffer, double value);

int my_vfprintf(FILE *file, char const *fmt, va_list arg) {

    int int_temp;
    char char_temp;
    char *string_temp;
    double double_temp;

    char ch;
    int length = 0;

    char buffer[512];

    while ((ch = *fmt++)) {
        if ( '%' == ch ) {
            switch (ch = *fmt++) {
                /* %% - print out a single %    */
                case '%':
                    fputc('%', file);
                    length++;
                    break;

                /* %c: print out a character    */
                case 'c':
                    char_temp = va_arg(arg, int);
                    fputc(char_temp, file);
                    length++;
                    break;

                /* %s: print out a string       */
                case 's':
                    string_temp = va_arg(arg, char *);
                    fputs(string_temp, file);
                    length += strlen(string_temp);
                    break;

                /* %d: print out an int         */
                case 'd':
                    int_temp = va_arg(arg, int);
                    sprintf(buffer, "%d", int_temp);
                    fputs(buffer, file);
                    length += strlen(buffer);
                    break;

                case 'f':
                    double_temp = va_arg(arg, double);
                    ftoa_fixed(buffer, double_temp);
                    fputs(buffer, file);
                    length += strlen(buffer);
                    break;

                case 'e':
                    double_temp = va_arg(arg, double);
                    ftoa_sci(buffer, double_temp);
                    fputs(buffer, file);
                    length += strlen(buffer);
                    break;
            }
        }
        else {
            putc(ch, file);
            length++;
        }
    }
    fputc('\n', file);
    return length + 1;
}

int normalize(double *val) {
    int exponent = 0;
    double value = *val;

    while (value >= 1.0) {
        value /= 10.0;
        ++exponent;
    }

    while (value < 0.1) {
        value *= 10.0;
        --exponent;
    }
    *val = value;
    return exponent;
}

static void ftoa_fixed(char *buffer, double value) {
    /* carry out a fixed conversion of a double value to a string, with a precision of 5 decimal digits.
     * Values with absolute values less than 0.000001 are rounded to 0.0
     * Note: this blindly assumes that the buffer will be large enough to hold the largest possible result.
     * The largest value we expect is an IEEE 754 double precision real, with maximum magnitude of approximately
     * e+308. The C standard requires an implementation to allow a single conversion to produce up to 512
     * characters, so that's what we really expect as the buffer size.
     */

    int exponent = 0;
    int places = 0;
    static const int width = 4;

    if (value == 0.0) {
        buffer[0] = '0';
        buffer[1] = '\0';
        return;
    }

    if (value < 0.0) {
        *buffer++ = '-';
        value = -value;
    }

    exponent = normalize(&value);

    while (exponent > 0) {
        int digit = value * 10;
        *buffer++ = digit + '0';
        value = value * 10 - digit;
        ++places;
        --exponent;
    }

    if (places == 0)
        *buffer++ = '0';

    *buffer++ = '.';

    while (exponent < 0 && places < width) {
        *buffer++ = '0';
        --exponent;
        ++places;
    }

    while (places < width) {
        int digit = value * 10.0;
        *buffer++ = digit + '0';
        value = value * 10.0 - digit;
        ++places;
    }
    *buffer = '\0';
}

void ftoa_sci(char *buffer, double value) {
    int exponent = 0;
    int places = 0;
    static const int width = 4;

    if (value == 0.0) {
        buffer[0] = '0';
        buffer[1] = '\0';
        return;
    }

    if (value < 0.0) {
        *buffer++ = '-';
        value = -value;
    }

    exponent = normalize(&value);

    int digit = value * 10.0;
    *buffer++ = digit + '0';
    value = value * 10.0 - digit;
    --exponent;

    *buffer++ = '.';

    for (int i = 0; i < width; i++) {
        int digit = value * 10.0;
        *buffer++ = digit + '0';
        value = value * 10.0 - digit;
    }

    *buffer++ = 'e';
    sprintf(buffer, "%d", exponent);
}

int my_printf(char const *fmt, ...) {
    va_list arg;
    int length;

    va_start(arg, fmt);
    length = my_vfprintf(stdout, fmt, arg);
    va_end(arg);
    return length;
}

int add_to_csv(char const *fmt, ...) {
    FILE *file = fopen(csv_filename, "a");
    if (!file) {
      file = fopen(local_csv_filename, "a");
    }
    va_list arg;
    int length;

    va_start(arg, fmt);
    length = my_vfprintf(file, fmt, arg);
    va_end(arg);
    return length;
}

/* void add_to_csv(const char *filename, int num_fields, ...) { */
/*     FILE *file = fopen(filename, "a"); */
/*     if (file == NULL) { */
/*         perror("Failed to open file"); */
/*         return; */
/*     } */

/*     va_list args; */
/*     va_start(args, num_fields); */

/*     for (int i = 0; i < num_fields; ++i) { */
/*         const char *value = va_arg(args, const char*); */
/*         fprintf(file, "%s", value); */
/*         if (i < num_fields - 1) { */
/*             fputc(',', file); */
/*         } */
/*     } */

/*     fputc('\n', file); */
/*     va_end(args); */

/*     fclose(file); */
/* } */
