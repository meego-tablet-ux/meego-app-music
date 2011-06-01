import Qt 4.7
import QtMultimediaKit 1.1
import Qt.labs.folderlistmodel 1.0
import "awd-client.js" as Awd
import "functions.js" as Code
import AcerWidgetsDaemonInterface 0.1

Item {
    id: mif
    width: 0;
    height: 0;

    property variant main
    property variant audioItem
    property bool awdState
   // Binding { target: musicIntFace; property: "mdata"; value: Awd.musicData }

    signal playNeedsSongs()
    signal playNextSongs()
    signal playPrevSongs()
    signal pauseSongs()

    AwdAddress {
        id: awdAPI
        name: "music"
        type: "app"
    }

    function startup()
    {
        Awd.initRequestInfo();
    }

    function getRefresh()
    {
        main.audioPosition = Awd.musicData.positionA;
        main.audioDuration = Awd.musicData.durationA;

        //none, play, pause, next, prev, forward, backward       
        if(Awd.musicData.action=="play") play();
        else if(Awd.musicData.action=="pause") pause();
        else if(Awd.musicData.action=="next") next()
        else if(Awd.musicData.action=="prev") prev()
        else if(Awd.musicData.action=="init") initWidget();
//        else if(Awd.musicData.action=="forward") musicIntFace.forward()
//        else if(Awd.musicData.action=="backward") musicIntFace.backward()

        Awd.musicData.action="none"
    }

    function initWidget() {
        if(main.playqueueModel.total > 0) {
            Awd.musicData.state = false;
            Awd.musicData.action="none";
            Awd.musicData.urn = main.currentFocus.urnName;
            Awd.musicData.positionA = audioItem.position;
            Awd.musicData.durationA = audioItem.duration;
            Awd.musicData.pBarPosition = main.progressBarPosition;
            Awd.musicData.pbett = main.progressBarElapsedTimeText;
            Awd.musicData.song_title = main.currentFocus.trackName;
            Awd.musicData.album_title = main.currentFocus.albumName;
            Awd.musicData.image_source = main.currentFocus.imageSource;
            Awd.musicData.prev_count = main.currentFocus.currentIndex;
            Awd.musicData.next_count = main.currentFocus.count-main.currentFocus.currentIndex+1;
            Awd.musicData.all_count = main.currentFocus.count
            awdAPI.sendDataMode = "force"
            Awd.sendDataRequest(Awd.Obj2JSON(Awd.musicData));
            awdAPI.sendDataMode = "none"
        }
        else {
            main.playqueueModel.addItems(main.allTracksModel.getAllIDs());
            if(main.playqueueModel.total > 0)
                initWidget();
            else
                sendNoMuiscData();
        }
    }

    function play()
    {
//        if(main.currentFocus.urnName == Awd.musicData.urn && Awd.musicData.urn != "")
            mif.playNeedsSongs()
//        else
//            Code.startAndPlay(Awd.musicData.urn)
    }

    function pause()
    {
        mif.pauseSongs()
    }
    function prev()
    {
        mif.playPrevSongs()
    }
    function next()
    {
        mif.playNextSongs()
    }
//    function forward()
//    {
//        Awd.musicData.action = "forward"
//    }
//    function backward()
//    {
//        Awd.musicData.action = "backward"
//    }

    function sendNoMuiscData()
    {
        Awd.musicData.state = false;
        Awd.musicData.action="none";
        Awd.musicData.urn = "";
        Awd.musicData.positionA = 0;
        Awd.musicData.durationA = audioItem.duration;
        Awd.musicData.pBarPosition = 0.0;
        Awd.musicData.pbett = "0:00";
        Awd.musicData.song_title = "Track name";
        Awd.musicData.album_title = "Album name";
        Awd.musicData.image_source = "/home/meego/Music/Love.jpg";
        Awd.musicData.prev_count = 0;
        Awd.musicData.next_count = 0;
        Awd.musicData.all_count = 0
        Awd.sendDataRequest(Awd.Obj2JSON(Awd.musicData));
    }

    function sendCommandData()
    {
//        console.log("=========================== Send data ===========================\n");
        if(audioItem.duration <= 0 || audioItem.position < 0)
            return;

        if(!audioItem.seekable)
            return;

        Awd.musicData.state = awdState;
        Awd.musicData.action="none";
        Awd.musicData.urn = main.currentFocus.urnName;
        Awd.musicData.positionA = audioItem.position;
        Awd.musicData.durationA = audioItem.duration;
        Awd.musicData.pBarPosition = main.progressBarPosition;
        Awd.musicData.pbett = main.progressBarElapsedTimeText;
        Awd.musicData.song_title = main.currentFocus.trackName;
        Awd.musicData.album_title = main.currentFocus.albumName;
        Awd.musicData.image_source = main.currentFocus.imageSource;
        Awd.musicData.prev_count = main.currentFocus.currentIndex;
        Awd.musicData.next_count = main.currentFocus.count-main.currentFocus.currentIndex+1;
        Awd.musicData.all_count = main.currentFocus.count

//        console.log("------------------ mdata.song_title: " + main.currentFocus.trackName + " ------------------ \n");
//        console.log("------------------ mdata.album_title: " + main.currentFocus.albumName + " ------------------ \n");
//        console.log("------------------ mdata.image_source: " + main.currentFocus.imageSource + " ------------------ \n");
//        console.log("------------------ mdata.played_percent: " + main.progressBarPosition + " ------------------ \n");
        console.log(">>>>>>>>>>>>>>>--- Awd.musicData.all_count: " + Awd.musicData.all_count + " ------------------ \n");

//        Awd.musicData = mdata;
        Awd.sendDataRequest(Awd.Obj2JSON(Awd.musicData));
    }

    Component.onCompleted: {
//        startup();
    }

    Timer {
        id: requestTest
        interval: 1000; running: true; repeat: false

        onTriggered: {
            startup();
        }
    }
}


