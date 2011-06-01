/****************************************** Readme ******************************************/
/*  Usage & Sample                                                                          */
/*  import "awd-client.js" as Awd                                                           */
/*                                                                                          */
/*  Add initRequestInfo(name, type) function on your initialization                         */
/*  name for your application/widget name                                                   */
/*  type for your application/widget type. Either app or widget will be accepted            */
/*                                                                                          */
/*  Use sendDataRequest(data) function send your DATA for communication                     */
/*                                                                                          */
/*  At last, you need to modify handleStandByData(data) function to use the data received.  */
/****************************************** Readme ******************************************/

var xmlHttpStandByRequest,
    xmlHttpStartUpRequest,
    xmlHttpSendDataRequest;

var musicData =
{
        "state"         : false, //play or pause        
        "action"        : "none", //none, play, pause, next, prev, forward, backward
        "urn"           : "",
        "positionA"     : 0,
        "durationA"     : 0,
        "pBarPosition"  : 0.0,
        "pbett"         : "0:00",
        "song_title"    : "Track name",
        "album_title"   : "Album name",
        "image_source"  : "/home/meego/Music/Love.jpg",
        "prev_count"    : 0,    //count of previous music items
        "next_count"    : 0,    //count of next music items
        "all_count"    : 0,    //count of music items
}

var lastArrivedData = "";
var thisArrivedData = "";
var currentData = "";

//Add this one on your initialization
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

//Use this one send your DATA
function sendDataRequest(data)
{
    if(lastArrivedData.indexOf(data)==0 && data.indexOf(lastArrivedData)==0)
        return;
    else {
        console.log("app:[sendDataRequest]: " + data);
        xmlHttpSendDataRequest=new XMLHttpRequest();
        xmlHttpSendDataRequest.open("Get", awdAPI.getAddress("SendData", data), true);
        xmlHttpSendDataRequest.onreadystatechange = handleSendDataResponse;
        xmlHttpSendDataRequest.send(null);
        lastArrivedData = data;
    }
}

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
    console.log("app:[handleSendData]: " + data);
}

function handleStartUpData(data)
{
    currentData = Obj2JSON(musicData);
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.uid) {
            console.log("Wrong application don't need uid: "+recoverTest.uid+"\n");
        }
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = currentData;
    }

    standByRequest();

    thisArrivedData = data;

    if(lastArrivedData == thisArrivedData && thisArrivedData != currentData) {
        console.log("app:[handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(thisArrivedData == currentData) {
        console.log("app:[handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(lastArrivedData != thisArrivedData && thisArrivedData != currentData) {

        lastArrivedData = thisArrivedData;
        console.log("app:[handleStandByData]: " + data);

        //Parse your DATA here.
        musicData = JSON2Obj(data)
        mif.getRefresh()
    }
}

function handleStandByData(data)
{
    standByRequest();

    currentData = Obj2JSON(musicData);

    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.uid) {
            console.log("Wrong application don't need uid: "+recoverTest.uid+"\n");
        }
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = currentData;
    }

    thisArrivedData = data;

    if(lastArrivedData == thisArrivedData && thisArrivedData != currentData) {
        console.log("app:[handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(thisArrivedData == currentData) {
        console.log("app:[handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(lastArrivedData != thisArrivedData && thisArrivedData != currentData) {

        lastArrivedData = thisArrivedData;
        console.log("app:[handleStandByData]: " + data);

        //Parse your DATA here.
        musicData = JSON2Obj(data)
        mif.getRefresh()
    }
}
