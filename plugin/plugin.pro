TEMPLATE = lib
TARGET = MusicPlugin 
QT += declarative dbus
CONFIG += qt plugin
OBJECTS_DIR = .obj
MOC_DIR = .moc

TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET
# Input
SOURCES += \
    plugin.cpp \
    qmlsettings.cpp \
    MusicDbusObject.cpp \
    music_adaptor.cpp

HEADERS += \
    plugin.h \
    qmlsettings.h \
    MusicDbusObject.h \
    music_adaptor_p.h

OTHER_FILES = qmldir \
    music-dbus-test \
    music.xml \
    com.meego.app.music.service

QMAKE_POST_LINK = cp qmldir $$DESTDIR

tests.path = /usr/bin
tests.files += music-dbus-test

service.path = /usr/share/dbus-1/services
service.files += com.meego.app.music.service

qmlfiles.files += $$TARGET
qmlfiles.path += $$[QT_INSTALL_IMPORTS]/MeeGo/App/Music/
INSTALLS += qmlfiles service tests
