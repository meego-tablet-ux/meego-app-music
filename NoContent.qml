/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: noContents
    property alias content: innerContent.children
    anchors.fill: parent
    //TODO check margins
    anchors.margins: 20
    Column {
        id: col
        width: parent.width
        Loader {
            width: parent.width
            sourceComponent: separator
        }
        Item {
            id: innerContent
            //TODO check margins
            width: parent.width - 2*10
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Loader {
            width: parent.width
            sourceComponent: separator
        }
    }
    Component {
        id: separator
        Item {
            width: parent.width
            // TODO check margin
            height: 20
            Image {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                // TODO this probably is not correct separator
                source: "image://themedimage/images/dialog-separator"
            }
        }
    }
}
