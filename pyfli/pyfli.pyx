"""Interface to Finger Lakes Instrumentation SDK

With a few exceptions, the FLI function names have been modified by
stripping off the leading FLI and making the first letter of the result
lower case. The exceptions are at the top of the table.


Included Functions
------------------

=========================  ===========================
Module Function            FLI Function
=========================  ===========================
FLIClose                   FLIClose
FLIList                    FLIList
FLIOpen                    FLIOpen
FLISetDebugLevel           FLISetDebugLevel
cancelExposure             FLICancelExposure
configureIOPort            FLIConfigureIOPort
controlBackgroundFlush     FLIControlBackgroundFlush
controlShutter             FLIControlShutter
enableVerticalTable        FLIEnableVerticalTable
endExposure                FLIEndExposure
exposeFrame                FLIExposeFrame
flushRow                   FLIFlushRow
freeList                   FLIFreeList
getActiveWheel             FLIGetActiveWheel
getArrayArea               FLIGetArrayArea
getCameraMode              FLIGetCameraMode
getCameraModeString        FLIGetCameraModeString
getCoolerPower             FLIGetCoolerPower
getDeviceStatus            FLIGetDeviceStatus
getExposureStatus          FLIGetExposureStatus
getFWRevision              FLIGetFWRevision
getFilterCount             FLIGetFilterCount
getFilterName              FLIGetFilterName
getFilterPos               FLIGetFilterPos
getFocuserExtent           FLIGetFocuserExtent
getHWRevision              FLIGetHWRevision
getLibVersion              FLIGetLibVersion
getModel                   FLIGetModel
getPixelSize               FLIGetPixelSize
getReadoutDimensions       FLIGetReadoutDimensions
getSerialString            FLIGetSerialString
getStepperPosition         FLIGetStepperPosition
getStepsRemaining          FLIGetStepsRemaining
getTemperature             FLIGetTemperature
getVerticalTableEntry      FLIGetVerticalTableEntry
getVisibleArea             FLIGetVisibleArea
grabFrame                  FLIGrabFrame
grabRow                    FLIGrabRow
grabVideoFrame             FLIGrabVideoFrame
homeDevice                 FLIHomeDevice
homeFocuser                FLIHomeFocuser
lockDevice                 FLILockDevice
readIOPort                 FLIReadIOPort
readTemperature            FLIReadTemperature
readUserEEPROM             FLIReadUserEEPROM
setActiveWheel             FLISetActiveWheel
setBitDepth                FLISetBitDepth
setCameraMode              FLISetCameraMode
setExposureTime            FLISetExposureTime
setFanSpeed                FLISetFanSpeed
setFilterPos               FLISetFilterPos
setFrameType               FLISetFrameType
setHBin                    FLISetHBin
setImageArea               FLISetImageArea
setNFlushes                FLISetNFlushes
setTDI                     FLISetTDI
setTemperature             FLISetTemperature
setVBin                    FLISetVBin
setVerticalTableEntry      FLISetVerticalTableEntry
startVideoMode             FLIStartVideoMode
stepMotor                  FLIStepMotor
stepMotorAsync             FLIStepMotorAsync
stopVideoMode              FLIStopVideoMode
triggerExposure            FLITriggerExposure
unlockDevice               FLIUnlockDevice
usbBulkIO                  FLIUsbBulkIO
writeIOPort                FLIWriteIOPort
writeUserEEPROM            FLIWriteUserEEPROM
=========================  ===========================

Omitted Functions
-----------------

FLICreateList
FLIDeleteList
FLIListFirst
FLIListNext
FLISetDAC
FLIDebug

Deprecated Functions
--------------------
FLIHomeFocuser, deprecated, use homeDevice

Notes
-----

The functions can be collected together into cdef classes and that makes
the generated module significantly smaller as the ``device`` number can
be stored as a C type when the classes are instantiated and used in the
FLI function calls. However, the current form as a collection of separate
functions is a bit lower level and was chosen for that reason.

"""
import os
import sys
import warnings
import numpy as np

cimport cython
cimport libfli as fli
cimport numpy as np
from libc.stdlib cimport malloc, free

np.import_array()

__all__ = [
        'BGFLUSH_START', 'BGFLUSH_STOP', 'CAMERA_DATA_READY',
        'CAMERA_STATUS_EXPOSING', 'CAMERA_STATUS_IDLE',
        'CAMERA_STATUS_MASK', 'CAMERA_STATUS_READING_CCD',
        'CAMERA_STATUS_UNKNOWN', 'CAMERA_STATUS_WAITING_FOR_TRIGGER',
        'DEBUG_ALL', 'DEBUG_FAIL', 'DEBUG_INFO', 'DEBUG_IO', 'DEBUG_NONE',
        'DEBUG_WARN', 'DEVICE_CAMERA', 'DEVICE_ENUMERATE_BY_CONNECTION',
        'DEVICE_FILTERWHEEL', 'DEVICE_FOCUSER', 'DEVICE_HS_FILTERWHEEL',
        'DEVICE_NONE', 'DEVICE_RAW', 'DOMAIN_INET', 'DOMAIN_NONE',
        'DOMAIN_PARALLEL_PORT', 'DOMAIN_SERIAL', 'DOMAIN_SERIAL_1200',
        'DOMAIN_SERIAL_19200', 'DOMAIN_USB', 'EEPROM_PIXEL_MAP',
        'EEPROM_USER', 'FAN_SPEED_OFF', 'FAN_SPEED_ON',
        'FILTER_POSITION_CURRENT', 'FILTER_POSITION_UNKNOWN',
        'FILTER_STATUS_HOME', 'FILTER_STATUS_HOME_LEFT',
        'FILTER_STATUS_HOME_RIGHT', 'FILTER_STATUS_HOME_SUCCEEDED',
        'FILTER_STATUS_HOMING', 'FILTER_STATUS_MOVING_CCW',
        'FILTER_STATUS_MOVING_CW', 'FILTER_WHEEL_LEFT',
        'FILTER_WHEEL_PHYSICAL', 'FILTER_WHEEL_RIGHT',
        'FILTER_WHEEL_VIRTUAL', 'FLIClose', 'FLIList', 'FLIOpen',
        'FOCUSER_STATUS_HOME', 'FOCUSER_STATUS_HOMING',
        'FOCUSER_STATUS_LEGACY', 'FOCUSER_STATUS_LIMIT',
        'FOCUSER_STATUS_MOVING_IN', 'FOCUSER_STATUS_MOVING_MASK',
        'FOCUSER_STATUS_MOVING_OUT', 'FOCUSER_STATUS_UNKNOWN',
        'FRAME_TYPE_DARK', 'FRAME_TYPE_FLOOD', 'FRAME_TYPE_NORMAL',
        'FRAME_TYPE_RBI_FLUSH', 'INVALID_DEVICE', 'IO_P0', 'IO_P1',
        'IO_P2', 'IO_P3', 'MODE_16BIT', 'MODE_8BIT',
        'PIXEL_DEFECT_CLUSTER', 'PIXEL_DEFECT_COLUMN',
        'PIXEL_DEFECT_POINT_BRIGHT', 'PIXEL_DEFECT_POINT_DARK',
        'SHUTTER_CLOSE', 'SHUTTER_EXTERNAL_EXPOSURE_CONTROL',
        'SHUTTER_EXTERNAL_TRIGGER', 'SHUTTER_EXTERNAL_TRIGGER_HIGH',
        'SHUTTER_EXTERNAL_TRIGGER_LOW', 'SHUTTER_OPEN', 'TEMPERATURE_BASE',
        'TEMPERATURE_CCD', 'TEMPERATURE_EXTERNAL', 'TEMPERATURE_INTERNAL',
        'UsbBulkIO', 'cancelExposure', 'configureIOPort',
        'controlBackgroundFlush', 'controlShutter', 'enableVerticalTable',
        'endExposure', 'exposeFrame', 'flushRow', 'getActiveWheel',
        'getArrayArea', 'getCameraMode', 'getCameraModeString',
        'getCoolerPower', 'getDeviceStatus', 'getExposureStatus',
        'getFWRevision', 'getFilterCount', 'getFilterName', 'getFilterPos',
        'getFocuserExtent', 'getHWRevision', 'getLibVersion', 'getModel',
        'getPixelSize', 'getReadoutDimensions', 'getSerialString',
        'getStepperPosition', 'getStepsRemaining', 'getTemperature',
        'getVerticalTableEntry', 'getVisibleArea', 'grabFrame', 'grabRow',
        'grabVideoFrame', 'homeDevice', 'homeFocuser', 'lockDevice',
        'readIOPort', 'readTemperature', 'readUserEEPROM',
        'setActiveWheel', 'setBitDepth', 'setCameraMode', 'setDebugLevel',
        'setExposureTime', 'setFanSpeed', 'setFilterPos', 'setFrameType',
        'setHBin', 'setImageArea', 'setNFlushes', 'setTDI',
        'setTemperature', 'setVBin', 'setVerticalTableEntry',
        'startVideoMode', 'stepMotor', 'stepMotorAsync', 'stopVideoMode',
        'triggerExposure', 'unlockDevice', 'writeIOPort', 'writeUserEEPROM'
        ]

# python 3 compatibility functions

if sys.version_info[0] >= 3:

    def asbytes(s):
        if isinstance(s, bytes):
            return s
        return str(s).encode('latin1')

    def asstr(s):
        if isinstance(s, bytes):
            return s.decode('latin1')
        return str(s)

else:
    asbytes = str
    asstr = str

# precision lookup

ADCType = {'8bit' : np.dtype(np.uint8), '16bit': np.dtype(np.uint16)}

# maximum number of devices searched for
cdef int MAXDEVICES = 100

# FLI Defined constants

# Error defines
INVALID_DEVICE = fli.FLI_INVALID_DEVICE

# DOMAIN defines
DOMAIN_NONE = fli.FLIDOMAIN_NONE
DOMAIN_PARALLEL_PORT = fli.FLIDOMAIN_PARALLEL_PORT
DOMAIN_USB = fli.FLIDOMAIN_USB
DOMAIN_SERIAL = fli.FLIDOMAIN_SERIAL
DOMAIN_INET = fli.FLIDOMAIN_INET
DOMAIN_SERIAL_19200 = fli.FLIDOMAIN_SERIAL_19200
DOMAIN_SERIAL_1200 = fli.FLIDOMAIN_SERIAL_1200

# DEVICE defines
DEVICE_NONE = fli.FLIDEVICE_NONE
DEVICE_CAMERA = fli.FLIDEVICE_CAMERA
DEVICE_FILTERWHEEL = fli.FLIDEVICE_FILTERWHEEL
DEVICE_FOCUSER = fli.FLIDEVICE_FOCUSER
DEVICE_HS_FILTERWHEEL = fli.FLIDEVICE_HS_FILTERWHEEL
DEVICE_RAW = fli.FLIDEVICE_RAW
DEVICE_ENUMERATE_BY_CONNECTION = fli.FLIDEVICE_ENUMERATE_BY_CONNECTION

# FRAME defines
FRAME_TYPE_NORMAL = fli.FLI_FRAME_TYPE_NORMAL
FRAME_TYPE_DARK = fli.FLI_FRAME_TYPE_DARK
FRAME_TYPE_FLOOD = fli.FLI_FRAME_TYPE_FLOOD
FRAME_TYPE_RBI_FLUSH = fli.FLI_FRAME_TYPE_RBI_FLUSH

# MODE defines
MODE_8BIT = fli.FLI_MODE_8BIT
MODE_16BIT = fli.FLI_MODE_16BIT

# SHUTTER defines
SHUTTER_CLOSE = fli.FLI_SHUTTER_CLOSE
SHUTTER_OPEN = fli.FLI_SHUTTER_OPEN
SHUTTER_EXTERNAL_TRIGGER = fli.FLI_SHUTTER_EXTERNAL_TRIGGER
SHUTTER_EXTERNAL_TRIGGER_LOW = fli.FLI_SHUTTER_EXTERNAL_TRIGGER_LOW
SHUTTER_EXTERNAL_TRIGGER_HIGH = fli.FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH
SHUTTER_EXTERNAL_EXPOSURE_CONTROL = fli.FLI_SHUTTER_EXTERNAL_EXPOSURE_CONTROL

# BGFLUSH defines
BGFLUSH_STOP = fli.FLI_BGFLUSH_STOP
BGFLUSH_START = fli.FLI_BGFLUSH_START

# TEMPERATURE defines
TEMPERATURE_INTERNAL = fli.FLI_TEMPERATURE_INTERNAL
TEMPERATURE_EXTERNAL = fli.FLI_TEMPERATURE_EXTERNAL
TEMPERATURE_CCD = fli.FLI_TEMPERATURE_CCD
TEMPERATURE_BASE = fli.FLI_TEMPERATURE_BASE

# CAMERA_STATUS defines
CAMERA_STATUS_UNKNOWN = fli.FLI_CAMERA_STATUS_UNKNOWN
CAMERA_STATUS_MASK = fli.FLI_CAMERA_STATUS_MASK
CAMERA_STATUS_IDLE = fli.FLI_CAMERA_STATUS_IDLE
CAMERA_STATUS_WAITING_FOR_TRIGGER = fli.FLI_CAMERA_STATUS_WAITING_FOR_TRIGGER
CAMERA_STATUS_EXPOSING = fli.FLI_CAMERA_STATUS_EXPOSING
CAMERA_STATUS_READING_CCD = fli.FLI_CAMERA_STATUS_READING_CCD
CAMERA_DATA_READY = fli.FLI_CAMERA_DATA_READY

# FOCUSER_STATUS defines
FOCUSER_STATUS_UNKNOWN = fli.FLI_FOCUSER_STATUS_UNKNOWN
FOCUSER_STATUS_HOMING = fli.FLI_FOCUSER_STATUS_HOMING
FOCUSER_STATUS_MOVING_IN = fli.FLI_FOCUSER_STATUS_MOVING_IN
FOCUSER_STATUS_MOVING_OUT = fli.FLI_FOCUSER_STATUS_MOVING_OUT
FOCUSER_STATUS_MOVING_MASK = fli.FLI_FOCUSER_STATUS_MOVING_MASK
FOCUSER_STATUS_HOME = fli.FLI_FOCUSER_STATUS_HOME
FOCUSER_STATUS_LIMIT = fli.FLI_FOCUSER_STATUS_LIMIT
FOCUSER_STATUS_LEGACY = fli.FLI_FOCUSER_STATUS_LEGACY

# FILTER_WHEEL STATUS defines
FILTER_WHEEL_PHYSICAL = fli.FLI_FILTER_WHEEL_PHYSICAL
FILTER_WHEEL_VIRTUAL = fli.FLI_FILTER_WHEEL_VIRTUAL
FILTER_WHEEL_LEFT = fli.FLI_FILTER_WHEEL_LEFT
FILTER_WHEEL_RIGHT = fli.FLI_FILTER_WHEEL_RIGHT
FILTER_STATUS_MOVING_CCW = fli.FLI_FILTER_STATUS_MOVING_CCW
FILTER_STATUS_MOVING_CW = fli.FLI_FILTER_STATUS_MOVING_CW
FILTER_POSITION_UNKNOWN = fli.FLI_FILTER_POSITION_UNKNOWN
FILTER_POSITION_CURRENT = fli.FLI_FILTER_POSITION_CURRENT
FILTER_STATUS_HOMING = fli.FLI_FILTER_STATUS_HOMING
FILTER_STATUS_HOME = fli.FLI_FILTER_STATUS_HOME
FILTER_STATUS_HOME_LEFT = fli.FLI_FILTER_STATUS_HOME_LEFT
FILTER_STATUS_HOME_RIGHT = fli.FLI_FILTER_STATUS_HOME_RIGHT
FILTER_STATUS_HOME_SUCCEEDED = fli.FLI_FILTER_STATUS_HOME_SUCCEEDED

# DEBUG defines
DEBUG_NONE = fli.FLIDEBUG_NONE
DEBUG_INFO = fli.FLIDEBUG_INFO
DEBUG_WARN = fli.FLIDEBUG_WARN
DEBUG_FAIL = fli.FLIDEBUG_FAIL
DEBUG_IO = fli.FLIDEBUG_IO
DEBUG_ALL = fli.FLIDEBUG_ALL

# IO defines
IO_P0 = fli.FLI_IO_P0
IO_P1 = fli.FLI_IO_P1
IO_P2 = fli.FLI_IO_P2
IO_P3 = fli.FLI_IO_P3

# FAN defines
FAN_SPEED_OFF = fli.FLI_FAN_SPEED_OFF
FAN_SPEED_ON = fli.FLI_FAN_SPEED_ON

# EEPROM defines
EEPROM_USER = fli.FLI_EEPROM_USER
EEPROM_PIXEL_MAP = fli.FLI_EEPROM_PIXEL_MAP

# PIXEL_DEFECT defines
PIXEL_DEFECT_COLUMN = fli.FLI_PIXEL_DEFECT_COLUMN
PIXEL_DEFECT_CLUSTER = fli.FLI_PIXEL_DEFECT_CLUSTER
PIXEL_DEFECT_POINT_BRIGHT = fli.FLI_PIXEL_DEFECT_POINT_BRIGHT
PIXEL_DEFECT_POINT_DARK = fli.FLI_PIXEL_DEFECT_POINT_DARK


# Locking decorator
def withDeviceLocked(f):
    """Lock device used in fli function call.

    Parameters
    ----------
    f : function
        Function to work with device locked.

    Returns
    -------
    func : function
        Function wrapper for call

    """
    def func(dev, *args, **kwargs):
        lockDevice(dev)
        try:
            return f(dev, *args, **kwargs)
        finally:
            unlockDevice(dev)

    return func


# This helper function will be static by default.
cdef int chkerr(long err) nogil except -1:
    """

    Check FLI function return error code.

    The error code is supposed to be the system error code,
    but that might not be the case with invalid device which
    seems to be 1.

    Parameters
    ----------
    err : long

    Raises
    ------
    OSError
    RuntimeError

    """
    if err < 0:
        with gil:
            raise OSError(-err, os.strerror(-err))
    elif err > 0:
        # probably shouldn't happen
        with gil:
            raise RuntimeError("unknown error")

@withDeviceLocked
def enableVerticalTable(dev, width, offset, flags):
    """

    Enable vertical table.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    width : int

    offset : int

    flags : int

    """
    chkerr(fli.FLIEnableVerticalTable(dev, width, offset, flags))


@withDeviceLocked
def getVerticalTableEntry(dev, index):
    """

    Get vertical table entry.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    index : int

    Returns
    -------
    height : int
    bin : int
    mode : int

    """
    cdef long height
    cdef long bin_
    cdef long mode

    chkerr(fli.FLIGetVerticalTableEntry(dev, index, &height, &bin_, &mode))
    return height, bin_, mode


@withDeviceLocked
def setVerticalTableEntry(dev, index, height, bin_, mode):
    """

    Set vertical table entry.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    index : int
    height : int
    bin_ : int
    mode : int

    """
    chkerr(fli.FLISetVerticalTableEntry(dev, index, height, bin_, mode))


@withDeviceLocked
def grabFrame(dev, depth='16bit', out=None):
    """

    Grab frame.

    This function is an undocumented stub in libfli-1.104 and will return
    the error code for Invalid argument. So we make an appropriate function
    using other fli library functions. The size of the returned array is
    obtained from a call to `getReadoutDimensions`.

    Parameters
    ----------
    dev : int
        Device handle.
    depth : {'16bit', '8bit'}, optional
        Bitdepth. If this is set incorrectly a seqfault may result. The
        '16bit' value is safe and is the default, but if actual data is
        '8bit' the result will not look right.
    out : ndarray, optional
        The frame will be read into the `out` array if it is specified. It
        must have the correct dimensions to contain the frame, but it can
        have a different type than specified by `depth`.

    Returns
    -------
    frame : ndarray
        A 2-D ndarray. If `out` is given it will be a reference to `out`,
        otherwise it is a new array of type np.uint8 or np.uint16 depending
        on the value of `depth`.

    See Also
    --------
    getReadoutDimensions
    setImageArea
    grabRow

    """
    cdef long rowlen
    cdef long flidev
    cdef long err
    cdef void *rowptr

    width, hoffset, hbin, height, voffset, vbin = getReadoutDimensions(dev)
    shape = (height, width)
    convert = False

    dt = ADCType[depth]
    if out is not None:
        if out.shape != shape:
            msg = "The out argument has wrong dimensions."
            raise ValueError(msg)
        if out.dtype != dt:
            convert = True
            buf = np.empty(shape, dt)
        else:
            convert = False
            buf = out
    else:
        buf = np.empty(shape, dt)

    flidev = dev
    rowlen = width
    for row in buf:
        rowptr = np.PyArray_DATA(row)
        with nogil:
            chkerr(fli.FLIGrabRow(flidev, rowptr, rowlen))

    if convert:
        out[...] = buf
        return out
    else:
        return buf


@withDeviceLocked
def readUserEEPROM(dev, loc, address, nbytes):
    """

    Read user EEPROM.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    loc : {'user', 'pixel-map'}
        Location.
    address : int
        EEPROM byte address of first byte.
    nbytes : int
        Number of bytes to read.

    Returns
    -------
    data : ndarray of uint8

    """
    cdef long loc_

    if loc == 'user':
        loc_ = fli.FLI_EEPROM_USER
    elif loc == 'pixel-map':
        loc_ = fli.FLI_EEPROM_PIXEL_MAP
    else:
        msg = "Invalid loc %s." % loc
        raise ValueError(msg)

    buf = np.empty(nbytes, np.uint8)

    chkerr(fli.FLIReadUserEEPROM(dev, loc_, address, nbytes,
            np.PyArray_DATA(buf)))
    return buf


@withDeviceLocked
def writeUserEEPROM(dev, loc, address, data):
    """

    Write user EEPROM.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    loc : {'user', 'pixel-map'}
        Location.
    address : int
        EEPROM byte address of first byte.
    data : ndarray
        Data to be written. The data is converted to an array of
        contiguous bytes and then written in C order. So, for instance,
        an integer will normally fill four bytes.

    Examples
    --------

    >>> import pyfli as fli
    >>> import numpy as np
    >>> cam = fli.FLIOpen('/dev/flicamera', 'usb', 'camera')
    >>> msg = np.fromstring('Hello World', uint8)
    >>> fli.writeUserEEPROM(cam, 'user', 0, msg)
    >>> fli.readUserEEPROM(cam, 'user', 0, msg.size).tostring()
    'Hello World'
    >>> cam = fli.FLIClose(cam)




    """
    cdef long loc_

    if loc == 'user':
        loc_ = fli.FLI_EEPROM_USER
    elif loc == 'pixel-map':
        loc_ = fli.FLI_EEPROM_PIXEL_MAP
    else:
        msg = "Invalid loc %s." % loc
        raise ValueError(msg)

    data = np.ascontiguousarray(data).view(np.int8)
    chkerr(fli.FLIWriteUserEEPROM(dev, loc_, address, data.size,
            np.PyArray_DATA(data)))


@withDeviceLocked
def setTDI(dev, rate, flags):
    """

    Set TDI.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    rate : int
        TDI Rate.
    flags : int
        Flags

    """
    msg = "Undocumented, be careful, action unknown"
    warnings.warn(msg, RuntimeWarning)
    chkerr(fli.FLISetTDI(dev, rate, flags))


@withDeviceLocked
def startVideoMode(dev):
    """

    Start video Mode.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    stopVideoMode
    grabVideoFrame

    Notes
    -----
    Changing the image area while in video mode will cause a segfault on
    readout. This looks like an FLI bug.

    """
    chkerr(fli.FLIStartVideoMode(dev))


@withDeviceLocked
def stopVideoMode(dev):
    """

    Stop video mode.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    stopVideoMode
    grabVideoFrame

    """
    chkerr(fli.FLIStopVideoMode(dev))


@withDeviceLocked
def grabVideoFrame(dev, out=None):
    """

    Grab video frame.

    Undocumented. This feature is only available on ProLine and MicroLine
    cameras and the bitdepth is always 16 bits.

    Parameters
    ----------
    dev : int
        Device handle.
    out : ndarray, optional
        The frame will be read into the `out` array if it is specified. It
        must have the correct dimensions to contain the frame, but it can
        have a different type than specified by `depth`.

    Returns
    -------
    frame : ndarray
        A 2-D ndarray. If `out` is given it will be a reference to `out`,
        otherwise it is a new array of type np.uint16.

    See Also
    --------
    startVideoMode
    stopVideoMode
    getReadoutDimensions
    setImageArea
    setExposureTime

    """
    width, hoffset, hbin, height, voffset, vbin = getReadoutDimensions(dev)
    shape = (height, width)
    convert = False

    dt = ADCType['16bit']
    if out is not None:
        if out.shape != shape:
            msg = "The out argument has wrong dimensions."
            raise ValueError(msg)
        if out.dtype != dt:
            convert = True
            buf = np.empty(shape, dt)
        else:
            convert = False
            buf = out
    else:
        buf = np.empty(shape, dt)


    nbytes = buf.size * buf.itemsize
    chkerr(fli.FLIGrabVideoFrame(dev, np.PyArray_DATA(buf), nbytes))

    if convert:
        out[...] = buf
        return out
    else:
        return buf


#fixme
@withDeviceLocked
def UsbBulkIO(dev, int ep, long length):
    """

    USB bulk IO.

    Undocumented. This currently is set to raise RuntimeError until its
    proper use can be determined. It looks like `ep` is one of *_BULKWRITE,
    *_BULKREAD, where the prefix depends on windows or unix. Those macros
    aren't included in the toplevel include file, so it isn't clear if this
    is system dependent. This function currently raises RuntimeError until
    it can be properly understood.

    Parameters
    ----------
    dev : int
        Device handle.
    ep : int
        ? undocumented
    length : int
        ? bytes

    Returns
    -------
    data : ndarray of uint8
        The length of the array is the amount of data actually read, it
        may not be the same as the amount of data requested.

    """
    msg = "Undocumented, too dangerous to allow at this point"
    raise RuntimeError(msg)

    buf = np.empty(length, dtype=np.uint8)
    cdef long len_ = length

    chkerr(fli.FLIUsbBulkIO(dev, ep, np.PyArray_Data(buf), &len_))
    return buf[:len_]


#
# Functions relevant to libfli
#


def getLibVersion():
    """

    Get FLI library version.

    Returns
    -------
    version : str
        FLI library version.

    """
    cdef char buf[256]

    chkerr(fli.FLIGetLibVersion(buf, 256))
    return str(buf)


def setDebugLevel(logfile, verbosity):
    """

    Enable debugging of API operations and communications.

    Use this function in combination with debug to assist in diagnosing
    problems that may be encountered during programming.


    When usings Microsoft Windows operating systems, creating an empty file
    C:\\FLIDBG.TXT will override the `logfile` option. All debug output
    will then be directed to that file.

    The `logfile` option is ignored under Linux, instead output is sent to
    rsyslog. See man rsyslog.conf for how to configure rsyslogd. Logging
    seems to use the C syslog.h functions, but on Fedora the system logger
    is rsyslog.


    Parameters
    ----------
    logfile : str
        Path to debug log file.
    verbosity : {'none', 'fail', 'warn', 'info'}
        Debug level. The list from left to right enables progressively more
        verbosity

    """
    bpath = asbytes(logfile)
    cdef char * path = bpath
    cdef fli.flidebug_t level = 0

    if verbosity == 'none':
        level = fli.FLIDEBUG_NONE
    elif verbosity == 'fail':
        level = fli.FLIDEBUG_FAIL
    elif verbosity == 'warn':
        level = fli.FLIDEBUG_WARN
    elif verbosity == 'info':
        level = fli.FLIDEBUG_INFO
    else:
        msg = "Invalid verbosity level %s" % verbosity
        raise ValueError(msg)

    chkerr(fli.FLISetDebugLevel(path, level))


#
# Functions to find, open, and close FLI devices
#


def FLIList(interface, device):
    """

    List available FLI devices.

    Parameters
    ----------
    interface : {'parallel-port', 'usb', 'serial', 'inet'}
        Interface type. The 'inet' type looks to be unsupported
        in libfli-1.104 and will raise an error.
    device : {'camera', 'filterwheel', 'focuser'}
        Device type.

    Returns
    -------
    devs : list
        A list of found devices is returned. Each list entry is a list of
        of two strings [path, name].

    """
    cdef fli.flidomain_t domain = 0
    cdef char **res
    cdef char *cstr

    if interface == 'usb':
        domain |= fli.FLIDOMAIN_USB
    elif interface == 'serial':
        domain |= fli.FLIDOMAIN_SERIAL
    elif interface == 'parallel-port':
        domain |= fli.FLIDOMAIN_PARALLEL_PORT
#    elif interface == 'inet':
#        domain |= fli.FLIDOMAIN_INET
    else:
        msg = "Invalid interface type %s" % interface
        raise ValueError(msg)

    if device == 'camera':
        domain |= fli.FLIDEVICE_CAMERA
    elif device == 'filterwheel':
        domain |= fli.FLIDEVICE_FILTERWHEEL
    elif device == 'focuser':
        domain |= fli.FLIDEVICE_FOCUSER
    else:
        msg = "Invalid device type %s" % device
        raise ValueError(msg)

    chkerr(fli.FLIList(domain, &res))

    results = []
    for cstr in res[:MAXDEVICES]:
        if cstr == NULL:
            break
        # The split won't work in python 3 unless ';' is
        # a byte string, i.e., b';'
        results.append(asstr(cstr).split(';'))

    chkerr(fli.FLIFreeList(res))
    return results


def FLIOpen(path, interface, device):
    """

    Get a handle to an FLI device.

    This function requires the filename and domain of the requested device.
    Valid device filenames can be obtained using the FLIList function. An
    application may use any number of handles associated with the same
    physical device. When doing so, it is important to lock the appropriate
    device to ensure that multiple accesses to the same device do not occur
    during critical operations.

    Parameters
    ----------
    path : str
        Path to the device. The name of the device can be obtained from a
        call to FLIList. For parallel port devices that are not probed by
        FLIList (Windows 95/98/Me), place the address of the parallel port
        in a string in ascii form ie: "0x378". On Linux the device name
        will be something like ``/dev/xxx``
    interface : {'parallel-port', 'usb', 'serial', 'inet'}
        Interface type. The 'inet' type looks to be unsupported
        in libfli-1.104 and will raise an error.
    device : {'camera', 'filterwheel', 'focuser'}
        Device type.

    Returns
    -------
    handle : int
        Handle with which to call device functions.

    See Also
    --------
    FLIList

    """
    bpath = asbytes(path)
    cdef fli.flidomain_t domain = 0
    cdef char *path_ = bpath
    cdef fli.flidev_t dev

    if interface == 'usb':
        domain |= fli.FLIDOMAIN_USB
    elif interface == 'serial':
        domain |= fli.FLIDOMAIN_SERIAL
    elif interface == 'parallel-port':
        domain |= fli.FLIDOMAIN_PARALLEL_PORT
#    elif interface == 'inet':
#        domain |= fli.FLIDOMAIN_INET
    else:
        msg = "Invalid interface type %s" % interface
        raise ValueError(msg)

    if device == 'camera':
        domain |= fli.FLIDEVICE_CAMERA
    elif device == 'filterwheel':
        domain |= fli.FLIDEVICE_FILTERWHEEL
    elif device == 'focuser':
        domain |= fli.FLIDEVICE_FOCUSER
    else:
        msg = "Invalid device type %s" % device
        raise ValueError(msg)

    chkerr(fli.FLIOpen(&dev, path_, domain))
    return dev


def FLIClose(dev):
    """

    Close a handle to an FLI device.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    FLIOpen

    """
    lockDevice(dev)
    try:
        chkerr(fli.FLIClose(dev))
    except:
        unlockDevice(dev)
        raise


#
# Functions common to all devices
#


@withDeviceLocked
def getModel(dev):
    """

    Get the model of device.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    model_string : str

    See Also
    --------
    getHWRevision
    getFWRevision
    getSerialString

    """
    cdef char buf[256]

    chkerr(fli.FLIGetModel(dev, buf, 256))
    return asstr(buf)


@withDeviceLocked
def getSerialString(dev):
    """

    Get the serial string of device.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    serial_string : str

    See Also
    --------
    getHWRevision
    getFWRevision
    getModel

    """
    cdef char buf[256]

    chkerr(fli.FLIGetSerialString(dev, buf, 256))
    return asstr(buf)


@withDeviceLocked
def getHWRevision(dev):
    """

    Get hardware revision of device.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    getModel
    getFWRevision
    getSerialString

    """
    cdef long hwrev

    chkerr(fli.FLIGetHWRevision(dev, &hwrev))
    return hwrev


@withDeviceLocked
def getFWRevision(dev):
    """

    Get firmware revision of device.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    getModel
    getHWRevision
    getSerialString

    """
    cdef long fwrev

    chkerr(fli.FLIGetFWRevision(dev, &fwrev))
    return fwrev


def lockDevice(dev):
    """

    Lock device.

    This function establishes an exclusive lock (mutex) on the given
    device to prevent access to the device by any other function or
    process.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    unlockDevice

    """
    chkerr(fli.FLILockDevice(dev))


def unlockDevice(dev):
    """

    Unlock device.

    This function releases a previously established exclusive lock
    (mutex) on the given device to allow access to the device by any
    other function or process.

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    lockDevice

    """
    chkerr(fli.FLIUnlockDevice(dev))


#
# Camera functions
#


@withDeviceLocked
def getCameraModeString(dev, index):
    """

    Get Camera mode string.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    index : int
        Mode index
        0 - 4MHz
        1 - 12MHz

    Returns
    -------
    mode : str
        Mode string.

    See Also
    --------
    getCameraMode
    setCameraMode

    """
    cdef char mode[256]

    chkerr(fli.FLIGetCameraModeString(dev, index, mode, 256))
    return asstr(mode)


@withDeviceLocked
def getCameraMode(dev):
    """

    Get Camera mode.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    index : int
        Mode index.

    See Also
    --------
    setCameraMode
    getCameraModeString

    """
    cdef fli.flimode_t index

    chkerr(fli.FLIGetCameraMode(dev, &index))
    return index


@withDeviceLocked
def setCameraMode(dev, index):
    """

    Set camera mode.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    index : int
        Mode index.

    See Also
    --------
    getCameraMode
    getCameraModeString

    """
    chkerr(fli.FLISetCameraMode(dev, index))


@withDeviceLocked
def getPixelSize(dev):
    """

    Get the camera pixel dimensions.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    pix_x, pix_y : float
        The x and y dimensions of a pixel in microns.

    """
    cdef double pix_x, pix_y

    chkerr(fli.FLIGetPixelSize(dev, &pix_x, &pix_y))
    return pix_x, pix_y


@withDeviceLocked
def getArrayArea(dev):
    """

    Get the array area of the given camera.

    This function finds the total area of the CCD array for camera dev.
    This area is specified in terms of a upper left point and a
    lower right point. The upper left x-coordinate is placed in ul x,
    the upper left y-coordinate is placed in ul y, the lower right
    x-coordinate is placed in lr x, and the lower right y-coordinate is
    placed in lr y.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    ul_x, ul_y, lr_x, lr_y : int
        The coordinates of the upper left and lower right pixels.

    """
    cdef long ul_x, ul_y, lr_x, lr_y

    chkerr(fli.FLIGetArrayArea(dev, &ul_x, &ul_y, &lr_x, &lr_y))
    return ul_x, ul_y, lr_x, lr_y


@withDeviceLocked
def getVisibleArea(dev):
    """

    Get the visible area of the given camera.

    This function finds the visible area of the CCD array for the
    camera dev. This area is specified in terms of a upper left point
    and a lower right point. The upper left x-coordinate is placed in
    ul x, the upper left y-coordinate is placed in ul y, the lower right
    x-coordinate is placed in lr x, the lower right y-coordinate is
    placed in lr y.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    ul_x, ul_y, lr_x, lr_y : int
        The coordinates of the upper left and lower right pixels.

    """
    cdef long ul_x, ul_y, lr_x, lr_y

    chkerr(fli.FLIGetVisibleArea(dev, &ul_x, &ul_y, &lr_x, &lr_y))
    return ul_x, ul_y, lr_x, lr_y


@withDeviceLocked
def setExposureTime(dev, exptime):
    """

    Set the exposure time for a camera.

    This function sets the exposure time for the camera `dev` to `exptime`
    msec. If the camera firmware is so configured `exptime` may be in
    microseconds.

    Parameters
    ----------
    dev : int
        Device handle.
    exptime ; int
        Exposure time in milliseconds or microseconds.

    """
    chkerr(fli.FLISetExposureTime(dev, exptime))


@withDeviceLocked
def setImageArea(dev, ul_x, ul_y, lr_x, lr_y):
    """

    Set the image area of the camera.

    This function sets the image area for camera `dev` to an area
    specified in terms of a upper left point and a lower right point.
    The upper-left x-coordinate is `ul_x`, the upper left y-coordinate is
    `ul_y`, the lower right x-coordinate is `lr_x`, and the lower right
    y-coordinate is `lr_y`. Note that the given lower right coordinate
    must take into account the horizontal and vertical bin factor
    settings, but the upper left coordinate is absolute. In other
    words, the lower right coordinate used to set the image area is a
    virtual point (lr_x, lr_y) determined by:

        lr_x = ul_x + (lr_x' − ul_x)/hbin
        lr_y = ul_y + (lr_y' − ul_y)/vbin

    Where (lr_x, lr_y ) are the coordinates to pass to the
    FLISetImageArea function while (ul_x, ul_y) and (lr_x', lr_y') are
    the absolute coordinates of the desired image area, hbin is the
    horizontal bin factor, and vbin is the vertical bin factor.

    Note that the vertical and horizontal bins must be set separately.

    Parameters
    ----------
    dev : int
        Device handle.
    ul_x, ul_y, lr_x, lr_y : int
        The coordinates of the upper left and lower right pixels.

    See Also
    --------
    getReadoutDimensions
    setHBin
    setVBin

    """
    chkerr(fli.FLISetImageArea(dev, ul_x, ul_y, lr_x, lr_y))


@withDeviceLocked
def setHBin(dev, hbin):
    """

    Set the horizontal bin factor for a given camera.

    This function sets the horizontal bin factor for the camera to
    `hbin`. The valid range of the `hbin` parameter is from 1 to 16.

    Parameters
    ----------
    dev : int
        Device handle.
    hbin : int
        Bin horizontal dimension in pixels. The valid range is 1..16.

    See Also
    --------
    getReadoutDimensions
    setImageArea
    setVBin

    """
    chkerr(fli.FLISetHBin(dev, hbin))


@withDeviceLocked
def setVBin(dev, vbin):
    """

    Set the vertical bin factor for a given camera.

    This function sets the vertical bin factor for the camera to
    `vbin`. The valid range of the `vbin` is from 1 to 16.

    Parameters
    ----------
    dev : int
        Device handle.
    vbin : int
        Bin vertical dimension in pixels. The valid range is 1..16.

    See Also
    --------
    getReadoutDimensions
    setImageArea
    setHBin

    """
    chkerr(fli.FLISetVBin(dev, vbin))


@withDeviceLocked
def setFrameType(dev, ftype):
    """

    Set the frame type for a given camera.

    This function sets the frame type for the camera to ftype.  If
    `ftype` is 'normal' then the shutter will be open during the
    exposure.  If `ftype` is 'dark' a dark frame will be taken with the
    shutter closed. The other types, 'flood' and 'flush' are for RBI
    mitigation but currently undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    ftype : {'normal', 'dark', 'flood', 'flush'}
        The frame type. The last two are associated with the RBI and
        are guesses as they aren't documented.

    """
    cdef fli.fliframe_t frametype

    if ftype == 'normal':
        frametype = fli.FLI_FRAME_TYPE_NORMAL
    elif ftype == 'dark':
        frametype = fli.FLI_FRAME_TYPE_DARK
    elif ftype == 'flood':
        frametype = fli.FLI_FRAME_TYPE_FLOOD
    elif ftype == 'flush':
        frametupe = fli.FLI_FRAME_TYPE_RBI_FLUSH
    else:
        msg = "Invalid frame type %s" % ftype
        raise ValueError(msg)

    chkerr(fli.FLISetFrameType(dev, frametype))


@withDeviceLocked
def cancelExposure(dev):
    """

    Cancel an exposure.

    This function cancels an exposure in progress by closing the
    shutter.

    Parameters
    ----------
    dev : int
        Device handle.

    """
    chkerr(fli.FLICancelExposure(dev))


@withDeviceLocked
def endExposure(dev):
    """

    End an exposure.

    This function ends an exposure in progress by closing the
    shutter and reading out the image.

    Parameters
    ----------
    dev : int
        Device handle.

    """
    chkerr(fli.FLICancelExposure(dev))


@withDeviceLocked
def getExposureStatus(dev):
    """

    Get the remaining camera exposure time.

    The exposure time is given in either milliseconds or microseconds
    depending on the camera firmware. Milliseconds is the standard.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    timeleft : int
        Remaining exposure time in milliseconds or microseconds.

    """
    cdef long timeleft

    chkerr(fli.FLIGetExposureStatus(dev, &timeleft))
    return timeleft


@withDeviceLocked
def setTemperature(dev, temperature):
    """

    Set the camera temperature.

    This function sets the temperature of the CCD camera to
    `temperature` degrees Celsius. The valid range of temperature is
    from -55 C to 45 C.

    Parameters
    ----------
    dev : int
        Device handle.
    temperature : float
        Temperature in degrees Celsius.

    """
    chkerr(fli.FLISetTemperature(dev, temperature))


@withDeviceLocked
def getTemperature(dev):
    """

    Get the camera temperature.

    Returns the temperature in degrees Celsius of the CCD cold finger.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    temperature : float
        The camera temperature.

    """
    cdef double temperature

    chkerr(fli.FLIGetTemperature(dev, &temperature))
    return temperature


@withDeviceLocked
def getCoolerPower(dev):
    """

    Get the camera cooler power.

    The cooler power is given as a percent of maximum.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    percent : float
        The cooler power as a percent.

    """
    cdef double power

    chkerr(fli.FLIGetCoolerPower(dev, &power))
    return power


@withDeviceLocked
def grabRow(dev, depth='16bit', out=None):
    """

    Grab a row of an image.

    This function grabs the next available row of the image from the
    camera. A row is read from the camera and returned as an ndarray. Note
    that if `depth` is incorrect the buffer into which the data is read
    may be too small and a segfault will result. The width of the row read
    out is obtained from a call to `getReadoutDimensions`.

    Parameters
    ----------
    dev : int
        Device handle.

    depth : {'16bit', '8bit'}, optional
        Bitdepth. If this is set incorrectly a seqfault may result. The
        '16bit' value is safe and is the default, but if actual data is
        '8bit' the result will not look right.
    out : ndarray, optional
        The frame will be read into the `out` array if it is specified. It
        must have the correct dimensions to contain the frame, but it can
        have a different type than specified by `depth`.

    Returns
    -------
    row : ndarray
        A 1-D ndarray. If `out` is given it will be a reference to `out`,
        otherwise it is a new array of type np.uint8 or np.uint16 depending
        on the value of `depth`.

    See Also
    --------
    getReadoutDimensions
    setImageArea
    grabFrame

    """
    width, hoffset, hbin, height, voffset, vbin = getReadoutDimensions(dev)
    shape = (width,)
    convert = False

    dt = ADCType[depth]
    if out is not None:
        if out.shape != shape:
            msg = "The out argument has wrong dimensions."
            raise ValueError(msg)
        if out.dtype != dt:
            convert = True
            buf = np.empty(shape, dt)
        else:
            convert = False
            buf = out
    else:
        buf = np.empty(shape, dt)

    chkerr(fli.FLIGrabRow(dev, np.PyArray_DATA(buf), width))

    if convert:
        out[...] = buf
        return out
    else:
        return buf


@withDeviceLocked
def exposeFrame(dev):
    """

    Expose a frame for a given camera.

    This function exposes a frame according to the settings (image area,
    exposure time, bit depth, etc.) of the camera. The settings must be
    valid for the camera and are set by calling the appropriate functions.
    This function returns after the exposure has started.

    Parameters
    ----------
    dev : int
        Device handle.

    """
    chkerr(fli.FLIExposeFrame(dev))


@withDeviceLocked
def flushRow(dev, rows, repeat):
    """

    Flush rows of camera.

    This function flushes `rows` rows of camera dev `repeat` times.

    Parameters
    ----------
    dev : int
        Device handle.
    rows : int
        Number of rows to flush.
    repeat : int
        Number of time to flush rows.

    """
    chkerr(fli.FLIFlushRow(dev, rows, repeat))


@withDeviceLocked
def setNFlushes(dev, nflushes):
    """

    Set the number of flushes.

    This function sets the number of times the CCD array of camera dev is
    flushed by FLIExposeFrame to `nflushes`. The flushing takes place
    before the actual exposure. The valid range of the nflushes parameter
    is from 0 to 16.  Some FLI cameras support background flushing.
    Background flushing continuously flushes the CCD eliminating the need
    for pre-exposure flushing.

    Parameters
    ----------
    dev : int
        Device handle.
    nflushes : int

    """
    chkerr(fli.FLISetNFlushes(dev, nflushes))


@withDeviceLocked
def setBitDepth(dev, depth):
    """

    Set the gray-scale bit depth.

    This function sets the gray-scale bit depth of the camera `dev` to the
    specified bitdepth. Many cameras do not support this command.

    Parameters
    ----------
    dev : int
        Device handle.
    depth : {'8bit', '16bit'}
        Bitdepth.

    SeeAlso
    -------
    grabRow
    grabFrame

    """
    cdef fli.flibitdepth_t bitdepth

    if depth == '8bit':
        bitdepth = fli.FLI_MODE_8BIT
    elif depth == '16bit':
        bitdepth = fli.FLI_MODE_16BIT
    else:
        msg = "Invalid bitdepth %s" % depth
        raise ValueError(msg)

    chkerr(fli.FLISetBitDepth(dev, bitdepth))


@withDeviceLocked
def readIOPort(dev):
    """

    Read the camera I/O port.

    This function reads the I/O port on camera `dev` and returns
    the result as an integer.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    value: int
        The value read from the I/O port.

    See Also
    --------
    writeIOPort
    configureIOPort

    """
    cdef long ioportset

    chkerr(fli.FLIReadIOPort(dev, &ioportset))
    return ioportset


@withDeviceLocked
def writeIOPort(dev, ioportset):
    """

    Write to the camera I/O port.

    This function writes the value `ioportset` to the camera I/O port.

    Parameters
    ----------
    dev : int
        Device handle.
    ioportset : int
        Value to write to the I/O port. It must fit in a C long int, whose
        size will depend on the compiler and OS.

    See Also
    --------
    readIOPort
    configureIOPort

    """
    chkerr(fli.FLIWriteIOPort(dev, ioportset))


@withDeviceLocked
def configureIOPort(dev, ioportset):
    """

    Configure the camera I/O port.

    This function configures the camera I/O port with the value
    `ioportset`.  The I/O configuration of each pin on a given camera is
    determined by the bits of `ioportset`. Setting a respective I/O bit
    enables the corresponding port bit for output while clearing an I/O bit
    enables the bit for input. By default, all I/O ports are configured as
    inputs.

    Parameters
    ----------
    dev : int
        Device handle.
    ioportset : int
        The value that determines the I/O port configuration.

    See Also
    --------
    readIOPort
    writeIOPort

    """
    chkerr(fli.FLIConfigureIOPort(dev, ioportset))


@withDeviceLocked
def controlShutter(dev, shutter=None, control=None):
    """

    Control the camera shutter.

    This function controls the shutter function on camera `dev` according
    to the shutter parameter. A value of 'close' closes the shutter, 'open'
    opens the shutter,  'trigger-low' causes the exposure to begin when a
    logic LOW is detected on I/O port bit 0, 'trigger-high' causes the
    exposure to begin when a logic HIGH is detected on I/O port bit 0. This
    setting may not be available on all cameras. The control is rather
    complicated. The shutter can be opened or the shutter can be closed, or
    a combination of 'trigger-high', `trigger-low`, and `external-exposure`
    can be set. This is implemented here by dividing the controls into two
    mutually exclusive groups.

    Parameters
    ----------
    dev : int
        Device handle.
    shutter : {None, 'open', 'close'}, optional
        Open or close the shutter. This is mutually exclusive with control.
    exposure : {None, 'triggerLow', 'triggerHigh', 'external'}, optional
        External controls. The default is 'triggerHigh' when only 'external'
        is specified, but it is recommended to always specify the trigger
        when this argument is given.

    """
    cdef fli.flishutter_t command = 0

    if shutter is None and control is None:
        msg = "No command given"
        raise ValueError(msg)
    elif shutter is not None and control is not None:
        msg = "Only one of shutter or control can be specified"
        raise ValueError(msg)
    elif shutter is not None and control is None:
        if shutter == 'open':
            command = fli.FLI_SHUTTER_OPEN
        elif shutter == 'close':
            command = fli.FLI_SHUTTER_CLOSE
        else:
            msg = "Invalid shutter argument %s" % control
            raise ValueError(msg)
    else:
        if 'triggerLow' in control:
            command |= fli.FLI_SHUTTER_EXTERNAL_TRIGGER_LOW
            control.remove('triggerLow')
        if 'triggerHigh' in control:
            command |= fli.FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH
            control.remove('triggerHigh')
        if 'external' in control:
            command |= fli.FLI_SHUTTER_EXTERNAL_EXPOSURE
            control.remove('external')
        if command == 0:
            msg = "Invalid control arguments %s" % control
            raise ValueError(msg)

    chkerr(fli.FLIControlShutter(dev, shutter))


@withDeviceLocked
def triggerExposure(dev):
    """

    Trigger an exposure that is awaiting an external trigger.

    This is a software override for the external trigger option.

    Parameters
    ----------
    dev : int
        Device handle.

    """
    chkerr(fli.FLITriggerExposure(dev))


@withDeviceLocked
def controlBackgroundFlush(dev, control):
    """

    Enables background flushing of CCD array.

    This function starts or stops the background flushing of the CCD
    array. Note that this function may not succeed on all FLI products
    as this feature may not be available. Background flushing
    is stopped whenever exposeFrame or controlShutter is called.

    Parameters
    ----------
    dev : int
        Device handle.
    control : {'start', 'stop'}
        Flush control.

    See Also
    --------
    exposeFrame
    controlShutter

    """
    cdef fli.flibgflush_t bgflush

    if control == 'start':
        bgflush = fli.FLI_BGFLUSH_START
    elif control == 'stop':
        bgflush = fli.FLI_BGFLUSH_STOP
    else:
        msg = "Invalid background flush control %s" % control
        raise ValueError(msg)

    chkerr(fli.FLIControlBackgroundFlush(dev, bgflush))


@withDeviceLocked
def setFanSpeed(dev, state):
    """

    Turn fan on or off.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    state : {'on', 'off'}
        Turn fan on or off.

    """
    cdef long speed = 0

    if state == 'on':
        speed = fli.FLI_FAN_SPEED_ON
    elif state == 'off':
        speed = fli.FLI_FAN_SPEED_OFF
    else:
        msg = 'Invalid fan state %s' % state
        raise ValueError(msg)

    chkerr(fli.FLISetFanSpeed(dev, speed))


@withDeviceLocked
def getReadoutDimensions(dev):
    """

    Get readout dimensions.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    width, hoffset, hbin, height, voffset, vbin: int
       Horizontal width and vertical height are in bins, hbin and vbin are the
       horizontal and vertical bin sizes respectively, and hoffset and
       voffset are the x-coordinate and y-coordinates of the upper left
       corner of the image area.

    See Also
    --------
    setImageArea
    setHBin
    setVBin

    Notes
    -----
    In python, the returned image will have dimensions (height, width). In
    my full frame format camera width runs along the long dimension of the
    CCD.

    """
    cdef long width, hoffset, hbin, height, voffset, vbin

    chkerr(fli.FLIGetReadoutDimensions(dev,
            &width, &hoffset, &hbin,
            &height, &voffset, &vbin))
    return width, hoffset, hbin, height, voffset, vbin


#
# Stepper functions
#


@withDeviceLocked
def stepMotor(dev, steps):
    """

    Step the filter wheel or focuser motor.

    Use this function to move the focuser or filter wheel
    by an amount `steps`.

    Parameters
    ----------
    dev : int
        Device handle.
    steps : int
        Number of steps to step.

    See Also
    --------
    getStepperPosition

    """
    chkerr(fli.FLIStepMotor(dev, steps))


@withDeviceLocked
def stepMotorAsync(dev, steps):
    """

    Step the filter wheel or focuser motor.

    Use this function to move the focuser or filter wheel by an amount
    `steps`. This function is non-blocking.

    Parameters
    ----------
    dev : int
        Device handle.
    steps : int
        Number of steps to step the motor.

    See Also
    --------
    getStepperPosition

    """
    chkerr(fli.FLIStepMotorAsync(dev, steps))


@withDeviceLocked
def getStepperPosition(dev):
    """

    Get the stepper motor position of a given device.

    Use this function to read the stepper motor position of a filter wheel
    or focuser.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    position : int
        The stepper position.

    See Also
    --------
    stepMotor

    """
    cdef long position

    chkerr(fli.FLIGetStepperPosition(dev, &position))
    return position


@withDeviceLocked
def getStepsRemaining(dev):
    """

    Get the number of motor steps remaining.

    Use this function to determine if the stepper motor is still moving.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    steps : int
        Steps remaining.

    See Also
    --------
    setFilterPos

    """
    cdef long steps

    chkerr(fli.FLIGetStepsRemaining(dev, &steps))
    return steps


@withDeviceLocked
def getDeviceStatus(dev):
    """

    Get device status.

    The status values depend on the device type and are listed below in the
    Notes section.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    status : int
        Status.

    Notes
    -----

    The status values are listed here by device type. They are
    defined in this module. Some of these may also depend on
    the model of the device.

    Camera status Values
    ++++++++++++++++++++

    CAMERA_STATUS_UNKNOWN
    CAMERA_STATUS_MASK
    CAMERA_STATUS_IDLE
    CAMERA_STATUS_WAITING_FOR_TRIGGER
    CAMERA_STATUS_EXPOSING
    CAMERA_STATUS_READING_CCD
    CAMERA_DATA_READY

    Focuser status values
    +++++++++++++++++++++

    FOCUSER_STATUS_UNKNOWN
    FOCUSER_STATUS_HOMING
    FOCUSER_STATUS_MOVING_IN
    FOCUSER_STATUS_MOVING_OUT
    FOCUSER_STATUS_MOVING_MASK
    FOCUSER_STATUS_HOME
    FOCUSER_STATUS_LIMIT
    FOCUSER_STATUS_LEGACY

    Filter wheel status values
    ++++++++++++++++++++++++++

    FILTER_WHEEL_PHYSICAL
    FILTER_WHEEL_VIRTUAL
    FILTER_WHEEL_LEFT
    FILTER_WHEEL_RIGHT
    FILTER_STATUS_MOVING_CCW
    FILTER_STATUS_MOVING_CW
    FILTER_POSITION_UNKNOWN
    FILTER_POSITION_CURRENT
    FILTER_STATUS_HOMING
    FILTER_STATUS_HOME
    FILTER_STATUS_HOME_LEFT
    FILTER_STATUS_HOME_RIGHT
    FILTER_STATUS_HOME_SUCCEEDED

    """
    cdef long status

    chkerr(fli.FLIGetDeviceStatus(dev, &status))
    return status


@withDeviceLocked
def homeDevice(dev):
    """

    Home focuser or filter wheel.

    The home position of a device is defined as where the electromechanical
    home sensor detects home. Note that on color filter wheels this may not
    be located at filter slot zero and may in fact be between filter slots.
    It should be noted that this function replaces the deprecated function
    homeFocuser. This function may not return immediately as older FLI
    devices blocked during a HOME operation. Use the function
    getDeviceStatus to determine if the filter wheel or focuser is still
    moving (or is capable of reporting device status).

    Parameters
    ----------
    dev : int
        Device handle.

    See Also
    --------
    getDeviceStatus

    """
    chkerr(fli.FLIHomeDevice(dev))


#
# focuser functions
#


@withDeviceLocked
def homeFocuser(dev):
    """

    Home focuser.

    The home position is closed as far as mechanically possible.

    .. note:: Deprecated, use `homeDevice` instead.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    status : int
        Status. Meaning currently unknown.

    See Also
    --------
    getFocuserExtent

    """
    msg = "homeFocuser is deprecated, use homeDevice instead"
    warnings.warn(msg, DeprecationWarning)

    chkerr(fli.FLIHomeFocuser(dev))


@withDeviceLocked
def getFocuserExtent(dev):
    """

    Get maximum focuser extent.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    extent : int
        Extent meaning currently unknown.

    See Also
    --------
    homeFocuser

    """
    cdef long extent

    chkerr(fli.FLIGetFocuserExtent(dev, &extent))
    return extent


@withDeviceLocked
def readTemperature(dev, channel):
    """

    Read temperature of focuser channel.

    Parameters
    ----------
    dev : int
        Device handle.
    channel : {'internal', 'external'}

    Returns
    -------
    temperature : float
        Probably degrees Celsius, but unknown.

    """
    cdef double temperature
    cdef fli.flichannel_t channel_

    if channel == 'internal':
        channel_ = fli.FLI_TEMPERATURE_INTERNAL
    elif channel == 'external':
        channel_ = fli.FLI_TEMPERATURE_EXTERNAL
    else:
        msg = "Invalid temperature channel %s" % channel
        raise ValueError(msg)


    chkerr(fli.FLIReadTemperature(dev, channel_, &temperature))
    return temperature


#
# filterwheel functions
#


@withDeviceLocked
def getFilterName(dev, position):
    """

    Get filter name.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    position : int
        Filter position number.

    Returns
    -------
    name : str
        Filter name.

    """
    cdef char buf[256]

    chkerr(fli.FLIGetFilterName(dev, position, buf, 256))
    return asstr(buf)


@withDeviceLocked
def setActiveWheel(dev, wheel):
    """

    Set active filter wheel.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.
    wheel : int
        Filter wheel.

    See Also
    --------
    getActiveWheel

    """
    chkerr(fli.FLISetActiveWheel(dev, wheel))


@withDeviceLocked
def getActiveWheel(dev):
    """

    Get active filter wheel.

    Undocumented.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    wheel : int
        Active filter wheel.

    See Also
    --------
    setActiveWheel

    """
    cdef long wheel

    chkerr(fli.FLIGetActiveWheel(dev, &wheel))
    return wheel


@withDeviceLocked
def setFilterPos(dev, position):
    """

    Set the filter wheel position.

    Use this function to set the filter wheel position.

    Parameters
    ----------
    dev : int
        Device handle.
    position : int
        Desired filter position.

    See Also
    --------
    getFilterPos

    """
    chkerr(fli.FLISetFilterPos(dev, position))


@withDeviceLocked
def getFilterPos(dev):
    """

    Get the filter wheel position.

    Use this function to get the filter wheel position

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    position : int
        Filter wheel position.

    See Also
    --------
    setFilterPos

    """
    cdef long position

    chkerr(fli.FLIGetFilterPos(dev, &position))
    return position


@withDeviceLocked
def getFilterCount(dev):
    """

    Get the filter wheel filter count.

    Use this function to get the filter count of the filter wheel.

    Parameters
    ----------
    dev : int
        Device handle.

    Returns
    -------
    count : int
        Number of filters in the wheel.

    """
    cdef long count

    chkerr(fli.FLIGetFilterCount(dev, &count))
    return count
