/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

var dragComponent = null;
var dragitem = null;
var currentView = null;
var currentItem = null
var startPos = null;

function playlistNameValidate(parm,val) {
    if (parm == "") return true;
    for (var i=0; i<parm.length; i++) {
        if (val.indexOf(parm.charAt(i),0) != -1) return false;
    }
    return true;
}

function startDrag(mouse,view,item) {
    if (view == null || item == null)
        return;

    if (dragitem != null) {
        dragitem.destroy();
        dragitem = null;
    }

     dragComponent = view.delegate;

    currentView = view;
    currentItem = item;
    startPos = item.mapToItem(scene,mouse.x, mouse.y);

    if (dragComponent.status == Component.Loading) {
        component.statusChanged.connect(createItem);
    }else{
        createItem();
    }
}

// this function will return type SONG(2),ARTIST(3),ALBUM(4) or PLAYLIST(5) from MediaItem
// depending on the input type, which is one of the ModelType
// we can't access MediaItem from here, so hardcoded the enum value
function convertListType(type) {
    switch (type) {
    case MusicListModel.ListofSongs:
            return 2;

    case MusicListModel.ListofAlbums:
            return 4;

    case MusicListModel.ListofArtists:
            return 3;

    case MusicListModel.ListofPlaylists:
            return 5;

    case MusicListModel.ListofAlbumsForArtist:
            return 4;

    case MusicListModel.ListofSongsForAlbum:
            return 2;

    case MusicListModel.ListofSongsForArtist:
            return 2;

    case MusicListModel.ListofRecentlyPlayed:
            // special case
            return currentItem.mtype;

    case MusicListModel.MusicPlaylist:
            return 5;

    default:
            return -1;
    }
}

function createItem() {
    dragitem = dragComponent.createObject(scene);
    // set dragitem position:

    dragitem.x = startPos.x;
    dragitem.y = startPos.y;

    dragitem.mtitle = currentItem.mtitle;
    dragitem.mthumburi = currentItem.mthumburi;
    dragitem.mitemid = currentItem.mitemid;
    dragitem.mitemtype = currentItem.mitemtype;
    dragitem.opacity = 0.8;
    dragitem.mcount = currentItem.mcount;
    dragitem.martist = currentItem.martist;
}

// return true if the point is in item's area,
// the point should be in the item's coordinate system.
function itemContainsPoint(item, point) {
    if ( point.x >=0 && point.x < item.width
         && point.y >= 0 && point.y < item.height) {
        return true;
    }
    return false;
}

function moveDragItem(mouse,item) {

    if (dragitem == null)
        return;

    var pos = item.mapToItem(scene,mouse.x, mouse.y);
    dragitem.x = pos.x;
    dragitem.y = pos.y;

    if (sideContentStrip.activeContent.tabs) {
        for (var i = 0;  i < sideContentStrip.activeContent.tabs.length -1; i++) {
            var it = sideContentStrip.activeContent.tabs[i];
            var pt = item.mapToItem(it,mouse.x, mouse.y);
            if (itemContainsPoint(it,pt)) {
                sideContentStrip.activeContent.selectTabAtIndex(i);
                sideContentStrip.activeContent.open();
                return;
            }
        }

        // specific code for landingscreen side content
        if (sideContentStrip.activeContent.currentTabIndex == 1) {
            var view = sideContentStrip.activeContent.currentTab.playlistList;
            var map = item.mapToItem(view, mouse.x, mouse.y);
            var targetIndex = view.indexAt(map.x  , map.y + view.contentY);
            if (targetIndex != -1) {
                view.currentIndex = targetIndex;

               view.highlightItem.opacity = 0.4;
            }else {
               view.highlightItem.opacity = 0;
            }
        }
    }

}

function endDrag(mouse,item) {
    if (!dragitem) {
        return;
    }

    // check if dropped at now playing button,
    // if yes, add to now playing list
    var dropPos = item.mapToItem(npRect,mouse.x,mouse.y);
    if (dropPos.x > 0 && dropPos.x < npRect.width
        && dropPos.y > 0 && dropPos.y < npRect.height)
    {
        addToPlayqueue(item);
    }else {
        if (sideContentStrip.activeContent.currentTabIndex == 1) {
            var view = sideContentStrip.activeContent.currentTab.playlistList;
            var map = item.mapToItem(view, mouse.x, mouse.y) ;
            var targetIndex = view.indexAt(map.x  , map.y + view.contentY);
            if (targetIndex != -1) {
                appendItemToPlaylist(item,view.currentItem);
            }
            view.highlightItem.opacity = 0;
        }
    }

    if (dragitem != null) {
        dragitem.destroy(dragitem.animation == true? 500: 0);
        dragitem = null;
        currentView = null;
        currentItem = null;
        startPos = null;
        dragComponent == null
    }else {
        return;
    }
    updateNowNextPlaying();
}

function addToPlayqueue(item) {
    playqueueModel.addItems(item.mitemid);
    updateNowNextPlaying();
}

function addMultipleToPlayqueue(list) {
    playqueueModel.addItems(list.getSelectedIDs());
    updateNowNextPlaying();
    list.clearSelected();
    multibar.sharing.clearItems();
    multiSelectMode = false;
}

function removeFromPlayqueue(item) {
    if(playqueueView.currentIndex == playqueueModel.itemIndex(item.mitemid))
    {
        audio.stop();
    }
    playqueueModel.removeItems(item.mitemid);
    updateNowNextPlaying();
}

function removeMultipleFromPlayqueue(list) {
    var ids = list.getSelectedIDs();
    var i;
    for (i in ids) {
        if(playqueueView.currentIndex == playqueueModel.itemIndex(ids[i]))
        {
            audio.stop();
            break;
        }
    }
    playqueueModel.removeItems(ids);
    updateNowNextPlaying();
    list.clearSelected();
    multibar.sharing.clearItems();
    multiSelectMode = false;
}

function addToPlayqueueAndPlay(item)
{
    addToPlayqueue(item);
    playqueueView.currentIndex = playqueueModel.itemIndex(item.mitemid);
    console.log("Item Index is: " + playqueueModel.itemIndex(item.mitemid) + " " + item.mtitle);
    playNewSong();
    updateNowNextPlaying();
}

function addMultipleToPlayqueueAndPlay(list)
{
    var ids = list.getSelectedIDs();
    playqueueModel.addItems(ids);
    playqueueView.currentIndex = playqueueModel.itemIndex(ids[0]);
    playNewSong();
    updateNowNextPlaying();
    list.clearSelected();
    multibar.sharing.clearItems();
    multiSelectMode = false;
}

function changeItemFavorite(item, val) {
    editorModel.setFavorite(item.mitemid,val);
}

function changeMultipleItemFavorite(list, val) {
    var ids = list.getSelectedIDs();
    var i;
    for (i in ids) {
        editorModel.setFavorite(ids[i], val);
    }
    list.clearSelected();
    multibar.sharing.clearItems();
    multiSelectMode = false;
}

function play()
{
    if (audio.paused ) {
        audio.play();
    } else {
        return playNewSong();
    }
    return true;
}

function playNewSong() {
    audio.stop();

    // if there are no songs or the index is out of range, do nothing
    if((playqueueView.count <= 0)||
       (playqueueView.currentIndex >= playqueueView.count))
    {
        return false;
    }

    if (playqueueView.currentIndex == -1)
        playqueueView.currentIndex = 0;

    var item = playqueueView.currentItem;

    if (item == undefined){
        return false;
    }

    toolbar.trackName = item.mtitle;
    toolbar.artistName = item.martist;

    audio.source = item.muri;
    audio.playing = true;
    editorModel.setViewed(item.mitemid);
    return true;
}

function playNextSong() {
    if (shuffle) {
        playqueueView.currentIndex = playqueueModel.shuffleIndex(0);
        playqueueModel.shuffleIncrement();
    }else {
        if (playqueueView.currentIndex < (playqueueView.count -1))
        {
            playqueueView.currentIndex++;
        }
        else
        {
            if (loop){
                playqueueView.currentIndex = 0;
            }else{
                stop();
                return;
            }
        }
    }
    audio.source = "";
    playNewSong();
    updateNowNextPlaying();
}

function playPrevSong() {
    if (shuffle) {
        playqueueView.currentIndex = playqueueModel.shuffleIndex(0);
        playqueueModel.shuffleIncrement();
    }else {
        if (playqueueView.currentIndex == 0)
        {
            if (loop) {
                playqueueView.currentIndex = playqueueView.count - 1;
            }else {
                stop();
                return;
            }
        }
        else
        {
            playqueueView.currentIndex--;
        }
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
    } else if (shuffle) {
        dbusControl.nextItem1 = playqueueModel.shuffleIndex(1);
        dbusControl.nextItem2 = playqueueModel.shuffleIndex(2);
    } else  if (playqueueView.currentIndex == 0) {
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
        if (playqueueView.currentIndex+1 < playqueueView.count) {
            dbusControl.nextItem1 = playqueueView.currentIndex+1;

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


function pause()
{
    audio.pause()
}

function stop()
{
    audio.stop();
}

function formatLength(time)
{
    var val = parseInt(time);
    var dec = parseInt((time-val)*10);
    return (dec == 0)?val:(val + "." + dec)
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
        fromPage.addApplicationPage(artistDetailViewContent);
        break;
    case 4:
        // type is album
        thumbnailUri = item.mthumburi;
        labelAlbum = item.mtitle;
        albumLength = item.mlength;
        fromPage.addApplicationPage(albumDetailViewContent);
        break;
    case 5:
        // type is playlist
        thumbnailUri = item.mthumburi;
        labelPlaylist = item.mtitle;
        labelPlaylistURN = item.murn;
        fromPage.addApplicationPage(playlistDetailViewContent);
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
    miscModel.savePlaylist(playlistItem.mtitle);
}
