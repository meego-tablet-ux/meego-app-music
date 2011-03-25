/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Media 0.1
Item {
    id: container
    width: 1024
    height: 600

    property alias radius: menu.radius
    property alias color: menu.color
    property alias menuWidth: menu.width
    property alias menuHeight: menu.height
    property alias menuX: menu.x
    property alias menuY: menu.y
    property variant model

    property alias menuOpacity: menu.opacity
    property alias fogOpacity: fog.opacity

    property int fingerX: 0
    property int fingerY: 0

    property variant payload
    property int itemHeight: 50
    property int fingerMode: 0

    property string labelAddToPlaylist: qsTr("Add to a playlist")


    signal triggered(string itemid,string title, variant payload)
    signal close()

    Rectangle {
        id: fog
        anchors.fill: parent
        color: theme_dialogFogColor
        opacity: theme_dialogFogOpacity
        Behavior on opacity {
            PropertyAnimation { duration: theme_dialogAnimationDuration }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            container.close();
        }

        Rectangle {
            id: menu
            width: 300
            height: 400
            color: theme_dialogBackgroundColor
            radius: 40
            opacity: 0
            Behavior on opacity {
                PropertyAnimation { duration: 500 }
            }

            Rectangle {
                id: finger
                parent: container
                width:Math.sqrt(2) * rect.width/2
                height:width*2
                color:"transparent"
                clip:true
                x: 0
                y: 0
                opacity:menu.opacity
                Rectangle {
                    id: rect
                    width: menu.radius
                    height: menu.radius
                    color: menu.color
                    rotation:  -45
                    transformOrigin:Item.TopLeft
                    y: finger.height/2
                }
            }

            Text {
                id: titleText
                text:labelAddToPlaylist
                color:theme_dialogTitleFontColor
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.topMargin:20
                anchors.leftMargin: 20
                width:parent.width
                height:40
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment:Text.AlignLeft
                font.bold: true
                font.pixelSize:theme_dialogTitleFontPixelSize
            }
            ListView {
                id:playlistsView
                anchors.top:titleText.bottom
                anchors.left: parent.left
                anchors.leftMargin: 40
                clip:true
                width:parent.width - 40
                height: parent.height - titleText.height - 20 -menu.radius /2
                model: MusicListModel {
                    type: MusicListModel.ListofPlaylists
                    limit: 0
                    sort: MusicListModel.SortByCreationTime
                    Component.onCompleted: {
                        var h = titleText.height + 20 + count * 40
                        menu.height = h > 400 ? 400: h;
                    }
                }
                delegate : Text {
                    id: dinstance
                    text: title
                    width: parent.width
                    height: 40
                    font.pixelSize: theme_fontPixelSizeMedium
                    color:theme_fontColorNormal
                    property string mitemid: itemid
                    property string mtitle: title


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            container.triggered(mitemid,mtitle,container.payload);
                        }
                    }
                }
            }

            states: [
                State {
                    name: "left"
                    when: container.fingerMode == 0
                    PropertyChanges {
                        target: finger
                        x: fingerX+3
                        y: fingerY - finger.height/2
                    }
                },
                State {
                    name: "right"
                    when: container.fingerMode == 1
                    PropertyChanges {
                        target: finger
                        x: fingerX -finger.width -3 // there is a gap, don't know exactly why
                        y: fingerY - finger.height/2
                         rotation: 180
                    }
                },
                State {
                    name: "top"
                    when: container.fingerMode == 2
                    PropertyChanges {
                        target: finger
                        x: fingerX + (finger.width-finger.height)/2
                        y: fingerY + (finger.width -finger.height)/2
                        rotation: 90

                    }
                },
                State {
                    name: "bottom"
                    when: container.fingerMode == 3
                    PropertyChanges {
                        target: finger
                        x: fingerX  + (finger.width-finger.height)/2
                        y: fingerY  +(finger.width -finger.height)/2 - finger.width -2
                        rotation: 270

                    }
                }
            ]

        }
    }
}
