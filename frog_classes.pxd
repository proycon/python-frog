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
        string setatt(string&, string&, string&)
        string setatt(string&, string&)

cdef extern from "ticcutils/LogStream.h" namespace "TiCC":
    cdef cppclass LogStream:
        LogStream()
        LogStream(string prefix)

cdef extern from "ticcutils/CommandLine.h" namespace "TiCC":
    cdef cppclass CL_Options:
        CL_Options()
        void insert(string&, string&)
        void insert(char, string&, bool)
        bool is_present(string&)
        bool is_present(char)

cdef extern from "frog/Frog-util.h":
    cdef cppclass TimerBlock:
        pass

cdef extern from "frog/ucto_tokenizer_mod.h":
    cdef cppclass UctoTokenizer:
        Document * tokenizehelper( string)

cdef extern from "frog/FrogAPI.h":

    cdef cppclass FrogAPI:
        UctoTokenizer * tokenizer

        FrogAPI(CL_Options& options, LogStream * logstream, LogStream * debuglogstream)

        string Frogtostring(string s)

        string defaultConfigDir(string lang)
        string defaultConfigFile(string lang)
