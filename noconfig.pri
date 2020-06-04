
CONFIG += c++14

CONFIG += release
#CONFIG += debug

PREFIX_PATH = /usr/local

DEFINES += NDEBUG BUILD_RELEASE
DEFINES += NO_TIMING

# Full set of defines expected for all platforms when we have the
# sv-dependency-builds subrepo available to provide the dependencies.

DEFINES += \
        HAVE_BZ2 \
	HAVE_FFTW3 \
	HAVE_FFTW3F \
	HAVE_SNDFILE \
	HAVE_SAMPLERATE \
	HAVE_MAD \
	HAVE_ID3TAG \
	HAVE_OPUS

# Default set of libs for the above. Config sections below may update
# these.

LIBS += \
        -lbase \
        -lbz2 \
	-lrubberband \
	-lfftw3 \
	-lfftw3f \
	-lsndfile \
	-lFLAC \
	-logg \
	-lvorbis \
	-lvorbisenc \
	-lvorbisfile \
	-lopusfile \
	-lopus \
	-logg \
	-lmad \
	-lid3tag \
	-lsamplerate \
	-lz \
	-lsord-0 \
	-lserd-0

win32-g++ {

    # This config is currently used for 32-bit Windows builds.

    INCLUDEPATH += $$PWD/sv-dependency-builds/win32-mingw/include $$PWD/sv-dependency-builds/win32-mingw/include/opus

    LIBS += -Lrelease -L$$PWD/sv-dependency-builds/win32-mingw/lib

    DEFINES += NOMINMAX _USE_MATH_DEFINES CAPNP_LITE

    QMAKE_CXXFLAGS_RELEASE += -ffast-math
    
    # (We don't have MediaFoundation support, with this build sadly)
    
    LIBS += -lwinmm -lws2_32
}

win32-msvc* {

    # This config is actually used only for 64-bit Windows builds.
    # even though the qmake spec is still called win32-msvc*. If
    # we want to do 32-bit builds with MSVC as well, then we'll
    # need to add a way to distinguish the two.
    
    INCLUDEPATH += $$PWD/sv-dependency-builds/win64-msvc/include $$PWD/sv-dependency-builds/win64-msvc/include/opus

    CONFIG(release) {
        LIBS += -NODEFAULTLIB:LIBCMT -Lrelease \
            -L$$PWD/sv-dependency-builds/win64-msvc/lib
    }

    DEFINES += NOMINMAX _USE_MATH_DEFINES HAVE_MEDIAFOUNDATION AVOID_WINRT_DEPENDENCY

    QMAKE_CXXFLAGS_RELEASE += -fp:fast -gl
    QMAKE_LFLAGS_RELEASE += -ltcg

    # No Ogg/FLAC support in the sndfile build on this platform yet
    LIBS -= -lFLAC -lvorbis -lvorbisenc -lvorbisfile

    # These have different names
    LIBS -= -lsord-0 -lserd-0
    LIBS += -lsord -lserd
    
    LIBS += -lmfplat -lmfreadwrite -lmfuuid -lpropsys -ladvapi32 -lwinmm -lws2_32
}

macx* {

    # All Mac builds are 64-bit these days.

    INCLUDEPATH += $$PWD/sv-dependency-builds/osx/include $$PWD/sv-dependency-builds/osx/include/opus
    LIBS += -L$$PWD/sv-dependency-builds/osx/lib -L$$PWD

    QMAKE_CXXFLAGS_RELEASE += -O3 -ffast-math -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto

    DEFINES += HAVE_COREAUDIO HAVE_VDSP
    LIBS += \
        -framework CoreAudio \
	-framework CoreMidi \
	-framework AudioUnit \
	-framework AudioToolbox \
	-framework CoreFoundation \
	-framework CoreServices \
	-framework Accelerate
}

linux* {

    message("Building without ./configure on Linux is unlikely to work")
    message("If you really want to try it, remove this from noconfig.pri")
    error("Refusing to build without ./configure first")
}

