#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Setup script for pyfli.

"""
import numpy as np
import os
import platform
from distutils.core import setup
from distutils.extension import Extension
from distutils.command.build_ext import build_ext

system = platform.system()

flicom = "libfli-1.104"
fliwin = os.path.join(flicom, "windows")
fliunx = os.path.join(flicom, "unix")
flilin = os.path.join(fliunx, "linux")
flibsd = os.path.join(fliunx, "bsd")
fliosx = os.path.join(fliunx, "osx")

comsrc = [
    os.path.join(flicom, "libfli.c"),
    os.path.join(flicom, "libfli-camera.c"),
    os.path.join(flicom, "libfli-camera-parport.c"),
    os.path.join(flicom, "libfli-camera-usb.c"),
    os.path.join(flicom, "libfli-filter-focuser.c"),
    os.path.join(flicom, "libfli-mem.c")
    ]
unxsrc = [
    os.path.join(fliunx, "libfli-serial.c"),
    os.path.join(fliunx, "libfli-debug.c"),
    os.path.join(fliunx, "libfli-usb.c"),
    os.path.join(fliunx, "libfli-sys.c")
    ]
winsrc = [
    os.path.join(fliwin, "libfli-serial.c"),
    os.path.join(fliwin, "libfli-debug.c"),
    os.path.join(fliwin, "libfli-usb.c"),
    os.path.join(fliwin, "libfli-windows.c"),
    os.path.join(fliwin, "libfli-windows-parport.c"),
    os.path.join(flicom, "libfli-raw.c")
    ]
linsrc = [
    os.path.join(flilin, "libfli-usb-sys.c"),
    os.path.join(flilin, "libfli-parport.c")
    ]
bsdsrc = [
    os.path.join(flibsd, "libfli-usb-sys.c")
    ]
osxsrc = [
    ]

modpth = "pyfli"
modsrc = [os.path.join(modpth, "pyfli.c")]
if system == "Linux":
    src = modsrc + comsrc + unxsrc + linsrc
    inc = [np.get_include(), modpth, flicom, fliunx, flilin]
    lib = []
    mac = []
elif system == "BSD":
# not certain that BSD is the correct identifier
    src = modsrc + comsrc + unxsrc + bsdsrc
    inc = [np.get_include(), modpth, flicom, fliunx, flibsd]
    lib = []
    mac = []
elif system == "Darwin":
    src = modsrc + comsrc + unxsrc + osxsrc
    inc = [np.get_include(), modpth, flicom, fliunx, fliosx]
    lib = []
    mac = []
elif system == "Windows":
    src = modsrc + comsrc + winsrc
    inc = [np.get_include(), modpth, flicom, fliwin]
    lib = ["setupapi", "msvcrt" , "ws2_32"]
    mac = [("_LIB", None)]
else:
    raise RuntimeError("Unrecognized system")

compiler_settings = {
   'libraries'      : lib,
   'include_dirs'   : inc,
   'library_dirs'   : [],
   'define_macros'  : mac,
   'export_symbols' : None
}

package_data = {'pyfli': ['*.pyx']}
ext_modules = [Extension('pyfli', src, **compiler_settings)]


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
        "Operating System :: Microsoft :: Windows",
        "Operating System :: Microsoft :: Windows :: Windows 7",
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
This package supplies Python wrappers for the functions in the Finger Lakes
Instrumentation SDK libfli-1.104 on Linux and Windows. It exposes all the
public functions and macros with the following exceptions:

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
wrapper function names generally drop the 'FLI' prefix and lowercase the
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

The required numpy version is conservative and earlier versions
will probably work, but they haven't been tested.

"""
)



