#!/usr/bin/env python
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import platform
import os


includedirs = []
libdirs = []
if platform.system() == "Darwin":
    #we are running on Mac OS X (with homebrew hopefully), stuff is in specific locations:
    if platform.machine().lower() == "arm64":
        libdirs.append("/opt/homebrew/lib")
        includedirs.append("/opt/homebrew/include")
        libdirs.append("/opt/homebrew/icu4c/lib")
        includedirs.append("/opt/homebrew/icu4c/include")
        libdirs.append("/opt/homebrew/libxml2/lib")
        includedirs.append("/opt/homebrew/libxml2/include")
        includedirs.append("/opt/homebrew/libxml2/include/libxml2")
    else:
        #we are running on Mac OS X with homebrew, stuff is in specific locations:
        libdirs.append("/usr/local/opt/icu4c/lib")
        includedirs.append("/usr/local/opt/icu4c/include")
        libdirs.append("/usr/local/opt/libxml2/lib")
        includedirs.append("/usr/local/opt/libxml2/include")
        includedirs.append("/usr/local/opt/libxml2/include/libxml2")

#add some common default paths
includedirs += ['/usr/include/', '/usr/include/libxml2','/usr/local/include/' ]
libdirs += ['/usr/lib','/usr/local/lib']
if 'VIRTUAL_ENV' in os.environ:
    includedirs.insert(0,os.environ['VIRTUAL_ENV'] + '/include')
    libdirs.insert(0,os.environ['VIRTUAL_ENV'] + '/lib')
if 'INCLUDE_DIRS' in os.environ:
    includedirs = list(os.environ['INCLUDE_DIRS'].split(':')) + includedirs
if 'LIBRARY_DIRS' in os.environ:
    libdirs = list(os.environ['LIBRARY_DIRS'].split(':')) + libdirs

if platform.system() == "Darwin":
    extra_options = ["--stdlib=libc++",'-D U_USING_ICU_NAMESPACE=1']
else:
    extra_options = ['-D U_USING_ICU_NAMESPACE=1']

extensions = cythonize([ 
                        Extension("frog",
                            [ "libfolia_classes.pxd", "frog_classes.pxd", "frog_wrapper.pyx"],
                            language='c++',
                            include_dirs=includedirs,
                            library_dirs=libdirs,
                            libraries=['frog','ucto','folia'],
                            extra_compile_args=['--std=c++0x'] + extra_options) 
                       ],
                compiler_directives={"language_level": "3"}
                )


setup(
    name = 'python-frog',
    version = '0.6.3', #also ensure UCTODATAVERSION and FROGDATAVERSION are good in frog_wrapper.pyx
    author = "Maarten van Gompel",
    author_email = "proycon@anaproy.nl",
    description = ("Python binding to Frog, an NLP suite for Dutch doing part-of-speech tagging, lemmatisation, morphological analysis, named-entity recognition, shallow parsing, and dependency parsing."),
    license = "GPLv3",
    keywords = "nlp computational_linguistics dutch pos lemmatizer",
    url = "https://github.com/proycon/python-frog",
    ext_modules = extensions,
    cmdclass = {'build_ext': build_ext},
    requires = ['frog (>=0.26)','ucto (>=0.27)'],
    install_requires=['Cython'],
    data_files = [("sources",["frog_wrapper.pyx"])],
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
)
