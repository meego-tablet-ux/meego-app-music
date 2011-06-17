import Qt 4.7
import MeeGo.Media 0.1
import AcerWidgetsDaemonInterface 0.1   //lib from meego-ux-media as awdapi
import "functions.js" as Code

Item {
    id: musicAwdInterface

    //Other control bool
    property bool canAddAllTracks: false
    property int fisrtSetPosition: 0

    //control signal
    signal playSong()
    signal pauseSong()
    signal playNextSong()
    signal playPrevSong()

    AwdClient {
        id: awdclient
        name: "music"
        type: "app"
    }

    function setDeafultData() {
        //data to be transmitted
        //[widget] for data needed by widget only
        //[widget-current] for real-time data needed by widget which need to be transmitted all the time
        //[application] for data needed by application only
        //[application-start] for data needed by application only when application starts
        //[application-current] for real-time data needed by application which need to be transmitted all the time
        //[other] for other data which may be needed by both widget and application or for some special occasion
        var musicAwdData =
        {
            "act"   : 0,                //[application]: control signals
                                        /*
                                            {
                                                none     : 0
                                                play     : 1
                                                pause    : 2
                                                next     : 3
                                                prev     : 4
                                                forward  : 5
                                                backward : 6
                                                init     : 7
                                            }
                                        */
            "urn"   : "",               //[application-start]: play the urn
            "pa"    : 0,                //[application-start]: the audio position

            "pbp"   : 0,                //[widget-current]: for showing current progress bar position
            "pbt"   : "0:00",           //[widget-current]: for showing current elapsed time text in progress bar

            "da"    : 0,                //[widget]: for widget to calculate the total time of the song
            "pbn"   : 0,                //[widget]: play or pause, control widget's play button, 0 for false. 1 for true
            "prc"   : 0,                //[widget]: count of previous music items, for widget previous buttom's state
            "nxc"   : 0,                //[widget]: count of next music items, for widget next buttom's state
            "st"    : "Track name",     //[widget]: current song title for widget to show
            "at"    : "Album name",     //[widget]: current album title for widget to show
            "is"    : "/home/meego/Music/default.jpg",
                                        //[widget]: image source for widget background image
        }
        awdclient.setCurrentData(musicAwdData);
    }

    //sned init data for application
    function startup()
    {
        setDeafultData();
        awdclient.startup();
    }

    //handle data from daemon
    function startUpControlHandle() {
        if(awdclient.getData("act") != 7 && awdclient.getData("urn") != "")
            setRequestSongs(awdclient.getData("urn"))
        else
            initWidget();
    }

    //handle control signal from widget
    function controlHandle() {
        if(window.allTracksModel.total == 0)
            awdclient.setData("act", 7);
        switch(awdclient.getData("act")) {
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
        if(awdclient.getData("act") != 7)
            awdclient.setData("act", 0);
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
        fisrtSetPosition = awdclient.getData("pa");
        forceStates();
    }

    //init widget data when the first startup or songs are deleted or the very first song is added.
    function initWidget() {
        if(window.allTracksModel.total == 0) {
            initNoMuiscData();
        }
        else {
            awdclient.setData("act",0);
            awdclient.setData("prc",playqueueModel.playindex);
            awdclient.setData("nxc",playqueueModel.total - (playqueueModel.playindex + 1));
            awdclient.setData("urn",playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN));
            awdclient.setData("is", editorModel.datafromURN(awdclient.getData("urn"), MediaItem.ThumbURI));
            awdclient.setData("st", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title));
            awdclient.setData("at", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album));
        }
        awdclient.shootData();
    }

    //init data when there is no music at all
    function initNoMuiscData()
    {
        var tempMusicData = {};
        tempMusicData.act = 7;
        tempMusicData.urn = "";
        tempMusicData.pa = 0;
        tempMusicData.pbp = 0;
        tempMusicData.pbt = "0:00";
        tempMusicData.da = 0;
        tempMusicData.pbn = 0;
        tempMusicData.prc = 0;
        tempMusicData.nxc = 0;
        tempMusicData.st  = "";
        tempMusicData.at  = "";
        tempMusicData.is = "/home/meego/Music/default.jpg";
        awdclient.setCurrentData(tempMusicData);
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
        switch(awdclient.getData("act")) {
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
        awdclient.setData("act", 0);
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
            awdclient.setData("prc", playqueueModel.playindex);
            awdclient.setData("nxc", playqueueModel.total - (playqueueModel.playindex + 1));
            awdclient.setData("urn", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN));
            awdclient.setData("is", editorModel.datafromURN(awdclient.getData("urn"), MediaItem.ThumbURI));
            awdclient.setData("st", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title));
            awdclient.setData("at", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album));
            if(!canAddAllTracks)
                awdclient.shootData(); //send data
        }
    }

    Connections {
        target: audio
        onPositionChanged: {
            if(toolbar.playing)
                awdclient.setData("pbn",1);
            else
                awdclient.setData("pbn",0);
            if(awdclient.getData("st") != toolbar.trackName)
                awdclient.setData("st",toolbar.trackName);
            if(awdclient.getData("da") != audio.duration)
                awdclient.setData("da", audio.duration);
            awdclient.setData("pa", audio.position);
        }
        onDurationChanged: {
            awdclient.setData("da", audio.duration);
        }
        onStatusChanged: {
            if(!toolbar.playing)
                awdclient.shootData(); //send data
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
                awdclient.setData("pbn",1);
            else
                awdclient.setData("pbn",0);
            awdclient.shootData(); //send data
        }
        onAwdElapsedTimeTextChanged: {
            awdclient.setData("pbt",toolbar.awdElapsedTimeText);
        }
        onAwdSliderPositionChanged: {
            awdclient.setData("pbp",toolbar.awdSliderPosition);
            if(fisrtSetPosition == 0)
                awdclient.shootData(); //send data
        }
    }

    Connections {
        target: window.allTracksModel
        onTotalChanged: {
            if(awdclient.getData("act") == 7 && window.playqueueModel.total > 0) {
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


