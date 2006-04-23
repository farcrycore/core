<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/home.cfm,v 1.48.2.1 2004/02/13 06:34:37 brendan Exp $
$Author: brendan $
$Date: 2004/02/13 06:34:37 $
$Name: milestone_2-1-2 $
$Revision: 1.48.2.1 $

|| DESCRIPTION || 
$Description: The home page for farcry. Shows profile information, statistics, latest pages, pages waiting approval etc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes" requestTimeOut="200">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif session.firstLogin>
    <cfoutput>
    <script language="JavaScript">
    profileWin = window.open('edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=385,height=385,left=200,top=100');
    alert('This is the first time you\'ve logged into #application.config.general.siteTitle#. Please complete the following profile form with your details.');
    profileWin.focus();
    </script>
    </cfoutput>
    <cfset session.firstLogin = "false">
</cfif>

<cfoutput><table width="100%" border="0" cellpadding="10">
<tr>
	<!--- #### left column #### --->
	<td valign="top" width="33%">
		<!--- user profile stuff --->
		<span class="formTitle">Your Profile</span>
        <p>
		</cfoutput>
		<cfoutput>
		<cfscript>
			// display profile details
			oProfile = createObject("component", application.types.dmProfile.typePath);
			writeoutput(oProfile.displaySummary(session.dmProfile.objectID));
		</cfscript>

        <br>
        <hr width="100%" size="1" color="##000000" noshade>
		<p></p></cfoutput>
		
		<!--- graphs --->
				
		<!--- get all status breakdown --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getStatusBreakdown" returnvariable="stStatus"></cfinvoke>
		<cfoutput><span class="formTitle">Object Status Breakdown</span><p style="margin-left: 5%;">
		<cfchart 
			format="flash" 
			chartHeight="100" 
			chartWidth="250" 
			scaleFrom="0" 
			showXGridlines = "no" 
			showYGridlines = "no"
			showBorder = "no"
			font="arialunicodeMS"
			fontsize="10" fontbold="no" fontitalic="no" 
			labelFormat = "percent"
			show3D = "yes" rotated="no" sortxaxis="yes"
			showLegend = "yes" 
			tipStyle = "MouseOver" showmarkers="no" pieslicestyle="solid">
			
			<cfchartseries type="pie" colorlist="##eeeeee,##483D8B,##778899">
				<cfloop collection="#stStatus#" item="i">
					<cfchartdata item="#i#" value="#stStatus[i]#">
				</cfloop>
			</cfchartseries>
		</cfchart>
		
		<p></p>
		<hr width="100%" size="1" color="##000000" noshade>
		<p></p></cfoutput>
		
		<!--- age of content graph --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getAgeBreakdown" returnvariable="stAge">
			<cfinvokeargument name="breakdown" value="7,14,21"/>
		</cfinvoke>
		
		<cfoutput><span class="formTitle">Object Age Breakdown</span><p style="margin-left: 5%;">
		<cfchart 
			format="flash" 
			chartHeight="100" 
			chartWidth="250" 
			scaleFrom="0" 
			showXGridlines = "no" 
			showYGridlines = "no"
			showBorder = "no"
			font="arialunicodeMS"
			fontsize="10" fontbold="no" fontitalic="no" 
			labelFormat = "percent"
			show3D = "yes" rotated="no" sortxaxis="yes"
			showLegend = "yes" 
			tipStyle = "MouseOver" showmarkers="no" pieslicestyle="solid">
			
			<cfchartseries type="pie" colorlist="##eeeeee,##483D8B,##778899,##aeaeae">
				<cfloop collection="#stAge#" item="i">
					<!--- check if last segment ie > last defined date --->
					<cfif not isNumeric(i)>
						<cfchartdata item="#i# days" value="#stAge[i]#">
					<cfelse>
						<cfchartdata item="Last #i# days" value="#stAge[i]#">
					</cfif>
				</cfloop>
			</cfchartseries>
		</cfchart>
		<p></p>
		<hr width="100%" size="1" color="##000000" noshade>
		<p></p>
		
		<!--- FarCry Build Details --->
		<div class="formTitle">FarCry Build Details</div>
		</cfoutput>
		
		<!--- Read core build text file --->
		<cffile action="read" file="#application.path.core#/admin/build.txt" variable="buildFile">
		
		<!--- search for tag name --->
		<cfset stBuild = reFindNoCase('(\Name:[^\$]+\$)',buildFile,1,true)>
		<cfset substr = mid(buildFile,stBuild.pos[1],stBuild.len[1])>
		<cfset result = reReplaceNoCase(substr,'(\Name:)([^\$]+)(\$)','\2')>
		
		<!--- Read fourq build text file --->
		<cfset tmpFourqFile = replace(application.path.core,"\","/","all")>
		<cfset fourqFile = listDeleteAt(tmpFourqFile,listLen(tmpFourqFile,"/"),"/")>
		<cfset fourqFile = fourqFile & "/fourq/fourq.cfc">
		<cffile action="read" file="#fourqFile#" variable="fourqBuildFile">
		
		<!--- search for tag name --->
		<cfset stFourQBuild = reFindNoCase('(\Name:[^\$]+\$)',fourqBuildFile,1,true)>
		<cfset substrFourq = mid(fourqBuildFile,stFourQBuild.pos[1],stFourQBuild.len[1])>
		<cfset fourqResult = reReplaceNoCase(substrFourq,'(\Name:)([^\$]+)(\$)','\2')>
		
		
		<!--- display build details --->
		<cfoutput>
		FarCry: <cfif len(result) gt 2>#result#<cfelse>unknown</cfif><br>
		FourQ: <cfif len(fourqResult) gt 2>#fourqResult#<cfelse>unknown</cfif>
		
	</td></cfoutput>
	
	<!--- #### centre column #### --->
	<cfoutput><td valign="top"></cfoutput>
	
		<!--- get objects pending approval --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getObjectsPendingApproval" returnvariable="stPendingObjects">
			<cfinvokeargument name="userLogin" value="#session.dmProfile.userName#"/>
		</cfinvoke>

		<cfoutput><p></p>

		<!--- display objects needing approval --->
		<cfif not structIsEmpty(stPendingObjects)>
			<span class="formTitle">Objects Pending Your Approval</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="100%"><strong>OBJECT</strong></td>
				<td nowrap align="center"><strong>CREATED BY</strong></td>
				<td nowrap align="center"><strong>LAST UPDATED</strong></td>
			</tr>
            <cfset currentrow = 1>
			<cfloop collection="#stPendingObjects#" item="i">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stPendingObjects[i]["parentObject"]#">#stPendingObjects[i]["objectTitle"]#</cfoutput></td>
					<td><cfoutput><cfif stPendingObjects[i]["objectCreatedByEmail"] neq ""><a href="mailto:#stPendingObjects[i]["objectCreatedByEmail"]#" title="#stPendingObjects[i]["objectCreatedByEmail"]#"></cfif>#stPendingObjects[i]["objectCreatedBy"]#<cfif stPendingObjects[i]["objectCreatedByEmail"] neq ""></a></cfif></cfoutput></td>
					<td valign="top" align="center"><cfoutput>#dateformat(stPendingObjects[i]["objectLastUpdate"],"dd-mmm-yyyy")#</cfoutput></td>
				</tr>
             <cfset currentrow = currentrow + 1>
			</cfloop>
			</table>
			<p>
		</cfif>
		</cfoutput>
		
		<!--- get news pending approval --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getNewsPendingApproval" returnvariable="stPendingNews"></cfinvoke>
		
		<!--- display news pending approval --->
		<cfoutput>
		<cfif not structisempty(stPendingNews)>
			<span class="formTitle">News Articles Pending Your Approval</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="100%"><strong>OBJECT</strong></td>
				<td nowrap align="center"><strong>CREATED BY</strong></td>
				<td nowrap align="center"><strong>LAST UPDATED</strong></td>
			</tr>
            <cfset currentrow = 1>
			<cfloop collection="#stPendingNews#" item="i">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=dynamic&objectid=#i#&status=pending">#stPendingNews[i]["objectTitle"]#</td>
					<td><cfif stPendingNews[i]["objectCreatedByEmail"] neq ""><a href="mailto:#stPendingNews[i]["objectCreatedByEmail"]#" title="#stPendingNews[i]["objectCreatedByEmail"]#"></cfif>#stPendingNews[i]["objectCreatedBy"]#<cfif stPendingNews[i]["objectCreatedByEmail"] neq ""></a></cfif></td>
					<td valign="top" align="center">#dateformat(stPendingNews[i]["objectLastUpdate"],"dd-mmm-yyyy")#</td>
				</tr>
            <cfset currentrow = currentrow + 1>
			</cfloop>
			</table>
			<p>
		</cfif>
		</cfoutput>
		
		<!--- get all draft objects --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getUserDraftObjects" returnvariable="qDraftObjects">
			<cfinvokeargument name="userLogin" value="#session.dmProfile.userName#"/>
		</cfinvoke>
		
		<!--- display all draft objects --->
		<cfoutput>
		<cfif qDraftObjects.recordcount gt 0>
			<span class="formTitle">Objects you have in draft</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="!00%"><strong>OBJECT</strong></td>
				<td nowrap align="center"><strong>TYPE</strong></td>
				<td nowrap align="center"><strong>LAST UPDATED</strong></td>
			</tr>
			<cfparam name="url.draftEndRow" default="5">
			<cfloop query="qDraftObjects" startrow="1" endrow="#url.draftEndRow#">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<cfif objectType eq "dmNews">
						<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=dynamic&objectid=#objectid#&status=draft">#objectTitle#</td>
					<cfelse>						
						<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=site&rootobjectid=#objectParent#">#objectTitle#</td>
					</cfif>
					<td valign="top">#objectType#</td>
					<td valign="top" align="center">#dateformat(objectLastUpdated,"dd-mmm-yyyy")#</td>
				</tr>
			</cfloop>
			</table>
			<!--- show link to all draftObjects --->
			<cfif qDraftObjects.recordcount gt url.draftEndRow>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=#qDraftObjects.recordcount#">Show All</a></div>
			<cfelseif url.draftEndRow neq 5>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=5">Show most recent 5</a></div>
			</cfif>
		 <p>
		</cfif>
		</cfoutput>
		
		<!--- get all locked objects --->
		<cfinvoke component="#application.packagepath#.farcry.locking" method="getLockedObjects" returnvariable="qLockedObjects">
			<cfinvokeargument name="userLogin" value="#session.dmProfile.userName#_#session.dmProfile.userDirectory#"/>
		</cfinvoke>
		
		<!--- display all locked objects --->
		<cfoutput>
		<cfif qLockedObjects.recordcount gt 0>
			<span class="formTitle">Objects you have locked</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="!00%"><strong>OBJECT</strong></td>
				<td nowrap align="center"><strong>TYPE</strong></td>
				<td nowrap align="center"><strong>LAST UPDATED</strong></td>
				<td>&nbsp;</td>
			</tr>
			<cfparam name="url.lockedEndRow" default="5">
			<cfloop query="qLockedObjects" startrow="1" endrow="#url.lockedEndRow#">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<cfif not structKeyExists(application.types[objectType], "bUseInTree")>
						<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=dynamic&objectid=#objectid#&status=all">#objectTitle#</cfoutput></td>
					<cfelse>
						<cfif len(objectParent)>
							<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#objectParent#">#objectTitle#</cfoutput></td>
						<cfelse>
							<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=dynamic&objectid=#objectid#&status=all">#objectTitle#</cfoutput></td>
						</cfif>
					</cfif>
					<td valign="top">#objectType#</td>
					<td valign="top" align="center">#dateformat(objectLastUpdated,"dd-mmm-yyyy")#</td>
					<td valign="top" align="center"><a href="navajo/unlock.cfm?objectid=#objectid#&typename=#objectType#&return=home">[unlock]</a></td>
				</tr>
			</cfloop>
			</table>
			<!--- show link to all locked Objects --->
			<cfif qLockedObjects.recordcount gt url.lockedEndRow>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?lockedEndRow=<cfoutput>#qLockedObjects.recordcount#</cfoutput>">Show All</div>
			<cfelseif url.lockedEndRow neq 5>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?lockedEndRow=5">Show most recent 5</div>
			</cfif>
		</cfif>
		<p>&nbsp;</p>
	</td>
	</cfoutput>
	
	<!--- #### right column #### --->
	<cfoutput><td valign="top"></cfoutput>
		<!--- get all recent HTML objects --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getRecentObjects" returnvariable="stRecentHTMLObjects">
			<cfinvokeargument name="numberOfObjects" value="5"/>
			<cfinvokeargument name="objectType" value="dmHTML"/>
		</cfinvoke>
		
		<!--- display recent HTML objects --->
		<cfoutput>
		<cfif structCount(stRecentHTMLObjects) gt 0>
			<span class="formTitle">Recently Added Pages</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="100%"><strong>PAGE</strong></td>
				<td nowrap align="center"><strong>CREATED BY</strong></td>
				<td nowrap align="center"><strong>DATE CREATED</strong></td>
			</tr>
            <cfset currentrow = 1>
    		<cfloop collection="#stRecentHTMLObjects#" item="item">
                <cfset stRecentObj = stRecentHTMLObjects[item]>
			<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stRecentObj.objectParent#"><cfif stRecentObj.title neq "">#stRecentObj.title#<cfelse><em>undefined</em></cfif></cfoutput></td>
				<td valign="top"><cfoutput><cfif stRecentObj.userEmail neq ""><a href="mailto:#stRecentObj.userEmail#" title="#stRecentObj.userEmail#"></cfif>#stRecentObj.createdBy#<cfif stRecentObj.userEmail neq ""></a></cfif></cfoutput></td>
				<td valign="top" align="center"><cfoutput>#dateformat(stRecentObj.dateTimeCreated,"dd-mmm-yyyy")#</cfoutput></td>
			</tr>
                <cfset currentrow = currentrow + 1>
			</cfloop>
			</table>
			<p>
		</cfif>
		</cfoutput>
		
		<!--- get all recent News objects --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getRecentObjects" returnvariable="stRecentNewsObjects">
			<cfinvokeargument name="numberOfObjects" value="5"/>
			<cfinvokeargument name="objectType" value="dmNews"/>
		</cfinvoke>
		
		
		<!--- display recent News objects --->
		<cfoutput>
		<cfif structCount(stRecentNewsObjects) gt 0>
			<span class="formTitle">Recently Added News Articles</span>
			
			<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
			<tr class="dataheader">
				<td width="100%"><strong>NEWS ARTICLE</strong></td>
				<td nowrap align="center"><strong>CREATED BY</strong></td>
				<td nowrap align="center"><strong>DATE CREATED</strong></td>
			</tr>
            <cfset currentrow = 1>
			<cfloop collection="#stRecentNewsObjects#" item="item">
                <cfset stRecentObj = stRecentNewsObjects[item]>
			<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=dynamic&objectid=#stRecentObj.objectid#&status=all"><cfif stRecentObj.title neq "">#stRecentObj.title#<cfelse><em>undefined</em></cfif></cfoutput></td>
				<td valign="top"><cfoutput><cfif stRecentObj.userEmail neq ""><a href="mailto:#stRecentObj.userEmail#" title="#stRecentObj.userEmail#"></cfif>#stRecentObj.createdBy#<cfif stRecentObj.userEmail neq ""></a></cfif></cfoutput></td>
				<td valign="top" align="center"><cfoutput>#dateformat(stRecentObj.dateTimeCreated,"dd-mmm-yyyy")#</cfoutput></td>
			</tr>
            <cfset currentrow = currentrow + 1>
			</cfloop>
			</table>
		</cfif>
		
		<!--- site usage graph --->
		<cfscript>
			qStats = application.factory.oStats.getPageStatsByDate(before=now(),after=dateadd("m",-1,now()));
		</cfscript>
		
		<cfif qStats.Max gt 0>

			<cfoutput><p></p><span class="formTitle">Site Usage in the last month</span><p style="margin-left: 5%;">
	    		<div align="center"><cfchart 
				format="flash" 
				chartHeight="300" 
				chartWidth="300" 
				scaleFrom="0" 
				showXGridlines = "yes" 
				showYGridlines = "yes"
				seriesPlacement="default"
				showBorder = "no"
				font="arialunicodeMS"
				fontsize="10" fontbold="no" fontitalic="no" 
				labelFormat = "number"
				xAxisTitle = "Date" 
				yAxisTitle = "Total Views Per Day" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "yes" 
				tipStyle = "MouseOver"
				gridlines = "#qStats.max#">
			<cfchartseries type="line" query="qStats.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="Views in the last month" paintstyle="shade"></cfchartseries>

		</cfchart></div></cfoutput>

        </cfif>
	</td>
</tr>
</table>

<STYLE TYPE="text/css">
##idServer { position:relative;width: 1px;height: 1px;clip:rect(0px 1px 1px 0px);display:none;}
</STYLE>
<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P>This page uses a hidden frame and requires either Microsoft 
		Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
		higher.)</P>
		</ILAYER>
</IFRAME>

</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">
