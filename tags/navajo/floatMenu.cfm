<cfsetting enablecfoutputonly="Yes">
<!--- begin: build the floatMenu --->
<cfoutput>
<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css">

<script language = "javascript">
<!--
var ie = document.all ? 1 : 0
var ns = document.layers ? 1 : 0

if(ie){
document.write('<style type="text/css">')
document.write("##screen	{filter:Alpha(Opacity=30);}")
document.write("</style>")
}

if(ns){
document.write('<style type="text/css">')
document.write("##master	{clip:rect(0,150,250,0);}")
document.write("</style>")
}

//-->
</script>
<script language = "javascript">
<!--
var ie = document.all ? 1 : 0
var ns = document.layers ? 1 : 0

var master = new Object("element")
master.curLeft = -140;	master.curTop = 10;
master.gapLeft = 0;		master.gapTop = 0;
master.timer = null;

function moveAlong(layerName, paceLeft, paceTop, fromLeft, fromTop){
clearTimeout(eval(layerName).timer)

if(eval(layerName).curLeft != fromLeft){
     if((Math.max(eval(layerName).curLeft, fromLeft) - Math.min(eval(layerName).curLeft, fromLeft)) < paceLeft){eval(layerName).curLeft = fromLeft}
else if(eval(layerName).curLeft < fromLeft){eval(layerName).curLeft = eval(layerName).curLeft + paceLeft}
else if(eval(layerName).curLeft > fromLeft){eval(layerName).curLeft = eval(layerName).curLeft - paceLeft}
if(ie){document.all[layerName].style.left = eval(layerName).curLeft}
if(ns){document[layerName].left = eval(layerName).curLeft}
}

if(eval(layerName).curTop != fromTop){
     if((Math.max(eval(layerName).curTop, fromTop) - Math.min(eval(layerName).curTop, fromTop)) < paceTop){eval(layerName).curTop = fromTop}
else if(eval(layerName).curTop < fromTop){eval(layerName).curTop = eval(layerName).curTop + paceTop}
else if(eval(layerName).curTop > fromTop){eval(layerName).curTop = eval(layerName).curTop - paceTop}
if(ie){document.all[layerName].style.top = eval(layerName).curTop}
if(ns){document[layerName].top = eval(layerName).curTop}
}

eval(layerName).timer=setTimeout('moveAlong("'+layerName+'",'+paceLeft+','+paceTop+','+fromLeft+','+fromTop+')',30)
}

function setPace(layerName, fromLeft, fromTop, motionSpeed){
	eval(layerName).gapLeft = (Math.max(eval(layerName).curLeft, fromLeft) - Math.min(eval(layerName).curLeft, fromLeft))/motionSpeed
	eval(layerName).gapTop = (Math.max(eval(layerName).curTop, fromTop) - Math.min(eval(layerName).curTop, fromTop))/motionSpeed

moveAlong(layerName, eval(layerName).gapLeft, eval(layerName).gapTop, fromLeft, fromTop)
}

var expandState = 0

function expand(){
	if(expandState == 0){
		setPace("master", 0, 10, 5); 
		if(ie){
			document.menutop.src = "farcry/images/floatMenuOn1.gif"
		}; 
		expandState = 1;
	} else {
		setPace("master", -140, 10, 10); 
		if(ie){
			document.menutop.src = "farcry/images/floatMenuOff1.gif"
		}; 
		expandState = 0;
	}
}
//-->
</script>

<div id="master">

<div id="menu">
<table border="0" width="8" cellspacing="0" cellpadding="0">
<tr><td width="100%"><a href="javascript:expand()" onfocus="this.blur()"><img name="menutop" border="0" src="farcry/images/floatMenuOff1.gif" width="8" height="50"></a></td></tr>
</table>
</div>

<div id="top">
<table border="0" width="140" cellspacing="0" cellpadding="0">
<tr><td width="100%"><img border="0" src="farcry/images/floatMenuTop.gif" width="140" height="6"></td></tr>
</table>
</div>

<div id="screenlinks">
<table border="0" width="140" cellspacing="0" cellpadding="5" style="border : thin outset Gray;">
<tr><td width="100%">

<table border="0" width="100%" bgcolor="##808080" cellspacing="0" cellpadding="0">
<tr><td width="100%">

<table border="0" width="100%" cellspacing="1" cellpadding="5">
<tr><td width="100%" bgcolor="##FFFFFF">

<!--- begin: menu contents --->
<div class="floatertitle">:: FarCry ::</div>

<!--- Admin Options --->
<div>
<cfif iAdmin eq 1>
	<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#">&designmode=<cfif isDefined("url.designMode") and (url.designmode eq "1")>0<cfelse>1</cfif>">Toggle View</a><br>
	
	<!--- flushcache --->
	<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#">&flushcache=1&showdraft=0">Flush Cache</a><br>
		
	<!--- showdraft toggle --->
	<cfif isDefined("request.mode.showdraft") AND request.mode.showdraft eq 0>
	<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#&flushcache=1&showdraft=1"><cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Show Draft</a><br>
	<cfelse>
	<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#&flushcache=1&showdraft=0"><cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Hide Draft</a><br>
	</cfif>
	
	<a class="floaterLink" href="##" onClick="window.open('#application.url.farcry#/index.cfm','Admin');">Admin Page</a><br>
</cfif>

<!--- designmode header toggle --->
<cfif isdefined("session.designmodedisplay") and session.designmodedisplay>
<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#">&designmodeheader=0<cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Toggle Header</a><br>

<cfelse>
<a class="floaterLink" href="#application.url.conjurer#<cf_URLGenerator objectID="#url.ObjectID#">&designmodeheader=1<cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Toggle Header</a><br>
</cfif>

<!--- comment --->
<cfif iCanCommentOnContent eq 1>
<a class="floaterLink" href="##" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);">Comment</a><br>
</cfif>

<!--- logout --->
<a class="floaterLink" style="color:red" href="#cgi.script_name#?logout=1&#cgi.query_string#">Logout</a><br>
</div>
<!--- end: menu contents --->

</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>
</div>

</div>

<script language = "javascript">
<!--
if(ie){var sidemenu = document.all.master;}
if(ns){var sidemenu = document.master;}

function FixY(){
if(ie){sidemenu.style.top = document.body.scrollTop+10}
if(ns){sidemenu.top = window.pageYOffset+10}
}

setInterval("FixY()",100);
//-->
</script>
</cfoutput>
<!--- end: build the floatMenu --->
<cfsetting enablecfoutputonly="No">


