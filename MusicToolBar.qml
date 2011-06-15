/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Media 0.1
import QtMultimediaKit 1.1
import "functions.js" as Code
Item {
    id: container
    width: parent.width
    height: nowPlayingInfo.height + audioToolbar.height
    property string trackName
    property string artistName
    property string albumThumbnailURI
    property string defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
    property alias playing: audioToolbar.ispause
    property bool loop: false
    property bool shuffle: false
    property bool landscape: false
    property real nowPlayingHeight: 36
    property bool makeVisible: false

    signal playNeedsSongs()

    onPlayingChanged: {
        if( playing ){
            makeVisible = true;
        }else{
            hidingTimer.running = true;
        }
    }

    onShuffleChanged: {
        // if in shuffle state, loop makes no sense
        if (shuffle && loop) {
            loop = false;
        }
        playqueueModel.shuffle = shuffle;
    }
    onLoopChanged: {
        // if in loop state, shuffle should be off
        if (shuffle && loop) {
            shuffle = false;
        }
    }

    Image {
        id: albumThumbnailArea
        opacity: 1
        anchors.top: nowPlayingInfo.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: landscape ? (nowPlayingHeight+55) : 0
        source: (container.albumThumbnailURI == "")?defaultThumbnail:container.albumThumbnailURI
        fillMode: Image.Stretch
        }

    BorderImage {
        id: nowPlayingInfo
        anchors.left: albumThumbnailArea.right
        anchors.right: parent.right
        source: "image://themedimage/widgets/common/statusbar/statusbar-background"
        height: 0

        anchors.bottom: audioToolbar.top

        Item {
            id: nowPlayingText
            anchors.fill: parent
            Text {
                id: title
                text: qsTr("Now playing: ")
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                color: theme_fontColorMediaHighlight
            }
            Text {
                id: playinfo
                //: %1 is track name, %2 is artist name
                text:artistName != "" ? qsTr("%1, %2").arg(trackName).arg(artistName) : qsTr("%1").arg(trackName)
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: title.right
                anchors.leftMargin: 10
                color: theme_fontColorMediaHighlight
            }
            transform: Scale {
                origin.x: (title.width + playinfo.width + 10)/2
                origin.y: nowPlayingInfo.height/2
                yScale: nowPlayingInfo.height/nowPlayingHeight
            }
            smooth: true
        }
    }

    states: [
        State {
            name: "showNowPlayingBar"
            when: makeVisible
            PropertyChanges {
                target: nowPlayingInfo
                height: nowPlayingHeight
                opacity:1
            }
            PropertyChanges {
                target: audioToolbar
                height: 55
                opacity: 1
            }
        },
        State {
            name: "hideNowPlayingBar"
            when: !makeVisible
            PropertyChanges {
                target: nowPlayingInfo
                height: 0
                opacity: 0
            }
            PropertyChanges {
                target: audioToolbar
                height: 0
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            reversible: true
            ParallelAnimation{
                PropertyAnimation {
                    target:nowPlayingInfo
                    property: "height"
                    duration: 250
                }
                PropertyAnimation {
                    target: nowPlayingInfo
                    property: "opacity"
                    duration: 250
                }
                PropertyAnimation {
                    target: audioToolbar
                    property: "height"
                    duration: 250
                }
                PropertyAnimation {
                    target: audioToolbar
                    property: "opacity"
                    duration: 250
                }
            }
        }
    ]

    MediaToolbar {
        id: audioToolbar
        anchors.bottom: parent.bottom
        height: 55
        anchors.left: albumThumbnailArea.right
        anchors.right: parent.right
        landscape: container.landscape
        showprev: true
        showplay: true
        shownext: true
        showprogressbar: true
        showvolume: true
        volumeParent: container.parent
        showshuffle: true
        showrepeat: true
        onPrevPressed: Code.playPrevSong();
        onPlayPressed: {
            if(Code.play())
                ispause = true;
            else
                container.playNeedsSongs();
        }
        onPausePressed: {
            Code.pause();
            ispause = false;
            hidingTimer.running = true;
        }
        onNextPressed: Code.playNextSong();
        Connections {
            target: audio
            onPositionChanged: {
                var msecs = audio.duration - audio.position;
                audioToolbar.remainingTimeText = Code.formatTime(msecs/1000);
                audioToolbar.elapsedTimeText = Code.formatTime(audio.position/1000);
            }
        }
        onSliderMoved: {
            if (audio.seekable) {
                progressBarConnection.target = null
                audio.position = audio.duration * audioToolbar.sliderPosition;
                progressBarConnection.target = audio
            }
        }
        Timer{
            id: hidingTimer
            running: false
            repeat: false
            interval: 120000//TODO: add value to theme as "musicToolbarHidingTimeout"
            onTriggered: {if( !playing ){makeVisible=false;}}
        }
        Connections {
            id: progressBarConnection
            target: audio
            onPositionChanged: {
                if (audio.duration != 0) {
                    audioToolbar.sliderPosition = audio.position/audio.duration;
                }
            }
        }
        onShufflePressed: { shuffle = isshuffle; }
        onRepeatPressed: { loop = isrepeat; }
    }
}
