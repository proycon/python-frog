from __future__ import print_function, unicode_literals

import frog

frog = frog.Frog(frog.FrogOptions(parser=True))
output = frog.process_raw("Dit is een test")
print("RAW OUTPUT=",output)
output = frog.process("Dit is nog een test.")
print("PARSED OUTPUT=",output)
