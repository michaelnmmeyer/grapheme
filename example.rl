#include <stdio.h>
#include <string.h>

/* Length, in bytes, of the first grapheme of a valid UTF-8 string. */
static size_t grapheme_len(const char *str, size_t len)
{
   const unsigned char *p = (const unsigned char *)str;
   const unsigned char *const pe = p + len;
   const unsigned char *const eof = pe;
   const unsigned char *ts, *te;
   int cs, act;

   %%{

   machine grapheme_len;

   include grapheme "grapheme.rl";

   alphtype unsigned char;

   main := |*
      grapheme => { return te - ts; };
   *|;

   }%%

   %% write data noerror nofinal;
   %% write init;
   %% write exec;
   (void)grapheme_len_en_main;

   return 0;
}

int main(int argc, char **argv)
{
   while (*++argv) {
      const char *str = *argv;
      size_t len = strlen(str);
      for (size_t i = 0, glen; i < len; i += glen) {
         glen = grapheme_len(&str[i], len - i);
         fwrite(&str[i], 1, glen, stdout);
         putchar('\n');
      }
   }
}
