This project provides a Python wrappers for the Finger Lakes Instrumentation
SDK libfli-1.104 on Linux. It exposes all the public functions and macros
with the following exceptions:

    FLICreateList
    FLIDeleteList
    FLIListFirst
    FLIListNext
    FLISetDAC
    FLIDebug

The wrapper signatures are not precisely the same as the Finger Lakes
functions. For instance, functions that fill user supplied buffers return
numpy arrays instead, C strings are returned as Python strings, and some
arguments are passed as strings instead of C macro values.

All the wrappers have document strings that follow the Numpy documentation
standard. Some of the functions in the SDK were undocumented and
`FLIGrabFrame` was a stub. In the first case the lack of documentation is
noted where applicable, and for the second `FLIGrabFrame` was implemented
in a way that seemed appropriate to its name.

Some of the functions require knowledge of the ADC precision and may
segfault if it is incorrectly specified. Finger Lakes doesn't currently
provide a way to determine the operative precision, so it is up to the user
to be careful and track the precision in use.

Both Python and Numpy are needed for installation. The supported versions
are Python 2.6-2.7 and Numpy >= 1.5. These versions are probably
conservative and it is likely that earlier versions will work. Python 3 is
not currently supported, but as far as I know the only things that may
create difficulties are strings. One case that will definitely cause
trouble is noted in the pyfli.pyd source.

Tested on Linux 3.6.10-2.fc17.x86\_64 Fedora 17. FLI SDK 1.104 and FLI
Linux USB driver 1.3 from http://www.flicamera.com/software/index.html are
provided.

Another option for those interested in Python FLI support is Craig Versek's
ctypes based wrappers https://github.com/cversek/python-FLI.
