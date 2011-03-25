/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "plugin.h"
#include "qmlsettings.h"
#include "qmldbusmusic.h"

#include <QtDeclarative/qdeclarative.h>

void qsettingsqmlPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<QmlSetting>(uri, 1, 0, "QmlSetting");
    qmlRegisterType<QmlDBusMusic>(uri, 0, 1, "QmlDBusMusic");
}

Q_EXPORT_PLUGIN2(MusicPlugin, qsettingsqmlPlugin)

