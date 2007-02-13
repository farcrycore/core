<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/floater.cfm,v 1.14 2005/08/28 05:37:13 geoff Exp $
$Author: geoff $
$Date: 2005/08/28 05:37:13 $
$Name: milestone_3-0-1 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: FarCry DHTML Float Menu$


|| DEVELOPER ||
$Developer: Stephen 'Spike' Milligan (spike@spike.org.uk)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">

<cfsilent>
	<cfparam name="attributes.top" default="15">
	<cfparam name="attributes.left" default="0">
	<cfparam name="attributes.refreshRate" default="50">
	<cfparam name="attributes.showHideDelay" default="3000">
	<cfparam name="attributes.trackerAcceleration" default="0.5">
	<cfparam name="attributes.showHideAcceleration" default="0.7">
	<cfparam name="attributes.opacity" default="90">
	<cfparam name="usecontextmenu" default="false">
	<cfparam name="attributes.imagedir" default="">
	<cfparam name="attributes.buttonimage" default="menuopen.gif">
	<cfparam name="attributes.prefix" default="dmfloater">
	<cfparam name="attributes.useFade" default="false">
	<cfparam name="attributes.showDisableContext" default="true">
</cfsilent>

<cfoutput>
<!--
 FarCry DHTML Float Menu
 Written by Stephen 'Spike' Milligan (spike@spike.org.uk)
 Plase vist http://farcry.daemon.com.au for more information
-->

<style type="text/css">
div.#attributes.prefix#Menu {
	<cfif attributes.useFade>
	filter: progid:DXImageTransform.Microsoft.Alpha( Opacity=1, FinishOpacity=0, Style=0, StartX=0,  FinishX=100, StartY=0, FinishY=100) progid:DXImageTransform.Microsoft.Shadow(color=aaaaaa,Direction=115,Strength=4);
	<cfelse>
	filter: progid:DXImageTransform.Microsoft.Shadow(color=aaaaaa,Direction=115,Strength=4);
	</cfif>
	width: 180px;
	background-color: ##F9E6D4;
	border: 1px solid ##E17000;
	position: absolute;
	top: #attributes.top#px;
	left: #Evaluate(attributes.left + 6)#px;
	display: none;
	z-index: 999999;
	text-align:left;
}



img.#attributes.prefix#MenuBtn {
	cursor: pointer;
	position: absolute;
	top: #attributes.top#px;
	left: 0;
	z-index: 999998;
}

img.#attributes.prefix#MenuIcon {
	width: 19px;
	height: 16px;
	margin: 0 9px -5px 2px;
}

img.#attributes.prefix#MenuIconHover {
	width: 19px;
	height: 16px;
	margin: 0 9px -5px 2px;
}

div.#attributes.prefix#MenuItem {
	cursor: pointer;
	font: 86% arial,tahoma,verdana,sans-serif;
	color: ##000000;
	margin: 1px 0;
	padding: 3px 0;
	background: ##E17000 url(#attributes.imagedir#gutter.gif) repeat-y 0 0;
}


div.#attributes.prefix#MenuItemHover {
	cursor: pointer;
	font: 86% arial,tahoma,verdana,sans-serif;
	color: ##fff;
	margin: 1px 0;
	padding: 3px 0;
	background: ##E17000 url(#attributes.imagedir#gutter.gif) repeat-y 0 -50px;
}

hr.#attributes.prefix#MenuSeparator {
	margin: 0;
	padding: 0;
	height: 3px;
	line-height: 3px;
	width: 90%;
	border-top: none;
}

span.#attributes.prefix#MenuItemActive {
	color: green;
	background-color: green;
	font-size: 4pt;
}


span.#attributes.prefix#MenuItemInActive {
	color: red;
	background-color: red;
	font-size: 4pt;
}


span.#attributes.prefix#MenuItemNull {
	visibility: hidden;
	font-size: 4pt;
}

</style>
<!--- <div class="#attributes.prefix#Gutter">&nbsp;</div> --->
<div class="#attributes.prefix#Menu" onmouseover="Javascript:#attributes.prefix#ShowMenu();" onmouseout="Javascript:#attributes.prefix#ResetTimer();" id="#attributes.prefix#MenuID">
	<cfloop from="1" to="#arraylen(attributes.aItems)#" index="i">
		<cfif isStruct(attributes.aItems[i])>
			<cfsilent>			
			<cfif not structKeyExists(attributes.aItems[i],'icon')>
				<cfset target = 'pix.gif'>
			<cfelse>
				<cfset icon = attributes.aItems[i].icon>
			</cfif>
			
			<cfif not structKeyExists(attributes.aItems[i],'target')>
				<cfset target = '_self'>
			<cfelse>
				<cfset target = attributes.aItems[i].target>
			</cfif>
			<cfif not structKeyExists(attributes.aItems[i],'onclick')>
				<cfset onclick="">
			<cfelse>
				<cfset onclick = attributes.aItems[i].onclick>
			</cfif>			
			</cfsilent><div class="#attributes.prefix#MenuItem" onclick="#attributes.prefix#FollowMenuItem('#attributes.aItems[i].href#','#variables.target#')" onmouseout="Javscript:#attributes.prefix#UnHighlight(this);" onmouseover="Javascript:#attributes.prefix#Highlight(this);"><img src="#attributes.imagedir##variables.icon#" class="#attributes.prefix#MenuIcon">#attributes.aItems[i].text#</div>
		<cfelse>
			<hr class="#attributes.prefix#MenuSeparator">
		</cfif>
	</cfloop>
	<cfif attributes.showDisableContext and attributes.useContextMenu>
	<div class="#attributes.prefix#MenuItem" onclick="#variables.onclick#;#attributes.prefix#removeContextMenu();" onmouseout="Javscript:#attributes.prefix#UnHighlight(this);" onmouseover="Javascript:#attributes.prefix#Highlight(this);"><img src="#attributes.imagedir#pix.gif" class="#attributes.prefix#MenuIcon">Disable context menu</div>
	</cfif>
</div>
<img src="#attributes.imagedir##attributes.buttonimage#" width="15" height="52" alt="" border="0" onclick="Javascript:#attributes.prefix#ToggleMenu(this);" id="#attributes.prefix#MenuButtonID" class="#attributes.prefix#MenuBtn">

<script>
/*
 FarCry DHTML Float Menu
 Written by Stephen 'Spike' Milligan (spike@spike.org.uk)
 Plase vist http://farcry.daemon.com.au for more information
*/
var #attributes.prefix#ActiveMenu = document.getElementById('#attributes.prefix#MenuID');
var	#attributes.prefix#MenuBtn = document.getElementById('#attributes.prefix#MenuButtonID');
var ie = document.all ? 1 : 0;
var #attributes.prefix#Today = new Date();
var #attributes.prefix#RefTime = #attributes.prefix#Today.getTime();
var #attributes.prefix#MenuOpacity = #attributes.opacity#;
var #attributes.prefix#ShowHideAcceleration = #attributes.showHideAcceleration#;
var #attributes.prefix#TrackerAcceleration = #attributes.trackerAcceleration#;
var #attributes.prefix#HideDelay = #attributes.showHideDelay#;
var #attributes.prefix#RefreshMills = #attributes.refreshrate#;
var #attributes.prefix#MenuOffsetTop = #attributes.top#;
var #attributes.prefix#MenuOffsetLeft = #attributes.left#;
var #attributes.prefix#MenuTop = document.body.scrollTop + #attributes.prefix#MenuOffsetTop;
var #attributes.prefix#MenuLeft = document.body.scrollLeft + #attributes.prefix#MenuOffsetLeft;
var #attributes.prefix#Debug = false;
var #attributes.prefix#IgnoreMouse = false;
var #attributes.prefix#Timerid = 1;


if (    typeof(#attributes.prefix#ActiveMenu.filters) == 'unknown'
        ||
        typeof(#attributes.prefix#ActiveMenu.filters) == 'undefined')
{
        var #attributes.prefix#tmpfilter = new Object();
}
else {
        var #attributes.prefix#tmpfilter = #attributes.prefix#ActiveMenu.filters;
}

// Make sure the menufilter exists in non IE browsers
if (typeof(#attributes.prefix#tmpfilter.Opacity) != 'undefined') {
	var #attributes.prefix#MenuFilter = #attributes.prefix#ActiveMenu.filters.item('DXImageTransform.Microsoft.Alpha');
}
else {
	var #attributes.prefix#MenuFilter = new Object();
}

// Highlight a menu item
function #attributes.prefix#Highlight(item) {
	if (!#attributes.prefix#IgnoreMouse) {
		#attributes.prefix#ResetTimer();
		if (ie) {
			item.setAttribute('className','#attributes.prefix#MenuItemHover',0);
			//item.firstChild.nextSibling.setAttribute('className','#attributes.prefix#MenuIconHover',0);
		}
		else {
			item.setAttribute('class','#attributes.prefix#MenuItemHover');
			//item.firstChild.nextSibling.setAttribute('class','#attributes.prefix#MenuIconHover');;
		}
	}
}

// Remove the highlighting from a menuitem
function #attributes.prefix#UnHighlight(item) {
	if (!#attributes.prefix#IgnoreMouse) {
		if(ie) {
			item.setAttribute('className','#attributes.prefix#MenuItem',0);
			//item.firstChild.nextSibling.setAttribute('className','#attributes.prefix#MenuIcon',0);
		}
		else {
			item.setAttribute('class','#attributes.prefix#MenuItem');
			//item.firstChild.nextSibling.setAttribute('class','#attributes.prefix#MenuIcon');
		}
	}
}

// Show or hide the menu
function #attributes.prefix#ToggleMenu(src) {
	if(#attributes.prefix#ActiveMenu.style.display == '') {
		if (typeof(#attributes.prefix#MenuFilter.Opacity) != 'undefined') {
			#attributes.prefix#MenuFilter.Opacity = 1;
		}
		#attributes.prefix#IgnoreMouse = false;
		#attributes.prefix#Timerid = setTimeout('#attributes.prefix#TrackMenu()',#attributes.prefix#RefreshMills);
		#attributes.prefix#ShowMenu();
	}
	else {
		#attributes.prefix#IgnoreMouse = true;
		#attributes.prefix#HideMenu();
	}
}

// Show the menu
function #attributes.prefix#ShowMenu() {
	if (!#attributes.prefix#IgnoreMouse) {
		#attributes.prefix#ActiveMenu.style.display = 'block';
		if (typeof(#attributes.prefix#MenuFilter.Opacity) != 'undefined') {
			if (#attributes.prefix#MenuFilter.Opacity > #attributes.prefix#MenuOpacity) {
				#attributes.prefix#MenuFilter.Opacity = #attributes.prefix#MenuOpacity;
			}
			else {
				#attributes.prefix#MenuFilter.Opacity = #attributes.prefix#MenuOpacity+1 - (#attributes.prefix#MenuOpacity-#attributes.prefix#MenuFilter.Opacity)*#attributes.prefix#ShowHideAcceleration;
				#attributes.prefix#Timerid = setTimeout('#attributes.prefix#ShowMenu()',#attributes.prefix#RefreshMills);
				#attributes.prefix#ResetTimer();
			}
		}
		else {
			#attributes.prefix#Timerid = setTimeout('#attributes.prefix#TrackMenu()',#attributes.prefix#RefreshMills);
			#attributes.prefix#ResetTimer();
		}
	}
}

function #attributes.prefix#HideMenu() {
	#attributes.prefix#MenuOffsetTop = #attributes.top#;
	#attributes.prefix#MenuOffsetLeft = #attributes.left#;
	if (typeof(#attributes.prefix#tmpfilter.Opacity) != 'undefined') {
		#attributes.prefix#MenuFilter.Opacity = 1 - (1 - #attributes.prefix#MenuFilter.Opacity)*#attributes.prefix#ShowHideAcceleration;
		if (#attributes.prefix#MenuFilter.Opacity < 5) {
			#attributes.prefix#ActiveMenu.style.display = '';
		}
		else {
			#attributes.prefix#Timerid = setTimeout('#attributes.prefix#HideMenu()',#attributes.prefix#RefreshMills);
		}
	}
	else {
		#attributes.prefix#ActiveMenu.style.display = '';
	}
}


function #attributes.prefix#TrackMenu() {
	var #attributes.prefix#Now = new Date();
	
	if (#attributes.prefix#ActiveMenu.style.display != '' && #attributes.prefix#Now.getTime() - #attributes.prefix#RefTime > #attributes.prefix#HideDelay) {
		#attributes.prefix#HideMenu();
	}
	
	#attributes.prefix#MenuTop = document.body.scrollTop + #attributes.prefix#MenuOffsetTop;
	#attributes.prefix#MenuLeft = document.body.scrollLeft + #attributes.prefix#MenuOffsetLeft;
	
	if(typeof(#attributes.prefix#MenuBtn.style.posTop) != 'undefined') {
		#attributes.prefix#MenuBtn.style.posTop = #attributes.prefix#MenuTop - (#attributes.prefix#MenuTop-#attributes.prefix#MenuBtn.style.posTop)*#attributes.prefix#TrackerAcceleration;
		#attributes.prefix#MenuBtn.style.posLeft = #attributes.prefix#MenuLeft - (#attributes.prefix#MenuLeft-#attributes.prefix#MenuBtn.style.posLeft)*#attributes.prefix#TrackerAcceleration;
		#attributes.prefix#ActiveMenu.style.posTop = #attributes.prefix#MenuTop - (#attributes.prefix#MenuTop-#attributes.prefix#ActiveMenu.style.posTop)*#attributes.prefix#TrackerAcceleration;
		#attributes.prefix#ActiveMenu.style.posLeft = (#attributes.prefix#MenuLeft+6) - ((#attributes.prefix#MenuLeft+6)-#attributes.prefix#ActiveMenu.style.posLeft)*#attributes.prefix#TrackerAcceleration;
	
		
		#attributes.prefix#runTracker = false;
		
		if (Math.abs(#attributes.prefix#MenuBtn.style.posTop-#attributes.prefix#MenuTop) > 2) {
			#attributes.prefix#runTracker = true;
		}
		
		if (Math.abs(#attributes.prefix#MenuBtn.style.posLeft-#attributes.prefix#MenuLeft) > 2) {
			#attributes.prefix#runTracker = true;
		}
		
		if (#attributes.prefix#Now.getTime() - #attributes.prefix#RefTime < #attributes.prefix#HideDelay) {
			#attributes.prefix#runTracker = true;
		}
		
		if (#attributes.prefix#runTracker) {
			#attributes.prefix#Timerid = setTimeout('#attributes.prefix#TrackMenu()',#attributes.prefix#RefreshMills);
		}
		
	}
	else {
		#attributes.prefix#MenuBtn.style.top = #attributes.prefix#MenuTop;
		#attributes.prefix#MenuBtn.style.left = #attributes.prefix#MenuLeft;
		#attributes.prefix#ActiveMenu.style.top = #attributes.prefix#MenuTop;
		#attributes.prefix#ActiveMenu.style.left = #attributes.prefix#MenuLeft+6;
		
		
		#attributes.prefix#runTracker = false;
		
		if (Math.abs(#attributes.prefix#MenuBtn.style.top-#attributes.prefix#MenuTop) > 2) {
			#attributes.prefix#runTracker = true;
		}
		
		if (Math.abs(#attributes.prefix#MenuBtn.style.lefteft-#attributes.prefix#MenuLeft) > 2) {
			#attributes.prefix#runTracker = true;
		}
		
		if (#attributes.prefix#Now.getTime() - #attributes.prefix#RefTime < #attributes.prefix#HideDelay) {
			#attributes.prefix#runTracker = true;
		}
		
		if (#attributes.prefix#runTracker) {
			#attributes.prefix#Timerid = setTimeout('#attributes.prefix#TrackMenu()',#attributes.prefix#RefreshMills);
		}
		
	}
	
	#attributes.prefix#ShowDebug();
}


// Reset the refTime so that the menu disappears after the hideDelay time has elapsed
function #attributes.prefix#ResetTimer() {
	var #attributes.prefix#Now = new Date();
	#attributes.prefix#RefTime = #attributes.prefix#Now.getTime();
}




function #attributes.prefix#ShowDebug() {
	if(#attributes.prefix#Debug) {
		var #attributes.prefix#Now = new Date();
		window.status = 'Time offset: '
		window.status += #attributes.prefix#Now.getTime() - #attributes.prefix#RefTime;
		window.status += ' | Opacity: ';
		window.status += #attributes.prefix#MenuFilter.opacity;
		window.status += ' | Display: ';
		window.status += #attributes.prefix#ActiveMenu.style.display;
		window.status += ' | Timerid: ';
		window.status += #attributes.prefix#Timerid;
		window.status += ' | btnTop: ';
		window.status += #attributes.prefix#MenuBtn.style.posTop;
		window.status += ' | docTop: ';
		window.status += document.body.scrollTop;
		window.status += ' | menuTop: ';
		window.status += #attributes.prefix#MenuTop;
		window.status += ' | curpos: ';
		window.status += #attributes.prefix#MenuTop - (#attributes.prefix#MenuTop-#attributes.prefix#MenuBtn.style.posTop)*#attributes.prefix#TrackerAcceleration;

	}
}

function #attributes.prefix#FollowMenuItem(url,target) {
	if (!#attributes.prefix#IgnoreMouse) {
		var fs=window.open(url,target,'');
 		fs.focus();
	}
}

function #attributes.prefix#removeContextMenu() {
	if(typeof(document.body.addEventListener) != 'undefined') {
		document.body.removeEventListener('contextmenu',#attributes.prefix#DoContextMenu,true);
	}
	else {
		document.body.oncontextmenu = #attributes.prefix#doNothing;
	}
	document.body.oncontextmenu = #attributes.prefix#doNothing;
	#attributes.prefix#HideMenu();
}

function #attributes.prefix#doNothing() {

}


function #attributes.prefix#DoContextMenu(e) {
	if (document.all ) e=window.event;
  e.cancelBubble=true;
	if (ie) {
		#attributes.prefix#MenuOffsetTop = e.offsetY;
		#attributes.prefix#MenuOffsetLeft = e.offsetX;
	}
	else {
		#attributes.prefix#MenuOffsetTop = e.clientY;
		#attributes.prefix#MenuOffsetLeft = e.clientX;
	}
	#attributes.prefix#IgnoreMouse = false;
	#attributes.prefix#Timerid = setTimeout('#attributes.prefix#TrackMenu()',#attributes.prefix#RefreshMills);
	#attributes.prefix#ShowMenu();
	return false;
}


window.onscroll = #attributes.prefix#TrackMenu;

<cfif attributes.useContextMenu>
document.body.oncontextmenu = #attributes.prefix#DoContextMenu;
if(typeof(document.body.addEventListener) != 'undefined') {
	document.body.addEventListener('contextmenu',#attributes.prefix#DoContextMenu,true);
}
</cfif>
</script>

</cfoutput>

<cfsetting enablecfoutputonly="No">