#-------------------------------------------------
#
# Redis Desktop Manager
#
#-------------------------------------------------

QT += core gui network xml concurrent widgets

TARGET = rdm
TEMPLATE = app

SOURCES += \
    $$PWD/main.cpp \
    $$PWD/dialogs/*.cpp \
    $$PWD/core/*.cpp \
    $$PWD/core/ssh/*.cpp \
    $$PWD/widgets/*.cpp \
    $$PWD/crashhandler/*.cpp \
    $$PWD/updater/*.cpp \
    $$PWD/utils/*.cpp \
    $$PWD/models/*.cpp \
    $$PWD/models/items/*.cpp \
    $$PWD/models/value-view-formatters/*.cpp \

HEADERS  += \
    $$PWD/version.h \
    $$PWD/dialogs/*.h \
    $$PWD/core/*.h \
    $$PWD/core/ssh/*.h \
    $$PWD/widgets/*.h \
    $$PWD/crashhandler/*.h \
    $$PWD/updater/*.h \
    $$PWD/utils/*.h \
    $$PWD/models/*.h \
    $$PWD/models/items/*.h \
    $$PWD/models/value-view-formatters/*.h \
    $$PWD/core/core.h


DEPSDIR = $$PWD/../deps/
BREAKPADDIR = $$DEPSDIR/google-breakpad/src

win32-msvc* {
    CONFIG += c++11

    FORMS += \
        $$PWD/forms/*.ui \

    INCLUDEPATH += $$BREAKPADDIR\client\windows\handler\
    INCLUDEPATH += $$BREAKPADDIR\common\windows\
    INCLUDEPATH += $$BREAKPADDIR\client\windows\crash_generation
    INCLUDEPATH += $$BREAKPADDIR\client\windows\common\
    INCLUDEPATH += $$BREAKPADDIR\google_breakpad\common\
    INCLUDEPATH += $$BREAKPADDIR\processor
    INCLUDEPATH += $$BREAKPADDIR\

    CONFIG(release, debug|release) {
        WIN_DEPS_PATH = $$DEPSDIR/libs/win32/release/
    } else: CONFIG(debug, debug|release) {
        WIN_DEPS_PATH = $$DEPSDIR/libs/win32/debug/
    }

    #message(Deps path: $$WIN_DEPS_PATH)

    LIBS += -L$$WIN_DEPS_PATH -llibssh2
    LIBS += -lcommon -lcrash_generation_client -lexception_handler

    CONFIG(debug, debug|release) {
        LIBS += -llibeay32 -lssleay32 -lzlib
    }

    LIBS += -lws2_32 -lkernel32 -luser32 -lshell32 -luuid -lole32 -ladvapi32
    PRE_TARGETDEPS += $$WIN_DEPS_PATH/libssh2.lib

    release: DESTDIR = ./../bin/windows/release
    debug:   DESTDIR = ./../bin/windows/debug    

    RC_FILE += $$PWD/resources/rdm.rc
    QMAKE_CXXFLAGS += /MP
    QMAKE_LFLAGS_RELEASE += /MAP
    QMAKE_CFLAGS_RELEASE += /Zi
    QMAKE_LFLAGS_RELEASE += /debug /opt:ref

    message("Windows build")
}

unix {

    macx { # os x 10.8

        FORMS += \
            $$PWD/forms/*.ui \

        CONFIG += c++11 release
        CONFIG -= debug

        debug {
                CONFIG-=app_bundle
        }

        LIBS += /usr/local/lib/libssh2.dylib
        LIBS += $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework/Versions/A/Breakpad
        PRE_TARGETDEPS += /usr/local/lib/libssh2.dylib  $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework

        INCLUDEPATH += $$PWD/../deps/libssh/include

        QMAKE_INFO_PLIST =  $$PWD/resources/Info.plist
        ICON = $$PWD/resources/rdm.icns

        INCLUDEPATH += $$BREAKPADDIR/ \
                        $$BREAKPADDIR/client/mac/handler/ \
                        $$BREAKPADDIR/client/mac/ \
                        $$BREAKPADDIR/client/ \
                        $$BREAKPADDIR/client/mac/crash_generation/ \
                        $$BREAKPADDIR/common/mac/ \
                        $$BREAKPADDIR/common/linux/ \
                        $$BREAKPADDIR/common/ \
                        $$BREAKPADDIR/processor/ \
                        $$BREAKPADDIR/google_breakpad/common/ \
                        $$BREAKPADDIR/third_party/lss/ \

        LIBS += /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
        LIBS += /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices

        #breakpad app need debug info inside binaries
        QMAKE_CXXFLAGS+=-g

        APP_DATA_FILES.files = $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework
        APP_DATA_FILES.path = Contents/Frameworks
        QMAKE_BUNDLE_DATA += APP_DATA_FILES

        release: DESTDIR = ./../bin/linux/release
        debug:   DESTDIR = ./../bin/linux/debug

        CRASHREPORTER_APP.files = $$DESTDIR/crashreporter
        CRASHREPORTER_APP.path = Contents/MacOS
        QMAKE_BUNDLE_DATA += CRASHREPORTER_APP

    }
    else { # ubuntu & debian

        CONFIG += static release
        CONFIG -= debug

        FORMS += \
            $$PWD/forms/*.ui \

        QMAKE_CXXFLAGS += -std=gnu++0x -g #workaround for google breakpad
        QMAKE_LFLAGS += -static-libgcc -static-libstdc++

        LIBS += -Wl,-rpath=\\\$$ORIGIN/../lib #don't remove!!!
        LIBS += /usr/local/lib/libssh2.a \
                /usr/local/lib/libbreakpad.a \
                /usr/local/lib/libbreakpad_client.a \

        PRE_TARGETDEPS +=/usr/local/lib/libssh2.a \
                         /usr/local/lib/libbreakpad.a \
                         /usr/local/lib/libbreakpad_client.a \

        INCLUDEPATH += $$BREAKPADDIR/ \
            $$BREAKPADDIR/client/linux/handler/ \
            $$BREAKPADDIR/client/linux/crash_generation/ \
            $$BREAKPADDIR/client/linux/minidump_writer/ \
            $$BREAKPADDIR/client/linux/log/ \
            $$BREAKPADDIR/client/ \
            $$BREAKPADDIR/common/linux/ \
            $$BREAKPADDIR/common/ \
            $$BREAKPADDIR/google_breakpad/common/ \
            $$BREAKPADDIR/processor/ \
            $$BREAKPADDIR/third_party/lss/ \

        DEPENDPATH += $$BREAKPADDIR/ \
            $$BREAKPADDIR/client/linux/handler/ \
            $$BREAKPADDIR/client/linux/crash_generation/ \
            $$BREAKPADDIR/client/linux/minidump_writer/ \
            $$BREAKPADDIR/client/linux/log/ \
            $$BREAKPADDIR/client/ \
            $$BREAKPADDIR/common/linux/ \
            $$BREAKPADDIR/common/ \
            $$BREAKPADDIR/google_breakpad/common/ \
            $$BREAKPADDIR/processor/ \
            $$BREAKPADDIR/third_party/lss/ \

        target.path = /usr/share/redis-desktop-manager/bin
        target.files = $$DESTDIR/rdm $$DESTDIR/crashreporter  $$PWD/resources/qt.conf  $$PWD/resources/rdm.png
        INSTALLS += target

        deskicon.path = /usr/share/applications
        deskicon.files =  $$PWD/resources/rdm.desktop
        INSTALLS += deskicon

        data.path = /usr/share/redis-desktop-manager/lib
        data.files = lib/*
        INSTALLS += data

        release: DESTDIR = ./../bin/linux/release
        debug:   DESTDIR = ./../bin/linux/debug
    }

    OBJECTS_DIR = $$DESTDIR/obj
    MOC_DIR = $$DESTDIR/obj
    RCC_DIR = $$DESTDIR/obj
    UI_DIR = $$DESTDIR/obj
}

INCLUDEPATH += $$DEPSDIR/libssh/include
DEPENDPATH += $$DEPSDIR/libssh/include
DEPENDPATH += $$BREAKPADDIR

INCLUDEPATH += $$PWD/dialogs \
    $$PWD/core/ \
    $$PWD/core/ssh/ \
    $$PWD/widgets/ \
    $$PWD/crashhandler/ \
    $$PWD/updater/ \
    $$PWD/models/ \
    $$PWD/models/items/ \
    $$PWD/models/value-view-formatters/ \
    $$PWD/resourses \
    $$PWD/ \

RESOURCES += \
    $$PWD/resources/rdm.qrc \
    $$PWD/resources/fonts.qrc

OTHER_FILES += \
    qt.conf \
    Info.plist


