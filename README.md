Frog for Python
===========

This is a Python binding to the Natural Language Processing suite Frog. Frog is
intended for Dutch and performs part-of-speech tagging, lemmatisation,
morphological analysis, named entity recognition, shallow parsing, and
dependency parsing. The tool itseelf is implemented in C++
(http://ilk.uvt.nl/frog).

Installation
==============

 * Make sure to first install Frog itself (http://ilk.uvt.nl/frog or from git http://github.com/proycon/frog ) and its dependencies
 * Install Cython if not yet available on your system: ``$ sudo apt-get cython cython3`` (Debian/Ubuntu, may differ for others)
 * Run:  ``$ sudo python setup.py install``

Usage
================

Example::

    import frog
    frog = frog.Frog(frog.FrogOptions(parser=False), "/etc/frog/frog.cfg")
    output = frog.process_raw("Dit is een test")
    print("RAW OUTPUT=",output)
    output = frog.process("Dit is nog een test.")
    print("PARSED OUTPUT=",output)

Available keyword arguments for FrogOptions:

 * tok - True/False - Do tokenisation? (default: True)
 * lemma - True/False - Do lemmatisation? (default: True)
 * morph - True/False - Do morpholigical analysis? (default: True)
 * daringmorph - True/False - Do morphological analysis in new experimental style? (default: False)
 * mwu - True/False - Do Multi Word Unit detection? (default: True)
 * chunking - True/False - Do Chunking/Shallow parsing? (default: True)
 * ner - True/False - Do Named Entity Recognition? (default: True)
 * parser - True/False - Do Dependency Parsing? (default: False). The Parser won't work in this binding!
 * xmlin - True/False - Input is FoLiA XML (default: False)
 * xmlout - True/False - Output is FoLiA XML (default: False)
 * docid - str - Document ID (for FoLiA)
 * numThreads - int - Number of threads to use (default: unset, unlimited)




