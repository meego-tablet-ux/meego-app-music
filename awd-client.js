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

//basic functions for handling XMLHttpRequest
var xmlHttpStartUpRequest,
    xmlHttpStandByRequest,
    xmlHttpSendDataRequest;

function initRequestInfo()
{
    xmlHttpStartUpRequest=new XMLHttpRequest();
    xmlHttpStartUpRequest.open("Get", awdAPI.getAddress("StartUp"), true);
    xmlHttpStartUpRequest.onreadystatechange = handleStartUpResponse;
    xmlHttpStartUpRequest.send(null);
}

function standByRequest()
{
    xmlHttpStandByRequest=new XMLHttpRequest();
    xmlHttpStandByRequest.open("Get", awdAPI.getAddress("StandBy"), true);
    xmlHttpStandByRequest.onreadystatechange = handleStandByResponse;
    xmlHttpStandByRequest.send(null);
}

function sendDataRequest(data)
{
    xmlHttpSendDataRequest=new XMLHttpRequest();
    xmlHttpSendDataRequest.open("Get", awdAPI.getAddress("SendData", data), true);
    xmlHttpSendDataRequest.onreadystatechange = handleSendDataResponse;
    xmlHttpSendDataRequest.send(null);
}

//converting data between JSON and object
function JSON2Obj(JSONData) {
    var myObject = JSON.parse(JSONData);
    return myObject;
}

function Obj2JSON(myObject) {
    var data = JSON.stringify(myObject, replacer);
    return data
}

function replacer(key, value) {
    if (typeof value === 'number' && !isFinite(value)) {
        return String(value);
    }
    return value;
}

function handleStandByResponse()
{
    if(xmlHttpStandByRequest.readyState == 4)
    {
        if (xmlHttpStandByRequest.status == 200)
        {
            var standByResponseData = xmlHttpStandByRequest.responseText;
            handleStandByData(standByResponseData);            
        }
    }
}

function handleSendDataResponse()
{
    if(xmlHttpSendDataRequest.readyState == 4)
    {
        if (xmlHttpSendDataRequest.status == 200)
        {
            var sendDataResponseData = xmlHttpSendDataRequest.responseText;
            handleSendData(sendDataResponseData);
        }
    }
}

function handleStartUpResponse()
{
    if(xmlHttpStartUpRequest.readyState == 4)
    {
        if (xmlHttpStartUpRequest.status == 200)
        {
            var startUpResponseData = xmlHttpStartUpRequest.responseText;
            handleStartUpData(startUpResponseData);
        }
    }
}

function handleSendData(data)
{    
    xmlHttpSendDataRequest = undefined;
}

function handleStartUpData(data)
{
    musicAwdInterface.currentData = Obj2JSON(musicAwdData);
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = musicAwdInterface.currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = musicAwdInterface.currentData;
    }
    standByRequest();

    musicAwdInterface.thisArrivedData = data;

    if(musicAwdInterface.lastArrivedData == musicAwdInterface.thisArrivedData && musicAwdInterface.thisArrivedData != musicAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(musicAwdInterface.thisArrivedData == musicAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(musicAwdInterface.lastArrivedData != musicAwdInterface.thisArrivedData && musicAwdInterface.thisArrivedData != musicAwdInterface.currentData) {

        musicAwdInterface.lastArrivedData = musicAwdInterface.thisArrivedData;
        console.log("[app::handleStandByData]: " + data);

        //Parse your DATA here.
        musicAwdData = JSON2Obj(data)
        musicAwdInterface.startUpControlHandle();
    }
    xmlHttpStartUpRequest = undefined;
}

function handleStandByData(data)
{
    xmlHttpStandByRequest = undefined;
    standByRequest();
    musicAwdInterface.currentData = Obj2JSON(musicAwdData);
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = musicAwdInterface.currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = musicAwdInterface.currentData;
    }

    musicAwdInterface.thisArrivedData = data;

    if(musicAwdInterface.lastArrivedData == musicAwdInterface.thisArrivedData && musicAwdInterface.thisArrivedData != musicAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(musicAwdInterface.thisArrivedData == musicAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(musicAwdInterface.lastArrivedData != musicAwdInterface.thisArrivedData && musicAwdInterface.thisArrivedData != musicAwdInterface.currentData) {

        musicAwdInterface.lastArrivedData = musicAwdInterface.thisArrivedData;
        console.log("[app::handleStandByData]: " + data);

        //Parse your DATA here.
        musicAwdData = JSON2Obj(data)
        musicAwdInterface.controlHandle();
    }
}
