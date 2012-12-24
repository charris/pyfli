
cdef extern from '../libfli-1.104/libfli.h':

    # typedefs

    ctypedef long flidev_t
    ctypedef long flidomain_t
    ctypedef long fliframe_t
    ctypedef long flibitdepth_t
    ctypedef long flishutter_t
    ctypedef long flibgflush_t
    ctypedef long flichannel_t
    ctypedef long flidebug_t
    ctypedef long flimode_t
    ctypedef long flistatus_t
    ctypedef long flitdirate_t
    ctypedef long flitdiflags_t

    # flags
    # These are macros in the include file, but
    # making them enums works for Cython

    cdef enum:
        FLI_INVALID_DEVICE
        FLIDOMAIN_NONE
        FLIDOMAIN_PARALLEL_PORT
        FLIDOMAIN_USB
        FLIDOMAIN_SERIAL
        FLIDOMAIN_INET
        FLIDOMAIN_SERIAL_19200
        FLIDOMAIN_SERIAL_1200
        FLIDEVICE_NONE
        FLIDEVICE_CAMERA
        FLIDEVICE_FILTERWHEEL
        FLIDEVICE_FOCUSER
        FLIDEVICE_HS_FILTERWHEEL
        FLIDEVICE_RAW
        FLIDEVICE_ENUMERATE_BY_CONNECTION
        FLI_FRAME_TYPE_NORMAL
        FLI_FRAME_TYPE_DARK
        FLI_FRAME_TYPE_FLOOD
        FLI_FRAME_TYPE_RBI_FLUSH
        FLI_MODE_8BIT
        FLI_MODE_16BIT
        FLI_SHUTTER_CLOSE
        FLI_SHUTTER_OPEN
        FLI_SHUTTER_EXTERNAL_TRIGGER
        FLI_SHUTTER_EXTERNAL_TRIGGER_LOW
        FLI_SHUTTER_EXTERNAL_TRIGGER_HIGH
        FLI_SHUTTER_EXTERNAL_EXPOSURE_CONTROL
        FLI_BGFLUSH_STOP
        FLI_BGFLUSH_START
        FLI_TEMPERATURE_INTERNAL
        FLI_TEMPERATURE_EXTERNAL
        FLI_TEMPERATURE_CCD
        FLI_TEMPERATURE_BASE
        FLI_CAMERA_STATUS_UNKNOWN
        FLI_CAMERA_STATUS_MASK
        FLI_CAMERA_STATUS_IDLE
        FLI_CAMERA_STATUS_WAITING_FOR_TRIGGER
        FLI_CAMERA_STATUS_EXPOSING
        FLI_CAMERA_STATUS_READING_CCD
        FLI_CAMERA_DATA_READY
        FLI_FOCUSER_STATUS_UNKNOWN
        FLI_FOCUSER_STATUS_HOMING
        FLI_FOCUSER_STATUS_MOVING_IN
        FLI_FOCUSER_STATUS_MOVING_OUT
        FLI_FOCUSER_STATUS_MOVING_MASK
        FLI_FOCUSER_STATUS_HOME
        FLI_FOCUSER_STATUS_LIMIT
        FLI_FOCUSER_STATUS_LEGACY
        FLI_FILTER_WHEEL_PHYSICAL
        FLI_FILTER_WHEEL_VIRTUAL
        FLI_FILTER_WHEEL_LEFT
        FLI_FILTER_WHEEL_RIGHT
        FLI_FILTER_STATUS_MOVING_CCW
        FLI_FILTER_STATUS_MOVING_CW
        FLI_FILTER_POSITION_UNKNOWN
        FLI_FILTER_POSITION_CURRENT
        FLI_FILTER_STATUS_HOMING
        FLI_FILTER_STATUS_HOME
        FLI_FILTER_STATUS_HOME_LEFT
        FLI_FILTER_STATUS_HOME_RIGHT
        FLI_FILTER_STATUS_HOME_SUCCEEDED
        FLIDEBUG_NONE
        FLIDEBUG_INFO
        FLIDEBUG_WARN
        FLIDEBUG_FAIL
        FLIDEBUG_IO
        FLIDEBUG_ALL
        FLI_IO_P0
        FLI_IO_P1
        FLI_IO_P2
        FLI_IO_P3
        FLI_FAN_SPEED_OFF
        FLI_FAN_SPEED_ON
        FLI_EEPROM_USER
        FLI_EEPROM_PIXEL_MAP
        FLI_PIXEL_DEFECT_COLUMN
        FLI_PIXEL_DEFECT_CLUSTER
        FLI_PIXEL_DEFECT_POINT_BRIGHT
        FLI_PIXEL_DEFECT_POINT_DARK

    # functions

    long FLIOpen(flidev_t *dev, char *name, flidomain_t domain) nogil
    long FLISetDebugLevel(char *host, flidebug_t level) nogil
    long FLIClose(flidev_t dev) nogil
    long FLIGetLibVersion(char* ver, size_t len) nogil
    long FLIGetModel(flidev_t dev, char* model, size_t len) nogil
    long FLIGetPixelSize(flidev_t dev, double *pixel_x, double *pixel_y) nogil
    long FLIGetHWRevision(flidev_t dev, long *hwrev) nogil
    long FLIGetFWRevision(flidev_t dev, long *fwrev) nogil
    long FLIGetArrayArea(flidev_t dev, long* ul_x, long* ul_y, long* lr_x, long* lr_y) nogil
    long FLIGetVisibleArea(flidev_t dev, long* ul_x, long* ul_y, long* lr_x, long* lr_y) nogil
    long FLISetExposureTime(flidev_t dev, long exptime) nogil
    long FLISetImageArea(flidev_t dev, long ul_x, long ul_y, long lr_x, long lr_y) nogil
    long FLISetHBin(flidev_t dev, long hbin) nogil
    long FLISetVBin(flidev_t dev, long vbin) nogil
    long FLISetFrameType(flidev_t dev, fliframe_t frametype) nogil
    long FLICancelExposure(flidev_t dev) nogil
    long FLIGetExposureStatus(flidev_t dev, long *timeleft) nogil
    long FLISetTemperature(flidev_t dev, double temperature) nogil
    long FLIGetTemperature(flidev_t dev, double *temperature) nogil
    long FLIGetCoolerPower(flidev_t dev, double *power) nogil
    long FLIGrabRow(flidev_t dev, void *buff, size_t width) nogil
    long FLIExposeFrame(flidev_t dev) nogil
    long FLIFlushRow(flidev_t dev, long rows, long repeat) nogil
    long FLISetNFlushes(flidev_t dev, long nflushes) nogil
    long FLISetBitDepth(flidev_t dev, flibitdepth_t bitdepth) nogil
    long FLIReadIOPort(flidev_t dev, long *ioportset) nogil
    long FLIWriteIOPort(flidev_t dev, long ioportset) nogil
    long FLIConfigureIOPort(flidev_t dev, long ioportset) nogil
    long FLILockDevice(flidev_t dev) nogil
    long FLIUnlockDevice(flidev_t dev) nogil
    long FLIControlShutter(flidev_t dev, flishutter_t shutter) nogil
    long FLIControlBackgroundFlush(flidev_t dev, flibgflush_t bgflush) nogil
    long FLISetDAC(flidev_t dev, unsigned long dacset) nogil
    long FLIList(flidomain_t domain, char ***names) nogil
    long FLIFreeList(char **names) nogil
    long FLIGetFilterName(flidev_t dev, long filter, char *name, size_t len) nogil
    long FLISetActiveWheel(flidev_t dev, long wheel) nogil
    long FLIGetActiveWheel(flidev_t dev, long *wheel) nogil
    long FLISetFilterPos(flidev_t dev, long filter) nogil
    long FLIGetFilterPos(flidev_t dev, long *filter) nogil
    long FLIGetFilterCount(flidev_t dev, long *filter) nogil
    long FLIStepMotor(flidev_t dev, long steps) nogil
    long FLIStepMotorAsync(flidev_t dev, long steps) nogil
    long FLIGetStepperPosition(flidev_t dev, long *position) nogil
    long FLIGetStepsRemaining(flidev_t dev, long *steps) nogil
    long FLIHomeFocuser(flidev_t dev) nogil
    long FLICreateList(flidomain_t domain) nogil
    long FLIDeleteList() nogil
    long FLIListFirst(flidomain_t *domain, char *filename, size_t fnlen, char *name, size_t namelen) nogil
    long FLIListNext(flidomain_t *domain, char *filename, size_t fnlen, char *name, size_t namelen) nogil
    long FLIReadTemperature(flidev_t dev, flichannel_t channel, double *temperature) nogil
    long FLIGetFocuserExtent(flidev_t dev, long *extent) nogil
    long FLIUsbBulkIO(flidev_t dev, int ep, void *buf, long *len) nogil
    long FLIGetDeviceStatus(flidev_t dev, long *status) nogil
    long FLIGetCameraModeString(flidev_t dev, flimode_t mode_index, char *mode_string, size_t siz) nogil
    long FLIGetCameraMode(flidev_t dev, flimode_t *mode_index) nogil
    long FLISetCameraMode(flidev_t dev, flimode_t mode_index) nogil
    long FLIHomeDevice(flidev_t dev) nogil
    long FLIGrabFrame(flidev_t dev, void* buff, size_t buffsize, size_t* bytesgrabbed) nogil
    long FLISetTDI(flidev_t dev, flitdirate_t tdi_rate, flitdiflags_t flags) nogil
    long FLIGrabVideoFrame(flidev_t dev, void *buff, size_t size) nogil
    long FLIStopVideoMode(flidev_t dev) nogil
    long FLIStartVideoMode(flidev_t dev) nogil
    long FLIGetSerialString(flidev_t dev, char* serial, size_t len) nogil
    long FLIEndExposure(flidev_t dev) nogil
    long FLITriggerExposure(flidev_t dev) nogil
    long FLISetFanSpeed(flidev_t dev, long fan_speed) nogil
    long FLISetVerticalTableEntry(flidev_t dev, long index, long height, long bin, long mode) nogil
    long FLIGetVerticalTableEntry(flidev_t dev, long index, long *height, long *bin, long *mode) nogil
    long FLIGetReadoutDimensions(flidev_t dev, long *width, long *hoffset, long *hbin, long *height, long *voffset, long *vbin) nogil
    long FLIEnableVerticalTable(flidev_t dev, long width, long offset, long flags) nogil
    long FLIReadUserEEPROM(flidev_t dev, long loc, long address, long length, void *rbuf) nogil
    long FLIWriteUserEEPROM(flidev_t dev, long loc, long address, long length, void *wbuf) nogil

