/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: noMusicScreen
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
        Text {
            id: noMusicScreenText1
            //TODO check margins
            width: parent.width - 2*10
            anchors.horizontalCenter: parent.horizontalCenter
            text: labelNoMusicText1
            font.pixelSize: theme_fontPixelSizeLarge*2//window.height/17
            wrapMode: Text.WordWrap
            height: paintedHeight + window.height/24
        }
        Text {
            id: noMusicScreenText2
            //TODO check margins
            width: parent.width - 2*10
            anchors.horizontalCenter: parent.horizontalCenter
            text: labelNoMusicText2
            font.pixelSize: theme_fontPixelSizeLarge//window.height/21
            wrapMode: Text.WordWrap
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
