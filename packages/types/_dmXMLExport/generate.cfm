<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmXMLExport/generate.cfm,v 1.18 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: generates rss feed$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="true">
<!--- get categories --->
<cfobject component="#application.packagepath#.farcry.category" name="oCategories">
<cfset lCategories = oCategories.getCategories(objectid=stObj.objectid,bReturnCategoryIDs="true")>

<cfparam name="stObj.NUMBEROFITEMS" type="numeric" default="0">

<cfif len(lCategories)>
	<!--- get objects in selected categories --->
	<cfset qObjects = oCategories.getData(typename=stObj.contentType,lCategoryIDs=lCategories,dsn=application.dsn,maxRows=stObj.NUMBEROFITEMS)>
<cfelse>
	<!--- get all objects --->
	<cfobject component="#application.types[stObj.contentType].typePath#" name="oContentType">
	<cfset stObjects = oContentType.getMultiple(dsn=application.dsn,dbowner=application.dbowner)>
</cfif>

<!--- get time zone information --->
<cfset stTimeZone = GetTimeZoneInfo()>

<cfobject component="#application.packagepath#.farcry.rss" name="oRSS">

<!--- loop over and generate xml (not using cfxml due to bug with sandbox security --->
<cfsavecontent variable="stFeed">
	<cfoutput>
	<rss version="2.0" 
	    xmlns:dc="http://purl.org/dc/elements/1.1/"
	    xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
	    xmlns:admin="http://webns.net/mvcb/"
	    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
	    xmlns:content="http://purl.org/rss/1.0/modules/content/">
	
	  <channel>
	    <title>#stObj.title#</title>
	    <link>http://#cgi.http_host##application.url.webroot#/#listRest(application.config.general.exportPath,"/")#/#stObj.xmlFile#</link>
	    <description>#stObj.description#</description>
	    <dc:language>#stObj.language#</dc:language>
	    <dc:creator>mailto:#stObj.creator#</dc:creator>
	    <dc:rights>#stObj.rights#</dc:rights>
	    <dc:date>#dateFormat(stObj.dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(stObj.dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(abs(stTimeZone.utcMinuteOffset),"00")#</dc:date>
		<admin:generatorAgent rdf:resource="#stObj.generatorAgent#"/>
	    <admin:errorReportsTo rdf:resource="mailto:#stObj.errorReportsTo#"/>
	    <sy:updatePeriod>#stObj.updatePeriod#</sy:updatePeriod>
	    <sy:updateFrequency>#stObj.updateFrequency#</sy:updateFrequency>
	    <sy:updateBase>2000-01-01T12:00+00:00</sy:updateBase>
		</cfoutput>
		<cfif len(lCategories)>
			<cfloop query="qObjects">
				<cfset bShow = 1>
				<!--- check object is available for publishing --->
				<cfif isDefined("qObjects.publishDate") and qObjects.publishDate gt now()>
					<cfset bShow = 0>
				<cfelseif isDefined("qObjects.expiryDate") and qObjects.expiryDate lt now()>
					<cfset bShow = 0>
				<cfelseif isDefined("qObjects.status") and qObjects.status neq "approved">
					<cfset bShow = 0>
				</cfif>
				<!--- add item to export --->
				<cfif bShow>
					<cfoutput>
					<item>
						<title>#xmlFormat(replace(rereplace(qObjects.label, "</?[^>]*>", "", "all"),"�","'","ALL"))#</title>
						<link>http://#cgi.http_host##application.url.conjurer#?objectid=#qObjects.objectid#</link>
						<description><cfif isdefined("qObjects.teaser") and len(qObjects.teaser)>#xmlFormat(replace(qObjects.teaser,"�","'","ALL"))#<cfelseif isdefined("qObjects.body") and len(qObjects.body)>#xmlFormat(replace(oRSS.HTMLStripper(left(qObjects.body,255)),"�","'","ALL"))#...</cfif></description>
						<guid isPermaLink="false">#qObjects.objectid#</guid>
						<!--- <dc:subject>subject</dc:subject> --->
						<dc:date>#dateFormat(qObjects.dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(qObjects.dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(abs(stTimeZone.utcMinuteOffset),"00")#</dc:date>
					</item>
					</cfoutput>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop collection="#stObjects#" item="obj">
				<cfset bShow = 1>
				<!--- check object is available for publishing --->
				<cfif structKeyExists(stObjects[obj],"publishDate") and stObjects[obj].publishDate gt now()>
					<cfset bShow = 0>
				<cfelseif structKeyExists(stObjects[obj],"publishDate") and stObjects[obj].expiryDate lt now()>
					<cfset bShow = 0>
				<cfelseif structKeyExists(stObjects[obj],"status") and stObjects[obj].status NEQ "approved">
					<cfset bShow = 0>
				</cfif>
				<!--- add item to export --->
				<cfif bShow>
					<cfoutput>
					<item>
						<title>#xmlFormat(replace(rereplace(stObjects[obj].label, "</?[^>]*>", "", "all"),"�","'","ALL"))#</title>
						<link>http://#cgi.http_host##application.url.conjurer#?objectid=#obj#</link>
						<description><cfif structKeyExists(stObjects[obj],"teaser") and len(stObjects[obj].teaser)>#xmlFormat(replace(stObjects[obj].teaser,"�","'","ALL"))#<cfelseif structKeyExists(stObjects[obj],"body") and len(stObjects[obj].body)>#xmlFormat(replace(oRSS.HTMLStripper(left(stObjects[obj].body,255)),"�","'","ALL"))#...</cfif></description>
						<guid isPermaLink="false">#obj#</guid>
						<!--- <dc:subject>subject</dc:subject> --->
						<dc:date>#dateFormat(stObjects[obj].dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(stObjects[obj].dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(abs(stTimeZone.utcMinuteOffset),"00")#</dc:date>
					</item>	
					</cfoutput>
				</cfif>
			</cfloop>
		</cfif>
		<cfoutput>
		</channel>
	</rss>
	</cfoutput>
</cfsavecontent>


<!--- check directory exists --->
<cfif not directoryExists("#application.path.project#/#application.config.general.exportPath#")>
	<cfdirectory action="CREATE" directory="#application.path.project#/#application.config.general.exportPath#">
</cfif>

<cftry>
	<!--- generate file --->
	<cffile action="write" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#" output="#toString(stFeed)#" addnewline="no" nameconflict="OVERWRITE" mode="664">
	<cfcatch><cfoutput>#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile# directory doesn't exist. Please create before trying to export.</cfoutput></cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false">
