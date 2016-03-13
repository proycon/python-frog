#*****************************
# Python-frog
#   by Maarten van Gompel
#   Centre for Language Studies
#   Radboud University Nijmegen
#
#   Licensed under GPLv3
#****************************/

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport *

from libfolia_classes cimport Document

cdef extern from "<iostream>" namespace "std":
    cdef cppclass ostream:
        ostream()

    cdef cppclass istream:
        pass

    extern ostream cout
    extern ostream cerr


cdef extern from "ticcutils/Configuration.h" namespace "TiCC":
    cdef cppclass Configuration:
        Configuration()
        bool fill( string filename )
        bool hasSection( string section )
        str configDir()

cdef extern from "ticcutils/LogStream.h" namespace "TiCC":
    cdef cppclass LogStream:
        LogStream()
        LogStream(string prefix)

cdef extern from "frog/Frog.h":
    cdef cppclass TimerBlock:
        pass

cdef extern from "frog/ucto_tokenizer_mod.h":
    cdef cppclass UctoTokenizer:
        Document * tokenizehelper( string)

cdef extern from "frog/FrogAPI.h":
    cdef cppclass FrogOptions:
        bool doTok
        bool doLemma
        bool doMorph
        bool doDeepMorph
        bool doMwu
        bool doIOB
        bool doNER
        bool doParse
        bool doSentencePerLine
        bool doQuoteDetection
        bool doDirTest
        bool doServer

        bool doXMLin
        bool doXMLout
        bool doKanon

        int debugFlag
        int numThreads


        bool interactive

        string encoding
        string uttmark
        string listenport
        string docid
        string textclass

        string tmpDirName

        int maxParserTokens


    cdef cppclass FrogAPI:
        UctoTokenizer * tokenizer

        FrogAPI(FrogOptions options, Configuration configuration, LogStream * logstream)

        string Frogtostring(string s)

        string defaultConfigDir()
        string defaultConfigFile()
