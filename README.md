.. image:: http://applejack.science.ru.nl/lamabadge.php/python-frog
   :target: http://applejack.science.ru.nl/languagemachines/

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

Example:

    from __future__ import print_function, unicode_literals #to make this work on Python 2 as well as Python 3

    import frog

    frog = frog.Frog(frog.FrogOptions(parser=False), "/etc/frog/frog.cfg")
    output = frog.process_raw("Dit is een test")
    print("RAW OUTPUT=",output)
    output = frog.process("Dit is nog een test.")
    print("PARSED OUTPUT=",output)


Output:

    RAW OUTPUT= 1   Dit     dit     [dit]   VNW(aanw,pron,stan,vol,3o,ev)
    0.777085        O       B-NP
    2       is      zijn    [zijn]  WW(pv,tgw,ev)   0.999891        O
    B-VP
    3       een     een     [een]   LID(onbep,stan,agr)     0.999113        O
    B-NP
    4       test    test    [test]  N(soort,ev,basis,zijd,stan)     0.789112
    O       I-NP


    PARSED OUTPUT= [{'chunker': 'B-NP', 'index': '1', 'lemma': 'dit', 'ner':
    'O', 'pos': 'VNW(aanw,pron,stan,vol,3o,ev)', 'posprob': 0.777085, 'text':
    'Dit', 'morph': '[dit]'}, {'chunker': 'B-VP', 'index': '2', 'lemma':
    'zijn', 'ner': 'O', 'pos': 'WW(pv,tgw,ev)', 'posprob': 0.999966, 'text':
    'is', 'morph': '[zijn]'}, {'chunker': 'B-NP', 'index': '3', 'lemma': 'nog',
    'ner': 'O', 'pos': 'BW()', 'posprob': 0.99982, 'text': 'nog', 'morph':
    '[nog]'}, {'chunker': 'I-NP', 'index': '4', 'lemma': 'een', 'ner': 'O',
    'pos': 'LID(onbep,stan,agr)', 'posprob': 0.995781, 'text': 'een', 'morph':
    '[een]'}, {'chunker': 'I-NP', 'index': '5', 'lemma': 'test', 'ner': 'O',
    'pos': 'N(soort,ev,basis,zijd,stan)', 'posprob': 0.903055, 'text': 'test',
    'morph': '[test]'}, {'chunker': 'O', 'index': '6', 'eos': True, 'lemma':
    '.', 'ner': 'O', 'pos': 'LET()', 'posprob': 1.0, 'text': '.', 'morph':
    '[.]'}]


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




