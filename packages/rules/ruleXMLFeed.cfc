<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleXMLFeed.cfc,v 1.13 2005/07/19 03:59:21 pottery Exp $
$Author: pottery $
$Date: 2005/07/19 03:59:21 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

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
		<cfset var stLocal = StructNew()>

<cfsetting enablecfoutputonly="Yes">
		<cfset stLocal.numMaxRecordsAllowed = 50>
		<cfif isDefined("form.updateRuleXMLFeed")>
			<cfset stObj.feedName = form.feedName>
			<cfset stObj.XMLFeedURL = form.XMLFeedURL>
			<cfset stObj.intro = form.intro>
			<cfset stObj.maxRecords = form.maxRecords>

			<q4:contentobjectdata typename="#application.rules.ruleXMLFeed.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset stLocal.successMessage = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
		</cfif>
<cfoutput>
<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" style="margin-top:-1.5em">
<fieldset>
<cfif StructKeyExists(stLocal,"successmessage")>
	<p id="fading1" class="fade"><span class="success">#stLocal.successmessage#</span></p></cfif>
	<label for="feedName"><b>#application.adminBundle[session.dmProfile.locale].feedName#:</b>
		<input type="text" id="feedName" name="feedName" value="#stObj.feedName#"><br />
	</label>

	<label for="intro"><b>#application.adminBundle[session.dmProfile.locale].xmlFeedIntro#:</b>
		<textarea id="intro" name="intro">#stObj.intro#</textarea><br />
	</label>

	<label for="maxRecords"><b>#application.adminBundle[session.dmProfile.locale].maxItemsToDisplay#:</b>
		<select name="maxRecords" id="maxRecords"><cfloop index="stLocal.i" from="1" to="#stLocal.numMaxRecordsAllowed#">
			<option value="#stLocal.i#"<cfif stLocal.i EQ stObj.maxRecords> selected="selected"</cfif>>#stLocal.i#</option></cfloop>
		</select><br />
	</label>

	<label for="xmlFeedURL"><b>#application.adminBundle[session.dmProfile.locale].xmlFeedLocation#:</b>
		<input type="text" id="xmlFeedURL" name="xmlFeedURL" value="#stObj.xmlFeedURL#"><br />
	</label>

<div class="f-submit-wrap">
	<input type="Submit" name="updateRuleXMLFeed" value="#application.adminBundle[session.dmProfile.locale].go#" class="f-submit" />		
</div>
	<input type="hidden" name="ruleID" value="#stObj.objectID#">
</fieldset>
</form>		


<h3>#application.adminBundle[session.dmProfile.locale].previewOutput#</h3>
<p>#execute(objectid)#</p>

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

