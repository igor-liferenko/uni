\language0
\font\tentex=lhtex10 % TeX extended character set (used in strings)

\let\lheader\rheader
\secpagedepth=2
@* Library for conversion between UNICODE and UTF-8.
We always do input via C library functions (e.g., |fgetwc|),
which automatically convert data to UNICODE and do error checking, so
it is assumed here that UTF-8 data is valid. Although care is taken
to ensure that algorithms below will not fail even if the data is
invalid.

@*1 Procedures for conversion of UNICODE to UTF-8.

@ The name `|wctomo|' is used
to aviod conflict with library's `|wctomb|'
(decrypted as `\.wide \.character \.{to} \.multi \.octet').

@<Predecl...@>=
size_t wctomo(wchar_t c, char *mbs);
@ @<Declarat...@>=
size_t wctomo(wchar_t c, char *mbs)
{
  size_t n;
  int i;
  @<Determine number of bytes |n| in UTF-8@>@;
  if (mbs==NULL) return n;
  @<Set first byte of UTF-8 sequence@>@;
  @<Set remaining bytes of UTF-8 sequence@>@;
  return n;
}

@ The length of the resulting UTF-8 sequence is determined using the
following chart:
\medskip
{\tt\obeylines\obeyspaces
0xxxxxxx
110xxxxx      10xxxxxx
1110xxxx      10xxxxxx      10xxxxxx
11110xxx      10xxxxxx      10xxxxxx      10xxxxxx
111110xx      10xxxxxx      10xxxxxx      10xxxxxx      10xxxxxx
1111110x      10xxxxxx      10xxxxxx      10xxxxxx      10xxxxxx      10xxxxxx
}
\medskip

@<Determine number of bytes...@>=
if (!(c&(wchar_t)~0x7f)) n=1;
else if (!(c&(wchar_t)~0x7ff)) n=2;
else if (!(c&(wchar_t)~0xffff)) n=3;
else if (!(c&(wchar_t)~0x1fffff)) n=4;
else if (!(c&(wchar_t)~0x3ffffff)) n=5;
else n=6;

@ Copy to the first byte data bits which belong there. Then set
its header according to the chart in |@<Determine number of bytes...@>|.

@<Set first byte...@>=
*mbs = (char)(c >> 6*(n-1));
if (n != 1)
  for (i=(int)(n-1); i>=0; i--)
    *mbs |= (char)(1 << (7-i));

@ Copy to each byte data bits which belong to this byte.
Then set its header to `10'.

@<Set remaining bytes...@>=
for (i=(int)(n-2); i>=0; i--) {
  mbs++;
  *mbs = (char)(c >> 6*i);
  *mbs |= (char)(1 << 7);
  *mbs &= (char)~(1 << 6);
}

@ The name `|wcstomos|' is used
to aviod conflict with library's `|wcstombs|'
(decrypted as `\.wide \.character
\.string \.{to} \.multi \.octet \.string').

@<Predecl...@>=
size_t wcstomos(wchar_t *s, char *mbs);
@ @<Declarat...@>=
size_t wcstomos(wchar_t *s, char *mbs)
{
  size_t n = 0;
  while (*s != L'\0') {
    n+=wctomo(*s, mbs==NULL?mbs:mbs+n);
    s++;
  }
  if (mbs != NULL) *(mbs+n)='\0';
  return n;
}

@*1 Procedures for conversion of UTF-8 to UNICODE.

@ Length of UTF-8 sequence is determined by its first byte.

The name `|motowc|' is used
to aviod conflict with library's `|mbtowc|'
(decrypted as `\.multi \.octet \.{to} \.wide \.character').

@<Predecl...@>=
int motowc(char *mbs, wchar_t *c);
@ @<Declarat...@>=
int motowc(char *mbs, wchar_t *c)
{
  int i, n;
  if (!(*mbs & (char)(1<<7))) { /* first byte begins with `0' */
    if (c!=NULL) *c = (wchar_t) *mbs;
    return 1;
  }
  @<Count the amount of `1' before first `0'@>@;
  if (c==NULL) return n;
  *c = 0;
  @<Take data from first byte@>@;
  @<Take data from the rest byte(s)@>@;
  return n;
}

@ According to the chart in |@<Determine number of bytes...@>|, the
amount of `1' is the length of UTF-8 sequence; it cannot exceed `6'.

@<Count the amount of `1' before first `0'@>=
for (i=7, n=0; i > 1; i--)
  if (*mbs & (char)(1 << i)) n++; @+ else break;

@ Loop over the data bits of the first byte and copy them to |c|.
`0' is skipped, because |c| is zeroed in advance.

@<Take data from first byte@>=
for (i=6-n; i>=0; i--)
  if (*mbs & (char)(1 << i)) *c |= (wchar_t)(1 << ((n-1)*6+i));

@ We just copy bits 6--1 from the rest byte(s) of UTF-8 sequence.
Recall the chart in |@<Determine number of bytes...@>|.

@<Take data from the rest byte(s)@>=
for (i=n-2; i>=0; i--) {
  mbs++;
  if (*mbs=='\0') return n-i-1; /* not to fail on bad data */
  *c |= (wchar_t)((*mbs & (char)~(1<<7)) << i*6);
}

@ The name `|mostowcs|' is used
to aviod conflict with library's `|mbstowcs|'
(decrypted as `\.multi \.octet \.string \.{to} \.wide \.character
\.string').

@<Predecl...@>=
size_t mostowcs(char *mbs, wchar_t *s);
@ @<Declarat...@>=
size_t mostowcs(char *mbs, wchar_t *s)
{
  size_t n = 0;
  while (*mbs!='\0') {
    mbs+=motowc(mbs, s);
    n++;
    if (s!=NULL) s++;
  }
  if (s!=NULL) *s=L'\0';
  return n;
}

@*1 Generate library files.
Last of all, generate header and module files.

@ @(uni.h@>=
@<Predeclarations of procedures@>@;

@ @c
#include <wchar.h>
#include "uni.h"
@<Declarations of procedures@>@;

@* Test UNICODE to UTF-8 conversion.

NOTE: you cannot use non-english letters in english document in CWEB, so use
escape-notation to use non-english letters.

@(unicode-to-utf8-test.c@>=
#include <assert.h>
#include <stdlib.h>
#include <locale.h>
#include <wchar.h>
#include "uni.h"

#define LCHR L'№'
#define LSTR L"привет мир"

int main(void)
{
  setlocale(LC_CTYPE, "C.UTF-8"); @+@t}\6{@>
  char *mbs;

  mbs = malloc(wctomo(LCHR, NULL)+1); /* |+1| for |'\0'| */
  assert (mbs != NULL);
  mbs[wctomo(LCHR, mbs)]='\0';
  wprintf(L"%s\n", mbs);
  free(mbs);
@#
  mbs = malloc(wcstomos(LSTR, NULL)+1); /* |+1| for |'\0'| */
  assert (mbs != NULL);
  wcstomos(LSTR, mbs);
  wprintf(L"%s\n", mbs);
  free(mbs);
@#
  return 0;
}

@* Test UTF-8 to UNICODE conversion.

NOTE: you cannot use non-english letters in english document in CWEB, so use
escape-notation to use non-english letters.

@(utf8-to-unicode-test.c@>=
#include <assert.h>
#include <stdlib.h>
#include <locale.h>
#include <wchar.h>
#include "uni.h"

#define CHR "№"
#define STR "привет мир"

int main(void)
{
  setlocale(LC_CTYPE, "C.UTF-8"); @+@t}\6{@>
  wchar_t c;
  wchar_t *s;

  motowc(CHR, &c);
  wprintf(L"%lc\n", c);
@#
  s = malloc((mostowcs(STR, NULL)+1)*sizeof(wchar_t)); /* |+1| for |L'\0'| */
  assert (s != NULL);
  mostowcs(STR, s);
  wprintf(L"%ls\n", s);
  free(s);
@#
  return 0;
}

@* Index.
