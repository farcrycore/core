<cfsetting enablecfoutputonly="Yes">
<!---
Description: Puts a red dot in the top right hand corner of the page that floats around,
			 when clicked on a drop down menu appears with edit options in it.
			 
Usage
-----
This file should just be included from the display page.
--->

<cfif cgi.HTTP_USER_AGENT contains "IE">

<cf_dmSec_loggedIn r_bLoggedIn="bLoggedIn">

<cfif bLoggedIn>

	<!--- check they are admin --->
	<cf_dmSec_PermissionCheck
		permissionName="Admin"
		reference1="PolicyGroup"
		targetType="PolicyGroup"
		r_iState="iAdmin">
	<!--- check they are able to comment --->

	<cf_dmSec2_PermissionCheck permissionName="CanCommentOnContent" objectId="#request.NavID#" r_iState="iCanCommentOnContent" reference1="dmNavigation">

	<cfif iAdmin eq 1 or iCanCommentOnContent eq 1>

		<cfset request.floaterIsOnPage = true>
		<!--- This is the magical div thingy... --->
		<cfoutput>
		<Style>
		.floaterLink:hover:visited
		{
			font-family:Verdana,Arial,Helvetica;
			font-size:8 pt;
			font-weight:normal;
			color:Blue;
			line-height : normal;
		}
		</STYLE>
		
		<DIV align="left" id="frmfly" style="z-index:1000; DISPLAY: none; LEFT: -200px; POSITION: absolute; TOP: 100px; VISIBILITY: hidden; WIDTH: 150px">
			<TABLE style="line-height : normal;" border="0" cellpadding="0" cellspacing="0" height="100" width="150">
				<TR >
					<TD width="14" bgColor="white"><IMG height="100%" src="farcry/images/floater_lb.gif" width="6"></TD>
					<!--- Put the body of the popup thingy in here... --->
					<td bgColor=white width="136" valign="top">
					<span style="line-height : normal;font-family:Verdana,Arial,Helvetica;font-size:8 pt;font-weight:normal;color:gray;">
<b>:: FarCry ::</b><br><br>

<cfif iAdmin eq 1>
	<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#">&designmode=<cfif isDefined("url.designMode") and (url.designmode eq "1")>0<cfelse>1</cfif>">Toggle View</a><br>
	<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#">&flushcache=1&showdraft=0">Flush Cache</a><br>
	
	<cfif isDefined("request.navajo.bShowDraftPending") AND request.navajo.bShowDraftPending eq 0>
		<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#&flushcache=1&showdraft=1"><cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Show Draft</a><br>
	<cfelse>
		<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#&flushcache=1&showdraft=0"><cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Hide Draft</a><br>
	</cfif>
	
	<cflock timeout="10" throwontimeout="Yes" type="READONLY" scope="SESSION">
		<cfif isdefined("session.designmodedisplay") and session.designmodedisplay>
			<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#">&designmodeheader=0<cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Toggle Header</a><br>
		<cfelse>
			<a class="floaterLink" href="#application.url.farcry#/navajo/display.cfm<cf_URLGenerator objectID="#url.ObjectID#">&designmodeheader=1<cfif isDefined("url.designMode") and (url.designmode eq "1")>&designmode=1</cfif>">Toggle Header</a><br>
		</cfif>
	</cflock>
	<a class="floaterLink" href="##" onClick="window.open('#application.url.farcry#/navajo/overview.cfm','Admin');">Admin Page</a><br>
</cfif>
<cfif iCanCommentOnContent eq 1>

	<a class="floaterLink" href="##" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);">Comment</a><br>
</cfif>
<a class="floaterLink" style="color:red" href="#cgi.script_name#?logout=1&#cgi.query_string#">Logout</a><br>
					<br>
					</span>
					</td>	
				<TR>
					<TD colspan="2"><IMG height="22" onClick="FooterClick();" src="farcry/images/floater_open.gif" width="150" border="0"></TD>
				</TR>
			</TABLE>
		</DIV>
		
		<DIV align="right" id="fly2" style="z-index:1000; DISPLAY: none; LEFT: -200px; POSITION: absolute; TOP: 2px; VISIBILITY: visible; WIDTH: 115px">
			<cfif Isdefined("URL.Designmode") AND URL.Designmode EQ 0></cfif>
			<SPAN onClick="FooterOpen()" style="CURSOR: hand"> 
				<TABLE border="0" cellpadding="0" cellspacing="0" height="7" width="115">
				<tr>
					<TD width="16">&nbsp;</td>
					<td><img src="farcry/images/floater_closed.gif" width="7" height="7" alt="" border="0"></td>
				</tr>
				</table>
			</SPAN>
		</DIV>
		
		<SCRIPT event=onresize for=window language=JScript>
		srs101();
		</SCRIPT>
		
		<SCRIPT event=onscroll for=window language=JScript>
		srs101();
		</SCRIPT>
		
		<SCRIPT language=javascript>
		srs101();
		
		// NickScript getacookietypedevice...
		function get_cookie_value(x)
		{
		var cookieMonster = document.cookie;
		var pos=cookieMonster.indexOf(x + "=");
		
		if (pos != -1)
			{
			var start = pos + x.length + 1;
			var end = cookieMonster.indexOf(";", start);
			if (end == -1) end = cookieMonster.length;	
			var value = cookieMonster.substring(start,end);
			value = unescape(value);
			return(value);	
			}
			else return(0);	
		}
		
		
		function FooterOpen() {
			if(document.getElementById('ositeSelect')) ositeSelect.style.visibility='hidden';
			srch='on';
			frmfly.style.visibility='visible';
			frmfly.style.display='inline';
			fly2.style.visibility='hidden';
			document.cookie="frrf=on";
			frrf='on';
			srs101();
		}
		
		function FooterClick() {
			if(document.getElementById('ositeSelect')) ositeSelect.style.visibility='visible';
			srch='off';
			frmfly.style.visibility='hidden';
			fly2.style.top=frmfly.style.posTop;
			fly2.style.left=frmfly.style.posLeft;
			fly2.style.visibility='visible';
			fly2.style.display='block';
			document.cookie="frrf=off";
			frrf='off';
		}
		
		function srs101()
		{
			with(document.body)
			{
				if((srch=="on")&&(frrf=="on"))
				{
					
					if(clientWidth>725)
					{
						frmfly.style.left=clientWidth-nOffSet;
						frmfly.style.top=scrollTop+2;
							
					}
				}
				else if((clientWidth>725)&&(winwide=="off"))
				{
					frmfly.style.top=scrollTop+2;
					fly2.style.top=scrollTop+2;
					frmfly.style.left=clientWidth-nOffSet;
					fly2.style.left=clientWidth-nOffSet;
					frmfly.style.display='';fly2.style.display='';
					setTimeout("var winwide='on';var srch='on';var frrf='on';srs101();",5000);
				}
			}
		}
		
		// store / retrive the status of the floater...
		var frrf;
		if ( !(frrf = get_cookie_value("frrf")) ){
			document.cookie="frrf=off";
			frrf="off";
		}
		
		
		var srch="off";
		var winwide="off";
		var nOffSet = 150;
		
		frmfly.style.posLeft = document.body.clientWidth-nOffSet;
		fly2.style.posLeft = document.body.clientWidth-nOffSet;
		
		if(document.body.clientWidth>725){
			var srch="on";
			frmfly.style.display='';
		}else{
			var winwide="off";
		}
		
		if(document.body.clientWidth>725){
			if ((srch=="on")&&(frrf=="on")) {
				frmfly.style.visibility='visible';
				fly2.style.visibility='hidden';
				srs101();
			} 
			else {
				frmfly.style.visibility='hidden';
				with(fly2.style){
					top=frmfly.style.posTop;
					left=frmfly.style.posLeft;
					visibility='visible';
					display='none'
				}
				fly2.style.display='';		
				srs101();
			}
		}
		
		</SCRIPT>
	</cfoutput>
	
	</cfif>
</cfif>

</cfif>

<cfsetting enablecfoutputonly="No">