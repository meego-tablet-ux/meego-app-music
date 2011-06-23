import Qt 4.7
import MeeGo.Media 0.1

Item {
    id: songListHeader
    width: parent.width
    height: showDetails ? (120 + bottomEmptySpace) : (40 + bottomEmptySpace)
    property string artistName: ""
    property string albumTitle: ""
    property bool showDetails: false
    property int bottomEmptySpace: 0
    //color: "#e9e7e7"
    //opacity: 1

    Text {
        id: albumTitleTextInListHeader
        visible: showDetails
        anchors.top: parent.top
        anchors.topMargin: 20//TODO: theme
        anchors.leftMargin: 20//TODO: theme
        anchors.left: parent.left
        height: ( visible ? 345/9 : 0 )//345: albumThumbnail height
        width: parent.width
        text: albumTitle
        color: track_title_color
        font.pixelSize: theme_fontPixelSizeLarge+10
        verticalAlignment:Text.AlignVCenter
        horizontalAlignment:Text.AlignLeft
        elide: Text.ElideRight
    }
    Text {
        id: albumArtistTextInListHeader
        anchors.top: albumTitleTextInListHeader.bottom
        anchors.leftMargin: 20
        anchors.left: parent.left
        height: ( visible ? 345/9 : 0 )//345: albumThumbnail height
        width: parent.width
        visible: showDetails
        text: artistName
        color: fontColorMediaArtist
        font.pixelSize: theme_fontPixelSizeLarge+10
        verticalAlignment:Text.AlignVCenter
        horizontalAlignment:Text.AlignLeft
        elide: Text.ElideRight
    }

    Rectangle{//dark
        id:separatorTop
        anchors.bottom: separatorBottom.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height:1
        color: theme_separatorDarkColor
        opacity: theme_separatorDarkAlpha
    }
    Rectangle{//light
        id:separatorBottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 19 + bottomEmptySpace
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height:1
        color: theme_separatorLightColor
        opacity: theme_separatorLightAlpha
    }
}
