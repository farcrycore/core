<cfsetting enablecfoutputonly="Yes">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfoutput><table width="100%" border="0" cellpadding="10">
<tr>
	<!--- #### left column #### --->
	<td valign="top" align="center" width="33%">
		<!--- user profile stuff --->
		<span class="formTitle">Your Profile</span><p></p>
		<span class="framMenuBullet">&raquo;</span> <a href="##"  onClick="javascript:window.open('security/updatePassword.cfm','','width=350,height=250,left=200,top=100');startTimer()">Change your password</a>
		
		<p></p>
		<hr width="80%" align="center">
		<p></p></cfoutput>
		
		<!--- graphs --->
		
		<!--- get all status breakdown --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getStatusBreakdown" returnvariable="stStatus"></cfinvoke>
		<cfoutput><span class="formTitle">Object Status Breakdown</span><p>
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
		<hr width="80%" align="center">
		<p></p></cfoutput>
		
		<!--- age of content graph --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getAgeBreakdown" returnvariable="stAge">
			<cfinvokeargument name="breakdown" value="7,14,21"/>
		</cfinvoke>
		
		<cfoutput><span class="formTitle">Object Age Breakdown</span><p>
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
		<hr width="80%" align="center">
		<p></p>
	</td></cfoutput>
	
	<!--- #### centre column #### --->
	<cfoutput><td align="center" valign="top" width="34%"></cfoutput>
	
		<!--- get objects pending approval --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getObjectsPendingApproval" returnvariable="stPendingObjects">
			<cfinvokeargument name="userLogin" value="#request.stLoggedInUser.userlogin#"/>
		</cfinvoke>
		
		<cfoutput><p></p>
		
		<!--- display objects needing approval --->
		<cfif not structIsEmpty(stPendingObjects)>
			<span class="formTitle">Objects Pending Your Approval</span>
			
			<table width="100%" cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
			<tr class="dataheader">
				<td width="100%">Object</td>
				<td nowrap align="center">Created By</td>
				<td nowrap align="center">Last Updated</td>
			</tr>
			<cfloop collection="#stPendingObjects#" item="i">
				<tr>
					<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stPendingObjects[i]["parentObject"]#">#stPendingObjects[i]["objectTitle"]#</cfoutput></td>
					<td><cfoutput><cfif stPendingObjects[i]["objectCreatedByEmail"] neq "n/a"><a href="mailto:#stPendingObjects[i]["objectCreatedByEmail"]#"></cfif>#stPendingObjects[i]["objectCreatedBy"]#<cfif stPendingObjects[i]["objectCreatedByEmail"] neq "n/a"></a></cfif></cfoutput></td>
					<td valign="top" align="center"><cfoutput>#dateformat(stPendingObjects[i]["objectLastUpdate"],"dd-mmm-yyyy")#</cfoutput></td>
				</tr>
			</cfloop>
			</table>
			<p>&nbsp;</p>
		</cfif>
		</cfoutput>
		
		<!--- get news pending approval --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getNewsPendingApproval" returnvariable="stPendingNews">	</cfinvoke>
		
		<!--- display news pending approval --->
		<cfoutput>
		<cfif not structisempty(stPendingNews)>
			<span class="formTitle">News Pending Your Approval</span>
			
			<table width="100%" cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
			<tr class="dataheader">
				<td width="100%">Object</td>
				<td nowrap align="center">Created By</td>
				<td nowrap align="center">Last Updated</td>
			</tr>
			<cfloop collection="#stPendingNews#" item="i">
				<tr>
					<td><span class="frameMenuBullet">&raquo;</span> <a href="index.cfm?section=dynamic&objectid=#i#&status=pending">#stPendingNews[i]["objectTitle"]#</td>
					<td><cfif stPendingNews[i]["objectCreatedByEmail"] neq "n/a"><a href="mailto:#stPendingNews[i]["objectCreatedByEmail"]#"></cfif>#stPendingNews[i]["objectCreatedBy"]#<cfif stPendingNews[i]["objectCreatedByEmail"] neq "n/a"></a></cfif></td>
					<td valign="top" align="center">#dateformat(stPendingNews[i]["objectLastUpdate"],"dd-mmm-yyyy")#</td>
				</tr>
			</cfloop>
			</table>
			<p>&nbsp;</p>
		</cfif>
		</cfoutput>
		
		<!--- get all draft objects --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getUserDraftObjects" returnvariable="qDraftObjects">
			<cfinvokeargument name="userLogin" value="#request.stLoggedInUser.userlogin#"/>
			<cfinvokeargument name="objectTypes" value="dmNews,dmHTML"/>
		</cfinvoke>
		
		<!--- display all draft objects --->
		<cfoutput>
		<cfif qDraftObjects.recordcount gt 0>
			<span class="formTitle">Objects you have in draft</span>
			
			<table width="100%" cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
			<tr class="dataheader">
				<td width="!00%">Object</td>
				<td nowrap align="center">Type</td>
				<td nowrap align="center">Last Updated</td>
			</tr>
			<cfparam name="url.draftEndRow" default="5">
			<cfloop query="qDraftObjects" startrow="1" endrow="#url.draftEndRow#">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<cfif objectType eq "dmNews">
						<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=dynamic&objectid=#objectid#&status=draft">#objectTitle#</cfoutput></td>
					<cfelse>						
						<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#objectParent#">#objectTitle#</cfoutput></td>
					</cfif>
					<td valign="top"><cfoutput>#objectType#</cfoutput></td>
					<td valign="top" align="center"><cfoutput>#dateformat(objectLastUpdated,"dd-mmm-yyyy")#</cfoutput></td>
				</tr>
			</cfloop>
			</table>
			<!--- show link to all draftObjects --->
			<cfif qDraftObjects.recordcount gt url.draftEndRow>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=<cfoutput>#qDraftObjects.recordcount#</cfoutput>">Show All</div>
			<cfelseif url.draftEndRow neq 5>
				<div align="left" style="margin-left:7px;margin-top:5px;"><span class="frameMenuBullet" >&raquo;</span> <a href="index.cfm?draftEndRow=5">Show most recent 5</div>
			</cfif>
		</cfif>
	</td>
	</cfoutput>
	
	<!--- #### right column #### --->
	<cfoutput><td valign="top" align="center" width="33%"></cfoutput>
		<!--- get all recent HTML objects --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getRecentObjects" returnvariable="qRecentHTMLObjects">
			<cfinvokeargument name="numberOfObjects" value="5"/>
			<cfinvokeargument name="objectType" value="dmHTML"/>
		</cfinvoke>
		
		
		<!--- display recent HTML objects --->
		<cfoutput>
		<cfif qRecentHTMLObjects.recordcount gt 0>
			<span class="formTitle">Recently Added HTML Objects</span>
			
			<table width="100%" cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
			<tr class="dataheader">
				<td width="100%">Object</td>
				<td nowrap align="center">Created By</td>
				<td nowrap align="center">Created Date</td>
			</tr>
			<cfloop query="qRecentHTMLObjects">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#objectParent#"><cfif title neq "">#Title#<cfelse><em>undefined</em></cfif></cfoutput></td>
					<td valign="top"><cfoutput><cfif userEmail neq "n/a"><a href="mailto:#userEmail#"></cfif>#CreatedBy#<cfif userEmail neq "n/a"></a></cfif></cfoutput></td>
					<td valign="top" align="center"><cfoutput>#dateformat(dateTimeCreated,"dd-mmm-yyyy")#</cfoutput></td>
				</tr>
			</cfloop>
			</table>
			<p>&nbsp;</p>
		</cfif>
		</cfoutput>
		
		<!--- get all recent News objects --->
		<cfinvoke component="#application.packagepath#.farcry.reporting" method="getRecentObjects" returnvariable="qRecentNewsObjects">
			<cfinvokeargument name="numberOfObjects" value="5"/>
			<cfinvokeargument name="objectType" value="dmNews"/>
		</cfinvoke>
		
		
		<!--- display recent News objects --->
		<cfoutput>
		<cfif qRecentNewsObjects.recordcount gt 0>
			<span class="formTitle">Recently Added News Objects</span>
			
			<table width="100%" cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
			<tr class="dataheader">
				<td width="100%">Object</td>
				<td nowrap align="center">Created By</td>
				<td nowrap align="center">Created Date</td>
			</tr>
			<cfloop query="qRecentNewsObjects">
				<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=dynamic&objectid=#objectid#&status=all"><cfif title neq "">#Title#<cfelse><em>undefined</em></cfif></cfoutput></td>
					<td valign="top"><cfoutput><cfif userEmail neq "n/a"><a href="mailto:#userEmail#"></cfif>#CreatedBy#<cfif userEmail neq "n/a"></a></cfif></cfoutput></td>
					<td valign="top" align="center"><cfoutput>#dateformat(dateTimeCreated,"dd-mmm-yyyy")#</cfoutput></td>
				</tr>
			</cfloop>
			</table>
		</cfif>
	</td>
</tr>
</table>
</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">