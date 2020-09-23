[Brute Force Password Generator]

version: 2003-10-03
author : redbird77
email  : redbird77@earthlink.net
www    : http://home.earthlink.net/~redbird77

This is a "password generator" that can (on my puny PII 333mHz computer) generate about 150000-250000 passwords per second (number varies based on password length).

This project was inspired by this Planet-Source-Code post:
"Fast BruteForce Class Example" by §e7eN.
http://www.Planet-Source-Code.com/vb/scripts/ShowCode.asp?txtCodeId=48276&lngWId=1

and by various websites, code snippets, and newsgroup posts.

I have no interest/knowledge in using this to break into anything or do any harm.  I'm do love the logic behind such challenges.  Though, I'm sure I'm at the pre-k level when it comes to serious string manipulation.

I searched the www hi and lo for info on combinations, permutations, and the like.  I jotted down some of my findings in perms.txt.  The big moment came when I found a 2003-05-27 post by Thad Smith (thad@ionsky.com) in comp.programming that gave the idea of using translating decimal numbers into base-n numbers then using the digits of the base-n numbers as indicies in an character set array.  Voila!

[To Do]
Fix the whole ActiveState thing.  Breaking out of big loops in classes is not fun.

[Revision History]
2003-10-03
Various speed-ups. (40k-80k to 150k-250k passwords/sec).
Got rid of string concatenation replaced with Mid$ function.
Made password producing function an "inline" function, no more repeated calls.
Fixed bug that wouldn't let you close the form even if you hadn't started generating yet.
No more version numbers, just date of release.

2003-09-26
Initial release.