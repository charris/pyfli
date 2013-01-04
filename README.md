This project provides Python wrappers for the Finger Lakes Instrumentation
(FLI) SDK libfli-1.104 on Linux and Windows. It exposes all the public
functions and macros with the following exceptions:

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
first letter. The function correspondence is tabulated in the module
documentation.

All the wrappers have document strings that follow the Numpy documentation
standard. Some of the functions in the SDK were undocumented and
`FLIGrabFrame` was a stub. In the first case the lack of documentation is
noted where applicable, and for the second `FLIGrabFrame` was implemented
in a way that seemed appropriate to its name.

Some of the functions require knowledge of the ADC precision and may
segfault if it is incorrectly specified. Finger Lakes doesn't currently
provide a way to determine the operative precision, so it is up to the user
to be careful and track the precision in use. The default value of the
relevant argument has been set to 16 bits, which is safe but will not
provide the expected results for 8 bit devices.

Both Python and Numpy are needed for installation. The supported versions
are Python 2.6-2.7, 3.x and Numpy >= 1.5. These versions are conservative
and it is likely that earlier versions will work.

Tested on Linux Fedora 17 and Windows 7 using python(x,y). The FLI SDK
1.104 and FLI Linux USB driver 1.3 from the FLI support page are provided.

Another option for those interested in Python FLI support is Craig Versek's
ctypes based wrappers https://github.com/cversek/python-FLI.
