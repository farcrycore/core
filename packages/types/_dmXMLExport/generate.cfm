<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/generate.cfm,v 1.14.2.3 2005/05/06 05:07:47 guy Exp $
$Author: guy $
$Date: 2005/05/06 05:07:47 $
$Name: milestone_2-1-2 $
$Revision: 1.14.2.3 $

|| DESCRIPTION || 
$Description: generates rss feed$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfscript>
function high2ascii(str) {
	while(1) {
		p=REFind("[^[:ascii:]]",str);
	    if(not p) break;
	    	str = replace(str,mid(str,p,1),"&###asc(mid(str,p,1))#;","all");
	}
	return str;
}
</cfscript>

<!--- get categories --->
<cfobject component="#application.packagepath#.farcry.category" name="oCategories">
<cfset lCategories = oCategories.getCategories(objectid=stObj.objectid,bReturnCategoryIDs="true")>

<cfif application.types[stObj.contentType].bCustomType>
	<cfset packagepath = application.custompackagepath>
<cfelse>
	<cfset packagepath = application.packagepath>
</cfif>
	
<cfif len(lCategories)>
	<!--- get objects in selected categories --->
	<cfset qObjects = oCategories.getData(typename=stObj.contentType,lCategoryIDs=lCategories,dsn=application.dsn)>
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
						<title>#xmlFormat(qObjects.label)#</title>
						<link>http://#cgi.http_host##application.url.conjurer#?objectid=#qObjects.objectid#</link>
						<description><cfif isdefined("qObjects.teaser") and len(qObjects.teaser)>#xmlFormat(high2ascii(qObjects.teaser))#<cfelseif isdefined("qObjects.body") and len(qObjects.body)>#xmlFormat(oRSS.HTMLStripper(high2ascii(left(qObjects.body,255))))#...</cfif></description>
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
						<title>#xmlFormat(stObjects[obj].label)#</title>
						<link>http://#cgi.http_host##application.url.conjurer#?objectid=#obj#</link>
						<description><cfif structKeyExists(stObjects[obj],"teaser") and len(stObjects[obj].teaser)>#xmlFormat(high2ascii(stObjects[obj].teaser))#<cfelseif structKeyExists(stObjects[obj],"body") and len(stObjects[obj].body)>#xmlFormat(oRSS.HTMLStripper(high2ascii(left(stObjects[obj].body,255))))#...</cfif></description>
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
	<cffile action="write" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#" output="#toString(stFeed)#" addnewline="no" nameconflict="OVERWRITE">
	<cfcatch><cfoutput>#application.path.project#/#application.config.general.exportPath# directory doesn't exist. Please create before trying to export.</cfoutput></cfcatch>
</cftry>
				
