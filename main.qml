/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Media 0.1
import QtMultimediaKit 1.1
import MeeGo.App.Music.MusicPlugin 1.0
import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1
import "functions.js" as Code

Window {
    id: window
    property string labelPlayqueue: qsTr("Play queue")
    property string labelFavorites: qsTr("Favorites")
    property string labelMusicApp: qsTr("Music")
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
    property string labelOpenAlbum: qsTr("Open album")
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
    property string labelRemoveFromPlayQueue: qsTr("Remove from queue")
    property string labelCreate: qsTr("Create")
    property string labelSavePlaylist: qsTr("Save as playlist")
    property string labelClearPlayqueue: qsTr("Clear play queue")
    property string labelClearPlaylist: qsTr("Clear playlist")

    property string labelItemCount: qsTr("%1 items")
    property string labelAlbumCount: qsTr("%1 album")
    property string labelTrackCount: qsTr("%1 tracks")

    property string labelGrid: qsTr("Grid")
    property string labelList: qsTr("List")

    property string labelAlphabetical: qsTr("Alphabetically")
    property string labelDateOrder: qsTr("By date")

    property string labelCreateNewPlaylist: qsTr("Create new playlist")
    property string labelRenamePlaylist: qsTr("Rename playlist")

    property string labelConfirmDelete: qsTr("Delete")
    property string labelCancel: qsTr("Cancel")
    property string labelDefaultText:qsTr("Type playlist name here.")
    property string labelMultiSelect:qsTr("Select multiple songs")

    property string labelNoMusicText1:qsTr("Where is all the music?")
    property string labelNoMusicText2:qsTr("Buy, download or copy your music onto your table, then you can enjoy listening to it from here.")
    property string forbiddenchars: qsTr("\n\'\t\"\\");
    property string forbiddencharsDisplay: qsTr("<return>, <tab>, \', \", \\");
    property string defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"

    property int animationDuration: 500

    property string artistName: ""
    property int tabContentWidth: 300
    property int albumLength: 0
    property alias shuffle: toolbar.shuffle
    property alias loop: toolbar.loop

    property string thumbnailUri:""
    property bool multiSelectMode: false
    property variant multiSelectModel: allTracksModel

    property variant bookModel: [labelPlayqueue,labelAllPlaylist,labelFavorites,
                                 labelAllArtist,labelAllAlbums,labelAllTracks]
    property variant bookPayload: [playQueueContent,playlistsContent,favoritesContent,
                                   artistsContent,albumsContent,allTracksContent]
    bookMenuModel: bookModel
    bookMenuPayload: bookPayload

    onMultiSelectModeChanged: {
        if(multiSelectMode)
            window.setBookMenuData([], []);
        else
            window.setBookMenuData(bookModel, bookPayload);
    }

    ShareObj {
        id: shareObj
        shareType: MeeGoUXSharingClientQmlObj.ShareTypeAudio
    }

    property variant allTracksModel: MusicListModel {
        type: MusicListModel.ListofSongs
        sort:MusicListModel.SortByDefault
        limit: 0
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
        property int songnum: 0
        onItemAvailable: {
            var thetitle;
            if(editorModel.isURN(identifier))
            {
                remoteControlItem.mitemid = editorModel.datafromURN(identifier, MediaItem.ID);
                remoteControlItem.mitemtype = editorModel.datafromURN(identifier, MediaItem.ItemType);
                thetitle = editorModel.datafromURN(identifier, MediaItem.Title);
            }
            else
            {
                remoteControlItem.mitemid = identifier;
                remoteControlItem.mitemtype = editorModel.datafromID(identifier, MediaItem.ItemType);
                thetitle = editorModel.datafromID(identifier, MediaItem.Title);
            }
            if (remoteControlItem.mitemtype == MediaItem.SongItem) {
                console.log("song loaded");
                Code.addToPlayqueueAndPlay(remoteControlItem);
            }else if (remoteControlItem.mitemtype == MediaItem.MusicArtistItem) {
                labelArtist = thetitle;
                thumbnailUri = editorModel.datafromURN(identifier, MediaItem.ThumbURI)
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                console.log("artist loaded: " + labelArtist + ", " + thumbnailUri);
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(artistDetailViewContent);
            }else if (remoteControlItem.mitemtype == MediaItem.MusicAlbumItem) {
                labelAlbum = thetitle;
                labelArtist = editorModel.datafromURN(identifier, MediaItem.Artist)[0];
                thumbnailUri = editorModel.datafromURN(identifier, MediaItem.ThumbURI)
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                console.log("album loaded: " + labelAlbum + ", " + thumbnailUri);
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(albumDetailViewContent);
            }else if (remoteControlItem.mitemtype == MediaItem.MusicPlaylistItem) {
                labelPlaylist = thetitle;
                labelPlaylistURN = identifier;
                thumbnailUri = editorModel.datafromURN(identifier, MediaItem.ThumbURI)
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                console.log("playlist loaded: " + labelPlaylist + ", " + thumbnailUri);
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(playlistDetailViewContent);
            }
        }
        onSongItemAvailable: {
            remoteControlItem.mitemid = editorModel.datafromURN(identifier, MediaItem.ID);
            remoteControlItem.mitemtype = MediaItem.SongItem;
            if(songnum == 0)
                Code.addToPlayqueueAndPlay(remoteControlItem);
            else
                Code.addToPlayqueue(remoteControlItem);
            songnum++
        }
    }

    property variant playlistEditor: MusicListModel {
        type: MusicListModel.MusicPlaylist
        limit: 0
        sort: MusicListModel.SortByDefault
    }

    QmlSetting{
        id: settings
        organization: "MeeGo"
        application:"meego-app-music"
    }

    Connections {
        target: mainWindow
        onCall: {
            editorModel.songnum = 0;
            var cmd = parameters[0];
            var cdata = parameters[1];
            if (cmd == "play") {
                Code.play();
            } else if (cmd == "pause") {
                Code.pause();
            } else if (cmd == "stop") {
                Code.stop();
            } else if (cmd == "playSong") {
                editorModel.requestItem(MediaItem.SongItem, cdata);
            } else if (cmd == "playArtist") {
                editorModel.requestItem(MediaItem.MusicArtistItem, cdata);
            } else if (cmd == "playAlbum") {
                editorModel.requestItem(MediaItem.MusicAlbumItem, cdata);
            } else if (cmd == "playPlaylist") {
                editorModel.requestItem(MediaItem.MusicPlaylistItem, cdata);
            }
        }
    }
    QtObject {
        id: remoteControlItem
        property string mitemid
        property string mitemtype
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
            dbusControl.nowNextTracks = newNowNext;
        }
        onStateChanged: {
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

    Timer {
        id: startupTimer
        interval: 2000
        repeat: false
    }

    Component.onCompleted: {
        switchBook(allTracksContent);
        startupTimer.start();
    }

    function musicContextMenu(mouseX, mouseY, payload, entrylist)
    {
        var map = payload.mapToItem(topItem.topItem, mouseX, mouseY);
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
        contextMenu.model = ctxList;
        contextMenu.payload = payload;
        topItem.calcTopParent();
        contextMenu.setPosition( map.x, map.y );
    }

    function addToPlaylist(payload, title, uri, thumbUri, type)
    {
        playlistEditor.clear();
        playlistEditor.playlist = title;
        playlistEditor.addItems(payload);
        playlistEditor.savePlaylist(title);
        if(multiSelectMode)
        {
            multiSelectModel.clearSelected();
            shareObj.clearItems();
            multiSelectMode = false;
        }
    }

    overlayItem: Item {
        id: globalItems
        z: 1000
        anchors.fill: parent

        MusicToolBar {
            id: toolbar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            audioItem: audio
            playing: false
            landscape: window.inLandscape
        }

        MediaMultiBar {
            id: multibar
            height: 55
            opacity: 0
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            landscape: window.inLandscape
            showadd: true
            onCancelPressed: {
                multiSelectModel.clearSelected();
                shareObj.clearItems();
                multiSelectMode = false;
            }
            onDeletePressed: {
                if(multiSelectModel.selectionCount() > 0)
                {
                    deleteMultipleItemsDialog.deletecount = multiSelectModel.selectionCount();
                    deleteMultipleItemsDialog.show();
                }
            }
            onAddPressed: {
                if(multiSelectModel.selectionCount() > 0)
                {
                    playlistPicker.okclicked = false;
                    playlistPicker.payload = multiSelectModel.getSelectedIDs()
                    playlistPicker.show();
                }
            }
            onSharePressed: {
                if(shareObj.shareCount > 0)
                {
                    var map = mapToItem(topItem.topItem, fingerX, fingerY);
                    contextShareMenu.model = shareObj.serviceTypes;
                    topItem.calcTopParent()
                    contextShareMenu.setPosition( map.x, map.y );
                    contextShareMenu.show();
                }
            }
            states: [
                State {
                    name: "showActionBar"
                    when: multiSelectMode
                    PropertyChanges {
                        target: multibar
                        opacity:1
                    }
                    PropertyChanges {
                        target: toolbar
                        opacity:0
                    }
                },
                State {
                    name: "hideActionBar"
                    when: !multiSelectMode
                    PropertyChanges {
                        target: multibar
                        opacity: 0
                    }
                    PropertyChanges {
                        target: toolbar
                        opacity:1
                    }
                }
            ]

            transitions: [
                Transition {
                    reversible: true
                    ParallelAnimation{
                        PropertyAnimation {
                            target: multibar
                            property: "opacity"
                            duration: 250
                        }
                        PropertyAnimation {
                            target: toolbar
                            property: "opacity"
                            duration: 250
                        }
                    }
                }
            ]
        }

        MusicPicker{
            id: playlistPicker
            property bool okclicked: false
            property variant payload: []
            showPlaylists: true
            showAlbums:false
            onAlbumOrPlaylistSelected: {
                if(!okclicked)
                {
                    okclicked = true;
                    addToPlaylist(payload, title, uri, thumbUri, type);
                }
            }
        }

        ModalDialog {
            id: deleteItemDialog
            title: labelDelete
            acceptButtonText: labelConfirmDelete
            cancelButtonText:labelCancel
            property variant payload
            onPayloadChanged:{
                deleteItemContents.artist = payload.martist;
                deleteItemContents.track = payload.mtitle;
            }
            onAccepted: {
                console.log(payload.muri);
                editorModel.destroyItemByID(payload.mitemid);
            }
            content: Item {
                id: deleteItemContents
                anchors.fill: parent
                property alias artist : artistName.text
                property alias track : trackName.text
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
                    text: qsTr("If you delete this, it will be removed from your device")
                    anchors.top:trackName.bottom
                    width:  parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: theme_fontPixelSizeMedium
                }
            }
        }

        ModalDialog {
            id: deleteMultipleItemsDialog
            property int deletecount: multiSelectModel.selectionCount()
            title: (deletecount < 2)?qsTr("Permanently delete this song?"):qsTr("Permanently delete these %1 songs?").arg(deletecount)
            acceptButtonText: labelConfirmDelete
            cancelButtonText: labelCancel
            onAccepted: {
                multiSelectModel.destroyItemsByID(multiSelectModel.getSelectedIDs());
                multiSelectModel.clearSelected();
                shareObj.clearItems();
                multiSelectMode = false;
            }
            content: Item {
                anchors.fill: parent
                clip: true
                Text {
                    text: qsTr("If you delete these, they will be removed from your device")
                    anchors.verticalCenter:parent.verticalCenter
                    width:  parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: theme_fontPixelSizeMedium
                }
            }
        }

        ModalDialog {
            id: createPlaylistDialog
            title:labelCreateNewPlaylist
            cancelButtonText:labelCancel
            acceptButtonText:labelCreate
            z: 1000
            property string playlistTitle: ""
            property bool isvalid: true
            onAccepted: {
                if(isvalid) {
                    playlistEditor.clear();
                    playlistEditor.savePlaylist(playlistTitle);
                }
            }
            content: Item{
                anchors.fill: parent
                TextEntry{
                    id: editorCreate
                    width: parent.width
                    anchors.top: parent.top
                    height: 50
                    focus: true
                    defaultText: labelDefaultText
                    onTextChanged: {
                        createPlaylistDialog.playlistTitle = text;
                        createPlaylistDialog.isvalid = Code.playlistNameValidate(text, forbiddenchars);
                    }
                }
                Text{
                    visible: !createPlaylistDialog.isvalid
                    width: parent.width
                    height: 50
                    font.pixelSize: theme_fontPixelSizeLarge
                    color: "red"
                    anchors.top: editorCreate.bottom
                    text: qsTr("Invalid characters: %1").arg(forbiddencharsDisplay);
                    wrapMode: Text.WordWrap
                }
            }
        }

        ModalDialog {
            id: renamePlaylistDialog
            title:labelRenamePlaylist
            cancelButtonText:labelCancel
            acceptButtonText:labelRename
            property string currTitle: ""
            property string urn: ""
            property string newTitle: ""
            property variant playListModel
            property bool isvalid: true
            onAccepted: {
                if(isvalid) {
                    playListModel.changeTitleByURN(urn, newTitle);
                    labelPlaylist = newTitle;
                }
            }
            content: Item {
                anchors.fill: parent
                TextEntry{
                    id: editorRename
                    width: parent.width
                    anchors.top: parent.top
                    height: 50
                    focus: true
                    text: renamePlaylistDialog.currTitle
                    onTextChanged: {
                        renamePlaylistDialog.newTitle = text;
                        renamePlaylistDialog.isvalid = Code.playlistNameValidate(text, forbiddenchars);
                    }
                }
                Text{
                    visible: !renamePlaylistDialog.isvalid
                    width: parent.width
                    height: 50
                    font.pixelSize: theme_fontPixelSizeLarge
                    color: "red"
                    anchors.top: editorRename.bottom
                    text: qsTr("Invalid characters: %1").arg(forbiddencharsDisplay);
                    wrapMode: Text.WordWrap
                }
            }
        }

        ModalDialog {
            id: playqueuePlaylistDialog
            title:labelCreateNewPlaylist
            cancelButtonText:labelCancel
            acceptButtonText:labelCreate
            property string playlistTitle: ""
            onAccepted: {
                playlistEditor.clear();
                playlistEditor.addItems(playqueueModel.getAllIDs());
                playlistEditor.savePlaylist(playlistTitle);
            }
            content: Item{
                anchors.fill: parent
                TextEntry{
                    width: parent.width
                    height: 50
                    focus: true
                    defaultText: labelDefaultText
                    onTextChanged: {
                        playqueuePlaylistDialog.playlistTitle = text
                    }
                }
            }
        }

        ContextMenu {
            id: contextShareMenu
            property alias model: contextShareActionMenu.model
            content: ActionMenu {
                id: contextShareActionMenu
                onTriggered: {
                    var svcTypes = shareObj.serviceTypes;
                    for (x in svcTypes) {
                        if (model[index] == svcTypes[x]) {
                            shareObj.showContext(model[index], contextShareMenu.x, contextShareMenu.y);
                            break;
                        }
                    }
                    contextMenu.hide();
                }
            }
        }

        ContextMenu {
            id: contextMenu
            property alias payload: contextActionMenu.payload
            property alias model: contextActionMenu.model
            property variant shareModel: []
            property variant openpage
            property variant playlistmodel
            content: ActionMenu {
                id: contextActionMenu
                property variant payload: undefined
                onTriggered: {
                    if (model[index] == labelPlay)
                    {
                        // Play
                        if(!multiSelectMode)
                            Code.addToPlayqueueAndPlay(payload);
                        else if(multiSelectModel.selectionCount() > 0)
                            Code.addMultipleToPlayqueueAndPlay(multiSelectModel);
                        contextMenu.hide();
                    }
                    else if (model[index] == labelOpen)
                    {
                        // Open
                        Code.openItemInDetailView(contextMenu.openpage,payload);
                        contextMenu.hide();
                    }
                    else if ((model[index] == labelFavorite)||(model[index] == labelUnFavorite))
                    {
                        // Favorite/unfavorite
                        if(!multiSelectMode)
                            Code.changeItemFavorite(payload, (model[index] == labelFavorite));
                        else if(multiSelectModel.selectionCount() > 0)
                            Code.changeMultipleItemFavorite(multiSelectModel, (model[index] == labelFavorite));
                        contextMenu.hide();
                    }
                    else if (model[index] == labelAddToPlayQueue)
                    {
                        // Add to play queue
                        if(!multiSelectMode)
                            Code.addToPlayqueue(payload);
                        else if(multiSelectModel.selectionCount() > 0)
                            Code.addMultipleToPlayqueue(multiSelectModel);
                        contextMenu.hide();
                    }
                    else if (model[index] == labelRemoveFromPlayQueue)
                    {
                        // Remove from play queue
                        if(!multiSelectMode)
                            Code.removeFromPlayqueue(payload);
                        else if(multiSelectModel.selectionCount() > 0)
                            Code.removeMultipleFromPlayqueue(multiSelectModel);
                        contextMenu.hide();
                    }
                    else if (model[index] == labelAddToPlaylist)
                    {
                        // Add to a play list
                        if(!multiSelectMode)
                        {
                            playlistPicker.okclicked = false;
                            playlistPicker.payload = [payload.mitemid];
                            playlistPicker.show();
                        }
                        else if(multiSelectModel.selectionCount() > 0)
                        {
                            playlistPicker.okclicked = false;
                            playlistPicker.payload = multiSelectModel.getSelectedIDs()
                            playlistPicker.show();
                        }
                        contextMenu.hide();
                    }
                    else if (model[index] == labelRemFromPlaylist)
                    {
                        // Remove from a play list
                        if(!multiSelectMode)
                        {
                            contextMenu.playlistmodel.removeItems(payload.mitemid);
                            contextMenu.playlistmodel.savePlaylist(contextMenu.playlistmodel.playlist);
                        }
                        else if(multiSelectModel.selectionCount() > 0)
                        {
                            contextMenu.playlistmodel.removeItems(multiSelectModel.getSelectedIDs());
                            contextMenu.playlistmodel.savePlaylist(contextMenu.playlistmodel.playlist);
                            multiSelectModel.clearSelected();
                            shareObj.clearItems();
                            multiSelectMode = false;
                        }
                        contextMenu.hide();
                    }
                    else if (model[index] == labelClearPlaylist)
                    {
                        // Clear a play list
                        playlistEditor.playlist = payload.mtitle;
                        playlistEditor.clear();
                        playlistEditor.savePlaylist(payload.mtitle);
                        contextMenu.hide();
                    }
                    else if (model[index] == labelRenamePlaylist)
                    {
                        // Rename playlist
                        renamePlaylistDialog.currTitle = payload.mtitle;
                        renamePlaylistDialog.urn = payload.murn;
                        renamePlaylistDialog.playListModel = contextMenu.playlistmodel;
                        renamePlaylistDialog.show();
                        contextMenu.hide();
                    }
                    else if (model[index] == labelDelete)
                    {
                        // Delete
                        if(!multiSelectMode)
                        {
                            deleteItemDialog.payload = payload;
                            deleteItemDialog.show();
                        }
                        else if(multiSelectModel.selectionCount() > 0)
                        {
                            deleteMultipleItemsDialog.deletecount = multiSelectModel.selectionCount();
                            deleteMultipleItemsDialog.show();
                        }
                        contextMenu.hide();
                    }
                    else if (model[index] == labelMultiSelect)
                    {
                        // Multi Select
                        multiSelectMode = true;
                        contextMenu.hide();
                    }
                    else if (model[index] == labelcShare)
                    {
                        // Share
                        shareObj.clearItems();
                        if(!multiSelectMode)
                        {
                            shareObj.addItem(payload.muri) // URI
                        }
                        else if(multiSelectModel.selectionCount() > 0)
                        {
                            shareObj.addItems(multiSelectModel.getSelectedURIs()) // URIs
                        }
                        contextMenu.shareModel = shareObj.serviceTypes;
                        contextMenu.shareModel = contextMenu.shareModel.concat(labelCancel);
                        contextMenu.subMenuModel = contextMenu.shareModel;
                        contextMenu.subMenuPayload = contextMenu.shareModel;
                        contextMenu.subMenuVisible = true;
                    }
                }
            }
            onSubMenuTriggered: {
                if (shareModel[index] == labelCancel)
                {
                    contextMenu.subMenuVisible = false;
                }
                else
                {
                    var svcTypes = shareObj.serviceTypes;
                    for (x in svcTypes) {
                        if (shareModel[index] == svcTypes[x]) {
                            shareObj.showContext(shareModel[index], contextMenu.x, contextMenu.y);
                            break;
                        }
                    }
                    contextMenu.hide();
                }
            }
        }

        TopItem { id: topItem }
    }

    Component {
        id: playQueueContent
        AppPage {
            id: playQueuePage
            anchors.fill: parent
            pageTitle: labelPlayqueue
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            actionMenuModel: [labelSavePlaylist, labelClearPlayqueue]
            actionMenuPayload: ["save", "clear"]
            onActionMenuTriggered: {
                if(selectedItem == "save")
                {
                    playqueuePlaylistDialog.show();
                }
                else if(selectedItem == "clear")
                {
                    Code.stop();
                    playqueueModel.clear();
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }

            Connections {
                target: window
                onSearch: {
                    playqueueView.model.search = needle;
                }
            }

            Component.onCompleted: {
                playqueueView.parent = playQueuePage;
            }
            Component.onDestruction: {
                playqueueView.parent = parkingLot;
            }
        }
    }

    Component {
        id:playlistsContent
        AppPage {
            id: playlistsPage
            anchors.fill: parent
            pageTitle: labelAllPlaylist
            property bool showGridView: settings.get("PlaylistsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            Connections {
                target: window
                onSearch: {
                    gridView.model.search = needle;
                }
            }
            actionMenuModel: [labelNewList, labelGrid, labelList]
            actionMenuPayload: ["new", "grid", "list"]
            onActionMenuTriggered: {
                if(selectedItem == "new")
                {
                    createPlaylistDialog.show();
                }
                else if(selectedItem == "grid")
                {
                    showGridView = true;
                    settings.set("PlaylistsView",0);
                }
                else if(selectedItem == "list")
                {
                    showGridView = false;
                    settings.set("PlaylistsView",1);
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((gridView.model.total == 0)&&(allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }
            MusicListView {
                anchors.fill: parent
                model:gridView.model
                mode : 1
                footerHeight: toolbar.height
                visible: !showGridView
                onClicked: {
                     Code.openItemInDetailView(playlistsPage,payload);
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelRenamePlaylist, labelClearPlaylist, labelDelete]);
                    contextMenu.openpage = playlistsPage;
                    contextMenu.playlistmodel = gridView.model;
                    contextMenu.show();
                }
            }


            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                anchors.fill: parent
                cellWidth: ((width- 15) / (window.inLandscape ? 7: 4))
                cellHeight: cellWidth
                visible:showGridView
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"
                footerHeight: toolbar.height
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
                    contextMenu.show();
                }
            }
        }
    }

    Component {
        id: artistsContent
        AppPage {
            id: artistsPage
            anchors.fill: parent
            pageTitle: labelAllArtist
            property bool showGridView: settings.get("AllArtistsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            Connections {
                target: window
                onSearch: {
                    artistsGridView.model.search = needle;
                }
            }
            actionMenuModel: [labelGrid, labelList]
            actionMenuPayload: ["grid", "list"]
            onActionMenuTriggered: {
                if(selectedItem == "grid")
                {
                    showGridView = true;
                    settings.set("AllArtistsView",0);
                }
                else if(selectedItem == "list")
                {
                    showGridView= false;
                    settings.set("AllArtistsView",1);
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }
            MusicListView {
                id: artistsListView
                anchors.fill:parent
                visible: !showGridView
                model:artistsGridView.model
                mode: 2
                footerHeight: toolbar.height
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
                    contextMenu.show();
                }
            }
            MediaGridView {
                id: artistsGridView
                type: musictype // music app = 0
                anchors.fill: parent
                visible: showGridView
                cellWidth:(width- 15) / (window.inLandscape ? 7: 4)
                cellHeight: cellWidth
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"
                footerHeight: toolbar.height
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
                    contextMenu.show();
                }
            }
        }
    }

    Component {
        id:albumsContent
        AppPage {
            id: albumsPage
            anchors.fill: parent
            pageTitle: labelAllAlbums
            property bool showGridView: settings.get("AllAlbumsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            Connections {
                target: window
                onSearch: {
                    albumsGridView.model.search = needle;
                }
            }
            actionMenuModel: [labelGrid, labelList]
            actionMenuPayload: ["grid", "list"]
            onActionMenuTriggered: {
                if(selectedItem == "grid")
                {
                    showGridView = true;
                    settings.set("AllAlbumsView",0);
                }
                else if(selectedItem == "list")
                {
                    showGridView= false;
                    settings.set("AllAlbumsView",1);
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }
            MusicListView {
                id: albumsListView
                anchors.fill:parent
                visible: !showGridView
                model:albumsGridView.model
                mode: 3
                footerHeight: toolbar.height
                onClicked: {
                    labelArtist = payload.martist;
                    Code.openItemInDetailView(albumsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.show();
                }
            }

            MediaGridView {
                id: albumsGridView
                type: musictype // music app = 0
                anchors.fill: parent
                visible: showGridView
                cellWidth:(width- 15) / (window.inLandscape ? 7: 4)
                cellHeight: cellWidth
                anchors.leftMargin: 15
                anchors.topMargin:3
                defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"
                footerHeight: toolbar.height
                model: MusicListModel {
                    type: MusicListModel.ListofAlbums
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    labelArtist = payload.martist;
                    Code.openItemInDetailView(albumsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload);
                }
                onLongPressAndHold: {
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.show();
                }
            }
        }
    }

    Component {
        id: allTracksContent
        AppPage {
            id: allTracksPage
            anchors.fill: parent
            pageTitle: labelAllTracks
            property bool showGridView: settings.get("AllTracksView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            Connections {
                target: window
                onSearch: {
                   listview.model.search = needle;
                }
            }
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(listview.model.getAllIDs());
                    playqueueView.currentIndex = 0;
                    Code.play();
                }
            }
            actionMenuModel: [labelGrid, labelList]
            actionMenuPayload: ["grid", "list"]
            onActionMenuTriggered: {
                if(selectedItem == "grid")
                {
                    showGridView = true;
                    settings.set("AllTracksView",0);
                }
                else if(selectedItem == "list")
                {
                    showGridView= false;
                    settings.set("AllTracksView",1);
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }
            MusicListView {
                id: listview
                selectionMode: multiSelectMode
                anchors.fill:parent
                visible: !showGridView
                model: allTracksModel
                footerHeight: toolbar.height
                onClicked: {
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            shareObj.addItem(payload.muri);
                        else
                            shareObj.delItem(payload.muri);
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
                    contextMenu.show();
                }
            }
            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                selectionMode: multiSelectMode
                anchors.fill:parent
                visible: showGridView
                cellWidth:(width- 15) / (window.inLandscape ? 7: 4)
                cellHeight: cellWidth
                model: listview.model
                anchors.leftMargin: 15
                anchors.topMargin:3
                footerHeight: toolbar.height
                defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"
                onClicked: {
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            shareObj.addItem(payload.muri);
                        else
                            shareObj.delItem(payload.muri);
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
                    contextMenu.show();
                }
            }
        }
    }

    Component {
        id: favoritesContent
        AppPage {
            id: favoritesPage
            anchors.fill: parent
            pageTitle: labelFavorites
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
            }
            onDeactivated : { infocus = false; }
            property variant model: MusicListModel {
                type: MusicListModel.ListofSongs
                limit: 0
                filter:MusicListModel.FilterFavorite // favorite
                sort:(settings.get("FavoriteView") == 1? MusicListModel.SortByAddedTime:MusicListModel.SortByTitle)
            }
            Connections {
                target: window
                onSearch: {
                   listView.model.search = needle;
                    if (!needle ) {
                        listView.model.filter=MusicListModel.FilterFavorite
                    }
                }
            }
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueView.currentIndex = 0;
                    Code.play();
                }
            }
            actionMenuModel: [labelAlphabetical, labelDateOrder]
            actionMenuPayload: ["title", "date"]
            onActionMenuTriggered: {
                if(selectedItem == "title")
                {
                    listView.model.sort = MusicListModel.SortByTitle;
                    settings.set("FavoriteView",0);
                }
                else if(selectedItem == "date")
                {
                    listView.model.sort = MusicListModel.SortByAddedTime;
                    settings.set("FavoriteView",1);
                }
            }
            Item {
                id: noMusicScreen
                anchors.centerIn: parent
                height: parent.height/2
                width: (window.inLandscape)?(parent.width/2):(parent.width/1.2)
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                Text {
                    id: noMusicScreenText1
                    width: parent.width
                    text: labelNoMusicText1
                    font.pixelSize: window.height/17
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: noMusicScreenText2
                    width: parent.width
                    text: labelNoMusicText2
                    font.pixelSize: window.height/21
                    anchors.top: noMusicScreenText1.bottom
                    anchors.topMargin: window.height/24
                    wrapMode: Text.WordWrap
                }
            }
            MusicListView {
                id: listView
                selectionMode: multiSelectMode
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                width: parent.width
                height: parent.height
                model: favoritesPage.model
                footerHeight: toolbar.height
                onClicked :{
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                            shareObj.addItem(payload.muri);
                        else
                            shareObj.delItem(payload.muri);
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
                    contextMenu.show();
                }
            }
        }
    }

    Component {
        id: artistDetailViewContent
        AppPage {
            id: artistDetailViewPage
            anchors.fill: parent
            pageTitle: labelArtist
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
            }
            onDeactivated : { infocus = false; }
            property variant model: MusicListModel {
                type: MusicListModel.ListofAlbumsForArtist
                artist: labelArtist
                limit: 0
                sort:MusicListModel.SortByDefault
            }
            property bool showList: settings.get("ArtistDetailView") == 0

            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueView.currentIndex = 0;
                    Code.play();
                }
            }
            actionMenuModel: [labelGrid, labelList]
            actionMenuPayload: ["grid", "list"]
            onActionMenuTriggered: {
                if(selectedItem == "grid")
                {
                    artistDetailViewPage.showList = false;
                    settings.set("ArtistDetailView",1);
                }
                else if(selectedItem == "list")
                {
                    artistDetailViewPage.showList = true;
                    settings.set("ArtistDetailView",0);
                }
            }
            Image {
                id: artistDetailViewMain
                anchors.fill: parent
                fillMode: Image.Tile
                source: "image://meegotheme/images/bg_application_p"
                BorderImage {
                    id: artistTitleText
                    width: parent.width
                    source: (window.inLandscape)?"image://meegotheme/images/media/subtitle_landscape_bar":"image://theme/media/subtitle_portrait_bar"
                    Text {
                        text: labelArtist
                        font.pixelSize: theme_fontPixelSizeLarge
                        anchors.fill: parent
                        color:theme_fontColorNormal
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment:Text.AlignLeft
                        elide: Text.ElideRight
                        anchors.leftMargin: 50
                    }
                }

                MediaGridView {
                    id: artistAlbumsGridView
                    type: musictype // music app = 0
                    clip: true
                    model: artistDetailViewPage.model
                    width: parent.width
                    height: parent.height - artistTitleText.height
                    anchors.top: artistTitleText.bottom
                    cellWidth:(width- 15) / (window.inLandscape ? 7: 4)
                    cellHeight: cellWidth
                    anchors.leftMargin: 15
                    anchors.topMargin:3
                    visible: false
                    footerHeight: toolbar.height
                    defaultThumbnail: "image://meegotheme/images/media/music_thumb_med"
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
                        contextMenu.show();
                    }
                }


                ListView {
                    id: artistAlbumsListView
                    width: parent.width
                    height: parent.height - artistTitleText.height
                    anchors.top: artistTitleText.bottom
                    clip: true
                    model: artistDetailViewPage.model
                    boundsBehavior: Flickable.StopAtBounds
                    footer: Item{
                        width: artistAlbumsListView.width
                        height: toolbar.height
                    }
                    delegate: Item {
                        id: dinstance
                        width: artistAlbumsListView.width
                        height: Math.max(albumDetailBackground.height, songsInAlbumList.height)

                        property string mthumburi: thumburi
                        property string mtitle: title
                        property string mitemid: itemid
                        property bool mfavorite: favorite
                        property string martist
                        property int mitemtype: itemtype
                        property bool misvirtual: isvirtual
                        property int mlength: length

                        martist: {
                            artist[0] == undefined? labelUnknownArtist:artist[0];
                        }

                        BorderImage {
                            id: albumDetailBackground
                            source: "image://meegotheme/widgets/apps/media/gradient-albumview"
                            Item {
                                id: albumDetailText
                                height: albumThumbnail.height/3
                                width: albumThumbnail.width
                                Item {
                                    id: albumDetailTextContainer
                                    anchors.centerIn: parent
                                    height: albumThumbnail.height/3
                                    width: (parent.width*3)/4
                                    Text {
                                        id: albumTitleText
                                        anchors.top: parent.top
                                        height: albumThumbnail.height/9
                                        width: parent.width
                                        text: mtitle
                                        color: theme_fontColorMediaHighlight
                                        font.pixelSize: theme_fontPixelSizeLarge
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        id: albumTrackcountText
                                        anchors.top: albumTitleText.bottom
                                        height: albumThumbnail.height/10
                                        width: parent.width
                                        text: qsTr("%1 songs").arg(tracknum)
                                        color: theme_fontColorMediaHighlight
                                        font.pixelSize: theme_fontPixelSizeLarge-3
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        id: albumLengthText
                                        anchors.top: albumTrackcountText.bottom
                                        height: albumThumbnail.height/10
                                        width: parent.width
                                        text: (length < 60)?(qsTr("%1 seconds").arg(Code.formatLength(length))):
                                                ((length < 3600)?(qsTr("%1 minutes").arg(Code.formatLength(length/60))):
                                                 (qsTr("%1 hours").arg(Code.formatLength(length/3600))))
                                        color: theme_fontColorMediaHighlight
                                        font.pixelSize: theme_fontPixelSizeLarge-3
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            BorderImage {
                                id: albumThumbnail
                                border.left: 10; border.top: 10
                                border.right: 10; border.bottom: 10
                                width:400
                                height:width
                                source: "image://meegotheme/images/media/music_border_lrg"
                                smooth:misvirtual? true: false
                                anchors.leftMargin: 15
                                Image {
                                    z: -10
                                    anchors.fill: parent
                                    fillMode:Image.PreserveAspectFit
                                    source:(thumburi == ""|thumburi == undefined)?"image://meegotheme/images/media/music_thumb_med":thumburi
                                }

                                MouseArea {
                                    anchors.fill:parent
                                    onClicked:{
                                        if(misvirtual) {
                                            return;
                                        }
                                        Code.openItemInDetailView(artistDetailViewPage,dinstance)
                                    }
                                    onPressAndHold: {
                                        musicContextMenu(mouseX, mouseY, dinstance,
                                            [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                                        contextMenu.openpage = artistDetailViewPage;
                                        contextMenu.show();
                                    }
                                }
                            }
                        }
                        MusicListView{
                            id: songsInAlbumList
                            selectionMode: multiSelectMode
                            height: 500
                            interactive: false
                            footerHeight: toolbar.height
                            Component.onCompleted: {
                                height = model.count * 50 + titleBarHeight;
                            }
                            model: MusicListModel {
                                type: misvirtual? MusicListModel.ListofOrphanSongsForArtist: MusicListModel.ListofSongsForAlbum
                                artist: misvirtual? martist:""
                                album:misvirtual? "":mtitle
                                limit:0
                                sort:MusicListModel.SortByDefault
                                onCountChanged: {
                                    songsInAlbumList.height = count * 50 + songsInAlbumList.titleBarHeight;
                                }
                            }
                            onClicked: {
                                if(multiSelectMode)
                                {
                                    model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                                    if (model.isSelected(payload.mitemid))
                                        shareObj.addItem(payload.muri);
                                    else
                                        shareObj.delItem(payload.muri);
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
                                contextMenu.show();
                            }
                        }

                        states: [
                            State {
                                name: "landscapeArtistDetailView"
                                when: window.inLandscape
                                PropertyChanges {
                                    target: dinstance
                                    height: Math.max(albumDetailBackground.height, songsInAlbumList.height)
                                }
                                PropertyChanges {
                                    target: albumDetailBackground
                                    width: albumThumbnail.width + 30
                                    height: Math.max(songsInAlbumList.height, albumThumbnail.height + albumThumbnail.height/3)
                                }
                                PropertyChanges {
                                    target: albumDetailText
                                    height: albumThumbnail.height/3
                                    width: albumThumbnail.width
                                }
                                PropertyChanges {
                                    target: songsInAlbumList
                                    width: parent.width - albumThumbnail.width - 30
                                }
                                AnchorChanges {
                                    target: albumDetailBackground
                                    anchors.left:parent.left
                                    anchors.top:parent.top
                                }
                                AnchorChanges {
                                    target:songsInAlbumList
                                    anchors.left:albumDetailBackground.right
                                    anchors.top:albumDetailBackground.top
                                }
                                AnchorChanges {
                                    target: albumThumbnail
                                    anchors.left:albumDetailBackground.left
                                    anchors.top:albumDetailBackground.top
                                }
                                AnchorChanges {
                                    target: albumDetailText
                                    anchors.left:albumDetailBackground.left
                                    anchors.top: albumThumbnail.bottom
                                }
                            },
                            State {
                                name: "portraitArtistDetailView"
                                when: !window.inLandscape
                                PropertyChanges {
                                    target: dinstance
                                    height: albumDetailBackground.height + songsInAlbumList.height
                                }
                                PropertyChanges {
                                    target: albumDetailBackground
                                    width: parent.width
                                    height: albumThumbnail.height
                                }
                                PropertyChanges {
                                    target: albumDetailText
                                    height: albumThumbnail.height
                                    width: parent.width - albumThumbnail.width
                                }
                                PropertyChanges {
                                    target: songsInAlbumList
                                    width: parent.width - 5
                                }

                                AnchorChanges {
                                    target: albumDetailBackground
                                    anchors.left:parent.left
                                    anchors.top:parent.top
                                }
                                AnchorChanges {
                                    target: albumDetailText
                                    anchors.top:albumDetailBackground.top
                                    anchors.left:albumThumbnail.right
                                }
                                AnchorChanges {
                                    target: albumThumbnail
                                    anchors.left:albumDetailBackground.left
                                    anchors.top: albumDetailBackground.top
                                }
                                AnchorChanges {
                                    target:songsInAlbumList
                                    anchors.left:parent.left
                                    anchors.top:albumDetailBackground.bottom
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
    }

    Component {
        id:albumDetailViewContent
        AppPage {
            id: albumDetailViewPage
            anchors.fill: parent
            pageTitle: labelAlbum
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
            }
            onDeactivated : { infocus = false; }

            property variant model: MusicListModel {
                type: MusicListModel.ListofSongsForAlbum
                limit: 0
                sort:MusicListModel.SortByDefault
                album:labelAlbum
                onAlbumChanged: {
                    albumSongList.currentIndex = -1;
                }
            }
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueView.currentIndex = 0;
                    Code.play();
                }
            }
            Image {
                id: box
                anchors.fill: parent
                fillMode: Image.Tile
                source: "image://meegotheme/images/bg_application_p"
                BorderImage {
                    id: artistTitleText
                    width: parent.width
                    anchors.top: parent.top
                    source: (window.inLandscape)?"image://meegotheme/images/media/subtitle_landscape_bar":"image://theme/media/subtitle_portrait_bar"
                    Text {
                        text: labelArtist
                        font.pixelSize: theme_fontPixelSizeLarge
                        anchors.fill: parent
                        color:theme_fontColorNormal
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment:Text.AlignLeft
                        elide: Text.ElideRight
                        anchors.leftMargin: 50
                    }
                }

                BorderImage {
                    id: albumDetailBackground
                    anchors.top: artistTitleText.bottom
                    source: "image://meegotheme/widgets/apps/media/gradient-albumview"
                    Item {
                        id: albumDetailText
                        height: albumThumbnail.height/3
                        width: albumThumbnail.width
                        Item {
                            id: albumDetailTextContainer
                            anchors.centerIn: parent
                            height: albumThumbnail.height/3
                            width: (parent.width*3)/4
                            Text {
                                id: albumTitleText
                                anchors.top: parent.top
                                height: albumThumbnail.height/9
                                width: parent.width
                                text: labelAlbum
                                color: theme_fontColorMediaHighlight
                                font.pixelSize: theme_fontPixelSizeLarge
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            Text {
                                id: albumTrackcountText
                                anchors.top: albumTitleText.bottom
                                height: albumThumbnail.height/10
                                width: parent.width
                                text: qsTr("%1 songs").arg(model.count)
                                color: theme_fontColorMediaHighlight
                                font.pixelSize: theme_fontPixelSizeLarge-3
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            Text {
                                id: albumLengthText
                                anchors.top: albumTrackcountText.bottom
                                height: albumThumbnail.height/10
                                width: parent.width
                                text: (albumLength < 60)?(qsTr("%1 seconds").arg(Code.formatLength(albumLength))):
                                        ((albumLength < 3600)?(qsTr("%1 minutes").arg(Code.formatLength(albumLength/60))):
                                         (qsTr("%1 hours").arg(Code.formatLength(albumLength/3600))))
                                color: theme_fontColorMediaHighlight
                                font.pixelSize: theme_fontPixelSizeLarge-3
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                        }
                    }

                    BorderImage {
                        id: albumThumbnail
                        border.left: 10; border.top: 10
                        border.right: 10; border.bottom: 10
                        width:400
                        height:width
                        source: "image://meegotheme/images/media/music_border_lrg"
                        anchors.leftMargin: 15
                        Image {
                            z: -10
                            anchors.fill: parent
                            fillMode:Image.PreserveAspectFit
                            source:thumbnailUri
                        }
                    }
                }

                MusicListView{
                    id: albumSongList
                    selectionMode: multiSelectMode
                    model: albumDetailViewPage.model
                    footerHeight: toolbar.height
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                            if (model.isSelected(payload.mitemid))
                                shareObj.addItem(payload.muri);
                            else
                                shareObj.delItem(payload.muri);
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
                        contextMenu.show();
                    }
                }
            }
            states: [
                State {
                    name: "landscapeAlbumDetailsView"
                    when: window.inLandscape
                    PropertyChanges {
                        target: albumDetailBackground
                        width: albumThumbnail.width + 30
                        height: parent.height - artistTitleText.height
                    }
                    PropertyChanges {
                        target: albumDetailText
                        height: albumThumbnail.height/3
                        width: albumThumbnail.width
                    }
                    PropertyChanges {
                        target: albumSongList
                        width: parent.width - albumDetailBackground.width
                        height: parent.height - artistTitleText.height
                    }
                    AnchorChanges {
                        target: albumDetailBackground
                        anchors.left:parent.left
                        anchors.top:artistTitleText.bottom
                    }
                    AnchorChanges {
                        target:albumSongList
                        anchors.left:albumDetailBackground.right
                        anchors.top:albumDetailBackground.top
                    }
                    AnchorChanges {
                        target: albumThumbnail
                        anchors.left:albumDetailBackground.left
                        anchors.top:albumDetailBackground.top
                    }
                    AnchorChanges {
                        target: albumDetailText
                        anchors.left:albumDetailBackground.left
                        anchors.top: albumThumbnail.bottom
                    }
                },
                State {
                    name: "portraitAlbumDetailView"
                    when: !window.inLandscape
                    PropertyChanges {
                        target: albumDetailBackground
                        width: parent.width
                        height: albumThumbnail.height
                    }
                    PropertyChanges {
                        target: albumDetailText
                        height: albumThumbnail.height
                        width: parent.width - albumThumbnail.width
                    }
                    PropertyChanges {
                        target: albumSongList
                        width: parent.width - 5
                        height: parent.height - albumDetailBackground.height - artistTitleText.height
                    }

                    AnchorChanges {
                        target: albumDetailBackground
                        anchors.left:parent.left
                        anchors.top:artistTitleText.bottom
                    }
                    AnchorChanges {
                        target: albumDetailText
                        anchors.top:albumDetailBackground.top
                        anchors.left:albumThumbnail.right
                    }
                    AnchorChanges {
                        target: albumThumbnail
                        anchors.left:albumDetailBackground.left
                        anchors.top: albumDetailBackground.top
                    }
                    AnchorChanges {
                        target:albumSongList
                        anchors.left:parent.left
                        anchors.top:albumDetailBackground.bottom
                    }
                }
            ]
        }
    }

    Component {
        id: playlistDetailViewContent
        AppPage {
            id: playlistDetailViewPage
            anchors.fill: parent
            pageTitle: labelAllPlaylist
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
            }
            onDeactivated : { infocus = false; }

            property alias model: playlistList.model
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueView.currentIndex = 0;
                    Code.play();
                }
            }
            actionMenuModel: [labelRenamePlaylist, labelClearPlaylist]
            actionMenuPayload: ["rename", "clear"]
            onActionMenuTriggered: {
                if(selectedItem == "rename")
                {
                    renamePlaylistDialog.currTitle = labelPlaylist;
                    renamePlaylistDialog.urn = labelPlaylistURN;
                    renamePlaylistDialog.playListModel = playlistList.model;
                    renamePlaylistDialog.show();
                }
                else if(selectedItem == "clear")
                {
                    playlistList.model.clear();
                    playlistList.model.savePlaylist(labelPlaylist);
                }
            }
            Image {
                id: box
                anchors.fill: parent
                fillMode: Image.Tile
                source: "image://meegotheme/images/bg_application_p"
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
                    source: "image://meegotheme/images/media/music_border_lrg"
                    Image {
                        z: -10
                        anchors.fill: parent
                        fillMode:Image.PreserveAspectFit
                        source:thumbnailUri
                    }
                }
                MusicListView {
                    id: playlistList
                    selectionMode: multiSelectMode
                    anchors.margins: 3
                    footerHeight: toolbar.height
                    model: MusicListModel {
                        type: MusicListModel.MusicPlaylist
                        playlist: labelPlaylist
                        limit: 0
                        sort:MusicListModel.SortByDefault
                        onPlaylistChanged: {
                            playlistList.currentIndex = -1;
                        }
                    }
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                            if (model.isSelected(payload.mitemid))
                                shareObj.addItem(payload.muri);
                            else
                                shareObj.delItem(payload.muri);
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
                        contextMenu.show();
                    }
                }
            }
            states: [
                State {
                    name: "landscapePlaylistDetailView"
                    when: window.inLandscape
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
                    when: !window.inLandscape
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
        footerHeight: toolbar.height
        onClicked:{
            if(multiSelectMode)
            {
                model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                if (model.isSelected(payload.mitemid))
                    shareObj.addItem(payload.muri);
                else
                    shareObj.delItem(payload.muri);
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
            contextMenu.show();
        }
    }

    Item {
        id: parkingLot
        x: window.width
        y: window.y
        width: 0
        height: 0
        clip:true
    }

    Component.onDestruction: {
        Code.stop();
    }
}
