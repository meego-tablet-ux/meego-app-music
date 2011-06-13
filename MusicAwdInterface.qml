import Qt 4.7
import MeeGo.Media 0.1
import AcerWidgetsDaemonInterface 0.1   //lib from meego-ux-media as awdapi
import "awd-client.js" as AwdClient
import "functions.js" as Code

Item {
    id: musicAwdInterface

    //string data for comparing to avoid chaos
    property string lastArrivedData : ""    //currently lastArrivedData == lastSendData
    property string thisArrivedData : ""    //data just arrived
    property string currentData : ""        //current application music data

    //Other control bool
    property bool canAddAllTracks: false
    property int fisrtSetPosition: 0

    //control signal
    signal playSong()
    signal pauseSong()
    signal playNextSong()
    signal playPrevSong()

    //AcerWidgetsDaemon API for composing a http url
    AwdAddress {
        id: awdAPI
        name: "music"
        type: "app"
    }

    //sned init data for application
    function startup()
    {
        AwdClient.initRequestInfo();
    }

    //handle data from daemon
    function startUpControlHandle() {
        if(AwdClient.musicAwdData.act != 7 && AwdClient.musicAwdData.urn != "")
            setRequestSongs(AwdClient.musicAwdData.urn)            
        else
            initWidget();
    }

    //handle control signal from widget
    function controlHandle() {
        if(window.allTracksModel.total == 0)
            AwdClient.musicAwdData.act = 7;
        switch(AwdClient.musicAwdData.act) {
        case 0: break;         //do nothing
        case 1:
            playSong();
            break;
        case 2:
            pauseSong();
            break;
        case 3:
            playNextSong();
            break;
        case 4:
            playPrevSong();
            break;
        case 5: break;         //no forward function yet
        case 6: break;         //no backward function yet
        case 7:
            initWidget();
            break;
        default:
            break;
        }
        if(AwdClient.musicAwdData.act != 7)
            AwdClient.musicAwdData.act = 0;
    }

    //set playqueue plays the song last time played
    function setRequestSongs(identifier)
    {
        window.playqueueModel.clear();
        //add request song first;
        window.playqueueModel.addItems(editorModel.datafromURN(identifier, MediaItem.ID));
        //Then add all the songs;
        window.playqueueModel.addItems(window.allTracksModel.getAllIDs());
        window.playqueueModel.playindex = 0;
        fisrtSetPosition = AwdClient.musicAwdData.pa;
        forceStates();
    }

    //init widget data when the first startup or songs are deleted or the very first song is added.
    function initWidget() {
        if(window.allTracksModel.total == 0) {
            initNoMuiscData();
        }
        else {
            AwdClient.musicAwdData.act = 0;
            AwdClient.musicAwdData.prc = playqueueModel.playindex;
            AwdClient.musicAwdData.nxc = playqueueModel.total - (playqueueModel.playindex + 1);
            AwdClient.musicAwdData.urn = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN);
            AwdClient.musicAwdData.is = editorModel.datafromURN(AwdClient.musicAwdData.urn, MediaItem.ThumbURI);
            AwdClient.musicAwdData.st = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title);
            AwdClient.musicAwdData.at = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album);
        }
        shootData();
    }

    //init data when there is no music at all
    function initNoMuiscData()
    {
        AwdClient.musicAwdData.act = 7;
        AwdClient.musicAwdData.urn = "";
        AwdClient.musicAwdData.pa = 0;
        AwdClient.musicAwdData.pbp = 0;
        AwdClient.musicAwdData.pbt = "0:00";
        AwdClient.musicAwdData.da = 0;
        AwdClient.musicAwdData.pbn = 0;
        AwdClient.musicAwdData.prc = 0;
        AwdClient.musicAwdData.nxc = 0;
        AwdClient.musicAwdData.st  = "";
        AwdClient.musicAwdData.at  = "";
        AwdClient.musicAwdData.is = "/home/meego/Music/default.jpg";
    }

    //send collected data
    function shootData()
    {
        lastArrivedData = AwdClient.Obj2JSON(AwdClient.musicAwdData);
        AwdClient.sendDataRequest(lastArrivedData);
    }

    function syncPosition() {
        //sync audio sposition
        audio.position = fisrtSetPosition;
        //sync tool bar
        if (audio.duration != 0) {
            toolbar.awdSliderPosition = fisrtSetPosition/audio.duration;
            var msecs = audio.duration - fisrtSetPosition;
            toolbar.awdRemainingTimeText = Code.formatTime(msecs/1000);
            toolbar.awdElapsedTimeText = Code.formatTime(fisrtSetPosition/1000);
        }
        switch(AwdClient.musicAwdData.act) {
        case 0: break;         //do nothing
        case 1:
            playSong();
            break;
        case 3:
            playNextSong();
            break;
        case 4:
            playPrevSong();
            break;
        default:
            break;
        }
        fisrtSetPosition = 0;
        AwdClient.musicAwdData.act = 0;
    }

    function forceStates() {
        audio.source = playqueueModel.datafromIndex(0, MediaItem.URI);
    }

    onPlaySong: {
        if(!toolbar.playing) {
            if(Code.play())
                toolbar.playing = true;
            else
                toolbar.playNeedsSongs();
        }
        else {
            Code.pause();
            Code.play();
        }
    }

    onPauseSong: {
        if(toolbar.playing) {
            Code.pause();
            toolbar.playing = false;
        }
    }

    onPlayNextSong: {
        Code.playNextSong();
    }

    onPlayPrevSong: {
        Code.playPrevSong();
    }

    Connections {
        target: window.playqueueModel
        onPlayIndexChanged: {
            AwdClient.musicAwdData.prc = playqueueModel.playindex;
            AwdClient.musicAwdData.nxc = playqueueModel.total - (playqueueModel.playindex + 1);
            AwdClient.musicAwdData.urn = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN);
            AwdClient.musicAwdData.is = editorModel.datafromURN(AwdClient.musicAwdData.urn, MediaItem.ThumbURI);
            AwdClient.musicAwdData.st = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title);
            AwdClient.musicAwdData.at = playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album);
            if(!canAddAllTracks)
                shootData(); //send data
        }
    }

    Connections {
        target: audio
        onPositionChanged: {
            if(toolbar.playing)
                AwdClient.musicAwdData.pbn = 1;
            else
                AwdClient.musicAwdData.pbn = 0;
            if(AwdClient.musicAwdData.st != toolbar.trackName)
                AwdClient.musicAwdData.st = toolbar.trackName
            if(AwdClient.musicAwdData.da != audio.duration)
                AwdClient.musicAwdData.da = audio.duration;
            AwdClient.musicAwdData.pa = audio.position
        }
        onDurationChanged: {
            AwdClient.musicAwdData.da = audio.duration;
        }
        onStatusChanged: {
            if(!toolbar.playing)
                shootData(); //send data
        }
        onSeekableChanged: {
            if(audio.seekable && fisrtSetPosition != 0) {
                syncPosition();
            }
        }
    }

    Connections {
        target: toolbar
        onPlayingChanged: {
            if(toolbar.playing)
                AwdClient.musicAwdData.pbn = 1;
            else
                AwdClient.musicAwdData.pbn = 0;
            shootData(); //send data
        }
        onAwdElapsedTimeTextChanged: {
            AwdClient.musicAwdData.pbt = toolbar.awdElapsedTimeText;
        }
        onAwdSliderPositionChanged: {
            AwdClient.musicAwdData.pbp = toolbar.awdSliderPosition;
            if(fisrtSetPosition == 0)
                shootData(); //send data
        }
    }

    Connections {
        target: window.allTracksModel
        onTotalChanged: {
            if(AwdClient.musicAwdData.act == 7 && window.playqueueModel.total > 0) {
                initWidget();
            }
            if(window.playqueueModel.total == 0)
                canAddAllTracks = true
            if(window.playqueueModel.total < window.allTracksModel.total && canAddAllTracks) {
                initDefaultPlayQueue.stop();
                window.playqueueModel.clear();
                window.playqueueModel.addItems(window.allTracksModel.getAllIDs());
                window.playqueueModel.playindex = 0;
                initDefaultPlayQueue.start();
            }
        }
    }

    Timer {
        id: initDefaultPlayQueue
        interval: 500; running: false; repeat: false

        onTriggered: {
            canAddAllTracks = false;    //Stop add allTracksModel songs to playqueueModel
                                        //if allTracksModel seems stop adding new songs.
        }
    }

    Timer {
        id: requestTest
        interval: 1000; running: true; repeat: false

        onTriggered: {
            startup();  //should use Component.onCompleted: {} to startup?
        }
    }
}


