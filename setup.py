#!/usr/bin/env python3
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
import glob
import os

from os.path import expanduser
HOMEDIR = expanduser("~")


extensions = [ Extension("frog",
                [ "frog_classes.pxd", "frog_wrapper.pyx"],
                language='c++',
                include_dirs=[HOMEDIR + '/local/include/','/usr/include/', '/usr/include/libxml2','/usr/local/include/' ],
                library_dirs=[HOMEDIR + '/local/lib/','/usr/lib','/usr/local/lib'],
                libraries=['frog','ucto','folia'],
                pyrex_gdb=True
                ) ]

setup(
    name = 'python-frog',
    version = '0.1',
    ext_modules = extensions,
    cmdclass = {'build_ext': build_ext},
    classifiers=[
        "Development Status :: 4 - Beta",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
)
