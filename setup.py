#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Setup script for pyfli.

"""
import numpy as np
import os
from distutils.core import setup
from distutils.extension import Extension
from distutils.command.build_ext import build_ext


compiler_settings = {
   'libraries'      : ['fli'],
   'include_dirs'   : [np.get_include(), 'libfli-1.104'],
   'library_dirs'   : ['libfli-1.104'],
   'define_macros'  : []
}

sources = [os.path.join('pyfli', 'pyfli.c')]
package_data = {'pyfli': ['*.pyx']}
ext_modules = [Extension('pyfli', sources, **compiler_settings)]


setup(
    name = "pyfli",
    version = "0.1",
    author = "Charles R. Harris",
    author_email = "charlesr.harris@gmail.com",
    download_url = " ",
    keywords = ["FLI", "fli"],
    description = "Python wrapper for Finger Lakes Instrumention SDK",
    package_data = package_data,
    ext_modules = ext_modules,
    requires = ['numpy (>=1.5)'],
    cmdclass = {'build_ext': build_ext},
    classifiers = [
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: BSD License",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Cython",
        "Topic :: Scientific/Engineering",
        "Topic :: Scientific/Engineering :: Astronomy",
        "Topic :: Software Development :: Libraries :: Python Modules"
        ],
    long_description = """\
This is a Python wrapper for the Finger Lakes Instrumentation SDK
libfli-1.104. It exposes all the public functions and macros with the
following exceptions:

    FLICreateList
    FLIDeleteList
    FLIListFirst
    FLIListNext
    FLISetDAC
    FLIDebug

The wrapper for FLIUsbBulkIO is currently set to raise an error as I don't
yet understand the implications of the function and it looks potentially
dangerous.

The wrapper signatures are not precisely the same as the Finger Lakes
functions. For instance, functions that fill user supplied buffers return
numpy arrays instead, C strings are returned as Python strings, and some
arguments are passed as strings instead of C macro values. In addition, the
wrapper functions names generally drop the 'FLI' prefix and lowercase the
first letter. The function correspondence is tabulate in the module
documentation.

All the wrappers have document strings that follow the numpy documentation
standard. Some of the functions in the SDK were undocumented and
FLIGrabFrame was a stub. In the first case the lack of documentation is
noted, and in the second, FLIGrabFrame was implemented in a way that
seemed appropriate to its name.

Some of the functions require knowledge of the ADC precision and may
segfault if it is incorrectly specified. Finger Lakes doesn't currently
provide a way to determine the operative precision, so it is up to the user
to be careful and track the precision in use. The default value of the
relevant argument has been set to 16 bits, which is safe but will not
provide the expected results for 8 bit devices.

The requred numpy version is probably conservative and earlier versions
will probably work, but that hasn't been tested.

"""
)



