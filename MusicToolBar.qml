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
import QtMultimediaKit 1.1
import "functions.js" as Code
Item {
    id: container
    width: parent.width
    height: nowPlayingInfo.height + audioToolbar.height
    property variant audioItem
    property string trackName
    property string artistName
    property alias playing: audioToolbar.ispause
    property bool loop: false
    property bool shuffle: false
    property bool landscape: false

    signal playNeedsSongs()

    onShuffleChanged: {
        // if in shuffle state, loop makes no sense
        if (shuffle && loop) {
            loop = false;
        }
    }
    onLoopChanged: {
        // if in loop state, shuffle should be off
        if (shuffle && loop) {
            shuffle = false;
        }
    }
    BorderImage {
        id: nowPlayingInfo
        width: parent.width
        source: "image://theme/media/media_playbar_nowplaying_bg"
        height: 0

        border.left: 10; border.top: 10
        border.right: 10; border.bottom: 10
        anchors.bottom: audioToolbar.top
        anchors.left: parent.left

        Text {
            id: title
            text: qsTr("Now playing: ")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: theme_fontColorMediaHighlight
        }
        Text {
            id: playinfo
            text:qsTr("%1, %2").arg(trackName).arg(artistName)
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: title.right
            anchors.leftMargin: 10
            color: theme_fontColorMediaHighlight
        }
    }

    states: [
        State {
            name: "showNowPlayingBar"
            when: playing
            PropertyChanges {
                target: nowPlayingInfo
                height: 36
                opacity:1
            }
        },
        State {
            name: "hideNowPlayingBar"
            when: !playing
            PropertyChanges {
                target: nowPlayingInfo
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
            }
        }
    ]

    MediaToolbar {
        id: audioToolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 55
        width: parent.width
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
