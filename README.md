# grapheme

Unicode grapheme segmentation


## Purpose

This is a finite-state machine for segmenting texts into extended grapheme
clusters. It follows [the Unicode 9.0.0
specification](http://www.unicode.org/reports/tr29/tr29-29.html).


## Usage

Install [Ragel](http://www.colm.net/open-source/ragel/) if need be, then copy
the files `grapheme.rl` and `grapheme_properties.rl` into your program
directory.

The file `grapheme.rl` defines a finite-state machine named `grapheme` that
matches a single extended grapheme cluster. Write a Ragel interface for your
host programming language, and compile the whole thing.

If you need inspiration for writing an interface, check the file `example.rl`.
You can compile it with:

    $ make example

And invoke the binary like so:

    $ ./example अभिनवगुप्त
    अ
    भि
    न
    व
    गु
    प्
    त

It is assumed that your host programming language encodes its strings as UTF-8.
If it uses something else, you need to emend the script `mkdata.py` accordingly,
and then rebuild the grapheme properties file with :

    $ make grapheme_properties.rl
