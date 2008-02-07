<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/home.cfm,v 1.59 2005/09/06 10:21:29 paul Exp $
$Author: paul $
$Date: 2005/09/06 10:21:29 $
$Name: milestone_3-0-1 $
$Revision: 1.59 $

|| DESCRIPTION || 
$Description: The home page for farcry. Shows profile information, statistics, latest pages, pages waiting approval etc $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="Yes" requestTimeOut="200">
<!--- check for customised myFarCry home page --->
<cfif fileexists(application.path.project & "/customadmin/home.cfm")>
    <cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/home.cfm">
<cfelse>
		<!--- set up page header --->
		<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
		<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
		
		<cfif session.firstLogin>
		    <cfoutput>
		    <script type="text/javascript">
		    profileWin = window.open('edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=385,height=385,left=200,top=100');
		    alert('#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].firstTimeLoginBlurb,"#application.config.general.siteTitle#")#');
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
				<span class="formTitle">#application.adminBundle[session.dmProfile.locale].yourProfile#</span>
		        <p>
				</cfoutput>
				
				<cfscript>
					// display profile details
					oProfile = createObject("component", application.types.dmProfile.typePath);
					writeoutput(oProfile.displaySummary(session.dmProfile.objectID));
				</cfscript>
		
		        <cfoutput><br>
		        <hr width="100%" size="1" color="##000000" noshade>
				<p></p></cfoutput>
				
				<!--- graphs --->
						
				<!--- get all status breakdown --->
				<cfinvoke component="#application.packagepath#.farcry.workflow" method="getStatusBreakdown" returnvariable="stStatus"></cfinvoke>
				<cfoutput><span class="formTitle">#application.adminBundle[session.dmProfile.locale].objStatusBreakdown#</span><p style="margin-left: 5%;"></cfoutput>
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
					<!--- i18n: slip in localized words for obj status: Draft, Pending & Approved --->
					<cfchartseries type="pie" colorlist="##eeeeee,##483D8B,##778899">
						<cfloop collection="#stStatus#" item="i">
							<cfchartdata item="#application.adminBundle[session.dmProfile.locale][i]#" value="#stStatus[i]#">
						</cfloop>
					</cfchartseries>
				</cfchart>
				
				<cfoutput><p></p>
				<hr width="100%" size="1" color="##000000" noshade>
				<p></p></cfoutput>
				
				<!--- age of content graph --->
				<cfinvoke component="#application.packagepath#.farcry.reporting" method="getAgeBreakdown" returnvariable="stAge">
					<cfinvokeargument name="breakdown" value="7,14,21"/>
				</cfinvoke>
				
				<cfoutput><span class="formTitle">#application.adminBundle[session.dmProfile.locale].objAgeBreakdown#</span><p style="margin-left: 5%;"></cfoutput>
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
								<cfset tD=application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].numberDays,i)>
								<cfchartdata item="#tD#" value="#stAge[i]#">
							<cfelse>
								<cfset tD=application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].numberlastDays,i)>
								<cfchartdata item="#tD#" value="#stAge[i]#">
							</cfif>
						</cfloop>
					</cfchartseries>
				</cfchart>
				<cfoutput><p></p>
				<hr width="100%" size="1" color="##000000" noshade>
				<p></p>
				
				<!--- FarCry Build Details --->
				<div class="formTitle">#application.adminBundle[session.dmProfile.locale].buildDetails#</div>
				</cfoutput>
				
				<cftry>
				<!--- Read core build text file --->
				<cffile action="read" file="#application.path.core#/webtop/build.txt" variable="buildFile">
				
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
					<cfcatch>
					<!--- if we can't read the files, then show unknown for now 050323GB --->
						<cfset result="Unknown">
						<cfset fourqResult="Unknown">
						<cftrace type="warning" var="cfcatch.Detail">
					</cfcatch>
				</cftry>
				<!--- display build details --->
				<cfoutput>
				FarCry: <cfif len(result) gt 2>#result#<cfelse>#application.adminBundle[session.dmProfile.locale].unknown#</cfif><br>
				FourQ: <cfif len(fourqResult) gt 2>#fourqResult#<cfelse>#application.adminBundle[session.dmProfile.locale].unknown#</cfif>
				
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
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].objPendingApproval#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="100%"><strong>#application.adminBundle[session.dmProfile.locale].object#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].createdBy#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].lastUpdated#</strong></td>
					</tr>
		            <cfset currentrow = 1>
					<cfloop collection="#stPendingObjects#" item="i">
						<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
							<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stPendingObjects[i]["parentObject"]#">#stPendingObjects[i]["objectTitle"]#</cfoutput></td>
							<td><cfoutput><cfif stPendingObjects[i]["objectCreatedByEmail"] neq ""><a href="mailto:#stPendingObjects[i]["objectCreatedByEmail"]#" title="#stPendingObjects[i]["objectCreatedByEmail"]#"></cfif>#stPendingObjects[i]["objectCreatedBy"]#<cfif stPendingObjects[i]["objectCreatedByEmail"] neq ""></a></cfif></cfoutput></td>
							<td valign="top" align="center"><cfoutput>#application.thisCalendar.i18nDateFormat(stPendingObjects[i]["objectLastUpdate"],session.dmProfile.locale,application.longF)#</cfoutput></td>
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
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].newsPendingApproval#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="100%"><strong>#application.adminBundle[session.dmProfile.locale].object#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].createdBy#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].lastUpdated#</strong></td>
					</tr>
		            <cfset currentrow = 1>
					<cfloop collection="#stPendingNews#" item="i">
						<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
							<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=dynamic&objectid=#i#&status=pending">#stPendingNews[i]["objectTitle"]#</td>
							<td><cfif stPendingNews[i]["objectCreatedByEmail"] neq ""><a href="mailto:#stPendingNews[i]["objectCreatedByEmail"]#" title="#stPendingNews[i]["objectCreatedByEmail"]#"></cfif>#stPendingNews[i]["objectCreatedBy"]#<cfif stPendingNews[i]["objectCreatedByEmail"] neq ""></a></cfif></td>
							<td valign="top" align="center">#application.thisCalendar.i18nDateFormat(stPendingNews[i]["objectLastUpdate"],session.dmProfile.locale,application.longF)#</td>
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
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].draftObjects#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="!00%"><strong>#application.adminBundle[session.dmProfile.locale].object#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].type#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].lastUpdated#</strong></td>
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
							<td valign="top" align="center">#application.thisCalendar.i18nDateFormat(objectLastUpdated,session.dmProfile.locale,application.longF)#</td>
						</tr>
					</cfloop>
					</table>
					<!--- show link to all draftObjects --->
					<cfif qDraftObjects.recordcount gt url.draftEndRow>
						<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=#qDraftObjects.recordcount#">#application.adminBundle[session.dmProfile.locale].showAll#</a></div>
					<cfelseif url.draftEndRow neq 5>
						<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=5">#application.adminBundle[session.dmProfile.locale].showRecent5#</a></div>
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
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].lockedObjects#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="!00%"><strong>#application.adminBundle[session.dmProfile.locale].object#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].type#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].lastUpdated#</strong></td>
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
							<td valign="top" align="center">#application.thisCalendar.i18nDateFormat(objectLastUpdated,session.dmProfile.locale,application.longF)#</td>
							<td valign="top" align="center"><a href="navajo/unlock.cfm?objectid=#objectid#&typename=#objectType#&return=home">[#application.adminBundle[session.dmProfile.locale].unlock#]</a></td>
						</tr>
					</cfloop>
					</table>
					<!--- show link to all locked Objects --->
					<cfif qLockedObjects.recordcount gt url.lockedEndRow>
						<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?lockedEndRow=<cfoutput>#qLockedObjects.recordcount#</cfoutput>">#application.adminBundle[session.dmProfile.locale].showAll#</div>
					<cfelseif url.lockedEndRow neq 5>
						<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?lockedEndRow=5">#application.adminBundle[session.dmProfile.locale].showRecent5#</div>
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
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].recentlyAddedPages#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="100%"><strong>#application.adminBundle[session.dmProfile.locale].page#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].createdBy#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].dateCreated#</strong></td>
					</tr>
		            <cfset currentrow = 1>
		    		<cfloop collection="#stRecentHTMLObjects#" item="item">
		                <cfset stRecentObj = stRecentHTMLObjects[item]>
					<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stRecentObj.objectParent#"><cfif stRecentObj.title neq "">#stRecentObj.title#<cfelse><em>#application.adminBundle[session.dmProfile.locale].undefined#</em></cfif></cfoutput></td>
						<td valign="top"><cfoutput><cfif stRecentObj.userEmail neq ""><a href="mailto:#stRecentObj.userEmail#" title="#stRecentObj.userEmail#"></cfif>#stRecentObj.createdBy#<cfif stRecentObj.userEmail neq ""></a></cfif></cfoutput></td>
						<td valign="top" align="center"><cfoutput>#application.thisCalendar.i18nDateFormat(stRecentObj.dateTimeCreated,session.dmProfile.locale,application.longF)#</cfoutput></td>
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
				<cfif structCount(stRecentNewsObjects) gt 0>
					<cfoutput>
					<span class="formTitle">#application.adminBundle[session.dmProfile.locale].recentNewsArticles#</span>
					
					<table width="100%" cellpadding="5" cellspacing="1" border="0" style="margin-left:0px;margin-top:10px;border:1px solid ##000;">
					<tr class="dataheader">
						<td width="100%"><strong>#application.adminBundle[session.dmProfile.locale].newsArticle#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].createdBy#</strong></td>
						<td nowrap align="center"><strong>#application.adminBundle[session.dmProfile.locale].dateCreated#</strong></td>
					</tr>
					</cfoutput>
		            <cfset currentrow = 1>
					<cfloop collection="#stRecentNewsObjects#" item="item">
		                <cfset stRecentObj = stRecentNewsObjects[item]>
					<cfoutput>
					<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=dynamic&objectid=#stRecentObj.objectid#&status=all"><cfif stRecentObj.title neq "">#stRecentObj.title#<cfelse><em>#application.adminBundle[session.dmProfile.locale].undefined#</em></cfif></td>
						<td valign="top"><cfif stRecentObj.userEmail neq ""><a href="mailto:#stRecentObj.userEmail#" title="#stRecentObj.userEmail#"></cfif>#stRecentObj.createdBy#<cfif stRecentObj.userEmail neq ""></a></cfif></td>
						<td valign="top" align="center">#application.thisCalendar.i18nDateFormat(stRecentObj.dateTimeCreated,session.dmProfile.locale,application.longF)#</td>
					</tr>
					</cfoutput>
		            <cfset currentrow = currentrow + 1>
					</cfloop>
					<cfoutput></table></cfoutput>
				</cfif>
				
				<!--- site usage graph --->
				<cfscript>
					qStats = application.factory.oStats.getPageStatsByDate(before=now(),after=dateadd("m",-1,now()));
				</cfscript>
				
				<cfif qStats.Max gt 0>
					<cfoutput><p></p><span class="formTitle">#application.adminBundle[session.dmProfile.locale].siteUsageLastMonth#</span><p style="margin-left: 5%;">
			    		<div align="center"></cfoutput>
			    	<cfchart 
						format="flash" 
						chartHeight="300" 
						chartWidth="300" 
						scaleFrom="0"
						scaleTo="#qStats.max*1.1#"
						showXGridlines = "yes" 
						showYGridlines = "yes"
						seriesPlacement="default"
						showBorder = "no"
						font="arialunicodeMS"
						fontsize="10" fontbold="no" fontitalic="no" 
						labelFormat = "number"
						xAxisTitle = "#application.adminBundle[session.dmProfile.locale].date#" 
						yAxisTitle = "#application.adminBundle[session.dmProfile.locale].totalViews#" 
						show3D = "yes"
						xOffset = "0.15" 
						yOffset = "0.15"
						rotated = "no" 
						showLegend = "no" 
						tipStyle = "MouseOver">
					<cfchartseries type="line" query="qStats.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="#application.adminBundle[session.dmProfile.locale].viewsInLastMonth#" paintstyle="shade"></cfchartseries>
		
					</cfchart>
					<cfoutput></div></cfoutput>
		        </cfif>
		
		<cfoutput>
			</td>
		</tr>
		</table>
		
		</cfoutput>
		
		<!--- setup footer --->
		<admin:footer>
</cfif>
<cfsetting enablecfoutputonly="No">
