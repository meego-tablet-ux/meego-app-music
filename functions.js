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
    updateNowNextPlaying();
}

function addMultipleToPlayqueue() {
    playqueueModel.addItems(getSelectedIDs());
    updateNowNextPlaying();
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function removeFromPlayqueue() {
    if(playqueueModel.playindex == targetIndex)
    {
        audio.stop();
        resourceManager.userwantsplayback = false;
    }
    playqueueModel.removeIndex(targetIndex);
    updateNowNextPlaying();
}

function removeFromPlaylist(list) {
    list.removeIndex(targetIndex);
    clearSelected();
}

function removeMultipleFromPlayqueue() {
    var playid = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.ID);
    var ids = getSelectedIDs();
    var i;
    for (i in ids) {
        if(ids[i] == playid)
        {
            audio.stop();
            resourceManager.userwantsplayback = false;
            break;
        }
    }
    playqueueModel.removeSelected();
    updateNowNextPlaying();
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function removeMultipleFromPlaylist(list) {
    list.removeSelected();
    clearSelected();
    shareObj.clearItems();
    multiSelectMode = false;
}

function addToPlayqueueAndPlay(item)
{
    var idx = playqueueModel.count;
    addToPlayqueue(item);
    playqueueModel.playindex = idx;
    playNewSong();
    updateNowNextPlaying();
}

function addMultipleToPlayqueueAndPlay()
{
    var ids = getSelectedIDs();
    var idx = playqueueModel.count;
    playqueueModel.addItems(ids);
    playqueueModel.playindex = idx;
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
    playqueueModel.playstatus = MusicListModel.Playing;
    toolbar.playing = true;
}

function pause()
{
    audio.pause();
    resourceManager.userwantsplayback = false;
    dbusControl.playbackState = 2;
    playqueueModel.playstatus = MusicListModel.Paused;
    toolbar.playing = false;
}

function stop()
{
    audio.stop();
    currentState.command = "stop";
    resourceManager.userwantsplayback = false;
    dbusControl.updateNowNextTracks();
    dbusControl.playbackState = 3;
    playqueueModel.playstatus = MusicListModel.Stopped;
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
    if((playqueueView.count <= 0)||
       (playqueueModel.playindex >= playqueueView.count))
    {
        return false;
    }

    if (playqueueModel.playindex == -1)
        playqueueModel.playindex = 0;

    toolbar.trackName = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title);
    try {
        toolbar.artistName = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Artist)[0];
    }
    catch(err) {
        toolbar.artistName = "";
    }

    audio.source = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URI);
    audioplay();
    editorModel.setViewed(playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.ID));
    return true;
}

function playNextSong() {
    if (playqueueModel.playindex < (playqueueView.count -1))
    {
        playqueueModel.playindex++;
    }
    else
    {
        if (loop){
            playqueueModel.playindex = 0;
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
    if (playqueueModel.playindex == 0)
    {
        if (loop) {
            playqueueModel.playindex = playqueueView.count - 1;
        }else {
            stop();
            return;
        }
    }
    else
    {
        playqueueModel.playindex--;
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
    } else  if (playqueueModel.playindex == 0) {
        if (playqueueView.count == 1) {
            dbusControl.nextItem1 = -1;
            dbusControl.nextItem2 = -1;
        } else if (playqueueView.count == 2) {
            dbusControl.nextItem1 = 1;
            dbusControl.nextItem2 = -1;
        } else {
            dbusControl.nextItem1 = 1;
            dbusControl.nextItem2 = 2;
        }
    } else {
        if (playqueueModel.playindex+1 < playqueueView.count) {
            dbusControl.nextItem1 = playqueueModel.playindex+1;

            if (dbusControl.nextItem1+1 < playqueueView.count) {
                dbusControl.nextItem2 = dbusControl.nextItem1+1;
            } else if (loop && playqueueView.count > 2) {
                dbusControl.nextItem2 = 0
            } else {
                dbusControl.nextItem2 = -1;
            }

        } else if (loop && playqueueView.count > 1) {
            dbusControl.nextItem1 = 0;
            if (playqueueView.count > 2) {
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
        //: music album length in seconds
        time = qsTr("%n second(s)", "", secs);
    }
    else
    {
        if( hours == 0 )
        {//only show minutes
            //: music album length in minutes
            time = qsTr("%n minute(s)", "", mins);
        }
        else
        {
            if( mins == 0 )
            {//only show hours
                //: music album length in hours
                time = qsTr("%n hour(s)", "", hours);
            }
            else
            {//show hours and minutes
                var time_mins = qsTr("%n minute(s)", "", mins);
                var time_hours = qsTr("%n hour(s)", "", hours);
                //: %1 is "%n hour(s)", %2 is "%n minute(s)"
                time = qsTr("%1 %2").arg(time_hours).arg(time_mins);
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

function songCheck(cdata)
{
    // if the song ands in .desktop, it's not a song
    return (cdata.indexOf(".desktop", cdata.length - 8) == -1);
}

function getSomeThumbnailsForPlaylist( model )
{
    stackThumbnailUriCurr = "";
    stackThumbnailUri1 = "";
    stackThumbnailUri2 = "";
    stackThumbnailUri3 = "";
    stackThumbnailUri4 = "";

    var uri;
    var curr_uri = playqueueModel.datafromIndex( playqueueModel.playindex, MediaItem.ThumbURI );
    var playlistIds = model.getAllIDs();
    var currAppearsInPlaylist=false

    var i;
    var a;
    for (i in playlistIds)
    {
        uri = model.datafromID(playlistIds[i], MediaItem.ThumbURI )
        if( uri == curr_uri ){ currAppearsInPlaylist = true; }
        if( stackThumbnailUri1 == uri ){ continue;}
        if( stackThumbnailUri2 == uri ){ continue;}
        if( stackThumbnailUri3 == uri ){ continue;}
        if( stackThumbnailUri4 == uri ){ continue;}
        if( stackThumbnailUri1 == "" && stackThumbnailUri1 != uri ){ stackThumbnailUri1 = uri; continue; }
        if( stackThumbnailUri2 == "" && stackThumbnailUri2 != uri ){ stackThumbnailUri2 = uri; continue; }
        if( stackThumbnailUri3 == "" && stackThumbnailUri3 != uri ){ stackThumbnailUri3 = uri; continue; }
        if( stackThumbnailUri4 == "" && stackThumbnailUri4 != uri ){ stackThumbnailUri4 = uri; continue; }
    }
    if( stackThumbnailUri1 == "" ){ stackThumbnailUri1 = "image://themedimage/images/media/music_thumb_med";}
    if( stackThumbnailUri2 == "" ){ stackThumbnailUri2 = "image://themedimage/images/media/music_thumb_med";}
    if( stackThumbnailUri3 == "" ){ stackThumbnailUri3 = "image://themedimage/images/media/music_thumb_med";}
    if( stackThumbnailUri4 == "" ){ stackThumbnailUri4 = "image://themedimage/images/media/music_thumb_med";}
    if( currAppearsInPlaylist )
        {stackThumbnailUriCurr = (curr_uri == undefined ? "image://themedimage/images/media/music_thumb_med" : curr_uri );}
    else
        {stackThumbnailUriCurr = stackThumbnailUri4;}
    if( stackThumbnailUriCurr == "" ){stackThumbnailUriCurr = "image://themedimage/images/media/music_thumb_med";}
    playlistAnimationNeeded=!playlistAnimationNeeded;
}

function getNowPlayingThumbnailForPlaylist( )
{
    var olduri = stackThumbnailUriCurr;
    var uri = playqueueModel.datafromIndex( playqueueModel.playindex, MediaItem.ThumbURI );
    stackThumbnailUriCurr = (uri == undefined ? "image://themedimage/images/media/music_thumb_med" : uri );

    if( stackThumbnailUriCurr == "" ){stackThumbnailUriCurr = "image://themedimage/images/media/music_thumb_med";}

    if( olduri != stackThumbnailUriCurr )
    {
        globalNewAngle = randomAngle(2,10,(playlistAnimationNeeded?1:-1));
        stackThumbnailUri4 = stackThumbnailUri3;
        stackThumbnailUri3 = stackThumbnailUri2;
        stackThumbnailUri2 = stackThumbnailUri1;
        stackThumbnailUri1 = olduri;
        playlistAnimationNeeded=!playlistAnimationNeeded;
    }
}

function randomAngle( start, end, sign )
{
    var today = new Date();
    var randSeed = today.getTime();
    var diff = end-start;
    return sign * (start + diff*Math.random(randSeed));
}
