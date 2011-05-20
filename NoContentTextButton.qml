/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

NoContent {
    id: noContent
    property string text: ""
    property string buttonText: ""
    property bool showContextMenu: false
    property variant contextMenuModel
    signal clicked(variant mouse);
    signal triggered(int index);
    ContextMenu {
        id: contextMenu
        forceFingerMode: 2
        content: ActionMenu {
            model: contextMenuModel
            onTriggered: {
                noContent.triggered(index);
                contextMenu.hide();
            }
        }
    }
    TopItem { id: topItem }
    content: Item {
        width: parent.width
        height: Math.max(descText.height, button.height)
        Text {
            id: descText
            text: noContent.text
            anchors.left: parent.left
            anchors.right: button.left
            anchors.verticalCenter: parent.verticalCenter
            // TODO check font
            font.pixelSize: theme_fontPixelSizeLarge
            wrapMode: Text.WordWrap
        }
        Button {
            id: button
            text: noContent.buttonText
            //active: contextMenu.visible
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if (showContextMenu) {
                    var pos = mapToItem(topItem.topItem, width-(height/2),height/2);
                    contextMenu.setPosition(pos.x, pos.y);
                    contextMenu.show();
                } else {
                    noContent.clicked(mouse);
                }
            }
        }
    }
}

