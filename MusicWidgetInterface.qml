import Qt 4.7
import MeeGo.Media 0.1
import MeeGo.WidgetInterface 0.1
import "functions.js" as Code

Item {
    id: musicWidgetInterface

    //Other control bool
    property bool canAddAllTracks: false
    property int fisrtSetPosition: 0

    //control signal
    signal playSong()
    signal pauseSong()
    signal playNextSong()
    signal playPrevSong()

    WidgetClient {
        id: widgetclient
        name: "music"
        type: "app"
    }

    function setDefaultData() {
        //data to be transmitted
        //[widget] for data needed by widget only
        //[widget-current] for real-time data needed by widget which need to be transmitted all the time
        //[application] for data needed by application only
        //[application-start] for data needed by application only when application starts
        //[application-current] for real-time data needed by application which need to be transmitted all the time
        //[other] for other data which may be needed by both widget and application or for some special occasion
        var musicWidgetData =
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
        widgetclient.setCurrentData(musicWidgetData);
    }

    //sned init data for application
    function startup()
    {
        requestTest.running = false;
        setDefaultData();
        widgetclient.startup();
    }

    //handle data from daemon
    function startUpControlHandle() {
        if(widgetclient.getData("act") != 7 && widgetclient.getData("urn") != "") {
            setRequestSongs(widgetclient.getData("urn"));
        }
        else
            initWidget();
    }

    //handle control signal from widget
    function controlHandle() {
        if(window.allTracksModel.total == 0)
            widgetclient.setData("act", 7);
        switch(widgetclient.getData("act")) {
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
        if(widgetclient.getData("act") != 7)
            widgetclient.setData("act", 0);
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
        fisrtSetPosition = widgetclient.getData("pa");
        forceStates();
    }

    //init widget data when the first startup or songs are deleted or the very first song is added.
    function initWidget() {
        if(window.allTracksModel.total == 0) {
            initNoMuiscData();
        }
        else {
            widgetclient.setData("act",0);
            widgetclient.setData("prc",playqueueModel.playindex);
            widgetclient.setData("nxc",playqueueModel.total - (playqueueModel.playindex + 1));
            widgetclient.setData("urn",playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN));
            widgetclient.setData("is", editorModel.datafromURN(widgetclient.getData("urn"), MediaItem.ThumbURI));
            widgetclient.setData("st", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title));
            widgetclient.setData("at", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album));
        }
        widgetclient.shootData("force");
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
        widgetclient.setCurrentData(tempMusicData);
    }

    function syncPosition() {
        //sync audio sposition
        audio.position = fisrtSetPosition;
        //sync tool bar
        if (audio.duration != 0) {
            toolbar.widgetSliderPosition = fisrtSetPosition/audio.duration;
            var msecs = audio.duration - fisrtSetPosition;
            toolbar.widgetRemainingTimeText = Code.formatTime(msecs/1000);
            toolbar.widgetElapsedTimeText = Code.formatTime(fisrtSetPosition/1000);
        }
        switch(widgetclient.getData("act")) {
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
        widgetclient.setData("act", 0);
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
            widgetclient.setData("prc", playqueueModel.playindex);
            widgetclient.setData("nxc", playqueueModel.total - (playqueueModel.playindex + 1));
            widgetclient.setData("urn", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.URN));
            widgetclient.setData("is", editorModel.datafromURN(widgetclient.getData("urn"), MediaItem.ThumbURI));
            widgetclient.setData("st", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Title));
            widgetclient.setData("at", playqueueModel.datafromIndex(playqueueModel.playindex, MediaItem.Album));
            if(!canAddAllTracks)
                widgetclient.shootData(); //send data
        }
    }

    Connections {
        target: audio
        onPositionChanged: {
            if(toolbar.playing)
                widgetclient.setData("pbn",1);
            else
                widgetclient.setData("pbn",0);
            if(widgetclient.getData("st") != toolbar.trackName)
                widgetclient.setData("st",toolbar.trackName);
            if(widgetclient.getData("da") != audio.duration)
                widgetclient.setData("da", audio.duration);
            widgetclient.setData("pa", audio.position);
        }
        onDurationChanged: {
            widgetclient.setData("da", audio.duration);
        }
        onStatusChanged: {
            if(!toolbar.playing)
                widgetclient.shootData("force"); //send data
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
                widgetclient.setData("pbn",1);
            else
                widgetclient.setData("pbn",0);
            widgetclient.shootData("force"); //send data
        }
        onWidgetElapsedTimeTextChanged: {
            widgetclient.setData("pbt",toolbar.widgetElapsedTimeText);
        }
        onWidgetSliderPositionChanged: {
            widgetclient.setData("pbp",toolbar.widgetSliderPosition);
            if(fisrtSetPosition == 0)
                widgetclient.shootData(); //send data
        }
    }

    Connections {
        target: window.allTracksModel
        onTotalChanged: {
            if(widgetclient.getData("act") == 7 && window.playqueueModel.total > 0) {
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


