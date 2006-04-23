function synchTab(frameName, activeTabClass, normalTabClass, linkid) {

  var elList, i;

  // Exit if no frame name was given.

  if (frameName == null)
    return;

  // Set current active link to non active

  elList = document.getElementsByTagName("A");
  for (i = 0; i < elList.length; i++)

    // Check if the link's target matches the frame being loaded.

    if (elList[i].target == frameName) {

      // If the link's URL matches the page being loaded, activate it.
      // Otherwise, make sure the tab is deactivated.
	  if (elList[i].className == activeTabClass) {
	  
        elList[i].className = normalTabClass;
        elList[i].blur();
      }
    } 
	
	 // Set active link
   document.all[linkid].className = activeTabClass;
   //CalculateRemainingTime();
}

function synchTitle (newtitle)
{
	document.all.EditFrameTitle.innerText = newtitle;
}


// #### Countdown Timer Code  #### 

var timerID;
var timeEnd;
var timerRunning = false;

function startTimer()
{
	stopTimer();
	document.timer.timer.value = "";
	showTime();
}

function stopTimer()
{
	if(timerRunning)
		clearTimeout(timerID);
		timerRunning = false;
}

function showTime()
{
 if ( document.timer.timer.value.length == 0 )
	{
		var date = new Date();
		document.timer.timer.value = date.getTime();
	}
  var timeNow = parseInt( document.timer.timer.value );
  timeEnd = new Date( timeNow + 60*60000 );
  var timeRemainingString = "";
  var timeNow = new Date();
  var time = Math.floor( (timeEnd.getTime() - timeNow.getTime()) / 1000.0 );

  timeOut = 0;

  if (time < 0)
  {
  	alert("Your session has timed out.");
	stopTimer();
  }
  else
  {
    hours   = Math.floor( time /3600) % 24;
    minutes = Math.floor( time  / 60) % 60;
    seconds = (time%60);

    if (minutes < 10) minutes = "0" + minutes;
    if (seconds < 10) seconds = "0" + seconds;

    timeRemainingString = minutes + ":" + seconds;
    timeOut = 1000;
	document.timer.clock.value = timeRemainingString;
	window.status = "Session will time out in: " + timeRemainingString;
  	timerID = setTimeout("showTime()",1000);
  	timerRunning = true;
  }
}