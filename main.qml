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
import MeeGo.App.Music.MusicPlugin 1.0
import MeeGo.Sharing 0.1
import "functions.js" as Code

Window {
    id: scene
    property string labelRecentlyAdded: qsTr("Recently Added")
    property string labelRecentlyViewed: qsTr("Recently Viewed")
    property string labelPlayqueue: qsTr("Play queue")
    property string labelFavorites: qsTr("Favorites")
    property string labelMusicApp: qsTr("Music")
    property string labelNowPlaying: qsTr("Now Playing")
    property string labelRecents: qsTr("Recently played")
    property string labelAllArtist: qsTr("Artists")
    property string labelArtist: ""
    property string labelAllAlbums: qsTr("Albums")
    property string labelAlbum: ""
    property string labelAllPlaylist: qsTr("Playlists")
    property string labelPlaylist: ""
    property string labelPlaylistURN: ""
    property string labelAllTracks: qsTr("All tracks")

    property string labelUnknownArtist: qsTr("unknown artist")
    property string labelUnknownAlbum: qsTr("unknown album")

    property string labelPlay: qsTr("Play")
    property string labelOpen: qsTr("Open")
    property string labelOpenAlbum: qsTr("Open Album")
    property string labelFavorite: qsTr("Favorite")
    property string labelUnFavorite: qsTr("Unfavorite")
    property string labelAddToPlayQueue: qsTr("Add to play queue")
    property string labelAddToPlaylist: qsTr("Add to playlist")
    property string labelRemFromPlaylist: qsTr("Remove from playlist")

    property string labelRename:qsTr("Rename")

    property string labelNewList: qsTr("New")
    property string labelEdit: qsTr("Edit")
    property string labelcShare: qsTr("Share")
    property string labelDelete: qsTr("Delete")
    property string labelRemoveFromPlayQueue: qsTr("Remove From Queue")
    property string labelCreate: qsTr("Create")
    property string labelSavePlaylist: qsTr("Save as playlist")
    property string labelClearPlaylist: qsTr("Clear play queue")

    property string labelItemCount: qsTr("%1 Items")
    property string labelAlbumCount: qsTr("%1 Album")
    property string labelTrackCount: qsTr("%1 Tracks")

    property string labelGrid: qsTr("Grid")
    property string labelList: qsTr("List")

    property string labelAlphabetical: qsTr("Sort Alphabetically")
    property string labelDateOrder: qsTr("Sort by Date")

    property string labelCreateNewPlaylist: qsTr("Create new playlist")
    property string labelRenamePlaylist: qsTr("Rename playlist")

    property string labelConfirmDelete: qsTr("Yes, Delete")
    property string labelCancel: qsTr("Cancel")
    property string labelDefaultText:qsTr("Type playlist name here.")
    property string labelMultiSelect:qsTr("Select Multiple Songs")
    property int animationDuration: 500

    property int numberOfTrack: 0
    property int numberOfAlbum: 0
    property string artistName: ""
    property int tabContentWidth: 300

    property alias shuffle: toolbar.shuffle
    property alias loop: toolbar.loop

    property string thumbnailUri:""
    property bool multiSelectMode: false
    property variant multiSelectModel

    title: labelMusicApp
    onSearch: {
       // contentStrip.activeContent.model.search = needle;
    }

    property variant theFilterModel: [labelPlayqueue,labelAllPlaylist,labelFavorites,
          labelAllArtist, labelAllAlbums,
          labelAllTracks]
    filterModel: (multiSelectMode)?[]:theFilterModel

    onFilterTriggered: {
        if (index == 0) {
            scene.applicationPage = playQueueContent;
        }else if (index == 1)
        {
            scene.applicationPage = playlistsContent;
        }else if (index == 2)
        {
            scene.applicationPage = favoritesContent;
        }else if (index == 3)
        {
            scene.applicationPage = artistsContent;
        }else if (index == 4)
        {
            scene.applicationPage = albumsContent;
        }else if (index == 5)
        {
            scene.applicationPage = allTracksContent;
        }
    }

    ShareObj {
        id: shareObj
        shareType: MeeGoUXSharingClientQmlObj.ShareTypeAudio
    }

    // global now playing queue
    property variant playqueueModel: MusicListModel {
        type: MusicListModel.NowPlaying
        limit: 0
        sort: MusicListModel.SortByDefault
    }

    // an editor model, it is used to do things like tag arbitrary items as favorite/viewed
    property variant editorModel: MusicListModel {
        type:MusicListModel.MixedList
        limit: 0
        mixtypes:MusicListModel.Songs|MusicListModel.Albums|MusicListModel.Artists|MusicListModel.Playlists
        sort: MusicListModel.SortByDefault
        onItemAvailable: {
            console.log("Item Available: " + identifier);
            var thetitle;
            if(editorModel.isURN(identifier))
            {
                remoteControlItem.mitemid = editorModel.getIDfromURN(identifier);
                remoteControlItem.mitemtype = editorModel.getTypefromURN(identifier);
                thetitle = editorModel.getTitlefromURN(identifier);
            }
            else
            {
                remoteControlItem.mitemid = identifier;
                remoteControlItem.mitemtype = editorModel.getTypefromID(identifier);
                thetitle = editorModel.getTitlefromID(identifier);
            }
            if (remoteControlItem.mitemtype == 2) {
                // song
                console.log("song loaded");
                Code.addToPlayqueueAndPlay(remoteControlItem);
            }else if (remoteControlItem.mitemtype == 3) {
                // artist
                console.log("artist loaded");
                labelArtist = thetitle;
                scene.applicationPage = artistDetailViewContent;
            }else if (remoteControlItem.mitemtype == 4) {
                // album
                console.log("album loaded");
                labelAlbum = thetitle;
                scene.applicationPage = albumDetailViewContent;
            }else if (remoteControlItem.mitemtype == 5) {
                // playlist
                console.log("playlist loaded");
                labelPlaylist = thetitle;
                labelPlaylistURN = identifier;
                scene.applicationPage = playlistDetailViewContent;
            }
        }
    }

    property variant miscModel: MusicListModel {
        //  type:MusicListModel.MusicPlaylist
        limit: 0
        sort: MusicListModel.SortByDefault
    }

    Item {
        id: proxyItem
        property string mtitle
        property int mitemtype
        property string mitemid
    }

    QmlSetting{
        id: settings
        organization: "MeeGo"
        application:"meego-app-music"
    }

   Connections {
        target: mainWindow
        onCall: {
            var cmd = parameters[0];
            var cdata = parameters[1];
            if (cmd == "play") {
                Code.play();
            } else if (cmd == "pause") {
                Code.pause();
            } else if (cmd == "stop") {
                Code.stop();
            } else if (cmd == "playSong") {
	        editorModel.requestItem(2, cdata);
            } else if (cmd == "playArtist") {
	        editorModel.requestItem(3, cdata);
            } else if (cmd == "playAlbum") {
	        editorModel.requestItem(4, cdata);
            } else if (cmd == "playPlaylist") {
	        editorModel.requestItem(5, cdata);
            } else if(cmd == "orientation") {
                orientation = (orientation+1)%4;
            }
        }
    }
   QtObject {
       id: remoteControlItem
       property string mitemid
       property string mitemtype
   }
    onApplicationDataChanged: {
    }


    onStatusBarTriggered: {
        orientation = (orientation+1)%4;
    }

    QmlDBusMusic {
        id: dbusControl
        onNext: Code.playNextSong();
        onPrev: Code.playPrevSong();
        onPlay: Code.play();
        onPause: Code.pause();

        property int nextItem1: -1
        property int nextItem2: -1

        function updateNowNextTracks() {
            var newNowNext = [
                    playqueueView.currentItem.murn,
                    playqueueModel.getURNFromIndex(nextItem1),
                    playqueueModel.getURNFromIndex(nextItem2)
                ]
            console.log("here's my list: " + newNowNext);
            console.log("from nI1: " + nextItem1 + ", nI2: " + nextItem2);
            dbusControl.nowNextTracks = newNowNext;
        }
        onStateChanged: {
            console.log("State changed, new state: " + state);
            Code.updateNowNextPlaying();
        }

    }

    Audio {
        id: audio
        autoLoad: true
        onError: {
            Code.playNextSong();
        }

        onPaused: dbusControl.state = "paused";
        onResumed: {
            dbusControl.updateNowNextTracks();
            dbusControl.state = "playing";
        }
        onStarted: {
            dbusControl.updateNowNextTracks();
            dbusControl.state = "playing";
        }
        onStopped: {
            dbusControl.updateNowNextTracks();
            dbusControl.state = "stopped";
        }

        onStatusChanged: {
            if (status == Audio.EndOfMedia) {
                Code.playNextSong();
            }
        }
        onPlayingChanged: {
            var id = playqueueView.currentItem.mitemid;
            if (!playing) {
                playqueueModel.setPlayStatus(id, MusicListModel.Stopped);
                toolbar.playing = false;
            }else {
                playqueueModel.setPlayStatus(id, MusicListModel.Playing);
                toolbar.playing = true;
            }
        }
        onPausedChanged: {
            var id = playqueueView.currentItem.mitemid;
            if (playing) {
               if(paused){
                   playqueueModel.setPlayStatus(id, MusicListModel.Paused);
                   toolbar.playing = false;
               }else{
                   playqueueModel.setPlayStatus(id, MusicListModel.Playing);
                   toolbar.playing = true;
               }
            }
            else{
                playqueueModel.setPlayStatus(id, MusicListModel.Stopped);
                toolbar.playing = false;
            }
        }
    }

    Component.onCompleted: {
        applicationPage = allTracksContent
    }


    Loader {
        id: contextLoader
    }
    Loader {
        id: dialogLoader
        onStatusChanged :{
            if (status == Loader.Ready){
                item.parent = content;
            }
        }
    }

    ContextMenu {
        id: contextMenu
        menuWidth: 400
        property variant openpage
        property variant playlistmodel
        property variant sharemodel
        onTriggered: {
            if (model[index] == labelPlay)
            {
                // Play
                if(!multiSelectMode)
                    Code.addToPlayqueueAndPlay(payload);
                else if(multiSelectModel.selectionCount() > 0)
                    Code.addMultipleToPlayqueueAndPlay(multiSelectModel);
            }
            else if (model[index] == labelOpen)
            {
                // Open
                Code.openItemInDetailView(openpage,payload);
            }
            else if ((model[index] == labelFavorite)||(model[index] == labelUnFavorite))
            {
                // Favorite/unfavorite
                if(!multiSelectMode)
                    Code.changeItemFavorite(payload, (model[index] == labelFavorite));
                else if(multiSelectModel.selectionCount() > 0)
                    Code.changeMultipleItemFavorite(multiSelectModel, (model[index] == labelFavorite));
            }
            else if (model[index] == labelAddToPlayQueue)
            {
                // Add to play queue
                if(!multiSelectMode)
                    Code.addToPlayqueue(payload);
                else if(multiSelectModel.selectionCount() > 0)
                    Code.addMultipleToPlayqueue(multiSelectModel);
            }
            else if (model[index] == labelRemoveFromPlayQueue)
            {
                // Remove from play queue
                if(!multiSelectMode)
                    Code.removeFromPlayqueue(payload);
                else if(multiSelectModel.selectionCount() > 0)
                    Code.removeMultipleFromPlayqueue(multiSelectModel);
            }
            else if (model[index] == labelAddToPlaylist)
            {
                // Add to a play list
                if(!multiSelectMode)
                {
                    playlistPicker.payload = payload.mitemid;
                    playlistPicker.show();
                }
                else if(multiSelectModel.selectionCount() > 0)
                {
                    playlistPicker.payload = multiSelectModel.getSelectedIDs()
                    playlistPicker.show();
                }
            }
            else if (model[index] == labelRemFromPlaylist)
            {
                // Remove from a play list
                if(!multiSelectMode)
                {
                    playlistmodel.removeItems(payload.mitemid);
                    playlistmodel.savePlaylist(playlistmodel.playlist);
                }
                else if(multiSelectModel.selectionCount() > 0)
                {
                    playlistmodel.removeItems(multiSelectModel.getSelectedIDs());
                    playlistmodel.savePlaylist(playlistmodel.playlist);
                    multiSelectModel.clearSelected();
                    multibar.sharing.clearItems();
                    multiSelectMode = false;
                }
            }
            else if (model[index] == labelRenamePlaylist)
            {
                // Rename playlist
                scene.showModalDialog(renamePlaylistComponent);
                dialogLoader.item.currTitle = payload.mtitle;
                dialogLoader.item.urn = payload.murn;
                dialogLoader.item.playListModel = playlistmodel;
            }
            else if (model[index] == labelDelete)
            {
                // Delete
                if(!multiSelectMode)
                {
                    scene.showModalDialog(deleteItemComponent);
                    dialogLoader.item.payload = payload;
                }
                else if(multiSelectModel.selectionCount() > 0)
                {
                    scene.showModalDialog(deleteMultipleItemsComponent);
                }
            }
            else if (model[index] == labelMultiSelect)
            {
                // Multi Select
                multiSelectMode = true;
            }
            else if (model[index] == labelcShare)
            {
                // Share
                if(!multiSelectMode)
                {
                    shareObj.clearItems();
                    shareObj.addItem(payload.muri) // URI
                    shareObj.showContextTypes(mouseX, mouseY);
                }
                else if(multiSelectModel.selectionCount() > 0)
                {
                    shareObj.clearItems();
                    shareObj.addItems(multiSelectModel.getSelectedURIs()) // URIs
                    shareObj.showContextTypes(mouseX, mouseY);
                }
            }
        }
    }

    function musicContextMenu(mouseX, mouseY, payload, entrylist)
    {
        var map = payload.mapToItem(scene, mouseX, mouseY);
        var ctxList = [];
        var e, x;
        for (e in entrylist) {
            if(multiSelectMode&&
               ((entrylist[e] == labelMultiSelect)||
               (entrylist[e] == labelRenamePlaylist)||
                (entrylist[e] == labelOpen)))
            {
                // skip these entries if you're in multiselect mode
                continue;
            }
            else if(entrylist[e] == "favorite")
            {
                ctxList = ctxList.concat(payload.mfavorite ? labelUnFavorite: labelFavorite);
            }
            else
            {
                ctxList = ctxList.concat(entrylist[e]);
            }
        }
        contextMenu.model = ctxList
        contextMenu.payload = payload;
        contextMenu.menuX = map.x;
        contextMenu.menuY = map.y;
    }

    Component {
        id: deleteItemComponent
        ModalDialog {
            dialogTitle: labelDelete
            leftButtonText: labelConfirmDelete
            rightButtonText:labelCancel
            property variant payload
            onPayloadChanged:{
                contentLoader.item.artist = payload.martist;
                contentLoader.item.track = payload.mtitle;
            }

            onDialogClicked: {
                if( button == 1) {
                    console.log(payload.muri);
                    editorModel.destroyItemByID(payload.mitemid);
                }
                dialogLoader.sourceComponent = undefined;
            }
            Component.onCompleted: {
                contentLoader.sourceComponent = dialogContent;
            }
            Component {
                id: dialogContent
                Item {
                    anchors.fill: parent
                    property alias artist : artistName.text
                    property alias track: trackName.text
                    clip: true
                    Text{
                        id: artistName
                        text : qsTr("Artist name")
                        anchors.top: parent.top
                        width:  parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text{
                        id: trackName
                        text: qsTr("Track name")
                        anchors.top:artistName.bottom
                        width:  parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        id:warning
                        text: qsTr("If you delete this, it will be removed from your device")
                        anchors.top:trackName.bottom
                        width:  parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: theme_fontPixelSizeMedium
                    }
                }

            }
        }
    }

    Component {
        id: deleteMultipleItemsComponent
        ModalDialog {
            property int deletecount: multiSelectModel.selectionCount()
            dialogTitle: (deletecount < 2)?qsTr("Permanently delete this song?"):qsTr("Permanently delete these %1 songs?").arg(deletecount)
            leftButtonText: labelConfirmDelete
            rightButtonText:labelCancel
            onDialogClicked: {
                if( button == 1) {
                    multiSelectModel.destroyItemsByID(multiSelectModel.getSelectedIDs());
                    multiSelectModel.clearSelected();
                    multibar.sharing.clearItems();
                    multiSelectMode = false;
                }
                dialogLoader.sourceComponent = undefined;
            }
            Component.onCompleted: {
                contentLoader.sourceComponent = dialogContent;
            }
            Component {
                id: dialogContent
                Item {
                    anchors.fill: parent
                    clip: true
                    Text {
                        id:warning
                        text: qsTr("If you delete these, they will be removed from your device")
                        anchors.verticalCenter:parent.verticalCenter
                        width:  parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: theme_fontPixelSizeMedium
                    }
                }
            }
        }
    }

    Component {
        id: createPlaylistComponent
        ModalDialog {
            dialogTitle:labelCreateNewPlaylist
            rightButtonText:labelCancel
            leftButtonText:labelCreate
            property string playlistTitle: ""
            onDialogClicked: {
                if(button == 1) {
                    miscModel.type = MusicListModel.MusicPlaylist;
                    miscModel.clear();
                    miscModel.savePlaylist(playlistTitle);
                }
                dialogLoader.sourceComponent = undefined;
            }

            Component.onCompleted: {
                contentLoader.sourceComponent = editorComponent;
            }
            Component {
                id: editorComponent
                Item{
                    anchors.fill: parent
                    TextEntry{
                        id: editor
                        width: parent.width
                        height: 50
                        focus: true
                        defaultText: labelDefaultText
                        onTextChanged: {
                            playlistTitle = text
                        }
                    }
                }
            }
        }
    }

    Component {
        id: renamePlaylistComponent
        ModalDialog {
            dialogTitle:labelRenamePlaylist
            rightButtonText:labelCancel
            leftButtonText:labelRename
            property string currTitle: ""
            property string urn: ""
            property string newTitle: ""
            property variant playListModel
            onDialogClicked: {
                if(button == 1) {
                    playListModel.changeTitleByURN(urn, newTitle);
                    labelPlaylist = newTitle;
                }
                dialogLoader.sourceComponent = undefined;
            }

            Component.onCompleted: {
                contentLoader.sourceComponent = editorComponent;
            }
            Component {
                id: editorComponent
                Item{
                    anchors.fill: parent
                    TextEntry{
                        id: editor
                        width: parent.width
                        height: 50
                        focus: true
                        text: currTitle
                        onTextChanged: {
                            newTitle = text
                        }
                    }
                }
            }
        }
    }

    Component {
        id: playqueuePlaylistComponent
        ModalDialog {
            dialogTitle:labelCreateNewPlaylist
            rightButtonText:labelCancel
            leftButtonText:labelCreate
            property string playlistTitle: ""
            onDialogClicked: {
                if(button == 1) {
                    miscModel.type = MusicListModel.MusicPlaylist;
                    miscModel.clear();
                    miscModel.addItems(playqueueModel.getAllIDs());
                    miscModel.savePlaylist(playlistTitle);
                }
                dialogLoader.sourceComponent = undefined;
            }

            Component.onCompleted: {
                contentLoader.sourceComponent = editorComponent;
            }
            Component {
                id: editorComponent
                Item{
                    anchors.fill: parent
                    TextEntry{
                        id: editor
                        width: parent.width
                        height: 50
                        focus: true
                        defaultText: labelDefaultText
                        onTextChanged: {
                            playlistTitle = text
                        }
                    }
                }
            }
        }
    }

    Component {
        id: playQueueContent
        ApplicationPage {
            id: playQueuePage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title:labelPlayqueue
            onApplicationDataChanged: {
                if(applicationData != undefined)
                    scene.applicationData = undefined;
            }
            menuContent: Rectangle{
                visible: !multiSelectMode
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10
                Button {
                    id: saveBt
                    title: labelSavePlaylist
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        scene.showModalDialog(playqueuePlaylistComponent)
                        playQueuePage.closeMenu();
                    }
                }
                Button {
                    id: clearBt
                    title: labelClearPlaylist
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: saveBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        Code.stop();
                        playqueueModel.clear();
                        playQueuePage.closeMenu();
                    }
                }
            }


            onSearch: {
                playqueueView.model.search = needle;
            }

            Component.onCompleted: {
                playqueueView.parent = playQueuePage.content;
            }
            Component.onDestruction: {
                playqueueView.parent = parkingLot;
            }
        }
    }

    Component {
        id:playlistsContent
        ApplicationPage {
            id: playlistsPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAllPlaylist
            property bool showGridView: settings.get("PlaylistsView") == 0
            showSearch: false
            onSearch: {
                gridView.model.search = needle;
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                    scene.applicationData = undefined;
            }
            menuContent: Rectangle{
                visible: !multiSelectMode
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10
                Button {
                    id: createNewListBt
                    title: labelNewList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        scene.showModalDialog(createPlaylistComponent)
                        playlistsPage.closeMenu();
                    }
                }
                Button {
                    id: gridBt
                    title: labelGrid
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: createNewListBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView = true;
                        settings.set("PlaylistsView",0);
                        playlistsPage.closeMenu();
                    }
                }
                Button {
                    id: listBt
                    title: labelList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gridBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView = false;
                        settings.set("PlaylistsView",1);
                        playlistsPage.closeMenu();
                    }
                }
            }

            MusicListView {
                parent: playlistsPage.content
                anchors.fill: parent
                model:gridView.model
                mode : 1
                visible: !showGridView
                onClicked: {
                     Code.openItemInDetailView(playlistsPage,payload);
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelRenamePlaylist, labelDelete]);
                    contextMenu.openpage = playlistsPage;
                    contextMenu.playlistmodel = gridView.model;
                    contextMenu.visible = true;
                }
            }


            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                parent: playlistsPage.content
                anchors.fill: parent
                cellWidth: ((width- 15) / (scene.isLandscapeView() ? 7: 4))
                cellHeight: cellWidth
                visible:showGridView
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://theme/media/music_thumb_med"
                model: MusicListModel {
                    type: MusicListModel.ListofPlaylists
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    Code.openItemInDetailView(playlistsPage,payload);
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(dinstance);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelRenamePlaylist, labelDelete]);
                    contextMenu.openpage = playlistsPage;
                    contextMenu.playlistmodel = gridView.model;
                    contextMenu.visible = true;
                }
            }
        }
    }

    Component {
        id: artistsContent
        ApplicationPage {
            id: artistsPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAllArtist
            property bool showGridView: settings.get("AllArtistsView") == 0
            showSearch: false
            onSearch: {
                artistsGridView.model.search = needle;
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                    scene.applicationData = undefined;
            }
            menuContent: Rectangle{
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10

                Button {
                    id: gridBt
                    title: labelGrid
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView = true;
                        settings.set("AllArtistsView",0);
                        artistsPage.closeMenu();
                    }
                }
                Button {
                    id: listBt
                    title: labelList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gridBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView= false;
                        settings.set("AllArtistsView",1);
                        artistsPage.closeMenu();
                    }
                }
            }
            MusicListView {
                id: artistsListView
                parent: artistsPage.content
                anchors.fill:parent
                visible: !showGridView
                model:artistsGridView.model
                mode: 2
                onClicked: {
                    Code.openItemInDetailView(artistsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = artistsPage;
                    contextMenu.visible = true;
                }
            }
            MediaGridView {
                id: artistsGridView
                type: musictype // music app = 0
                parent: artistsPage.content
                anchors.fill: parent
                visible: showGridView
                cellWidth:(width- 15) / (scene.isLandscapeView() ? 7: 4)
                cellHeight: cellWidth
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://theme/media/music_thumb_med"
                model: MusicListModel {
                    type: MusicListModel.ListofArtists
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    Code.openItemInDetailView(artistsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = artistsPage;
                    contextMenu.visible = true;
                }
            }
        }
    }

    Component {
        id:albumsContent
        ApplicationPage {
            id: albumsPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAllAlbums
            property bool showGridView: settings.get("AllAlbumsView") == 0
            showSearch: false
            onSearch: {
                albumsGridView.model.search = needle;
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                    scene.applicationData = undefined;
            }
            menuContent: Rectangle{
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10

                Button {
                    id: gridBt
                    title: labelGrid
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView = true;
                        settings.set("AllAlbumsView",0);
                        albumsPage.closeMenu();
                    }
                }
                Button {
                    id: listBt
                    title: labelList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gridBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView= false;
                        settings.set("AllAlbumsView",1);
                        albumsPage.closeMenu();
                    }
                }
            }
            MusicListView {
                id: albumsListView
                parent: albumsPage.content
                anchors.fill:parent
                visible: !showGridView
                model:albumsGridView.model
                mode: 3
                onClicked: {
                    Code.openItemInDetailView(albumsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.visible = true;
                }
            }

            MediaGridView {
                id: albumsGridView
                type: musictype // music app = 0
                parent: albumsPage.content
                anchors.fill: parent
                visible: showGridView
                cellWidth:(width- 15) / (scene.isLandscapeView() ? 7: 4)
                cellHeight: cellWidth
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://theme/media/music_thumb_med"
                model: MusicListModel {
                    type: MusicListModel.ListofAlbums
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    Code.openItemInDetailView(albumsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.visible = true;
                }
            }
        }
    }

    Component {
        id: allTracksContent
        ApplicationPage {
            id: allTracksPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAllTracks
            property bool showGridView: settings.get("AllTracksView") == 0
            showSearch: false
            onSearch: {
               listview.model.search = needle;
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                {
                    if(applicationData == "playneedssongs")
                    {
                        playqueueModel.clear();
                        playqueueModel.addItems(listview.model.getAllIDs());
                        playqueueView.currentIndex = 0;
                        Code.play();
                    }
                    scene.applicationData = undefined;
                }
            }
            menuContent: Rectangle{
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10

                Button {
                    id: gridBt
                    title: labelGrid
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView = true;
                        settings.set("AllTracksView",0);
                        allTracksPage.closeMenu();
                    }
                }
                Button {
                    id: listBt
                    title: labelList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gridBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        showGridView= false;
                        settings.set("AllTracksView",1);
                        allTracksPage.closeMenu();
                    }
                }
            }
            MusicListView {
                id: listview
                selectionMode: multiSelectMode
                parent: allTracksPage.content
                anchors.fill:parent
                visible: !showGridView
                model:MusicListModel {
                    type: MusicListModel.ListofSongs
                    sort:MusicListModel.SortByDefault
                    limit: 0
                }
                onClicked: {
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            multibar.sharing.addItem(payload.muri);
                        else
                            multibar.sharing.delItem(payload.muri);
                    }
                    else
                    {
                        listview.currentIndex = model.itemIndex(payload.mitemid);
                        Code.addToPlayqueueAndPlay(payload);
                    }
                }
                onLongPressAndHold:{
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.visible = true;
                }
            }
            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                selectionMode: multiSelectMode
                parent: allTracksPage.content
                anchors.fill:parent
                visible: showGridView
                cellWidth:(width- 15) / (scene.isLandscapeView() ? 7: 4)
                cellHeight: cellWidth
                model: listview.model
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://theme/media/music_thumb_med"
                onClicked: {
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            multibar.sharing.addItem(payload.muri);
                        else
                            multibar.sharing.delItem(payload.muri);
                    }
                    else
                    {
                        listview.currentIndex = model.itemIndex(payload.mitemid);
                        Code.addToPlayqueueAndPlay(payload);
                    }
                }
                onLongPressAndHold:{
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.visible = true;
                }
            }
        }
    }

    Component {
        id: favoritesContent
        ApplicationPage {
            id: favoritesPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelFavorites
            showSearch: false
            property variant model: MusicListModel {
                type: MusicListModel.ListofSongs
                limit: 0
                filter:MusicListModel.FilterFavorite // favorite
                sort:(settings.get("FavoriteView") == 1? MusicListModel.SortByAddedTime:MusicListModel.SortByTitle)
            }
            onSearch: {
               listView.model.search = needle;
                if (!needle ) {
                    listView.model.filter=MusicListModel.FilterFavorite
                }
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                {
                    if(applicationData == "playneedssongs")
                    {
                        playqueueModel.clear();
                        playqueueModel.addItems(model.getAllIDs());
                        playqueueView.currentIndex = 0;
                        Code.play();
                    }
                    scene.applicationData = undefined;
                }
            }
            menuContent:Rectangle{
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10
                Button {
                    id: azBt
                    title: labelAlphabetical
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        listView.model.sort = MusicListModel.SortByTitle;
                        settings.set("FavoriteView",0);
                        favoritesPage.closeMenu();
                    }
                }
                Button {
                    id: dateBt
                    title: labelDateOrder
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: azBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        listView.model.sort = MusicListModel.SortByAddedTime;
                        settings.set("FavoriteView",1);
                        favoritesPage.closeMenu();
                    }
                }
            }
            MusicListView {
                id: listView
                selectionMode: multiSelectMode
                parent:favoritesPage.content
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                width: parent.width
                height: parent.height
                model: favoritesPage.model
                onClicked :{
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            multibar.sharing.addItem(payload.muri);
                        else
                            multibar.sharing.delItem(payload.muri);
                    }
                    else
                    {
                        listView.currentIndex = model.itemIndex(payload.mitemid);
                        Code.addToPlayqueueAndPlay(payload);
                    }
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.visible = true;
                }
            }
        }
    }

    Component {
        id: artistDetailViewContent
        ApplicationPage {
            id: artistDetailViewPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelArtist
            showSearch: false
            property variant model: MusicListModel {
                type: MusicListModel.ListofAlbumsForArtist
                artist: labelArtist
                limit: 0
                sort:MusicListModel.SortByDefault
                onArtistChanged: {
                    numberOfAlbum = count;
                }
            }
            property bool showList: settings.get("ArtistDetailView") == 0

            onApplicationDataChanged: {
                if(applicationData != undefined)
                {
                    if(applicationData == "playneedssongs")
                    {
                        playqueueModel.clear();
                        playqueueModel.addItems(model.getAllIDs());
                        playqueueView.currentIndex = 0;
                        Code.play();
                    }
                    scene.applicationData = undefined;
                }
            }

            menuContent: Rectangle{
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10
                Button {
                    id: gridBt
                    title: labelGrid
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        artistDetailViewPage.showList = false;
                        settings.set("ArtistDetailView",1);
                        artistDetailViewPage.closeMenu();
                    }
                }
                Button {
                    id: listBt
                    title: labelList
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gridBt.bottom
                    anchors.topMargin: 10
                    onClicked: {
                        artistDetailViewPage.showList = true;
                        settings.set("ArtistDetailView",0);
                        artistDetailViewPage.closeMenu();
                    }
                }
            }
            MediaGridView {
                id: artistAlbumsGridView
                type: musictype // music app = 0
                parent:artistDetailViewPage.content
                clip: true
                model: artistDetailViewPage.model
                anchors.fill: parent
                cellWidth:(width- 15) / (scene.isLandscapeView() ? 7: 4)
                cellHeight: cellWidth
                anchors.leftMargin: 15
                anchors.topMargin:3
                visible: false
                defaultThumbnail: "image://theme/media/music_thumb_med"
                onClicked: {
                    if(payload.misvirtual) {
                        return;
                    }
                    Code.openItemInDetailView(artistDetailViewPage,payload)
                }

                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = artistDetailViewPage;
                    contextMenu.visible = true;
                }
            }


            ListView {
                id: artistAlbumsListView
                parent: artistDetailViewPage.content
                anchors.fill: parent
                clip: true
                model: artistDetailViewPage.model
                delegate: Item {
                    id: dinstance
                    width: artistAlbumsListView.width
                    height: Math.max(albumThumbnail.height, songsInAlbumList.height) + albumTitleText.height + 10

                    property string mthumburi: thumburi
                    property string mtitle: title
                    property string mitemid: itemid
                    property bool mfavorite: favorite
                    property string martist
                    property int mitemtype: itemtype
                    property bool misvirtual: isvirtual

                    martist: {
                        artist[0] == undefined? labelUnknownArtist:artist[0];
                    }

                    Text {
                        id: albumTitleText
                        height: 50
                        text: mtitle
                        font.bold:true
                        font.pixelSize: theme_fontPixelSizeLarge
                        color:theme_fontColorHighlight
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment:Text.AlignLeft
                        elide: Text.ElideRight
                        MouseArea {
                            anchors.fill:parent
                            onClicked:{
                                if(misvirtual) {
                                    return;
                                }
                                Code.openItemInDetailView(artistDetailViewPage,dinstance)
                            }
                        }
                    }

                    BorderImage {
                        id: albumThumbnail
                        border.left: 10; border.top: 10
                        border.right: 10; border.bottom: 10
                        width:400
                        height:width
                        source: "image://theme/media/music_border_lrg"
                        smooth:misvirtual? true: false
                        anchors.leftMargin: 15
                        RoundedItem {
                            anchors.fill: parent
                            radius: 8
                            clip: true
                            z: -10
                            Image {
                                anchors.fill: parent
                                fillMode:Image.PreserveAspectFit
                                source:misvirtual? "image://theme/media/music_default_album":thumburi
                            }
                        }

                        MouseArea {
                            anchors.fill:parent
                            onPressAndHold: {
                                musicContextMenu(mouseX, mouseY, dinstance,
                                    [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                                contextMenu.openpage = artistDetailViewPage;
                                contextMenu.visible = true;
                            }
                        }
                    }
                    MusicListView{
                        id: songsInAlbumList
                        selectionMode: multiSelectMode
                        height: 500
                        interactive: false
                        Component.onCompleted: {
                            height = model.count * 50 + titleBarHeight;
                        }
                        model: MusicListModel {
                            type: misvirtual? MusicListModel.ListofOrphanSongsForArtist: MusicListModel.ListofSongsForAlbum
                            artist: misvirtual? martist:""
                            album:misvirtual? "":mtitle
                            limit:0
                            sort:MusicListModel.SortByDefault
                        }
                        onClicked: {
                            if(multiSelectMode)
                            {
                                model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                                if (model.isSelected(payload.mitemid))
                                    multibar.sharing.addItem(payload.muri);
                                else
                                    multibar.sharing.delItem(payload.muri);
                            }
                            else
                            {
                                songsInAlbumList.currentIndex = model.itemIndex(payload.mitemid);
                                Code.addToPlayqueueAndPlay(payload);
                            }
                        }
                        onLongPressAndHold: {
                            musicContextMenu(mouseX, mouseY, payload,
                                [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                            multiSelectModel = model;
                            contextMenu.visible = true;
                        }
                    }

                    states: [
                        State {
                            name: "landscapeArtistDetailView"
                            when: scene.isLandscapeView()
                            PropertyChanges {
                                target: albumTitleText
                                anchors.leftMargin: 15
                                width: parent.width -15
                            }
                            PropertyChanges {
                                target: songsInAlbumList
                                anchors.margins: 3
                                width: parent.width - albumThumbnail.width - 21
                            }
                            AnchorChanges {
                                target: albumTitleText
                                anchors.top:parent.top
                                anchors.left:parent.left
                            }
                            AnchorChanges {
                                target: albumThumbnail
                                anchors.left:parent.left
                                anchors.top: albumTitleText.bottom
                            }
                            AnchorChanges {
                                target:songsInAlbumList
                                anchors.left:albumThumbnail.right
                                anchors.top:albumTitleText.bottom
                            }

                        },
                        State {
                            name: "portraitArtistDetailView"
                            when: !scene.isLandscapeView()
                            PropertyChanges {
                                target: albumTitleText
                                anchors.leftMargin: 15
                                width: parent.width - albumThumbnail.width - 5
                            }
                            PropertyChanges {
                                target: songsInAlbumList
                                width: parent.width - 5
                                anchors.margins: 3
                            }
                            PropertyChanges {
                                target: dinstance
                                height: albumThumbnail.height + songsInAlbumList.height + 30
                            }

                            AnchorChanges {
                                target: albumTitleText
                                anchors.top:parent.top
                                anchors.left:albumThumbnail.right
                            }
                            AnchorChanges {
                                target: albumThumbnail
                                anchors.left:parent.left
                                anchors.top: parent.top
                            }
                            AnchorChanges {
                                target:songsInAlbumList
                                anchors.left:parent.left
                                anchors.top:albumThumbnail.bottom
                            }
                        }
                    ]
                }
            }

            states: [
                State {
                    name: "listview"
                    when: artistDetailViewPage.showList
                    PropertyChanges {
                        target: artistAlbumsListView
                        visible: true
                    }
                    PropertyChanges {
                        target: artistAlbumsGridView
                        visible: false
                    }
                },
                State {
                    name: "gridview"
                    when: !artistDetailViewPage.showList
                    PropertyChanges {
                        target: artistAlbumsListView
                        visible: false
                    }
                    PropertyChanges {
                        target: artistAlbumsGridView
                        visible: true
                    }
                }
            ]

        }
    }

    Component {
        id:albumDetailViewContent
        ApplicationPage {
            id: albumDetailViewPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAlbum

            property variant model: MusicListModel {
                type: MusicListModel.ListofSongsForAlbum
                limit: 0
                sort:MusicListModel.SortByDefault
                album:labelAlbum
                onAlbumChanged: {
                    albumSongList.currentIndex = -1;
                }
            }
            onApplicationDataChanged: {
                if(applicationData != undefined)
                {
                    if(applicationData == "playneedssongs")
                    {
                        playqueueModel.clear();
                        playqueueModel.addItems(model.getAllIDs());
                        playqueueView.currentIndex = 0;
                        Code.play();
                    }
                    scene.applicationData = undefined;
                }
            }
            Item {
                id: box
                parent: albumDetailViewPage.content
                anchors.fill: parent

                Text {
                    id: tAlbum
                    text: labelAlbum
                    height:50
                    verticalAlignment:Text.AlignVCenter
                    horizontalAlignment:Text.AlignLeft
                    elide:Text.ElideRight
                    font.bold:true
                    font.pixelSize: theme_fontPixelSizeLarge
                    color:theme_fontColorHighlight
                }
                BorderImage {
                    id: albumThumbnail
                    border.left: 10; border.top: 10
                    border.right: 10; border.bottom: 10
                    width: 400
                    height: width
                    anchors.leftMargin: 15
                    source: "image://theme/media/music_border_lrg"
                    RoundedItem {
                        anchors.fill: parent
                        radius: 8
                        clip: true
                        z: -10
                        Image {
                            anchors.fill: parent
                            fillMode:Image.PreserveAspectFit
                            source:thumbnailUri
                        }
                    }

//                    MouseArea {
//                        anchors.fill:parent
//                        onPressAndHold: {
//                            var map = mapToItem(scene, mouseX, mouseY);
//                            // we don't have the instance to the current album item
//                            // so we take it from the side content, which has a ListOfAlbums,
//                            // and its current item is what we need.
//                            scene.openContextMenu(albumContextComponent, contextLoader, map.x, map.y, payloadItem,
//                                                  [labelPlay,labelAddToPlayQueue,labelAddToPlaylist,  payloadItem.mfavorite ? labelUnFavorite : labelFavorite,labelDelete]);
//                         }
//                    }
                }
                MusicListView{
                    id: albumSongList
                    selectionMode: multiSelectMode
                    model: albumDetailViewPage.model
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                            if (model.isSelected(payload.mitemid))
                                multibar.sharing.addItem(payload.muri);
                            else
                                multibar.sharing.delItem(payload.muri);
                        }
                        else
                        {
                            albumSongList.currentIndex = model.itemIndex(payload.mitemid);
                            Code.addToPlayqueueAndPlay(payload);
                        }
                    }
                    onLongPressAndHold: {
                        albumSongList.currentIndex = model.itemIndex(payload.mitemid);
                        musicContextMenu(mouseX, mouseY, payload,
                            [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                        multiSelectModel = model;
                        contextMenu.visible = true;
                    }
                }
            }
            states: [
                State {
                    name: "landscapeAlbumDetailsView"
                    when: scene.isLandscapeView()
                    PropertyChanges {
                        target: tAlbum
                        width: parent.width - 15
                        anchors.leftMargin: 15
                    }
                    PropertyChanges {
                        target: albumThumbnail
                        anchors.leftMargin:15
                    }
                    PropertyChanges {
                        target: albumSongList
                        anchors.margins:3
                        width: parent.width - albumThumbnail.width - 21
                        height: parent.height - tAlbum.height
                    }
                    AnchorChanges {
                        target: albumSongList
                        anchors.top: tAlbum.bottom
                        anchors.left:albumThumbnail.right
                    }
                    AnchorChanges {
                        target: albumThumbnail
                        anchors.left:parent.left
                        anchors.top:tAlbum.bottom
                    }
                    AnchorChanges {
                        target: tAlbum
                        anchors.left:parent.left
                        anchors.top:parent.top
                    }
                },
                State {
                    name: "portraitAlbumDetailView"
                    when: !scene.isLandscapeView()
                    PropertyChanges {
                        target: tAlbum
                        width: parent.width - albumThumbnail.width - 5
                        anchors.leftMargin: 5
                    }
                    PropertyChanges {
                        target: albumThumbnail
                        anchors.leftMargin:5
                    }
                    PropertyChanges {
                        target: albumSongList
                        anchors.margins:3
                        width: parent.width -5
                        height: parent.height - albumThumbnail.height
                    }
                    AnchorChanges {
                        target: albumSongList
                        anchors.top: albumThumbnail.bottom
                        anchors.left:parent.left
                    }
                    AnchorChanges {
                        target: albumThumbnail
                        anchors.left:parent.left
                        anchors.top:parent.top
                    }
                    AnchorChanges {
                        target: tAlbum
                        anchors.left:albumThumbnail.right
                        anchors.top:parent.top
                    }
                }

            ]

        }
    }


    Component {
        id: playlistDetailViewContent
        ApplicationPage {
            id: playlistDetailViewPage
            anchors.top:parent.top
            anchors.left: parent.left
            height: parent.height - toolbar.height
            width: parent.width
            title: labelAllPlaylist

            property alias model: playlistList.model
            onApplicationDataChanged: {
                if(applicationData != undefined)
                {
                    if(applicationData == "playneedssongs")
                    {
                        playqueueModel.clear();
                        playqueueModel.addItems(model.getAllIDs());
                        playqueueView.currentIndex = 0;
                        Code.play();
                    }
                    scene.applicationData = undefined;
                }
            }
            menuContent: Rectangle{
                visible: !multiSelectMode
                width: parent.width
                height: childrenRect.height + 20
                color:theme_appMenuBackgroundColor
                radius: 10
                Button {
                    id: renameListBt
                    title: labelRenamePlaylist
                    color: theme_buttonFontColor
                    width: parent.width -20
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    onClicked: {
                        // Rename playlist
                        scene.showModalDialog(renamePlaylistComponent);
                        dialogLoader.item.currTitle = labelPlaylist;
                        dialogLoader.item.urn = labelPlaylistURN;
                        dialogLoader.item.playListModel = playlistList.model;
                        playlistDetailViewPage.closeMenu();
                    }
                }
            }
            Item {
                id: box
                parent: playlistDetailViewPage.content
                anchors.fill: parent
                Text {
                    id: tPlaylist
                    text: labelPlaylist
                    height:50
                    verticalAlignment:Text.AlignVCenter
                    horizontalAlignment:Text.AlignLeft
                    elide:Text.ElideRight
                    font.bold:true
                    font.pixelSize: theme_fontPixelSizeLarge
                    color:theme_fontColorHighlight
                }

                BorderImage {
                    id: playlistThumbnail
                    border.left: 10; border.top: 10
                    border.right: 10; border.bottom: 10
                    width: 400
                    height: width
                    anchors.leftMargin: 15
                    source: "image://theme/media/music_border_lrg"
                    RoundedItem {
                        anchors.fill: parent
                        radius: 8
                        clip: true
                        z: -10
                        Image {
                            anchors.fill: parent
                            fillMode:Image.PreserveAspectFit
                            source:thumbnailUri
                        }
                    }
                }
                MusicListView {
                    id: playlistList
                    selectionMode: multiSelectMode
                    anchors.margins: 3
                    model: MusicListModel {
                        type: MusicListModel.MusicPlaylist
                        playlist: labelPlaylist
                        limit: 0
                        sort:MusicListModel.SortByCreationTime
                        onPlaylistChanged: {
                            numberOfTrack = count;
                            playlistList.currentIndex = -1;
                        }
                    }
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                            if (model.isSelected(payload.mitemid))
                                multibar.sharing.addItem(payload.muri);
                            else
                                multibar.sharing.delItem(payload.muri);
                        }
                        else
                        {
                            playlistList.currentIndex = model.itemIndex(payload.mitemid);
                            Code.addToPlayqueueAndPlay(payload);
                        }
                    }
                    onLongPressAndHold: {
                        musicContextMenu(mouseX, mouseY, payload,
                            [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelRemFromPlaylist]);
                        multiSelectModel = model;
                        contextMenu.playlistmodel = playlistList.model;
                        contextMenu.visible = true;
                    }
                }
            }
            states: [
                State {
                    name: "landscapePlaylistDetailView"
                    when: scene.isLandscapeView()
                    PropertyChanges {
                        target: tPlaylist
                        width:parent.width -15
                        anchors.leftMargin:15

                    }
                    PropertyChanges {
                        target: playlistThumbnail
                        anchors.leftMargin:15

                    }
                    PropertyChanges {
                        target: playlistList
                        width:parent.width - playlistThumbnail.width - 21
                        height:parent.height - tPlaylist.height
                    }
                    AnchorChanges {
                        target: playlistList
                        anchors.top: tPlaylist.bottom
                        anchors.left:playlistThumbnail.right
                    }

                    AnchorChanges {
                        target: playlistThumbnail
                        anchors.left:parent.left
                        anchors.top:tPlaylist.bottom
                    }

                    AnchorChanges {
                        target: tPlaylist
                        anchors.left:parent.left
                        anchors.top:parent.top
                    }
                },
                State {
                    name: "portraitPlaylistDetailView"
                    when: !scene.isLandscapeView()
                    PropertyChanges {
                        target: tPlaylist
                        width:parent.width - playlistThumbnail.width -5
                        anchors.leftMargin:5

                    }
                    PropertyChanges {
                        target: playlistThumbnail
                        anchors.leftMargin:5

                    }
                    PropertyChanges {
                        target: playlistList
                        width:parent.width - 5
                        height:parent.height - playlistThumbnail.height
                    }
                    AnchorChanges {
                        target: playlistList
                        anchors.top: playlistThumbnail.bottom
                        anchors.left:parent.left
                    }

                    AnchorChanges {
                        target: playlistThumbnail
                        anchors.left:parent.left
                        anchors.top: parent.top
                    }

                    AnchorChanges {
                        target: tPlaylist
                        anchors.left:playlistThumbnail.right
                        anchors.top:parent.top
                    }
                }
            ]
        }
    }
    MusicListView {
        id: playqueueView
        selectionMode: multiSelectMode
        parent:  parkingLot
        anchors.fill:parent
        model: playqueueModel
        onClicked:{
            if(multiSelectMode)
            {
                model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                if (model.isSelected(payload.mitemid))
                    multibar.sharing.addItem(payload.muri);
                else
                    multibar.sharing.delItem(payload.muri);
            }
            else
            {
                playqueueView.currentIndex = model.itemIndex(payload.mitemid);
                Code.playNewSong();
            }
        }
        onLongPressAndHold:{
            musicContextMenu(mouseX, mouseY, payload,
                [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlaylist, labelRemoveFromPlayQueue]);
            multiSelectModel = model;
            contextMenu.visible = true;
        }
    }
    MusicPicker{
        id: playlistPicker
        parent: content
        property variant payload;
        showPlaylists: true;
        showAlbums:false
        selectAlbumOrPlaylistOnly: true
        onAlbumOrPlaylistSelected: {
            miscModel.type = MusicListModel.MusicPlaylist;
            miscModel.clear();
            miscModel.playlist = albumOrPlaylist;
            miscModel.addItems(payload);
            miscModel.savePlaylist(albumOrPlaylist);
            if(multiSelectMode)
            {
                multiSelectModel.clearSelected();
                multibar.sharing.clearItems();
                multiSelectMode = false;
            }
        }
    }

    Item {
        id: parkingLot
        x: content.width
        y: content.y
        width: 0
        height: 0
        clip:true
    }

    MusicToolBar {
        id: toolbar
        parent:  content
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        audioItem: audio
        playing: false
        landscape: scene.isLandscapeView()
        onPlayNeedsSongs: {
            applicationData = "playneedssongs";
        }
    }

    MediaMultiBar {
        id: multibar
        parent:  content
        height: (multiSelectMode)?55:0
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        landscape: scene.isLandscapeView()
        showadd: true
        onCancelPressed: {
            sharing.clearItems();
            multiSelectModel.clearSelected();
            multiSelectMode = false;
        }
        onDeletePressed: {
            if(multiSelectModel.selectionCount() > 0)
                scene.showModalDialog(deleteMultipleItemsComponent);
        }
        onAddPressed: {
            if(multiSelectModel.selectionCount() > 0)
            {
                playlistPicker.payload = multiSelectModel.getSelectedIDs()
                playlistPicker.show();
            }
        }
    }

    Component.onDestruction: {
        Code.stop();
    }
}
