#!/usr/bin/env python3

import re, sys
from collections import defaultdict
from urllib.request import urlopen

def iter_codes(fp):
   for line in fp:
      line = line.strip()
      if not line or line.startswith("#"):
         continue
      span, category = re.match("(\S+)\s*;\s*(\S+)", line).groups()
      span = [int(c, 16) for c in span.split("..")]
      if len(span) == 1:
         start, end = span[0], span[0]
      else:
         start, end = span
      for c in range(start, end + 1):
         yield c, category

def is_surrogate(c):
   return 0xD800 <= c <= 0xDFFF

categories = defaultdict(list)
for code, category in iter_codes(sys.stdin):
   if is_surrogate(code):
      continue
   code_hex = ["0x%02X" % b for b in chr(code).encode("UTF-8")]
   categories[category].append(" ".join(code_hex))

print("""%%{

machine grapheme_properties;

Code_Point =
  (0x00 .. 0x7F)
| (0xc0 .. 0xdf) any
| (0xe0 .. 0xef) any any
| (0xf0 .. 0xf7) any any any
;
""")
for name, code_points in sorted(categories.items()):
   print("%s = " % name)
   sep = " "
   for seq in code_points:
      print("%s %s" % (sep, seq))
      sep = "|"
   print(";")
   print()
print("}%%")
