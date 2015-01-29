import frog

frog = frog.Frog(frog.FrogOptions(parser=False), "/etc/frog/frog.cfg")
output = frog.process_raw("Dit is een test")
print("RAW OUTPUT=",output)
output = frog.process("Dit is nog een test.")
print("PARSED OUTPUT=",output)
