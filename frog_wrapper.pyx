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
import os
import sys
cimport libfolia_classes
cimport frog_classes

FROGDATAVERSION = "0.22"
UCTODATAVERSION = "0.9.1"

try:
    from folia.main import Document as FoliaPyDocument
    HASFOLIAPY = True
except:
    try:
        from pynlpl.formats.folia import Document as FoliaPyDocument
        HASFOLIAPY = True
    except ImportError:
        HASFOLIAPY = False
        class FoLiAPyDocument: #dummy
            pass



cdef class Document:
    cdef frog_classes.Document capi



cdef class FrogOptions:
    """Options for Frog, passed as keyword arguments to the constructor. Also accessible like dictionary keys.

    You can pass as keyword arguments to the constructor any options similar to the command-line paramters accepted by Frog.
    Please see frog --help for a complete list.

        * ``skip`` ``[values]`` - Skip Tokenizer (t), Lemmatizer (l), Morphological Analyzer (a), Chunker (c), Multi-Word Units (m), Named Entity Recognition (n), or Parser (p)
        * ``id`` ``[string]`` - Document ID for FoLiA output

    Boolean parameters are passed like ``n=True``

    Old style-options: These are deprecated but supported for backward compatibility reasons:

        * ``tok`` - True/False - Do tokenisation? (default: True)
        * ``lemma`` - True/False - Do lemmatisation? (default: True)
        * ``morph`` - True/False - Do morpholigical analysis? (default: True)
        * ``deepmorph`` - True/False - Do morphological analysis in new experimental style? (default: False)
        * ``mwu`` - True/False - Do Multi Word Unit detection? (default: True)
        * ``chunking`` - True/False - Do Chunking/Shallow parsing? (default: True)
        * ``ner`` - True/False - Do Named Entity Recognition? (default: True)
        * ``parser`` - True/False - Do Dependency Parsing? (default: False)
        * ``xmlin`` - True/False - Input is FoLiA XML (default: False)
        * ``xmlout`` - True/False - Output is FoLiA XML (default: False)
        * ``docid`` - str - Document ID (for FoLiA)
        * ``numThreads`` - int - Number of threads to use (default: unset, unlimited)

    """
    cdef frog_classes.CL_Options capi
    cdef dict shadow
    cdef list skip

    def __init__(self, **kwargs):
        self.shadow = {} #shadow all settings in a dictionary
        self.skip = ["p"] #skip parser by default
        for key, value in kwargs.items():
            self[key] = value

    def __getitem__(self, key):
        key = key.replace("_","-").lower()
        if key in self.shadow:
            return self.shadow[key]
        else:
            raise KeyError("No such key: " + str(key))

    def get(self, key, default=False):
        key = key.replace("_","-").lower()
        if key in self.shadow:
            return self.shadow[key]
        else:
            return default

    def __setitem__(self, key, value):
        key = key.replace("_","-")
        self.shadow[key.lower()] = value
        if key.lower() in ('dotok','tok'):
            if not value: self.skip.append("t")
        elif key.lower() in ('dolemma','lemma'):
            if not value: self.skip.append("l")
        elif key.lower() in ('domorph','morph'):
            if not value: self.skip.append("a")
        elif key.lower() in ('dodaringmorph','daringmorph','deepmorph','dodeepmorph'):
            self.capi.insert(<string>b"deepmorph",<string>b"")
        elif key.lower() in ('domwu','mwu'):
            if not value: self.skip.append("m")
        elif key.lower() in ('doiob','iob','dochunking','chunking','shallowparsing'):
            if not value: self.skip.append("c")
        elif key.lower() in ('doner','ner'):
            if not value: self.skip.append("n")
        elif key.lower() in ('doparse','doparser','parse','parser'):
            if not value:
                self.skip.append("p")
            elif value:
                self.skip.remove("p")
        elif key.lower() in ('doxmlin','xmlin','foliain'):
            self.capi.insert(<char>b"x", <string>b"", False)
        elif key.lower() in ('doxmlout','xmlout','foliaout'):
            self.capi.insert(<char>b"X", <string>b"", False)
        elif key.lower() in ('debug','debugflag'):
            if value: self.capi.insert(<char>b"d", <string>b"1", False)
        elif key.lower() in ('docid','id'):
            if isinstance(value, bytes):
                self.capi.insert(<string>b"id", <string>value)
            else:
                self.capi.insert(<string>b"id", <string>value.encode('utf-8'))
        elif key.lower() in ('numthreads','threads'):
            self.capi.insert(<string>b"threads",<string>value)
        else:
            if key == 'x':
                self.shadow['xmlin'] = True
            elif key == 'X':
                self.shadow['xmlout'] = True
            self.capi.insert(<string>key, <string>value)

    def finish(self):
        v = "".join(self.skip)
        self.capi.insert(<string>b"skip", <string>v.encode('utf-8'))



cdef class Frog:
    cdef frog_classes.FrogAPI * capi
    cdef FrogOptions options
    cdef frog_classes.LogStream logstream
    cdef frog_classes.LogStream debuglogstream

    def __init__(self, FrogOptions options, configurationfile = "", overrides = None):
        """Initialises Frog, pass a FrogOptions instance and a configuration file, and optionally a dictionary containing overrides for the configuration."""

        options.finish()
        if overrides:
            assert(overrides, dict)
            for key, value in overrides.item():
                v = key + "=" + value
                options.capi.insert(<string>b"override", <string>v.encode('utf-8'))

        if configurationfile:
            if configurationfile.startswith("/") and not os.path.exists(configurationfile):
                #better let Python handle  this rather than the binding, so the interpreter can recover
                #When the configurationfile is not absolute thouugh, we let frog handle it (will search in the default config dirs but may come back with a hard failure!)
                raise FileNotFoundError(f"Specified configuration file {configurationfile} does not exist!")
            options.capi.insert(<string>b"config", <string>configurationfile.encode("utf-8"))
        else:
            configurationfile = self.capi.defaultConfigFile(b"nld")
            if not os.path.exists(configurationfile):
                #better let Python handle  this rather than the binding, so the interpreter can recover:
                raise FileNotFoundError(f"Default configuration file {configurationfile} does not exist! Try running frog.installdata() first")
            #(we don't pass this on because Frog will repeat the same logic by default)

        self.options = options
        self.capi = new frog_classes.FrogAPI(options.capi, &self.logstream, &self.debuglogstream)


    def process_raw(self, text):
        """Invokes Frog on the specified text, the text is considered one document. The raw results from Frog are returned as a string"""
        #cdef libfolia_classes.Document * doc = self.capi.tokenizer.tokenizehelper( text.encode('utf-8') )
        cdef string result = self.capi.Frogtostring(self._encode_text(text))
        r = result.decode('utf-8') #if (sys.version < '3' and type(text) == unicode) or (sys.version > '3' and type(text) == str) else result
        return r

    def parsecolumns(self, response):
        """Parse the raw Frog response"""
        if self.options.get('doDeepMorph'):
            columns = ('index','text','lemma','morph','compound','pos','posprob','ner','chunker','depindex','dep')
        else:
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
        if self.options.get('xmlin') and HASFOLIAPY and isinstance(text, FoliaPyDocument):
            text = str(text)
        elif not isinstance(text,str) and not (sys.version < '3' and isinstance(text,unicode)):
            raise ValueError("Text should be a string or FoLiA Document instance")

        if self.options.get('xmlout') and HASFOLIAPY:
            if HASFOLIAPY:
                data = self.process_raw(text)
                if not data:
                    raise ValueError("No data returned")
                elif data[0] != '<':
                    raise ValueError("Returned data is not XML, got: " + str(data[:25]))
                return FoliaPyDocument(string=data)
            else:
                raise Exception("Unable to return a FoLiA Document. FoLiAPy was not installed. Use process_raw() instead if you just want the XML output as string")
        else:
            return self.parsecolumns(self.process_raw(text))

    def _encode_text(self, text):
        if type(text) == str:
            return text.encode('utf-8')
        return text #already was bytes or python2 str

def localpath(name="frog"):
    xdg_config_dir = os.environ.get("XDG_CONFIG_HOME", os.path.join(os.environ.get("HOME",""), ".config"))
    return os.environ.get("FROGDATAPATH", os.path.join(xdg_config_dir,name) )

def installdata(targetdir=None, frogdataversion=FROGDATAVERSION, uctodataversion=UCTODATAVERSION):
    if targetdir is None:
        uctodir = localpath("ucto")
    else:
        uctodir = os.path.join(targetdir,"ucto")
    if os.path.exists(uctodir):
        print(f"Uctodata configuration directory already exists: {uctodir}, refusing to overwrite, please remove it first if you want to install the data anew.", file=sys.stderr)
    else:
        tmpdir=os.environ.get("TMPDIR","/tmp")
        if os.system(f"cd {tmpdir} && mkdir -p {uctodir} && wget -O uctodata.tar.gz https://github.com/LanguageMachines/uctodata/releases/download/v{uctodataversion}/uctodata-{uctodataversion}.tar.gz && tar -xzf uctodata.tar.gz && cd uctodata-{uctodataversion} && mv config/* {uctodir}/ && cd .. && rm -Rf uctodata-{uctodataversion} && rm -Rf uctodata.tar.gz") != 0:
            raise Exception("Installation of uctodata failed")
        print(f"Installation of uctodata {uctodataversion} complete", file=sys.stderr)

    if targetdir is None:
        frogdir = localpath()
    else:
        frogdir = os.path.join(targetdir,"frog")
    if os.path.exists(frogdir):
        print(f"Frogdata configuration directory already exists: {frogdir}, refusing to overwrite, please remove it first if you want to install the data anew.", file=sys.stderr)
    else:
        tmpdir=os.environ.get("TMPDIR","/tmp")
        if os.system(f"cd {tmpdir} && mkdir -p {frogdir} && wget -O frogdata.tar.gz https://github.com/LanguageMachines/frogdata/releases/download/v{frogdataversion}/frogdata-{frogdataversion}.tar.gz && tar -xzf frogdata.tar.gz && cd frogdata-{frogdataversion} && mv config/* {frogdir}/ && cd .. && rm -Rf frogdata-{frogdataversion} && rm -Rf frogdata.tar.gz") != 0:
            raise Exception("Installation of frogdata failed")
        print(f"Installation of frogdata {frogdataversion} complete", file=sys.stderr)

    textcatpath = os.environ.get("TEXTCATPATH","/usr/share/libexttextcat")
    if os.path.isdir(textcatpath):
        if os.system(f"cd {uctodir} && wget -O textcat.cfg https://raw.githubusercontent.com/LanguageMachines/ucto/master/config/textcat.cfg") != 0:
            raise Exception("Installation of textcat.cfg failed.")
        if textcatpath[-1] == '/': textcatpath = textcatpath[:-1]
        if textcatpath != "/usr/share/libexttextcat":
            data = open(f"{uctodir}/textcat.cfg",'r',encoding='utf-8').read()
            with open(f"{uctodir}/textcat.cfg",'w',encoding='utf-8') as f:
                f.write(data.replace("/usr/share/libexttextcat", textcatpath))
    else:
        print("Language detection will not be available unless you install libexttextcat and rerun installdata(). Libexttextcat was not found. If it is in a non-standard location, set environment variable TEXTCATPATH (defaults to /usr/share/libexttextcat) prior to calling installdata()", file=sys.stderr)


    
