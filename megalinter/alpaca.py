#!/usr/bin/env python3
from megalinter import config

test PR from forkkkk
# pylint: disable=E1111
def alpaca():
    print_alpaca = config.get("PRINT_ALPACA", "true") == "true"
    if not print_alpaca:
        return

    print(
        """
..........................................................................................----------
......................-:./-:::-.............................................................--------
...................---:--:-::-:+/-........................................................----------
................../-....-----..---/:.....................................................-----------
.................-:.....---.......-//.................________________..................------------
................-....-:++-://+/....-/-.............../                \\.................-----------
................-..-+so//::://://.../:............../     Je suis      \\...............------------
................-.-+hyhs:-:+ohy+/-..-/.............<    le lama NUL :) |...............-------------
...............:/.-:oso+::-oyys/::..-o-.............\\_________________/.............-.-------------
..............-ooo+:++s+yy+/ss/:-/..:o/............................................-..--------------
..............-+oo///:::oyo:--/:....-+/............................................-.---------------
.............../ys+:::+oyyy+........-/y-...................---::-/++/-/:-..........-----------------
.............../ssyy++sso+/:---:/-..--s-................--:o+---.:/+/:::-+///:-.-.------------------
...............-sososhhhyyso+/---.....+/...........-://+++/::-.....----::::::ss+--------------------
...............:+s+//+/+///:-....--::.-s-......-:/+o+/-.-----------------------:++:-----------------
...............:s+ydy++////::/::/+::/-.s/..:/oo+/:...--------------------..------:+:---------------:
...............:y-+ysysss++oo+/:sdo:-..sho+++/-..-.../-./:------------------:::::::+:--------------:
...............-s-:/:/++++///:/::o/--../y+-......-..--..o:--------+/:-:::--:-:::::-:o--------------:
...............-s--+oo/+//////:/:::-...-y+o++:-....-+sso+sss+:---:///:+::::+y/:-:---/o-------------:
...............++-::+s/+://////:::-.....+s:--://-...-syys--::y-.--::::::/:::hy::----ss-------------:
...........--..s:--:-----::////::-......//.-:--//:-...:+y:..-+-.--/-:+://:::sh/o+-:oyy-------------:
....----..-.---+-.-----:-::///:--.....-/:o:/::++o+:.....:o-.......--:o/+o/::oo+omo:y+h--------------
-...--::://:o+++/.-:-::::///:::--.-::/:-//-/::+/:+/....../-.-:-----:-:o+o//:s:/ymsosys----:---------
--.....--:::/:-+s-/so+o+::::::::-::::-:/:..-:::so/-+--.------/+:----:-+y//:+y++ysoy+h://:-----------
------.----:::/:+/:+soossssoso++/+o//+:------::/y/::---------/+/:---:-:s::/yo+oy+osoh+oo/:::-------:
------------:+s::/-:osssosysso++/+/---------/::/y/:----------o/::--:-:/y+/oso+o+ssoyh++s+----------:
----:::/+:---//--/:-/+oo++oo/+/::::--------////:/:----------:s::::-/-:/yy++y+sysosyy+/////::------::
--------::--------o/-:/o+//o:::::////:----:s:/h/////:-::--+/++::::////odoysyshsoshs+++/+///:------::
------------------:+//::////////+///------oo:os+///:://::/o:+/://++o++shohoyyo+/+++++/+////:-----:::
-------------:-----/o++++++o++//:::::---:+/+:://///:-//://++o:/oso+oshhso+/////++///++++/::------:::
:----------------:/++s+/:/+/:::::::---/s++//://///::-///+/sdossyyys+++///////+hs+/+/+/+/::-------:::
+--------:---::-:+++++++:---:--:/:/+oshsoo:///////////soo+yo/////+////++//////syssssso/----------:::
-------------++//+/++//++++++so/+ossssso+:/+yo+oohhsyyo+++o++++++//+++ho+/////////:::::----------:::
------------/+o+/////+//+/+ssyyhhyshmhdyhhhssyyoo+////++/+///+o/+///://///:::--------------------:::
---------------/+///+++++++++//+/+hho+o/+o+////::::::---------:::-:::::::::-----------//--------:::

----------------------------------------------------------------------------------------------------

    """
    )
    return True
