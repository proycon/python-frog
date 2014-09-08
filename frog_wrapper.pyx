#embedsignature=True
#*****************************
# Python-ucto
#   by Maarten van Gompel
#   Centre for Language Studies
#   Radboud University Nijmegen
#
#   Licensed under GPLv3
#****************************/

from libcpp.string cimport string
from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref, preincrement as inc
from cython import address
from libc.stdint cimport *
from libcpp.utility cimport pair
import os.path
cimport frog_classes
cimport libfolia_classes

cdef class Document:
    cdef frog_classes.Document capi



cdef class FrogOptions:
    cdef frog_classes.FrogOptions capi

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            self[key] = value

    def __getitem__(self, key):
        key = key.lower()
        if key in ('dotok','tok'):
            return self.capi.doTok
        elif key in ('dolemma','lemma'):
            return self.capi.doLemma
        elif key in ('domorph','morph'):
            return self.capi.doMorph
        elif key in ('dodaringmorph','daringmorph'):
            return self.capi.doDaringMorph
        elif key in ('domwu','mwu'):
            return self.capi.doMwu
        elif key in ('doiob','iob','dochunking','chunking','shallowparsing'):
            return self.capi.doIOB
        elif key in ('doner','ner'):
            return self.capi.doNER
        elif key in ('doparse','doparser','parse','parser'):
            return self.capi.doParse
        elif key in ('docid'):
            return self.capi.docid
        else:
            raise KeyError("No such key: " + str(key))



    def __setitem__(self, key, value):
        key = key.lower()
        if key in ('dotok','tok'):
            self.capi.doTok = bool(value)
        elif key in ('dolemma','lemma'):
            self.capi.doLemma = bool(value)
        elif key in ('domorph','morph'):
            self.capi.doMorph = bool(value)
        elif key in ('dodaringmorph','daringmorph'):
            self.capi.doDaringMorph = bool(value)
        elif key in ('domwu','mwu'):
            self.capi.doMwu = bool(value)
        elif key in ('doiob','iob','dochunking','chunking','shallowparsing'):
            self.capi.doIOB = bool(value)
        elif key in ('doner','ner'):
            self.capi.doNER = bool(value)
        elif key in ('doparse','doparser','parse','parser'):
            self.capi.doParse = bool(value)
        elif key in ('docid'):
            self.capi.docid = str(value)
        else:
            raise KeyError("No such key: " + str(key))




cdef class Frog:
    cdef frog_classes.FrogAPI * capi

    def __init__(self, FrogOptions options, str configurationfile):
        cdef frog_classes.Configuration configuration
        cdef frog_classes.LogStream logstream

        if configurationfile:
            configuration.fill(configurationfile.encode('utf-8'))

        self.capi = new frog_classes.FrogAPI(&options.capi, &configuration, &logstream)

    def processdocument(self, str text):
        cdef Document doc = self.capi.tokenizer.tokenizestring( text.encode('utf-8') );
        cdef frog_classes.ostream outstream
        self.capi.Test(doc, outstream, False)
        #TODO: Parse outstream into strings on C++ side

    def __del__(self):
        del self.capi

