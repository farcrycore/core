<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/includes/countdown.cfm,v 1.4 2004/07/15 01:12:50 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:12:50 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
Session timeout counter. Counts down time remaining in a user's session before they are logged out.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in:
out:

|| END DAEMONDOC||
--->

<cfprocessingDirective pageencoding="utf-8">

<script>
var timerID;
var timeEnd;
var timerRunning = false;

function startTimer()
{
	stopTimer();
	document.getElementById('timer').value = '';
	//document.timer.timer.value = "";
	showTime();
}

function stopTimer()
{
	if(timerRunning)
		clearTimeout(timerID);
		timerRunning = false;
}

function showTime(ConfigDefault)
{
	var em = document.getElementById('timer');
	if ( !em.value.length)
	{
		var date = new Date();
		em.value = date.getTime();
	}
  var timeNow = parseInt( em.value );
  timeEnd = new Date( timeNow + <cfoutput>#application.config.general.sessionTimeOut#</cfoutput>*60000 );
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
	document.getElementById('clock').innerHTML = timeRemainingString + ' remaining in session';
	timerID = setTimeout("showTime(<cfoutput>#application.config.general.sessionTimeOut#</cfoutput>)",1000);
  	timerRunning = true;
  }
}
</script>