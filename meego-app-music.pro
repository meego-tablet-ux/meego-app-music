VERSION = 0.2.20
TEMPLATE = subdirs
SUBDIRS += plugin

qmlfiles.files += *.qml *.png *.js
qmlfiles.path += $$INSTALL_ROOT/usr/share/$$TARGET

desktop.files += *.desktop
desktop.path += $$INSTALL_ROOT/usr/share/applications

INSTALLS += qmlfiles desktop

TRANSLATIONS += *.qml
PROJECT_NAME = meego-app-music

dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += rm -f $${PROJECT_NAME}-$${VERSION}/.gitignore &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}
QMAKE_EXTRA_TARGETS += dist
