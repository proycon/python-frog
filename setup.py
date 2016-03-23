#!/usr/bin/env python
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
import glob
import os

from os.path import expanduser
HOMEDIR = expanduser("~")


includedirs = [HOMEDIR + '/local/include/','/usr/include/', '/usr/include/libxml2','/usr/local/include/' ]
libdirs = [HOMEDIR + '/local/lib/','/usr/lib','/usr/local/lib']
if 'VIRTUAL_ENV' in os.environ:
    includedirs.insert(0,os.environ['VIRTUAL_ENV'] + '/include')
    libdirs.insert(0,os.environ['VIRTUAL_ENV'] + '/lib')

extensions = [ Extension("frog",
                [ "libfolia_classes.pxd", "frog_classes.pxd", "frog_wrapper.pyx"],
                language='c++',
                include_dirs=includedirs,
                library_dirs=libdirs,
                libraries=['frog','ucto','folia'],
                extra_compile_args=['--std=c++0x'],
                pyrex_gdb=True
                ) ]

setup(
    name = 'python-frog',
    version = '0.3.2',
    author_email = "proycon@anaproy.nl",
    description = ("Python binding to FROG, an NLP suite for Dutch doing part-of-speech tagging, lemmatisation, morphological analysis, named-entity recognition, shallow parsing, and dependency parsing."),
    requires = ['frog (>=0.13.4)'],
    license = "GPL",
    keywords = "nlp computational_linguistics dutch pos lemmatizer",
    url = "https://github.com/proycon/python-frog",
    ext_modules = extensions,
    cmdclass = {'build_ext': build_ext},
    classifiers=[
        "Development Status :: 4 - Beta",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
)
