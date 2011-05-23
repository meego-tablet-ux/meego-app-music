/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

NoContent {
    id: noMusicScreen
    notification: Column {
        width: parent.width
        Text {
            id: noMusicScreenText1
            width: parent.width
            text: labelNoMusicText1
            font.pixelSize: theme_fontPixelSizeLarge*2//window.height/17
            wrapMode: Text.WordWrap
            height: paintedHeight + 20
        }
        Text {
            id: noMusicScreenText2
            width: parent.width
            text: labelNoMusicText2
            font.pixelSize: theme_fontPixelSizeLarge//window.height/21
            wrapMode: Text.WordWrap
        }
    }
}
