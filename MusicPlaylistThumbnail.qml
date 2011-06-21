import Qt 4.7
import MeeGo.Media 0.1
import "functions.js" as Code

Item {
    id: container
    width:400
    height:width
    clip: true
    property bool animationNeeded: playlistAnimationNeeded
    property int animationDuration: 500

    onAnimationNeededChanged: {
        if( albumThumbnail.rotation == 0 &&
            albumThumbnail1.rotation == 0 &&
            albumThumbnail2.rotation == 0 &&
            albumThumbnail3.rotation == 0 &&
            albumThumbnail4.rotation == 0 )
        {
            albumThumbnail.rotation = Code.randomAngle(2,10,1);
            albumThumbnail1.rotation = Code.randomAngle(2,10,-1);
            albumThumbnail2.rotation = Code.randomAngle(2,10,1);
            albumThumbnail3.rotation = Code.randomAngle(2,10,-1);
            albumThumbnail4.rotation = Code.randomAngle(2,10,1);
            albumThumbnail.opacity = 1;
            albumThumbnail1.opacity = 1;
            albumThumbnail2.opacity = 1;
            albumThumbnail3.opacity = 1;
        }
        else
        {
            albumThumbnail.oldrotation = (albumThumbnail.rotation>10 ? 10 : albumThumbnail.rotation );
            if( window.isLandscape ){bringInAnimationLandscape.start();}else{bringInAnimationPortrait.start();} bringInAnimationRotation.start();
            albumThumbnail4.rotation = albumThumbnail3.rotation; bringInAnimation4.start();
            albumThumbnail3.rotation = albumThumbnail2.rotation;
            albumThumbnail2.rotation = albumThumbnail1.rotation;
            albumThumbnail1.rotation = albumThumbnail.oldrotation;
        }
    }


    Item {
        id: albumThumbnail4
        width:312
        height:345
        rotation: 0
        anchors.centerIn: parent
        opacity: 0
        NumberAnimation { id: bringInAnimation4; target: albumThumbnail4; property: "opacity"; from: 1; to:0; duration: animationDuration; }
        Image {
            smooth:true
            anchors.topMargin: 33
            anchors.bottomMargin: 16
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.fill: parent
            source:stackThumbnailUri4
        }
        Image {
            anchors.fill: parent
            smooth:true
            width:312
            height:345
            fillMode: Image.Stretch
            source: "image://themedimage/widgets/apps/media/tile-border-music-album-large-no-disc"
        }
    }

    Item {
        id: albumThumbnail3
        width:312
        height:345
        rotation: 0
        anchors.centerIn: parent
        opacity: 0
        Image {
            smooth:true
            anchors.topMargin: 33
            anchors.bottomMargin: 16
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.fill: parent
            source:stackThumbnailUri3
        }
        Image {
            anchors.fill: parent
            smooth:true
            width:312
            height:345
            fillMode: Image.Stretch
            source: "image://themedimage/widgets/apps/media/tile-border-music-album-large-no-disc"
        }
    }
    Item {
        id: albumThumbnail2
        width:312
        height:345
        rotation: 0
        opacity: 0
        anchors.centerIn: parent
        Image {
            smooth:true
            anchors.topMargin: 33
            anchors.bottomMargin: 16
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.fill: parent
            source:stackThumbnailUri2
        }
        Image {
            anchors.fill: parent
            smooth:true
            width:312
            height:345
            fillMode: Image.Stretch
            source: "image://themedimage/widgets/apps/media/tile-border-music-album-large-no-disc"
        }
    }
    Item {
        id: albumThumbnail1
        width:312
        height:345
        rotation: 0
        opacity: 0
        anchors.centerIn: parent
        Image {
            smooth:true
            anchors.topMargin: 33
            anchors.bottomMargin: 16
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.fill: parent
            source:stackThumbnailUri1
        }
        Image {
            anchors.fill: parent
            smooth:true
            width:312
            height:345
            fillMode: Image.Stretch
            source: "image://themedimage/widgets/apps/media/tile-border-music-album-large-no-disc"
        }
    }
    Item {
        id: albumThumbnail
        width:312
        height:345
        opacity: 0
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0
        property bool animation_active: false
        property real oldrotation: 0

        NumberAnimation {id: bringInAnimationLandscape; target: albumThumbnail; property: "anchors.horizontalCenterOffset"; from: container.width; to:0; duration: animationDuration; easing.type: Easing.OutSine; }
        NumberAnimation {id: bringInAnimationPortrait; target: albumThumbnail; property: "anchors.verticalCenterOffset"; from: container.width; to:0; duration: animationDuration; easing.type: Easing.OutSine; }
        NumberAnimation {id: bringInAnimationRotation; target: albumThumbnail; property: "rotation"; from: 30; to:globalNewAngle; duration: animationDuration; }
        Image {
            smooth:true
            anchors.topMargin: 33
            anchors.bottomMargin: 16
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.fill: parent
            source:stackThumbnailUriCurr
        }
        Image {
            anchors.fill: parent
            smooth:true
            width:312
            height:345
            fillMode: Image.Stretch
            source: "image://themedimage/widgets/apps/media/tile-border-music-album-large-no-disc"
        }

    }
}
