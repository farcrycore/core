<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleXMLFeed.cfc,v 1.11 2004/07/26 09:13:14 phastings Exp $
$Author: phastings $
$Date: 2004/07/26 09:13:14 $
$Name: milestone_2-3-2 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Publishing rule to pull, parse and display external RSS feeds.  Is dependent on the rss.cfc component. $
$TODO: add application scope cacheing to query$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<!--- <cfsetting enablecfoutputonly="Yes"> --->
<cfcomponent displayname="XML Feed Publishing Rule" extends="rules" hint="Displays an XML feed within a container">

<!--- rule object properties --->
<cfproperty name="feedName" type="string" hint="A useful name for this feed" required="No" default="">
<cfproperty name="XMLFeedURL" type="string" hint="The location of the feed (URL)" required="no" default="">
<cfproperty name="intro" type="string" hint="An introduction to this feed" required="no" default="">
<cfproperty name="maxRecords" type="numeric" hint="The maximum number of records to return to the user" required="no" default="20">

<!--- pseudo contructor --->
<cfimport prefix="q4" taglib="/farcry/fourq/tags">
<!--- /pseudo contructor --->
	
	<cffunction access="public" name="update" output="true" hint="Edit handler for the rule." >
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfset var stObj = getData(arguments.objectid)> 
		
		<cfsetting enablecfoutputonly="Yes">

		<cfif isDefined("form.updateRuleXMLFeed")>
			<cfscript>
				stObj.feedName = form.feedName;
				stObj.XMLFeedURL = form.XMLFeedURL; 
				stObj.intro = form.intro;
				stObj.maxRecords = form.maxRecords;
			</cfscript>
			<q4:contentobjectdata typename="#application.rules.ruleXMLFeed.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset message = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
		</cfif>

		<cfif isDefined("message")>
			<cfoutput><div align="center"><strong>#message#</strong></div></cfoutput>
		</cfif>			

		<cfoutput>
		<form action="" method="post">
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		
		<table width="100%">
		<tr>
			<td align="right">
				<strong>#application.adminBundle[session.dmProfile.locale].feedName#</strong>
			</td>
			<td>
				<input class="field" type="text" name="feedName" value="#stObj.feedName#">
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>#application.adminBundle[session.dmProfile.locale].xmlFeedIntro#</strong>
			</td>
			<td>
				<textarea  class="field" cols="50" name="intro" rows="5">#stObj.intro#</textarea>
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>#application.adminBundle[session.dmProfile.locale].maxItemsToDisplay#</strong>
			</td>		
			<td>
				<select name="maxRecords">
				<cfloop from="1" to="50" index="i"><option value="#i#" <cfif i EQ stObj.maxRecords>Selected</cfif>>#i#</option>
				</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>#application.adminBundle[session.dmProfile.locale].xmlFeedLocation#</strong>
			</td>
			<td>
				<input  class="field" type="text" name="xmlFeedURL" size="50" value="#stObj.xmlFeedURL#">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center"><input class="normalbttnstyle" type="submit" value="#application.adminBundle[session.dmProfile.locale].go#" name="updateRuleXMLFeed"></td>
		</tr>
		</table>
		
		</form>
		
		<div style="width: 80%; padding: 30px 30px;">
		<h3>#application.adminBundle[session.dmProfile.locale].previewOutput#</h3>
		#execute(objectid)#
		</div>
		</cfoutput>
		
		<cfsetting enablecfoutputonly="No">
		
	</cffunction> 
	
	<cffunction access="public" name="execute" output="false">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfset var stObj = getData(arguments.objectid)> 
		<cfset var html = "">
		<cfset var aItems = "">
		<cfset var count = "">
		<cfset var rss = "">
		
		<cfsetting enablecfoutputonly="Yes">
		<cftry>
			<!--- go get the feed --->
			<cfhttp url="#stObj.xmlFeedURL#" method="get" throwonerror="yes" timeout="10" />
			<cfcatch>
				<!--- Do nothing just at the moment --->
				<cfset cfhttp.filecontent="">
			</cfcatch>
		</cftry>
				
		<cftry>
			<cfscript>
				rss=createobject("component", "#application.packagepath#.farcry.rss");
				aItems=rss.getItemsAsArray(cfhttp.filecontent);
				count=arrayLen(aItems);
				if (count gt stobj.maxrecords)
					count=stobj.maxrecords;
			</cfscript>

			<cfsavecontent variable="html">
			<cfoutput>
			<div class="xmlfeed">
			#stObj.intro#
			</cfoutput>

			<cfloop from="1" to="#count#" index="i">
			<cfoutput>
			<div class="xmlitem">
			<a href="#aItems[i].link#">#aItems[i].title#</a> #application.thisCalendar.i18nDateFormat(aItems[i]["dc:date"],session.dmProfile.locale,application.longF)# 
			<!--- #dateformat(aItems[i]["dc:date"],"dd-mmm-yyyy")#  --->
			<br />
			#aItems[i].description#
			</div>
			</cfoutput>
			</cfloop>

			<cfoutput></div></cfoutput>
			</cfsavecontent>
			
			<cfcatch>
				<!--- Do Nada at the moment --->
				<cfset html="<!-- #cfcatch.detail# -->">
			</cfcatch>
		</cftry>
		
		<cfif isDefined("request.aInvocations")>
		<!--- update the containers aInvocations --->
			<cfset arrayAppend(request.aInvocations,html)>
		<cfelse>
		<!--- return output as a string --->
			<cfreturn html>
		</cfif>
		<cfsetting enablecfoutputonly="No">
	</cffunction> 
	
</cfcomponent>

