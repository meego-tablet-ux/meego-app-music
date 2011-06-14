/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

function selectionCount()
{
    switch(multiSelectModel.type) {
    case MusicListModel.NowPlaying:
    case MusicListModel.MusicPlaylist:
        return multiSelectModel.selectionCount(MusicListModel.SelectByIndex);
    default:
        return multiSelectModel.selectionCount(MusicListModel.SelectByID);
    }
}

function clearSelected()
{
    switch(multiSelectModel.type) {
    case MusicListModel.NowPlaying:
    case MusicListModel.MusicPlaylist:
        multiSelectModel.clearSelected(MusicListModel.SelectByIndex);
        break;
    default:
        multiSelectModel.clearSelected(MusicListModel.SelectByID);
    }
}

function getSelectedURIs()
{
    switch(multiSelectModel.type) {
    case MusicListModel.NowPlaying:
    case MusicListModel.MusicPlaylist:
        return multiSelectModel.getSelectedURIs(MusicListModel.SelectByIndex);
    default:
        return multiSelectModel.getSelectedURIs(MusicListModel.SelectByID);
    }
}

function getSelectedIDs()
{
    switch(multiSelectModel.type) {
    case MusicListModel.NowPlaying:
    case MusicListModel.MusicPlaylist:
        return multiSelectModel.getSelectedIDs(MusicListModel.SelectByIndex);
    default:
        return multiSelectModel.getSelectedIDs(MusicListModel.SelectByID);
    }
}

function playlistNameValidate(parm,val) {
    if (parm == "") return true;
    for (var i=0; i<parm.length; i++) {
        if (val.indexOf(parm.charAt(i),0) != -1) return false;
    }
    return true;
}

function addToPlayqueue(item) {
    playqueueModel.addItems(item.mitemid);
    if( activePlayingListModel == playqueueModel ){
        updateNowNextPlaying();
    }
}

function addMultipleToPlayqueue() {
    playqueueModel.addItems(getSelectedIDs());
    if( activePlayingListModel == playqueueModel ){
        updateNowNextPlaying();
    }
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function removeFromPlayqueue() {
    if( activePlayingListModel == playqueueModel && activePlayingListModel.playindex == targetIndex ){
        //pause();
        //resourceManager.userwantsplayback = false;
    }
    if( activePlayingListModel == playqueueModel )
        {dropFromActivePlayingList(activePlayingListModel.datafromIndex(targetIndex, MediaItem.ID));}//remove and take care of moving to the next item
    else
        {playqueueModel.removeIndex(targetIndex);}//just remove
}

function removeFromPlaylist(list) {
    //Handle removing a song from the playlist that we are playing
    if( activePlayingListModel == nowPlayingModel &&
        nowPlayingLabel == "Playlist" &&
        nowPlayingName == list.playlist )
    {
        console.log("do removeFromPlaylist: "+list.playlist);
        dropFromActivePlayingList(activePlayingListModel.datafromIndex(targetIndex, MediaItem.ID));
    }
    list.removeIndex(targetIndex);//the playlist is separate from "now playing", remove also from the actual list
    clearSelected();
}

function removeMultipleFromPlayqueue() {
    if( activePlayingListModel == playqueueModel )
        {dropFromActivePlayingList(-1);}//remove and take care of moving to the right item
    else
        {playqueueModel.removeSelected();}
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function removeMultipleFromPlaylist(list) {
    console.log("removeMultipleFromPlaylist: "+list.album);
    //Handle removing a song from the playlist that we are playing
    if( activePlayingListModel == nowPlayingModel &&
        nowPlayingLabel == "Playlist" &&
        nowPlayingName == list.playlist )
    {
        console.log("do removeMultipleFromPlaylist: "+list.playlist);
        dropFromActivePlayingList(-1);
    }
    list.removeSelected();//playlist separate from "now playing"
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function addToPlayqueueAndPlay(item)
{
    activePlayingListModel = playqueueModel;
    activePlayingListView  = playqueueView;
    var idx = activePlayingListModel.count;
    addToPlayqueue(item);
    activePlayingListModel.playindex = idx;
    playNewSong();
    updateNowNextPlaying();
}

function addMultipleToPlayqueueAndPlay()
{
    activePlayingListModel = playqueueModel;
    activePlayingListView  = playqueueView;
    var ids = getSelectedIDs();
    var idx = activePlayingListModel.count;
    activePlayingListModel.addItems(ids);
    activePlayingListModel.playindex = idx;
    playNewSong();
    updateNowNextPlaying();
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function changeItemFavorite(item, val) {
    editorModel.setFavorite(item.mitemid,val);
}

function changeMultipleItemFavorite(val) {
    var ids = getSelectedIDs();
    var i;
    for (i in ids) {
        editorModel.setFavorite(ids[i], val);
    }
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function audioplay()
{
    resourceManager.userwantsplayback = true;
    dbusControl.updateNowNextTracks();
    dbusControl.playbackState = 1;
    activePlayingListModel.playstatus = MusicListModel.Playing;
    toolbar.playing = true;
}

function pause()
{
    audio.pause();
    resourceManager.userwantsplayback = false;
    dbusControl.playbackState = 2;
    activePlayingListModel.playstatus = MusicListModel.Paused;
    toolbar.playing = false;
}

function stop()
{
    audio.stop();
    resourceManager.userwantsplayback = false;
    dbusControl.updateNowNextTracks();
    dbusControl.playbackState = 3;
    activePlayingListModel.playstatus = MusicListModel.Stopped;
    toolbar.playing = false;
}


function play()
{
    if (audio.paused ) {
        audioplay();
    } else {
        return playNewSong();
    }
    return true;
}

function playNewSong() {
    audio.stop();

    // if there are no songs or the index is out of range, do nothing
    if((activePlayingListView.count <= 0)||
       (activePlayingListModel.playindex >= activePlayingListView.count))
    {
        return false;
    }

    if (activePlayingListModel.playindex == -1)
        activePlayingListModel.playindex = 0;

    audio.source = activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.URI);
    audioplay();
    editorModel.setViewed(activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.ID));

    toolbar.trackName = activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.Title);
    try {
        toolbar.artistName = activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.Artist)[0];
    }
    catch(err) {
	toolbar.artistName = "";
    }
    if( activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.ThumbURI)) {
        toolbar.albumThumbnailURI = activePlayingListModel.datafromIndex(activePlayingListModel.playindex, MediaItem.ThumbURI);
    } else {
        toolbar.albumThumbnailURI = ""
    }
    return true;
}

function playNextSong() {
    if (activePlayingListModel.playindex < (activePlayingListView.count -1))
    {
        activePlayingListModel.playindex++;
    }
    else
    {
        if (loop){
            activePlayingListModel.playindex = 0;
        }else{
            stop();
            return;
        }
    }
    audio.source = "";
    playNewSong();
    updateNowNextPlaying();
}

function playPrevSong() {
    if (activePlayingListModel.playindex == 0)
    {
        if (loop) {
            activePlayingListModel.playindex = activePlayingListView.count - 1;
        }else {
            stop();
            return;
        }
    }
    else
    {
        activePlayingListModel.playindex--;
    }
    audio.source = "";
    playNewSong();
    updateNowNextPlaying();
}

function updateNowNextPlaying()
{
    if (dbusControl.state == "stopped") {
        dbusControl.nextItem1 = -1;
        dbusControl.nextItem2 = -1;
    } else  if (activePlayingListModel.playindex == 0) {
        if (activePlayingListView.count == 1) {
            dbusControl.nextItem1 = -1;
            dbusControl.nextItem2 = -1;
        } else if (activePlayingListView.count == 2) {
            dbusControl.nextItem1 = 1;
            dbusControl.nextItem2 = -1;
        } else {
            dbusControl.nextItem1 = 1;
            dbusControl.nextItem2 = 2;
        }
    } else {
        if (activePlayingListModel.playindex+1 < activePlayingListView.count) {
            dbusControl.nextItem1 = activePlayingListModel.playindex+1;

            if (dbusControl.nextItem1+1 < activePlayingListView.count) {
                dbusControl.nextItem2 = dbusControl.nextItem1+1;
            } else if (loop && activePlayingListView.count > 2) {
                dbusControl.nextItem2 = 0
            } else {
                dbusControl.nextItem2 = -1;
            }

        } else if (loop && activePlayingListView.count > 1) {
            dbusControl.nextItem1 = 0;
            if (activePlayingListView.count > 2) {
                dbusControl.nextItem2 = 1;
            } else {
                dbusControl.nextItem2 = -1
            }
        } else {
            dbusControl.nextItem1 = -1;
            dbusControl.nextItem2 = -1;
        }
    }
    dbusControl.updateNowNextTracks();
}

function formatLength(time)
{
    var val = parseInt(time);
    var dec = parseInt((time-val)*10);
    return (dec == 0)?val:(val + "." + dec)
}

function formatAlbumLength(length)
{
    var hours = parseInt(length/3600);
    var mins = parseInt( (length%3600)/60 );
    var time = "";
    if( hours == 0 && mins == 0 )
    {//only show seconds
        var secs = parseInt( length%3600 );
        // music album length in seconds
        time = (secs==1) ? qsTr("1 second") : qsTr("%1 seconds").arg(secs);
    }
    else
    {
        if( hours == 0 )
        {//only show minutes
            // music album length in minutes
            time = (mins==1) ? qsTr("1 minute") : qsTr("%1 minutes").arg(mins);
        }
        else
        {
            if( mins == 0 )
            {//only show hours
                // music album length in hours
                time = ((hours == 1) ? qsTr("1 hour") : qsTr("%1 hours").arg(hours));
            }
            else
            {//show hours and minutes
                // music album length in hours and minutes
                time = ((hours == 1) ? qsTr("1 hour") : qsTr("%1 hours").arg(hours)) + ((mins == 1) ? qsTr(" 1 minute") : qsTr(" %1 minutes").arg(mins));
            }
        }
    }
    return time
}

function formatTime(time)
{
    var min = parseInt(time/60);
    var sec = parseInt(time%60);
    return min+ (sec<10 ? ":0":":") + sec
}

function openItemInDetailView(fromPage, item)
{
    switch(item.mitemtype) {
    case 2:
        // type is song
        // no detail view
        break;
    case 3:
        // type is artist
        labelArtist = item.mtitle;
        window.addPage(artistDetailViewContent);
        break;
    case 4:
        // type is album
        thumbnailUri = item.mthumburi;
        labelAlbum = item.mtitle;
        currentAlbum = item;
        window.addPage(albumDetailViewContent);
        break;
    case 5:
        // type is playlist
        thumbnailUri = item.mthumburi;
        labelPlaylist = item.mtitle;
        labelPlaylistURN = item.murn;
        window.addPage(playlistDetailViewContent);
        break;
    default:
        break;
    }
}

function appendItemToPlaylist(item, playlistItem)
{
    miscModel.type = MusicListModel.MusicPlaylist;
    miscModel.clear();
    miscModel.playlist = playlistItem.mtitle;
    miscModel.addItems(item.mitemid);
}

//Functions to support playing from the current context
function playAndAddContextToNowPlaying(item)
{
    activePlayingListModel = nowPlayingModel;
    activePlayingListView = nowPlayingView;
    nowPlayingModel.clear();
    var ids = currentListModel.getAllIDs();
    var i;
    for (i in ids) {
        activePlayingListModel.addItems(ids[i]);
    }
    var idx = nowPlayingModel.itemIndex(item.mitemid);

    nowPlayingModel.playindex = idx;
    updateNowNextPlaying();
    playNewSong();
}

//Items are to be removed from the active playing model
//This is appropriate when a) we are removing items from the queue, playlists, favorites, or
//b) when we are actually removing files.
function dropFromActivePlayingList( itemid ){
    console.log("---- dropFromActivePlayingList");
    var playid = activePlayingListModel.datafromIndex( activePlayingListModel.playindex, MediaItem.ID );
    if( itemid == -1 )//No item given, implies multiselection
    {
        //First adjust playindex to account for lost items before the current playindex
        var ids = getSelectedIDs();
        var ai;//index in active
        var i;
        for (ai=0;ai < activePlayingListModel.playindex;++ai)
            {
            for (i in ids) {
                if(ids[i] == activePlayingListModel.datafromIndex(ai, MediaItem.ID)){
                    activePlayingListModel.playindex--;
                    break;
                }
            }
        }
        console.log("---- Playindex adjusted to: "+activePlayingListModel.playindex);
        //Remove selected items from the active playing list
        activePlayingListModel.removeSelected();
    }
    else//single item
    {
        //First adjust playindex to account for lost items before the current playindex
        if( activePlayingListModel.itemIndex( itemid ) < activePlayingListModel.playindex ){
            activePlayingListModel.playindex--;
        }
        activePlayingListModel.removeIndex(targetIndex);
    }
    // if there are no songs or the index is out of range, do nothing
    if (activePlayingListModel.playindex == -1 ||
        activePlayingListModel.playindex >= activePlayingListView.count)
        {activePlayingListModel.playindex = 0;}
    if( activePlayingListView.count > 0 ){
        playNewSong();
    }
    else
    {
        pause();
        toolbar.makeVisible = false;
    }
}

function songCheck(cdata)
{
    // if the song ands in .desktop, it's not a song
    return (cdata.indexOf(".desktop", cdata.length - 8) == -1);
}
