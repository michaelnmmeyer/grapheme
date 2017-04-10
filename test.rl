#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%%{

machine test;

alphtype unsigned char;
include grapheme "grapheme.rl";

main := |*
   grapheme => {
      memcpy(&output[output_len], ts, te - ts);
      output_len += te - ts;
      output[output_len++] = 0xff;
   };
*|;

}%%

static size_t process(unsigned char *output, const unsigned char *p, size_t len)
{
   const unsigned char *pe, *eof, *ts, *te;
   int cs, act;
   size_t output_len = 0;

   pe = eof = p + len;
   output[output_len++] = 0xff;

   %% write data noerror nofinal;
   %% write init;
   %% write exec;
   (void)test_en_main;

   return output_len;
}

static size_t put_utf8(unsigned char *buf, unsigned c)
{
   if (c < 0x80) {
      buf[0] = c;
      return 1;
   }
   if (c < 0x800) {
      buf[0] = 0xC0 + (c >> 6);
      buf[1] = 0x80 + (c & 0x3F);
      return 2;
   }
   if (c < 0x10000) {
      buf[0] = 0xE0 + (c >> 12);
      buf[1] = 0x80 + ((c >> 6) & 0x3F);
      buf[2] = 0x80 + (c & 0x3F);
      return 3;
   }
   buf[0] = 0xF0 + (c >> 18);
   buf[1] = 0x80 + ((c >> 12) & 0x3F);
   buf[2] = 0x80 + ((c >> 6) & 0x3F);
   buf[3] = 0x80 + (c & 0x3F);
   return 4;
}

#define MAX_LINE 1024

static int check(char *line, size_t lno)
{
   const char *orig = strcpy((char[MAX_LINE]){}, line);

   unsigned char input[MAX_LINE];
   size_t input_len = 0;

   unsigned char expect[MAX_LINE];
   size_t expect_len = 0;

   const char *seps = " \t";
   for (const char *tok = strtok(line, seps); tok; tok = strtok(NULL, seps)) {
      if (*tok == '#')
         break;
      if (!strcmp(tok, "×"))        // Don't break
         continue;
      if (!strcmp(tok, "÷")) {      // Break
         expect[expect_len++] = 0xff;
         continue;
      }
      unsigned c;
      if (sscanf(tok, "%X", &c) != 1)
         abort();
      // No surrogates in UTF-8, so skip tests that include any.
      if (c >= 0xD800 && c <= 0xDFFF)
         return 0;
      input_len += put_utf8(&input[input_len], c);
      expect_len += put_utf8(&expect[expect_len], c);
   }

   unsigned char output[MAX_LINE];
   size_t output_len = process(output, input, input_len);
   if (output_len != expect_len || memcmp(output, expect, expect_len)) {
      fprintf(stderr, "line %zu: %s", lno, orig);
      return 1;
   }
   return 0;
}

int main(void)
{
   char line[MAX_LINE];
   size_t lno = 0;
   
   int errs = 0;
   while (fgets(line, sizeof line, stdin)) {
      lno++;
      if (*line == '#')
         continue;
      if (!*line || line[strlen(line) - 1] != '\n')
         abort();
      errs += check(line, lno);
   }
   if (errs)
      abort();
}
