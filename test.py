#!/usr/bin/env python3

from frog import Frog, FrogOptions
import folia.main as folia

frog = Frog(FrogOptions(parser=True))
output = frog.process_raw("Dit is een test")
print("RAW OUTPUT=",output)
assert output

output = frog.process("Dit is nog een test.")
print("PARSED OUTPUT=",output)
assert output

frog = Frog(FrogOptions(parser=True,xmlout=True))
output = frog.process("Dit is een FoLiA test.")
assert isinstance(output, folia.Document)
assert len(output.data) == 1
assert next(output.select(folia.Sentence)).text() == "Dit is een FoLiA test."
#output is now no longer a string but an instance of folia.Document, provided by the FoLiA library in PyNLPl (pynlpl.formats.folia)
print("FOLIA OUTPUT=")
print(output.xmlstring())

print("Inspecting FoLiA output (example):")
for word in output.words():
    print(word.text() + " " + word.pos() + " " + word.lemma())
assert len(list(output.words())) == 6
