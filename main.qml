/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Ux.Kernel 0.1
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Components.Indicators 0.1
import MeeGo.Ux.Components.Media 0.1
import MeeGo.Media 0.1
import QtMultimediaKit 1.1
import MeeGo.App.Music.MusicPlugin 1.0
import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1
import "functions.js" as Code

Window {
    id: window
    property variant track_title_color: "#2b81a4"
    property variant fontColorMediaArtist: "#7c7a7b"
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
    //: This is a verb. Marks the operation whereby items are added to the favorites list
    property string labelFavorite: qsTr("Favorite", "Verb")
    //: This is a verb. Marks the operation whereby items are removed from the favorites list
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

    property string labelNoMusicText1:qsTr("You have no music on this tablet")
    property string labelNoMusicText2:qsTr("Download or copy your music onto the tablet. Connect the tablet to your computer with a USB cable, via WiFi or bluetooth.")
    property string labelPlayQueueEmptyText:qsTr("Your play queue is empty")
    property string labelPlayQueueAddMusic:qsTr("Add music to the play queue")
    property string labelPlayQueueHelpHeading1: qsTr("What's the play queue?")
    property string labelPlayQueueHelpText1: qsTr("A place to queue up the music you want to hear. You can queue albums, playlists or individual tracks. ")
    property string labelPlayQueueHelpHeading2: qsTr("How do I queue music?")
    //: %1 is "Add music to the play queue", %2 is "Add to play queue" button labels
    property string labelPlayQueueHelpText2: qsTr("To queue music, tap the '%1' button. You can also tap and hold a song, album or playlist, then select '%2'.").arg(qsTr("Add music to the play queue")).arg(qsTr("Add to play queue"))
    property string labelPlayQueueHelpHeading3: qsTr("How do I get music?")
    property string labelPlayQueueHelpText3: qsTr("Download or copy your music onto the tablet. Connect the tablet to your computer with a USB cable, via Wi-Fi or bluetooth.")
    property string labelAddTracks: qsTr("Add tracks")
    property string labelAddPlaylists: qsTr("Add playlists")
    property string labelAddAlbums: qsTr("Add albums")
    property string labelPlaylistsEmptyText:qsTr("You have no playlists")
    property string labelPlaylistsCreate:qsTr("Create a playlist")
    property string labelPlaylistsHelpHeading1: qsTr("What's a playlist?")
    property string labelPlaylistsHelpText1: qsTr("A compilation of music created by you. Create playlists to suit your mood, your activities and to share with friends.")
    property string labelPlaylistsHelpHeading2: qsTr("How do I add music to a playlist?")
    //: %1 is "Add to playlist" button label
    property string labelPlaylistsHelpText2: qsTr("To add music to a playlist, tap and hold the track you want to add. Then select '%1'.").arg(qsTr("Add to playlist"))
    property string labelPlaylistsHelpHeading3: labelPlayQueueHelpHeading3
    property string labelPlaylistsHelpText3: labelPlayQueueHelpText3
    property string labelFavoritesEmptyText: qsTr("You don't have any favorite music tracks")
    property string labelFavoritesViewAllTracks: qsTr("View all music tracks")
    property string labelFavoritesHelpHeading1: qsTr("What are favorites?")
    property string labelFavoritesHelpText1: qsTr("The place to keep the music tracks you like most.")
    property string labelFavoritesHelpHeading2: qsTr("How do I create favorites?")
    //: %1 is "Favorite" button label
    property string labelFavoritesHelpText2: qsTr("To add music to your favorites, tap and hold a music track you love. Then select '%1'.").arg(qsTr("Favorite", "Verb"))
    property string labelFavoritesHelpHeading3: labelPlayQueueHelpHeading3
    property string labelFavoritesHelpText3: labelPlayQueueHelpText3
    property string forbiddenchars: ("\n\'\t\"\\");
    property string forbiddencharsDisplay: ("<return>, <tab>, \', \", \\");
    property string defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
    property bool isLandscape: (window.inLandscape || window.inInvertedLandscape)

    property int animationDuration: 500

    property string artistName: ""
    property int tabContentWidth: 300
    property alias loop: toolbar.loop

    property string thumbnailUri:""
    property string stackThumbnailUriCurr:""//For the playlistDetailView's stack of albums
    property string stackThumbnailUri1:""//For the playlistDetailView's stack of albums
    property string stackThumbnailUri2:""//For the playlistDetailView's stack of albums
    property string stackThumbnailUri3:""//For the playlistDetailView's stack of albums
    property string stackThumbnailUri4:""//For the playlistDetailView's stack of albums
    property bool multiSelectMode: false
    property variant multiSelectModel: allTracksModel
    property variant currentListModel: allTracksModel
    property int targetIndex: 0

    property variant currentAlbum
    property variant currentPlaylist

    property variant bookModel: [labelPlayqueue,labelAllPlaylist,labelFavorites,
                                 labelAllArtist,labelAllAlbums,labelAllTracks]
    property variant bookPayload: [playQueueContent,playlistsContent,favoritesContent,
                                   artistsContent,albumsContent,allTracksContent]
    property int bookMenuSelectedIndexCopy: 5//Used for multiselection mode only
    property int selectedFavoritesAccumulator
    property bool multiSelectModeShowFavoriteAction

    property int contentMargins: 15
    property string nowPlayingLabel//in "Play Queue", "Playlist", "Album", "Artist", "All Tracks", "Favorites"
    property string nowPlayingName//name of the playlist, album or artist
    property string currentListNameForDisplay//For showing where playback is from
    property real globalNewAngle:0
    property bool playlistAnimationNeeded: false

    // state management hooks, calling setState sets targetState
    // currentState is updated to hold all the current values
    property variant targetState: StateData {}
    property variant currentState: StateData {}
    signal setState()

    // Save and Restore saves off the state data
    SaveRestoreState {
        id: stateManager
        onSaveRequired: {
            setValue("page", currentState.page);
            setValue("command", currentState.command);
            setValue("uri", currentState.uri);
            setValue("position", currentState.position);
            setValue("shuffle", currentState.shuffle);
            setValue("repeat", currentState.repeat);
            setValue("artist", currentState.artist);
            setValue("album", currentState.album);
            setValue("playlist", currentState.playlist);
            sync();
        }
    }

    Connections {
        target: window
        onSetState: {
            /* first set the song to its proper playing state */
            remoteControlItem.mitemid = targetState.uri;
            remoteControlItem.mitemid = editorModel.datafromURI(targetState.uri, MediaItem.ID);
            remoteControlItem.mitemtype = editorModel.datafromURI(targetState.uri, MediaItem.ItemType);
            if(targetState.command == "play")
                Code.addToPlayqueueAndPlay(remoteControlItem, targetState.position);
            else if(targetState.command == "pause")
                Code.addToPlayqueueAndPause(remoteControlItem, targetState.position);

            toolbar.shuffle = targetState.shuffle;
            toolbar.loop = targetState.repeat;

            if (targetState.page == 0) { // Playqueue Page
                switchBook(playQueueContent);
            } else if (targetState.page == 1) { // Playlists Page
                switchBook(playlistsContent);
            } else if (targetState.page == 2) { // Favorites Page
                switchBook(favoritesContent);
            } else if (targetState.page == 3) { // Artists Page
                switchBook(artistsContent);
            } else if (targetState.page == 4) { // Albums Page
                switchBook(albumsContent);
            } else if (targetState.page == 5) { // All Tracks Page
                switchBook(allTracksContent);
            } else if ((targetState.page == 6)&&(targetState.artist != "")) { // Artist Detail Page
                switchBook(artistsContent);
                labelArtist = targetState.artist;
                thumbnailUri = editorModel.datafromURI(targetState.uri, MediaItem.ThumbURI)
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(artistDetailViewContent);
            } else if ((targetState.page == 7)&&(targetState.album != "")) { // Album Detail Page
                switchBook(albumsContent);
                labelAlbum = targetState.album;
                try {
                    labelArtist = editorModel.datafromURI(targetState.uri, MediaItem.Artist)[0];
                }
                catch(err) {
                    labelArtist = "";
                }
                thumbnailUri = editorModel.datafromURI(targetState.uri, MediaItem.ThumbURI)
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(albumDetailViewContent);
            } else if ((targetState.page == 8)&&(targetState.playlist != "")) { // Playlist Detail Page
                switchBook(playlistsContent);
                labelPlaylist = targetState.playlist;
                labelPlaylistURN = editorModel.datafromURI(targetState.uri, MediaItem.URN);
                thumbnailUri = editorModel.datafromURI(targetState.uri, MediaItem.ThumbURI);
                if (thumbnailUri == "" | thumbnailUri == undefined)
                    thumbnailUri = defaultThumbnail;
                editorModel.setViewed(remoteControlItem.mitemid);
                window.addPage(playlistDetailViewContent);
            }
        }
    }

    bookMenuModel: bookModel
    bookMenuPayload: bookPayload

    bookMenuHighlightSelection: true
    actionMenuHighlightSelection: true

    onBookMenuSelectedIndexChanged: {
        bookMenuSelectedIndexCopy = ( bookMenuSelectedIndex == -1 ? bookMenuSelectedIndexCopy : bookMenuSelectedIndex );
    }

    onMultiSelectModeChanged: {
        if(multiSelectMode)
        {
            window.setBookMenuData([], []);
            bookMenuSelectedIndex = -1;
        }
        else
        {
            window.setBookMenuData(bookModel, bookPayload);
            bookMenuSelectedIndex = bookMenuSelectedIndexCopy;
        }
    }
    onBackButtonPressed:
    {
        Code.clearSelected();
        shareObj.clearItems();
        multiSelectMode = false;
    }
    property variant allTracksModel: MusicListModel {
        type: MusicListModel.ListofSongs
        sort:MusicListModel.SortByDefault
        limit: 0
    }
    property variant playlistsModel: MusicListModel {
        type: MusicListModel.ListofPlaylists
        limit:0
        sort:MusicListModel.SortByTitle
    }

    // global now playing queue
    property variant playqueueModel: MusicListModel {
        type: MusicListModel.NowPlaying
        limit: 0
        sort: MusicListModel.SortByDefault
        onBeginPlayback: Code.play();
        onPlayIndexChanged: {
            playqueueView.currentIndex = playindex;
        }
        onPlayStatusChanged: {
            if(playstatus == MusicListModel.Playing)
                playqueueView.currentIndex = playqueueModel.playindex;
        }
        onShuffleChanged: {
            playqueueView.currentIndex = playqueueModel.playindex;
        }
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
                Code.addToPlayqueueAndPlay(remoteControlItem, 0);
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
                Code.addToPlayqueueAndPlay(remoteControlItem, 0);
            else
                Code.addToPlayqueue(remoteControlItem);
            songnum++
        }
        onDatabaseInitComplete: {
            if(stateManager.restoreRequired)
            {
                targetState.set(stateManager.value("page"),
                                stateManager.value("command"),
                                stateManager.value("uri"),
                                stateManager.value("position"),
                                stateManager.value("shuffle"),
                                stateManager.value("repeat"),
                                stateManager.value("artist"),
                                stateManager.value("album"),
                                stateManager.value("playlist"));
                window.setState();
                stateManager.invalidate();
            }
        }
    }

    property variant playlistEditor: MusicListModel {
        type: MusicListModel.MusicPlaylist
        limit: 0
        sort: MusicListModel.SortByDefault
    }

    property variant resourceManager: ResourceManager {
        name: "player"
        type: ResourceManager.MusicApp
        onStartPlaying: {
            audio.play();
        }
        onStopPlaying: {
            audio.pause();
        }
    }

    QmlSetting{
        id: settings
        organization: "MeeGo"
        application:"meego-app-music"
    }

    function processCommand (parameters)
    {
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
            if(Code.songCheck(cdata))
                editorModel.requestItem(MediaItem.SongItem, cdata);
        } else if (cmd == "playArtist") {
            editorModel.requestItem(MediaItem.MusicArtistItem, cdata);
        } else if (cmd == "playAlbum") {
            editorModel.requestItem(MediaItem.MusicAlbumItem, cdata);
        } else if (cmd == "playPlaylist") {
            editorModel.requestItem(MediaItem.MusicPlaylistItem, cdata);
        } else if(cmd == "show") {
            if(cdata == "playqueue") {
                switchBook(playQueueContent);
            }
        }
    }

    Connections {
        target: mainWindow
        onCall: {
            processCommand(parameters);
        }
    }
    QtObject {
        id: remoteControlItem
        property string mitemid
        property string mitemtype
    }

    VolumeControl {
        id: volumeControl
    }

    Connections {
        id: volumeControlConnection // avoid loop modification
        target: volumeControl
        onVolumeChanged: {
            dbusConnection.target = null
            dbusControl.volume = value;   // int value (0~100)
            if(value > 0)
                dbusControl.muted = false;
            else
                dbusControl.muted = true;
            dbusConnection.target = dbusControl
        }

        onMuteChanged: {
            dbusConnection.target = null
            dbusControl.muted = muted;   // bool value
            dbusConnection.target = dbusControl
        }
    }

    Connections {
        id: dbusConnection // avoid loop modification
        target: dbusControl
        property int lastlevel: 0
        onMutedChanged: {
            volumeControlConnection.target = null
            if(dbusControl.muted)
            {
                dbusConnection.lastlevel = volumeControl.volume;
                volumeControl.volume = 0;
            }
            else
            {
                volumeControl.volume = dbusConnection.lastlevel;
            }
            volumeControlConnection.target = volumeControl
        }

        onVolumeChanged: {
            if (level >= 0 && level <= 100) {
                volumeControlConnection.target = null
                volumeControl.volume = level;   // int value (0~100)
                volumeControlConnection.target = volumeControl
            }
        }
    }

    MusicDbusObject {
        id: dbusControl
        onPlayNextTrack: Code.playNextSong();
        onPlayPreviousTrack: Code.playPrevSong();
        onPause: Code.pause();
        onStop: Code.stop();

        property int nextItem1: -1
        property int nextItem2: -1

        function updateNowNextTracks() {
            var newNowNext = [
                    playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN),
                    playqueueModel.getURNFromIndex(nextItem1),
                    playqueueModel.getURNFromIndex(nextItem2)
                ]
            dbusControl.nowNextTracks = newNowNext;
            var album = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album);
            var artist = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Artist);
            var title = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title);
            var length = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Length);
            dbusControl.setCurrentTrackMetadata(album, artist, title, length);
        }

        onPlay: {
            if(!Code.play()) {
                playqueueModel.playAllSongs();
            }
        }

        onStateChanged: {
            Code.updateNowNextPlaying();
        }

        onClose: {
            dbusControl.setPlayerClosed();
            Qt.quit();
        }

        onFastForward: {
            audio.position += 5000
        }

        onRewind: {
            audio.position -= 5000
        }

        onShow: {
            mainWindow.show();
            dbusControl.setPlayerLaunched();
        }

        Component.onCompleted: {
            dbusControl.playbackState = MusicDbusObject.PLAYBACK_STATE_UNKNOWN;
            dbusControl.playbackMode = MusicDbusObject.PLAYBACK_MODE_NORMAL;
        }
    }

    Connections {
        target: playqueueView

        onCountChanged: {  // all track number
            dbusControl.numberOfTracks = playqueueView.count;
        }

        onCurrentIndexChanged: {    // current track
            dbusControl.currentTrack = playqueueView.currentIndex;
        }
    }

    Connections {
        id: toolbarConnection
        target: toolbar       // Main Tool bar

        function updatePlaybackMode() {
            if (!toolbar.loop&&!toolbar.shuffle)
                dbusControl.playbackMode = MusicDbusObject.PLAYBACK_MODE_NORMAL;
            else if (toolbar.shuffle)
                dbusControl.playbackMode = MusicDbusObject.PLAYBACK_MODE_SHUFFLE;
            else
                dbusControl.playbackMode = MusicDbusObject.PLAYBACK_MODE_REPEATED;
        }

        onLoopChanged: toolbarConnection.updatePlaybackMode();
        onShuffleChanged: toolbarConnection.updatePlaybackMode();
    }

    Audio {
        id: audio
        autoLoad: true
        onError: {
            dbusControl.error(MusicDbusObject.SHOW_PLAYER_FAILED)
            Code.playNextSong();
        }
        onMutedChanged: {
            dbusControl.muted = audio.muted;
        }
        onPositionChanged: {
            dbusControl.position = audio.position;
            currentState.position = audio.position;
        }
        onSourceChanged: {
            currentState.urn = editorModel.datafromURI(audio.source, MediaItem.URN);
            currentState.uri = audio.source;
        }
        onStatusChanged: {
            if (status == Audio.EndOfMedia) {
                Code.playNextSong();
            }
        }
    }

    Timer {
        id: startupTimer
        interval: 2000
        repeat: false
    }

    Component.onCompleted: {
        multiSelectModeShowFavoriteAction = true;
        selectedFavoritesAccumulator = 0;
        switchBook(allTracksContent);
        bookMenuSelectedIndex = bookModel.indexOf(labelAllTracks);
        startupTimer.start();
        if(mainWindow.call)
        {
            processCommand(mainWindow.call);
        }
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
        contextMenu.mouseX = map.x;
        contextMenu.mouseY = map.y;
        topItem.calcTopParent();
        contextMenu.setPosition( map.x, map.y );
    }

    function addToPlaylist(payload, title, uri, thumbUri, type)
    {
        playlistEditor.clear();
        playlistEditor.playlist = title;
        playlistEditor.addItems(payload);
        if(multiSelectMode)
        {
            Code.clearSelected();
            shareObj.clearItems();
            multiSelectMode = false;
        }
    }

    overlayItem: Item {
        id: globalItems
        anchors.fill: parent

        ShareObj {
            id: shareObj
            shareType: MeeGoUXSharingClientQmlObj.ShareTypeAudio
            onSharingComplete: {
                if(multiSelectMode)
                {
                    Code.clearSelected();
                    shareObj.clearItems();
                    multiSelectMode = false;
                }
            }
        }

        MusicToolBar {
            id: toolbar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            playing: false
            landscape: window.isLandscape
        }

        MediaMultiBar {
            id: multibar
            height: ( visible ? 55 : 0 )
            visible: ( opacity > 0 ? true : false )
            opacity: 0
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            landscape: window.isLandscape
            showfavourite: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelFavorites))?false:(multiSelectModeShowFavoriteAction?true:false)
            showunfavourite: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelFavorites))?true:(multiSelectModeShowFavoriteAction?false:true)
            showrmfromqueue: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelPlayqueue))?true:false
            showrmfromplaylist: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelAllPlaylist))?true:false
            showaddtoqueue: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelPlayqueue))?false:true
            showaddtoplaylist: (bookMenuSelectedIndexCopy==bookModel.indexOf(labelAllPlaylist))?false:true
            showdelete: (bookMenuSelectedIndexCopy <= bookModel.indexOf(labelFavorites))?false:true
            onCancelPressed: {
                Code.clearSelected();
                shareObj.clearItems();
                multiSelectMode = false;
            }
            onDeletePressed: {
                if(Code.selectionCount() > 0)
                {
                    deleteMultipleItemsDialog.deletecount = Code.selectionCount();
                    deleteMultipleItemsDialog.show();
                }
            }
            onSharePressed: {
                if(shareObj.shareCount > 0)
                {
                    var map = mapToItem(topItem.topItem, fingerX, fingerY);
                    shareObj.showContextTypes(map.x, map.y)
                }
            }
            onFavouritePressed: {
                if(Code.selectionCount() > 0)
                    {Code.changeMultipleItemFavorite(true);}
            }
            onUnfavouritePressed: {
                if(Code.selectionCount() > 0)
                    {Code.changeMultipleItemFavorite(false);}
            }
            onRmFromQueuePressed: {
                if(Code.selectionCount() > 0)
                    {Code.removeMultipleFromPlayqueue();}
            }
            onRmFromPlaylistPressed: {
                if(Code.selectionCount() > 0)
                    {Code.removeMultipleFromPlaylist(contextMenu.playlistmodel);}
            }
            onAddToQueuePressed: {
                if(Code.selectionCount() > 0)
                    {Code.addMultipleToPlayqueue();}
            }
            onAddToPlaylistPressed: {
                if(Code.selectionCount() > 0)
                {
                    playlistPicker.okclicked = false;
                    playlistPicker.payload = Code.getSelectedIDs()
                    playlistPicker.show();
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
            content: Column {
                id: deleteItemContents
                anchors.left:parent.left
                anchors.right: parent.right
                property alias artist : artistName.text
                property alias track : trackName.text
                clip: true
                Text{
                    id: artistName
                    font.pixelSize: theme_fontPixelSizeLarge
                    text : qsTr("Artist name")
                    anchors.leftMargin: theme_dialogLeftMarginPixelSize
                    anchors.left:parent.left
                    anchors.right: parent.right
                    height: paintedHeight
                }
                Text{
                    id: trackName
                    text: qsTr("Track name")
                    anchors.leftMargin: theme_dialogLeftMarginPixelSize
                    anchors.left:parent.left
                    anchors.right: parent.right
                    height: paintedHeight
                }
                Item{
                    anchors.left:parent.left
                    anchors.right: parent.right
                    height: theme_dialogContentAreaTopAndBottomMarginPixelSize
                }

                Text {
                    height: paintedHeight
                    text: qsTr("If you delete this, it will be removed from your device")
                    anchors.left:parent.left
                    anchors.right: parent.right
                    font.pixelSize: theme_fontPixelSizeMedium
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        ModalDialog {
            id: deleteMultipleItemsDialog
            property int deletecount: Code.selectionCount()
            //: text asking the user if the song(s) is to deleted, warning them that it's permanent
            title: qsTr("Permanently delete the selected %n song(s)?", "", deletecount)
            acceptButtonText: labelConfirmDelete
            cancelButtonText: labelCancel
            onAccepted: {
                multiSelectModel.destroyItemsByID(Code.getSelectedIDs());
                Code.clearSelected();
                shareObj.clearItems();
                multiSelectMode = false;
            }
            content: Column {
                anchors.fill: parent
                clip: true
                Text {
                    text: qsTr("If you delete these, they will be removed from your device")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: paintedHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: theme_fontPixelSizeMedium
                    wrapMode: Text.WordWrap
                }
            }
        }

        ModalDialog {
            id: createPlaylistDialog
            title:labelCreateNewPlaylist
            cancelButtonText:labelCancel
            acceptButtonText:labelCreate
            property string playlistTitle: ""
            property bool isvalid: true
            onAccepted: {
                if(isvalid) {
                    playlistEditor.clear();
                    playlistEditor.savePlaylist(playlistTitle);
                    editorCreate.text = "";
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
                playlistEditor.playlist = playlistTitle;
                playlistEditor.addItems(playqueueModel.getAllIDs());
                playqueuePlaylistDialogTextEntry.text = "";

            }
            content: Item{
                anchors.fill: parent
                TextEntry{
                    id: playqueuePlaylistDialogTextEntry
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
            id: contextMenu
            property alias payload: contextActionMenu.payload
            property alias model: contextActionMenu.model
            property variant shareModel: []
            property variant openpage
            property variant playlistmodel
            property int mouseX
            property int mouseY
            content: ActionMenu {
                id: contextActionMenu
                property variant payload: undefined
                onTriggered: {
                    if (model[index] == labelPlay)
                    {
                        // Play
                        if(!multiSelectMode)
                            Code.addToPlayqueueAndPlay(payload, 0);
                        else if(Code.selectionCount() > 0)
                            Code.addMultipleToPlayqueueAndPlay();
                    }
                    else if (model[index] == labelOpen)
                    {
                        // Open
                        Code.openItemInDetailView(contextMenu.openpage,payload);
                    }
                    else if (model[index] == labelFavorite)
                    {
                        // Favorite
                        if(!multiSelectMode)
                            Code.changeItemFavorite(payload, true);
                        else if(Code.selectionCount() > 0)
                            Code.changeMultipleItemFavorite(true);
                    }
                    else if (model[index] == labelUnFavorite)
                    {
                        // unfavorite
                        if(!multiSelectMode)
                            Code.changeItemFavorite(payload, false);
                        else if(Code.selectionCount() > 0)
                            Code.changeMultipleItemFavorite(false);
                    }
                    else if (model[index] == labelAddToPlayQueue)
                    {
                        // Add to play queue
                        if(!multiSelectMode)
                            Code.addToPlayqueue(payload);
                        else if(Code.selectionCount() > 0)
                            Code.addMultipleToPlayqueue();
                    }
                    else if (model[index] == labelRemoveFromPlayQueue)
                    {
                        // Remove from play queue
                        if(!multiSelectMode)
                            Code.removeFromPlayqueue();
                        else if(Code.selectionCount() > 0)
                            Code.removeMultipleFromPlayqueue();
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
                        else if(Code.selectionCount() > 0)
                        {
                            playlistPicker.okclicked = false;
                            playlistPicker.payload = Code.getSelectedIDs()
                            playlistPicker.show();
                        }
                    }
                    else if (model[index] == labelRemFromPlaylist)
                    {
                        // Remove from a play list
                        if(!multiSelectMode)
                            Code.removeFromPlaylist(contextMenu.playlistmodel);
                        else if(Code.selectionCount() > 0)
                            Code.removeMultipleFromPlaylist(contextMenu.playlistmodel);
                    }
                    else if (model[index] == labelClearPlaylist)
                    {
                        // Clear a play list
                        playlistEditor.playlist = payload.mtitle;
                        playlistEditor.clearPlaylist();
                    }
                    else if (model[index] == labelRenamePlaylist)
                    {
                        // Rename playlist
                        renamePlaylistDialog.currTitle = payload.mtitle;
                        renamePlaylistDialog.urn = payload.murn;
                        renamePlaylistDialog.playListModel = contextMenu.playlistmodel;
                        renamePlaylistDialog.show();
                    }
                    else if (model[index] == labelDelete)
                    {
                        // Delete
                        if(!multiSelectMode)
                        {
                            deleteItemDialog.payload = payload;
                            deleteItemDialog.show();
                        }
                        else if(Code.selectionCount() > 0)
                        {
                            deleteMultipleItemsDialog.deletecount = Code.selectionCount();
                            deleteMultipleItemsDialog.show();
                        }
                    }
                    else if (model[index] == labelMultiSelect)
                    {
                        // Multi Select
                        multiSelectMode = true;
                        selectedFavoritesAccumulator = 0;
                    }
                    else if (model[index] == labelcShare)
                    {
                        // Share
                        shareObj.clearItems();
                        if(!multiSelectMode)
                        {
                            shareObj.addItem(payload.muri) // URI
                        }
                        else if(Code.selectionCount() > 0)
                        {
                            shareObj.addItems(Code.getSelectedURIs()) // URIs
                        }
                        shareObj.showContextTypes(contextMenu.mouseX, contextMenu.mouseY)
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
                currentState.page = 0;
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

            MusicPicker{
                id: playqueuePicker
                //TODO change to multiSelection when MusicPicker has working support for it.
                multiSelection: false

                // signal songSelected( string title, string uri, string thumbUri, string album, int type )
                onSongSelected: {
                    var itemid = allTracksModel.datafromURI(uri, MediaItem.ID);
                    playqueueModel.addItems(itemid);
                }

                //signal albumOrPlaylistSelected( string title, string uri, string thumbUri, int type )
                onAlbumOrPlaylistSelected: {
                    var itemid = playqueuePicker.model.datafromURI(uri, MediaItem.ID);
                    playqueueModel.addItems(itemid);
                }
                // signal multipleAlbumsOrPlaylistsSelected( variant titles, string uris, string thumbUris, variant types )
                // onMultipleAlbumsOrPlaylistsSelected: {
                //     console.log(titles);
                // }
                // signal multipleSongsSelected( variant titles, variant uris, variant thumbUris, string album, variant types )
                // onMultipleSongsSelected: {
                //     console.log(titles);
                // }
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
            }

            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }
            Item {
                anchors.fill: parent
                NoMusicNotification {
                    id: noMusicScreen
                    visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                    onVisibleChanged: {
                        playqueueView.visible = (!visible && !(playQueueEmpty.visible))
                    }
                }
                NoContent {
                    id: playQueueEmpty
                    bottomMargin: toolbar.height
                    visible: ((playqueueView.count == 0)&&(!startupTimer.running)) && !noMusicScreen.visible
                    onVisibleChanged: {
                        playqueueView.visible = (!visible && !noMusicScreen.visible)
                        button1ContextMenuModel = [labelAddTracks]
                        if (playlistsModel.total > 0) {
                            button1ContextMenuModel = button1ContextMenuModel.concat(labelAddPlaylists)
                        }
                        if (allTracksModel.total > 0) {
                            button1ContextMenuModel = button1ContextMenuModel.concat(labelAddAlbums)
                        }
                    }
                    title: labelPlayQueueEmptyText
                    button1Text: labelPlayQueueAddMusic
                    showButton1ContextMenu: true
                    onButton1MenuTriggered: {
                        console.log("playqueuePicker")
                        playqueuePicker.selectSongs = (button1ContextMenuModel[index] == labelAddTracks)
                        playqueuePicker.showPlaylists = (button1ContextMenuModel[index] == labelAddPlaylists)
                        playqueuePicker.showAlbums = (button1ContextMenuModel[index] == labelAddAlbums)
                        playqueuePicker.show();
                    }
                    help: HelpContent {
                        id: help
                        helpHeading1: labelPlayQueueHelpHeading1
                        helpText1: labelPlayQueueHelpText1
                        helpImage1: "image://themedimage/widgets/apps/media/blankscreen-music_view"
                        helpHeading2: labelPlayQueueHelpHeading2
                        helpText2: labelPlayQueueHelpText2
                        helpImage2: "image://themedimage/widgets/apps/media/blankscreen-music_menu"
                        helpHeading3: labelPlayQueueHelpHeading3
                        helpText3: labelPlayQueueHelpText3
                        helpImage3: "image://themedimage/widgets/apps/media/blankscreen-music_transfer"
                    }
                    Component.onCompleted: {
                        if (settings.get("PlayQueueOpenedBefore")) {
                            help.visible = false;
                        } else {
                            settings.set("PlayQueueOpenedBefore", 1)
                        }
                    }
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
            actionMenuHighlightSelection: true
            property bool showGridView: settings.get("PlaylistsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
                playlistsPage.actionMenuSelectedIndex = settings.get("PlaylistsView")+1;
                currentState.page = 1;
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
            Rectangle {
                anchors.fill: parent
                color: "black"
            }

            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }
            NoMusicNotification {
                id: noMusicScreen
                visible: ((gridView.model.total == 0)&&(allTracksModel.total == 0)&&(!startupTimer.running))
            }
            NoContent {
                id: noPlaylists
                bottomMargin: toolbar.height
                visible: ((gridView.model.total == 0)&&(!startupTimer.running)) && !noMusicScreen.visible
                title: labelPlaylistsEmptyText
                button1Text: labelPlaylistsCreate
                onButton1Clicked: {
                    createPlaylistDialog.show();
                }
                help: HelpContent {
                    id: help
                    helpHeading1: labelPlaylistsHelpHeading1
                    helpText1: labelPlaylistsHelpText1
                    helpImage1: "image://themedimage/widgets/apps/media/blankscreen-music_view"
                    helpHeading2: labelPlaylistsHelpHeading2
                    helpText2: labelPlaylistsHelpText2
                    helpImage2: "image://themedimage/widgets/apps/media/blankscreen-music_menu"
                    helpHeading3: labelPlaylistsHelpHeading3
                    helpText3: labelPlaylistsHelpText3
                    helpImage3: "image://themedimage/widgets/apps/media/blankscreen-music_transfer"
               }
               Component.onCompleted: {
                   if (settings.get("PlaylistsOpenedBefore")) {
                       help.visible = false;
                   } else {
                       settings.set("PlaylistsOpenedBefore", 1)
                   }
               }
            }

            MusicListView {
                anchors.fill: parent
                anchors.margins: contentMargins
                model:gridView.model
                mode: 1
                footerHeight: toolbar.height + multibar.height
                visible: !showGridView && !noMusicScreen.visible && !noPlaylists.visible
                onClicked: {
                     Code.openItemInDetailView(playlistsPage,payload);
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelRenamePlaylist, labelClearPlaylist, labelDelete]);
                    contextMenu.openpage = playlistsPage;
                    contextMenu.playlistmodel = gridView.model;
                    contextMenu.show();}
                }
            }

            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                anchors.leftMargin: (parent.width - Math.floor(parent.width / 326)*326) / 2
                anchors.rightMargin: anchors.leftMargin
                visible:showGridView && !noMusicScreen.visible && !noPlaylists.visible
                defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
                footerHeight: toolbar.height + multibar.height
                model: MusicListModel {
                    type: MusicListModel.ListofPlaylists
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    Code.openItemInDetailView(playlistsPage,payload);
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(dinstance, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelRenamePlaylist, labelDelete]);
                    contextMenu.openpage = playlistsPage;
                    contextMenu.playlistmodel = gridView.model;
                    contextMenu.show();}
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
            actionMenuHighlightSelection: true
            property bool showGridView: settings.get("AllArtistsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
                artistsPage.actionMenuSelectedIndex = settings.get("AllArtistsView");
                currentState.page = 3;
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
            NoMusicNotification {
                id: noMusicScreen
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
            }
            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }

            MusicListView {
                id: artistsListView
                anchors.fill:parent
                anchors.margins: contentMargins
                visible: !showGridView && !noMusicScreen.visible
                model:artistsGridView.model
                mode: 2
                footerHeight: toolbar.height + multibar.height
                onClicked: {
                    Code.openItemInDetailView(artistsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = artistsPage;
                    contextMenu.show();}
                }
            }

            MediaGridView {
                id: artistsGridView
                type: musictype // music app = 0
                anchors.fill: parent
                visible: showGridView && !noMusicScreen.visible
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                anchors.leftMargin: (parent.width - Math.floor(parent.width / 326)*326) / 2
                anchors.rightMargin: anchors.leftMargin
                defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
                footerHeight: toolbar.height + multibar.height
                model: MusicListModel {
                    type: MusicListModel.ListofArtists
                    limit:0
                    sort:MusicListModel.SortByTitle
                }
                onClicked: {
                    Code.openItemInDetailView(artistsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = artistsPage;
                    contextMenu.show();}
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
            actionMenuHighlightSelection: true
            property bool showGridView: settings.get("AllAlbumsView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
                albumsPage.actionMenuSelectedIndex = settings.get("AllAlbumsView");
                currentState.page = 4;
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
            Rectangle {
                anchors.fill: parent
                color: "black"
            }
            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }

            NoMusicNotification {
                id: noMusicScreen
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
            }
            MusicListView {
                id: albumsListView
                anchors.fill:parent
                anchors.margins: contentMargins
                visible: !showGridView && !noMusicScreen.visible
                model:albumsGridView.model
                mode: 3
                footerHeight: toolbar.height + multibar.height
                onClicked: {
                    labelArtist = payload.martist;
                    Code.openItemInDetailView(albumsPage,payload)
                }
                onDoubleClicked: {
                    Code.addToPlayqueueAndPlay(payload, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.show();}
                }
            }

            MediaGridView {
                id: albumsGridView
                type: musictype // music app = 0
                anchors.fill: parent
                visible: showGridView && !noMusicScreen.visible
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                anchors.leftMargin: 15
                anchors.rightMargin: anchors.leftMargin
                defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
                footerHeight: toolbar.height + multibar.height

                spacing: 10
                showHeader: true
                delegateHeaderSource: "image://themedimage/widgets/apps/media/music-album-header"
                delegateHeaderVisible: true
                delegateFooterSource: "image://themedimage/widgets/apps/media/photo-album-shadow"
                delegateFooterVisible: true
                borderImageSource: "image://themedimage/widgets/apps/media/photo-album-border"
                borderImageTop: 8
                borderImageBottom: 6
                borderImageLeft: 8
                borderImageRight: 8
                borderImageInnerMargin: 2


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
                    Code.addToPlayqueueAndPlay(payload, 0);
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    contextMenu.openpage = albumsPage;
                    contextMenu.show();}
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
            actionMenuHighlightSelection: true
            property bool showGridView: settings.get("AllTracksView") == 0
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
                allTracksPage.actionMenuSelectedIndex = settings.get("AllTracksView");
                currentState.page = 5;
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
                    playqueueModel.playindex = 0;
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
            Rectangle {
                anchors.fill: parent
                color: "black"
            }

            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }

            NoMusicNotification {
                id: noMusicScreen
                visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
            }

            MusicListView {
                id: listview
                selectionMode: multiSelectMode
                anchors.fill:parent
                anchors.margins: contentMargins
                visible: !showGridView && !noMusicScreen.visible
                model: allTracksModel
                footerHeight: toolbar.height + multibar.height
                onClicked: {
                    console.log("-- multiselect clicked");
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        listview.selectionChanged();
                        if (model.isSelected(payload.mitemid))
                            {
                            shareObj.addItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                            }
                        else
                            {
                            shareObj.delItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                            }
                        multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                    }
                    else
                    {
                        nowPlayingLabel=labelAllTracks;
                        Code.addToPlayqueueAndPlay(payload, 0);
                    }
                }
                onLongPressAndHold:{
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.show();}
                }
            }

            MediaGridView {
                id: gridView
                type: musictype // music app = 0
                selectionMode: multiSelectMode
                visible: showGridView && !noMusicScreen.visible
                footerHeight: toolbar.height + multibar.height
                defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
                model: listview.model

                anchors.fill: parent
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                anchors.leftMargin: (parent.width - Math.floor(parent.width / 326)*326) / 2
                anchors.rightMargin: anchors.leftMargin

                onClicked: {
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        if (model.isSelected(payload.mitemid))
                        {
                            shareObj.addItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                        }
                        else
                        {
                            shareObj.delItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                        }
                        multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                    }
                    else
                    {
                        nowPlayingLabel= labelAllTracks;
                        Code.addToPlayqueueAndPlay(payload, 0);
                    }
                }
                onLongPressAndHold:{
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.show();}
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
            actionMenuHighlightSelection: true
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = false;
                currentState.page = 2;
            }
            onDeactivated : { infocus = false; }
            property variant model: MusicListModel {
                type: MusicListModel.ListofFavorites
                limit: 0
                sort:(settings.get("FavoriteView") == 1? MusicListModel.SortByAddedTime:MusicListModel.SortByTitle)
            }
            Connections {
                target: window
                onSearch: {
                   listView.model.search = needle;
                    if (!needle ) {
                        listView.model.filter=MusicListModel.FilterAll
                    }
                }
            }
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueModel.playindex = 0;
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
            Rectangle {
                anchors.fill: parent
                color: "black"
            }

            BorderImage {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.bottomMargin: 5
                source: "image://themedimage/widgets/apps/media/content-background"
                border.left:   8
                border.top:    8
                border.bottom: 8
                border.right:  8
            }

            Item {
                anchors.fill: parent
                NoMusicNotification {
                    id: noMusicScreen
                    visible: ((allTracksModel.total == 0)&&(!startupTimer.running))
                }
                NoContent {
                    id: noFavorites
                    bottomMargin: toolbar.height
                    visible: ((listView.count == 0)&&(!startupTimer.running)) && !noMusicScreen.visible
                    title: labelFavoritesEmptyText
                    button1Text: labelFavoritesViewAllTracks
                    onButton1Clicked: {
                        switchBook(allTracksContent);
                    }
                    help: HelpContent {
                        id: help
                        helpHeading1: labelFavoritesHelpHeading1
                        helpText1: labelFavoritesHelpText1
                        helpImage1: "image://themedimage/widgets/apps/media/blankscreen-music_view"
                        helpHeading2: labelFavoritesHelpHeading2
                        helpText2: labelFavoritesHelpText2
                        helpImage2: "image://themedimage/widgets/apps/media/blankscreen-music_menu"
                        helpHeading3: labelFavoritesHelpHeading3
                        helpText3: labelFavoritesHelpText3
                        helpImage3: "image://themedimage/widgets/apps/media/blankscreen-music_transfer"
                        Component.onCompleted: {
                            if (settings.get("FavoritesOpenedBefore")) {
                                help.visible = false;
                            } else {
                                settings.set("FavoritesOpenedBefore", 1)
                            }
                        }
                   }
                }
            }
            MusicListView {
                id: listView
                selectionMode: multiSelectMode
                anchors.fill: parent
                anchors.margins: contentMargins
                visible: !noMusicScreen.visible && !noFavorites.visible
                model: favoritesPage.model
                footerHeight: toolbar.height + multibar.height
                onClicked :{
                    if(multiSelectMode)
                    {
                        model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                        listView.selectionChanged();
                        if (model.isSelected(payload.mitemid))
                        {
                            shareObj.addItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                        }
                        else
                        {
                            shareObj.delItem(payload.muri);
                            selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                        }
                        multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                    }
                    else
                    {
                        nowPlayingLabel = labelFavorites;
                        Code.addToPlayqueueAndPlay(payload, 0);
                    }
                }
                onLongPressAndHold: {
                    if( !multiSelectMode ){
                    musicContextMenu(mouseX, mouseY, payload,
                        [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                    multiSelectModel = model;
                    contextMenu.show();}
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
            actionMenuHighlightSelection: true
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
                currentState.page = 6;
                currentState.artist = labelArtist;
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
                    playqueueModel.playindex = 0;
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
                source: "image://themedimage/widgets/common/backgrounds/global-background-texture"

                BorderImage {
                    visible: artistAlbumsGridView.visible
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottomMargin: 5
                    source: "image://themedimage/widgets/apps/media/content-background"
                    border.left:   8
                    border.top:    8
                    border.bottom: 8
                    border.right:  8
                }

                MediaGridView {
                    id: artistAlbumsGridView
                    type: musictype // music app = 0
                    clip: true
                    model: artistDetailViewPage.model
                    anchors.fill: parent
                    anchors.margins: contentMargins
                    visible: false
                    footerHeight: toolbar.height + multibar.height
                    defaultThumbnail: "image://themedimage/images/media/music_thumb_med"
                    onClicked: {
                        if(payload.misvirtual) {
                            return;
                        }
                        Code.openItemInDetailView(artistDetailViewPage,payload)
                    }

                    onLongPressAndHold: {
                        if( !multiSelectMode ){
                        musicContextMenu(mouseX, mouseY, payload,
                            [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                        contextMenu.openpage = artistDetailViewPage;
                        contextMenu.show();}
                    }
                }


                BorderImage {
                    id: artistAlbumsListViewBorder
                    visible: artistAlbumsListView.visible
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottomMargin: 5
                    source: "image://themedimage/widgets/apps/media/content-background"
                    border.left:   8
                    border.top:    8
                    border.bottom: 8
                    border.right:  8
                }

                ListView {
                    id: artistAlbumsListView
                    anchors.fill: parent
                    anchors.margins: contentMargins
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
                        property int mitemcount: tracknum

                        martist: {
                            artist[0] == undefined? labelUnknownArtist:artist[0];
                        }

                        Item {
                            id: albumDetailBackground
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
                                        height: (!(window.isLandscape) ? albumThumbnail.height/9 : 0)
                                        visible: !(window.isLandscape)
                                        width: parent.width
                                        text: mtitle
                                        color: track_title_color
                                        font.pixelSize: theme_fontPixelSizeLarge+10
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        id: albumArtistText
                                        anchors.top: albumTitleText.bottom
                                        anchors.left: parent.left
                                        height: (!(window.isLandscape) ? albumThumbnail.height/9 : 0)
                                        visible: !(window.isLandscape)
                                        width: parent.width
                                        text: martist
                                        color: fontColorMediaArtist
                                        font.pixelSize: theme_fontPixelSizeLarge+10
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        id: albumTrackcountText
                                        anchors.top: albumArtistText.bottom
                                        height: albumThumbnail.height/10
                                        width: parent.width
                                        //: number of tracks in an album
                                        text: qsTr("%n song(s)", "", dinstance.mitemcount)
                                        color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
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
                                        text: Code.formatAlbumLength(dinstance.mlength);
                                        color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
                                        font.pixelSize: theme_fontPixelSizeLarge-3
                                        verticalAlignment:Text.AlignVCenter
                                        horizontalAlignment:Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            Image {
                                id: albumThumbnail
                                smooth:misvirtual? true: false
                                width:312
                                height:345
                                fillMode: Image.Stretch
                                anchors.leftMargin: 15
                                z: 0
                                source: "image://themedimage/widgets/apps/media/tile-border-music-album-large"
                                Image {
                                    z: 10
                                    anchors.topMargin: 33
                                    anchors.bottomMargin: 16
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    anchors.fill: parent
                                    source:(thumburi == ""|thumburi == undefined)?"image://themedimage/images/media/music_thumb_med":thumburi
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
                                        if( !multiSelectMode ){
                                        musicContextMenu(mouseX, mouseY, dinstance,
                                            [labelOpen, labelPlay, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                                        contextMenu.openpage = artistDetailViewPage;
                                        contextMenu.show();}
                                    }
                                }
                            }
                        }

                        MusicListView{
                            id: songsInAlbumList
                            selectionMode: multiSelectMode
                            height: 500
                            width: parent.width
                            interactive: false
                            showHeader: false
                            showThumbnail: false
                            anchors.leftMargin: 7
                            property int headerHeight:0
                            Component.onCompleted: {
                                height = model.count * entryHeight + titleBarHeight + 120 + 40;
                            }
                            listHeader: MusicListHeader {
                                artistName: martist
                                albumTitle: mtitle
                                showDetails: window.isLandscape
                            }
                            listFooter: MusicListHeader {
                                showDetails: false
                                width: listview.width
                                bottomEmptySpace: toolbar.height + multibar.height
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
                                    songsInAlbumList.selectionChanged();
                                    if (model.isSelected(payload.mitemid))
                                    {
                                        shareObj.addItem(payload.muri);
                                        selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                                    }
                                    else
                                    {
                                        shareObj.delItem(payload.muri);
                                        selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                                    }
                                    multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                                }
                                else
                                {
                                    nowPlayingLabel = labelAllArtist;
                                    Code.addToPlayqueueAndPlay(payload, 0);
                                }
                            }
                            onLongPressAndHold: {
                                if( !multiSelectMode ){
                                musicContextMenu(mouseX, mouseY, payload,
                                    [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                                multiSelectModel = model;
                                contextMenu.show();}
                            }
                        }

                        states: [
                            State {
                                name: "landscapeArtistDetailView"
                                when: window.isLandscape
                                PropertyChanges {
                                    target: dinstance
                                    height: Math.max(albumDetailBackground.height, songsInAlbumList.height)
                                }
                                PropertyChanges {
                                    target: artistAlbumsListViewBorder
                                    anchors.leftMargin: albumThumbnail.width + 30 + contentMargins
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
                                when: !window.isLandscape
                                PropertyChanges {
                                    target: dinstance
                                    height: albumDetailBackground.height + songsInAlbumList.height
                                }
                                PropertyChanges {
                                    target: artistAlbumsListViewBorder
                                    anchors.leftMargin: 8
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
            actionMenuHighlightSelection: true
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
                currentState.page = 7;
                currentState.album = labelAlbum;
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
                    playqueueModel.playindex = 0;
                    Code.play();
                }
            }
            Image {
                anchors.fill: parent
                fillMode: Image.Tile
                source: "image://themedimage/widgets/common/backgrounds/global-background-texture"
                BorderImage {
                    id: albumDetailBorder
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottomMargin: 5
                    source: "image://themedimage/widgets/apps/media/content-background"
                    border.left:   8
                    border.top:    8
                    border.bottom: 8
                    border.right:  8
                }
                Item {
                    id: albumDetailBackground
                    anchors.left: parent.left
                    anchors.margins: contentMargins
                    visible: true
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
                                visible: !(window.isLandscape)
                                anchors.top: parent.top
                                height: (visible ? albumThumbnail.height/9 : 0 )
                                width: parent.width
                                text: labelAlbum
                                color: (window.isLandscape ? theme_fontColorMediaHighlight : track_title_color )
                                font.pixelSize: theme_fontPixelSizeLarge+10
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            Text {
                                id: albumArtistText
                                visible: !(window.isLandscape)
                                anchors.top: albumTitleText.bottom
                                height: (visible ? albumThumbnail.height/9 : 0 )
                                width: parent.width
                                text: labelArtist
                                color: fontColorMediaArtist
                                font.pixelSize: theme_fontPixelSizeLarge+10
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            Text {
                                id: albumTrackcountText
                                anchors.top: albumArtistText.bottom
                                height: albumThumbnail.height/10
                                width: parent.width
                                //: number of songs in an album
                                text: qsTr("%n song(s)", "", model.count)
                                color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
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
                                text: Code.formatAlbumLength(currentAlbum.mlength);
                                color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
                                font.pixelSize: theme_fontPixelSizeLarge-3
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment:Text.AlignLeft
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Image {
                        id: albumThumbnail
                        width:312
                        height:345
                        fillMode: Image.Stretch
                        anchors.leftMargin: 15
                        z: 0
                        source: "image://themedimage/widgets/apps/media/tile-border-music-album-large"

                        Image {
                            z: 10
                            anchors.topMargin: 33
                            anchors.bottomMargin: 16
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            anchors.fill: parent
                            source:thumbnailUri
                        }
                    }
                }
                MusicListView{
                    id: albumSongList
                    selectionMode: multiSelectMode
                    model: albumDetailViewPage.model
                    showThumbnail: false
                    showHeader: false
                    anchors.leftMargin: 7
                    anchors.topMargin: 7
                    clip: true
                    listHeader: MusicListHeader {
                        artistName: labelArtist
                        albumTitle: labelAlbum
                        showDetails: window.isLandscape
                    }
                    listFooter: MusicListHeader {
                        showDetails: false
                        bottomEmptySpace: toolbar.height + multibar.height
                    }
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(payload.mitemid, !model.isSelected(payload.mitemid));
                            albumSongList.selectionChanged();
                            if (model.isSelected(payload.mitemid))
                            {
                                shareObj.addItem(payload.muri);
                                selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                            }
                            else
                            {
                                shareObj.delItem(payload.muri);
                                selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                            }
                            multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                        }
                        else
                        {
                            nowPlayingLabel=labelAllAlbums
                            Code.addToPlayqueueAndPlay(payload, 0);
                        }
                    }
                    onLongPressAndHold: {
                        if( !multiSelectMode ){
                        musicContextMenu(mouseX, mouseY, payload,
                            [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelDelete]);
                        multiSelectModel = model;
                        contextMenu.show();}
                    }
                }//End MusicListView
                states: [
                    State {
                        name: "landscapeAlbumDetailsView"
                        when: window.isLandscape
                        PropertyChanges {
                            target: albumDetailBorder
                            anchors.leftMargin: albumThumbnail.width + 30 + contentMargins
                        }
                        PropertyChanges {
                            target: albumDetailBackground
                            width: albumThumbnail.width + 30
                            height: parent.height
                        }
                        PropertyChanges {
                            target: albumDetailText
                            height: albumThumbnail.height/3
                            width: albumThumbnail.width
                        }
                        PropertyChanges {
                            target: albumSongList
                            width: albumDetailBorder.width - 14
                            height: albumDetailBorder.height - 14
                        }
                        AnchorChanges {
                            target: albumDetailBackground
                            anchors.left:parent.left
                            anchors.top: parent.top
                        }
                        AnchorChanges {
                            target:albumSongList
                            anchors.left:albumDetailBorder.left
                            anchors.top:albumDetailBorder.top
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
                        when: !window.isLandscape
                        PropertyChanges {
                            target: albumDetailBorder
                            anchors.leftMargin: 8
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
                            target: albumSongList
                            width: albumDetailBorder.width - 14
                            height: albumDetailBorder.height - albumDetailBackground.height - 14
                        }

                        AnchorChanges {
                            target: albumDetailBackground
                            anchors.left:parent.left
                            anchors.top: parent.top
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
                            anchors.left:albumDetailBorder.left
                            anchors.top:albumDetailBackground.bottom
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: playlistDetailViewContent
        AppPage {
            id: playlistDetailViewPage
            anchors.fill: parent
            pageTitle: labelPlaylist
            property bool infocus: true
            onActivated : {
                infocus = true;
                window.disableToolBarSearch = true;
                Code.getSomeThumbnailsForPlaylist( model );
                currentState.page = 8;
                currentState.playlist = labelPlaylist;
            }
            onDeactivated : { infocus = false; }

            property alias model: playlistSongList.model
            Connections {
                target: toolbar
                onPlayNeedsSongs: {
                    playqueueModel.clear();
                    playqueueModel.addItems(model.getAllIDs());
                    playqueueModel.playindex = 0;
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
                    renamePlaylistDialog.playListModel = playlistSongList.model;
                    renamePlaylistDialog.show();
                }
                else if(selectedItem == "clear")
                {
                    playlistSongList.model.clearPlaylist();
                }
            }
            Image {
                id: box
                anchors.fill: parent
                fillMode: Image.Tile
                source: "image://themedimage/widgets/common/backgrounds/global-background-texture"

                MusicPlaylistThumbnail {
                    id: playlistThumbnail
                    width:400
                    height:width
                    z:(window.isLandscape ? 0 : 3)
                }

                Item{
                    id: playlistDurationDisplay
                    z:(window.isLandscape ? 0 : 3)
                    width: (playlistThumbnail.width*3)/4
                    Text {
                        id: playlistLengthText
                        anchors.top: parent.top
                        height: playlistThumbnail.height/10
                        width: parent.width
                        text: Code.formatAlbumLength(currentPlaylist.mlength);
                        color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
                        font.pixelSize: theme_fontPixelSizeLarge-3
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment:Text.AlignLeft
                        elide: Text.ElideRight
                    }
                    Text {
                        id: playlistTrackcountText
                        anchors.top: playlistLengthText.bottom
                        height: playlistThumbnail.height/10
                        width: parent.width
                        text: qsTr("%1 songs").arg(playlistSongList.model.count)
                        color: (window.isLandscape ? theme_fontColorMediaHighlight : fontColorMediaArtist )
                        font.pixelSize: theme_fontPixelSizeLarge-3
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment:Text.AlignLeft
                        elide: Text.ElideRight
                    }
                }

                BorderImage {
                    id: playlistContentBorder
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottomMargin: 5
                    source: "image://themedimage/widgets/apps/media/content-background"
                    border.left:   8
                    border.top:    8
                    border.bottom: 8
                    border.right:  8
                }

                Text {
                    id: tPlaylist
                    text: labelPlaylist
                    height:50
                    verticalAlignment:Text.AlignVCenter
                    horizontalAlignment:Text.AlignLeft
                    elide:Text.ElideRight
                    font.pixelSize: theme_fontPixelSizeLarge+10
                    color: track_title_color
                    visible: !window.isLandscape
                }
                MusicListView {
                    id: playlistSongList
                    selectionMode: multiSelectMode
                    anchors.margins: 7
                    selectbyindex: true
                    showHeader: false
                    clip: true
                    listHeader: MusicListHeader {
                        artistName: ""
                        albumTitle: labelPlaylist
                        showDetails: window.isLandscape
                    }
                    listFooter: MusicListHeader {
                        showDetails: false
                        bottomEmptySpace: toolbar.height + multibar.height
                    }
                    model: MusicListModel {
                        type: MusicListModel.MusicPlaylist
                        playlist: labelPlaylist
                        limit: 0
                        sort:MusicListModel.SortByDefault
                        onPlaylistChanged: {
                            playlistSongList.currentIndex = -1;
                        }
                    }
                    onClicked: {
                        if(multiSelectMode)
                        {
                            model.setSelected(index, !model.isSelected(index));
                            playlistSongList.selectionChanged();
                            if (model.isSelected(index))
                            {
                                shareObj.addItem(payload.muri);
                                selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                            }
                            else
                            {
                                shareObj.delItem(payload.muri);
                                selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                            }
                            multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
                        }
                        else
                        {
                            nowPlayingLabel = labelAllPlaylist;
                            Code.addToPlayqueueAndPlay(payload, 0);
                            Code.getNowPlayingThumbnailForPlaylist();
                        }
                    }
                    onLongPressAndHold: {
                        if( !multiSelectMode ){
                        targetIndex = index;
                        musicContextMenu(mouseX, mouseY, payload,
                            [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlayQueue, labelAddToPlaylist, labelRemFromPlaylist]);
                        multiSelectModel = model;
                        contextMenu.playlistmodel = playlistSongList.model;
                        contextMenu.show();}
                    }
                }
            }
            states: [
                State {
                    name: "landscapePlaylistDetailView"
                    when: window.isLandscape
                    PropertyChanges {
                        target: tPlaylist
                        width: parent.width -15
                        anchors.leftMargin:15
                    }
                    PropertyChanges {
                        target: playlistThumbnail
                        anchors.leftMargin:5
                    }
                    PropertyChanges {
                        target: playlistContentBorder
                        anchors.leftMargin: playlistThumbnail.width// + playlistThumbnail.anchors.leftMargin + playlistThumbnail.anchors.rightMargin
                    }
                    AnchorChanges {
                        target: playlistSongList
                        anchors.top: playlistContentBorder.top
                        anchors.left: playlistContentBorder.left
                        anchors.right: playlistContentBorder.right
                        anchors.bottom: playlistContentBorder.bottom
                    }

                    AnchorChanges {
                        target: playlistThumbnail
                        anchors.left:parent.left
                        anchors.top: parent.top
                    }

                    AnchorChanges {
                        target: tPlaylist
                        anchors.left:parent.left
                        anchors.top:playlistContentBorder.top
                    }
                    AnchorChanges {
                        target:playlistContentBorder
                        anchors.top: playlistThumbnail.top
                    }
                    AnchorChanges {
                        target: playlistDurationDisplay
                        anchors.top: playlistThumbnail.bottom
                        anchors.horizontalCenter: playlistThumbnail.horizontalCenter
                    }
                },
                State {
                    name: "portraitPlaylistDetailView"
                    when: !window.isLandscape
                    PropertyChanges {
                        target: tPlaylist
                        width:parent.width - playlistThumbnail.width -5
                        anchors.leftMargin:5

                    }
                    PropertyChanges {
                        target: playlistThumbnail
                        anchors.leftMargin:5
                        anchors.topMargin: 5
                    }
                    PropertyChanges {
                        target: playlistSongList
                        width:parent.width - 5
                        height:parent.height - playlistThumbnail.height
                    }
                    AnchorChanges {
                        target: playlistSongList
                        anchors.top: playlistThumbnail.bottom
                        anchors.left: playlistContentBorder.left
                        anchors.right: playlistContentBorder.right
                        anchors.bottom: playlistContentBorder.bottom
                    }

                    AnchorChanges {
                        target: playlistThumbnail
                        anchors.left:playlistContentBorder.left
                        anchors.top: playlistContentBorder.top
                    }

                    AnchorChanges {
                        target: tPlaylist
                        anchors.left:playlistThumbnail.right
                        anchors.top: playlistThumbnail.verticalCenter
                    }
                    AnchorChanges {
                        target:playlistContentBorder
                        anchors.left:parent.left
                        anchors.top:playlistThumbnail.bottom
                    }
                    AnchorChanges {
                        target: playlistDurationDisplay
                        anchors.top: tPlaylist.bottom
                        anchors.left: tPlaylist.left
                    }
                }
            ]
        }
    }

    MusicListView {
        id: playqueueView
        selectionMode: multiSelectMode
        parent: parkingLot
        anchors.fill: parent
        anchors.margins: contentMargins
        model: playqueueModel
        selectbyindex: true
        playqueue: true
        footerHeight: parent.height - titleBarHeight
        onClicked:{
            if(multiSelectMode)
            {
                model.setSelected(index, !model.isSelected(index));
                playqueueView.selectionChanged();
                if (model.isSelected(index))
                {
                    shareObj.addItem(payload.muri);
                    selectedFavoritesAccumulator += (payload.mfavorite?1:-1);
                }
                else
                {
                    shareObj.delItem(payload.muri);
                    selectedFavoritesAccumulator += (payload.mfavorite?-1:1);
                }
                multiSelectModeShowFavoriteAction = (selectedFavoritesAccumulator <= 0) ? true : false;
            }
            else
            {
                nowPlayingLabel = labelPlayqueue;
                playqueueModel.playindex = index;
                playqueueView.currentIndex = index;
                Code.playNewSong(0);
            }
        }
        onLongPressAndHold:{
            if( !multiSelectMode ){
            targetIndex = index;
            musicContextMenu(mouseX, mouseY, payload,
                [labelPlay, "favorite", labelcShare, labelMultiSelect, labelAddToPlaylist, labelRemoveFromPlayQueue]);
            multiSelectModel = model;
            contextMenu.show();}
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
