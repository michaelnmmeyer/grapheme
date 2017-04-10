CFLAGS = -std=c99 -g -Wall -Werror

BASE_URL = http://www.unicode.org/Public/UCD/latest/ucd/auxiliary

all: grapheme_properties.rl example test

check: test grapheme_properties.rl GraphemeBreakTest.txt
	./$< < GraphemeBreakTest.txt

clean:
	rm -f test example GraphemeBreakProperty.txt GraphemeBreakTest.txt

.PHONY: all check clean

grapheme_properties.rl: mkdata.py GraphemeBreakProperty.txt
	python3 $< < GraphemeBreakProperty.txt > $@

%.c: %.rl grapheme.rl grapheme_properties.rl
	ragel -e -T1 $<

%.txt:
	wget $(BASE_URL)/$@
