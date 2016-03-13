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
import sys
cimport libfolia_classes
cimport frog_classes

try:
    from pynlpl.formats.folia import Document as PynlplFoliaDocument
    HASPYNLPL = True
except ImportError:
    HASPYNLPL = False
    class PynlplFoliaDocument:
        pass



cdef class Document:
    cdef frog_classes.Document capi



cdef class FrogOptions:
    """Options for Frog, passed as keyword arguments to the constructor. Also accessible like dictionary keys.

        tok - True/False - Do tokenisation? (default: True)
        lemma - True/False - Do lemmatisation? (default: True)
        morph - True/False - Do morpholigical analysis? (default: True)
        deepmorph - True/False - Do morphological analysis in new experimental style? (default: False)
        mwu - True/False - Do Multi Word Unit detection? (default: True)
        chunking - True/False - Do Chunking/Shallow parsing? (default: True)
        ner - True/False - Do Named Entity Recognition? (default: True)
        parser - True/False - Do Dependency Parsing? (default: False). The Parser won't work in this binding!
        xmlin - True/False - Input is FoLiA XML (default: False)
        xmlout - True/False - Output is FoLiA XML (default: False)
        docid - str - Document ID (for FoLiA)
        numThreads - int - Number of threads to use (default: unset, unlimited)

    """
    cdef frog_classes.FrogOptions capi

    def __init__(self, **kwargs):
        self['parser'] = False #Parser doesn't work in this binding (segfaults), disable by default
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
        elif key in ('dodaringmorph','daringmorph','deepmorph','dodeepmorph'):
            return self.capi.doDeepMorph
        elif key in ('domwu','mwu'):
            return self.capi.doMwu
        elif key in ('doiob','iob','dochunking','chunking','shallowparsing'):
            return self.capi.doIOB
        elif key in ('doner','ner'):
            return self.capi.doNER
        elif key in ('doparse','doparser','parse','parser'):
            return self.capi.doParse
        elif key in ('doxmlin','xmlin','foliain'):
            return self.capi.doXMLin
        elif key in ('doxmlout','xmlout','foliaout'):
            return self.capi.doXMLout
        elif key in ('docid'):
            return self.capi.docid
        elif key in ('numthreads','threads'):
            return self.capi.numThreads
        elif key in ('debug','debugflag'):
            return self.capi.debugFlag
        else:
            raise KeyError("No such key: " + str(key))



    def __setitem__(self, key, value):
        key = key.lower()
        if key in ('dotok','tok'):
            self.capi.doTok = <bool>value
        elif key in ('dolemma','lemma'):
            self.capi.doLemma = <bool>value
        elif key in ('domorph','morph'):
            self.capi.doMorph = <bool>value
        elif key in ('dodaringmorph','daringmorph','deepmorph','dodeepmorph'):
            self.capi.doDeepMorph = <bool>value
        elif key in ('domwu','mwu'):
            self.capi.doMwu = <bool>value
        elif key in ('doiob','iob','dochunking','chunking','shallowparsing'):
            self.capi.doIOB = <bool>value
        elif key in ('doner','ner'):
            self.capi.doNER = <bool>value
        elif key in ('doparse','doparser','parse','parser'):
            self.capi.doParse = <bool>value
        elif key in ('doxmlin','xmlin','foliain'):
            self.capi.doXMLin = <bool>value
        elif key in ('doxmlout','xmlout','foliaout'):
            self.capi.doXMLout = <bool>value
        elif key in ('debug','debugflag'):
            self.capi.debugFlag = <bool>value
        elif key in ('docid'):
            self.capi.docid = <string>value
        elif key in ('numthreads','threads'):
            self.capi.numThreads = <int>value
        else:
            raise KeyError("No such key: " + str(key))




cdef class Frog:
    cdef frog_classes.FrogAPI * capi
    cdef FrogOptions options
    cdef frog_classes.Configuration configuration
    cdef frog_classes.LogStream logstream

    def __init__(self, FrogOptions options, configurationfile = ""):
        """Initialises Frog, pass a FrogOptions instance and a configuration file"""

        self.options = options

        if configurationfile:
            self.configuration.fill(configurationfile.encode('utf-8'))
        else:
            self.configuration.fill(self.capi.defaultConfigFile())


        self.capi = new frog_classes.FrogAPI(options.capi, self.configuration, &self.logstream)


    def process_raw(self, text):
        """Invokes Frog on the specified text, the text is considered one document. The raw results from Frog are return as a string"""
        #cdef libfolia_classes.Document * doc = self.capi.tokenizer.tokenizehelper( text.encode('utf-8') )
        cdef string result = self.capi.Frogtostring(self._encode_text(text))
        r = result.decode('utf-8') #if (sys.version < '3' and type(text) == unicode) or (sys.version > '3' and type(text) == str) else result
        return r

    def parsecolumns(self, response):
        """Parse the raw Frog response"""
        columns = ('index','text','lemma','morph','pos','posprob','ner','chunker','depindex','dep')
        data = []
        for line in response.split('\n'):
            if not line.strip():
                if data:
                    data[-1]['eos'] = True
            else:
                item = {}
                for i, field in enumerate(line.split('\t')):
                    if field:
                        if columns[i] == 'posprob':
                            item[columns[i]] = float(field)
                        else:
                            item[columns[i]] = field
                data.append(item)
        return data


    def process(self, text):
        """Invokes Frog on the specified text. The text may be a string, or a folia.Document instance if Frog was instantiated with xmlin=True. If xmlout=False (default), the results from Frog are parsed into a list of dictionaries, one per token; if True, a FoLiA Document instance is returned"""
        if self.options['xmlin'] and HASPYNLPL and isinstance(text, PynlplFoliaDocument):
            text = str(text)
        elif not isinstance(text,str) and not (sys.version < '3' and isinstance(text,unicode)):
            raise ValueError("Text should be a string or FoLiA Document instance")

        if self.options['xmlout'] and HASPYNLPL:
            if HASPYNLPL:
                return PynlplFoliaDocument(string=self.process_raw(text))
            else:
                raise Exception("Unable to return a FoLiA Document. Pynlpl was not installed. Use process_raw() instead if you just want the XML output as string")
        else:
            return self.parsecolumns(self.process_raw(text))


    def __del__(self):
        del self.capi

    def _encode_text(self, text):
        if sys.version < '3' and type(text) == unicode:
            return text.encode('utf-8')
        if sys.version > '3' and type(text) == str:
            return text.encode('utf-8')
        return text #already was bytes or python2 str

