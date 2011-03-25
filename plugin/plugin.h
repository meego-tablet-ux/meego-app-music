/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef QSETTINGSQML_PLUGIN_H
#define QSETTINGSQML_PLUGIN_H

#include <QtDeclarative/QDeclarativeExtensionPlugin>

class qsettingsqmlPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:
    void registerTypes(const char *uri);
};

#endif // QSETTINGSQML_PLUGIN_H

