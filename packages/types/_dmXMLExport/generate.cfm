<!--- get categories --->
<cfobject component="#application.packagepath#.farcry.category" name="oCategories">
<cfset lCategories = oCategories.getCategories(objectid=stObj.objectid,bReturnCategoryIDs="true")>

<cfif len(lCategories)>
	<!--- get objects in selected categories --->
	<cfset qObjects = oCategories.getData(typename=stObj.contentType,lCategoryIDs=lCategories,dsn=application.dsn)>
<cfelse>
	<!--- get all objects --->
	<cfobject component="#application.packagepath#.types.#stObj.contentType#" name="oContentType">
	<cfset stObjects = oContentType.getMultiple(dsn=application.dsn,dbowner=application.dbowner)>
</cfif>

<!--- get time zone information --->
<cfset stTimeZone = GetTimeZoneInfo()>

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
	    <link>http://#cgi.http_host##application.url.webroot#/#application.config.general.exportPath#/#stObj.xmlFile#</link>
	    <description>#stObj.description#</description>
	    <dc:language>#stObj.language#</dc:language>
	    <dc:creator>mailto:#stObj.creator#</dc:creator>
	    <dc:rights>#stObj.rights#</dc:rights>
	    <dc:date>#dateFormat(stObj.dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(stObj.dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(stTimeZone.utcMinuteOffset,"00")#</dc:date>
		<admin:generatorAgent rdf:resource="#stObj.generatorAgent#"/>
	    <admin:errorReportsTo rdf:resource="mailto:#stObj.errorReportsTo#"/>
	    <sy:updatePeriod>#stObj.updatePeriod#</sy:updatePeriod>
	    <sy:updateFrequency>#stObj.updateFrequency#</sy:updateFrequency>
	    <sy:updateBase>2000-01-01T12:00+00:00</sy:updateBase>
		</cfoutput>
		
		<cfif len(lCategories)>
			<cfloop query="qObjects">
				<cfoutput>
				<item>
					<title>#qObjects.label#</title>
					<link>http://#cgi.http_host##application.url.conjurer#?objectid=#qObjects.objectid#</link>
					<description>#qObjects.teaser#</description>
					<guid isPermaLink="false">guid</guid>
					<dc:subject>subject</dc:subject>
					<dc:date>#dateFormat(qObjects.dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(qObjects.dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(stTimeZone.utcMinuteOffset,"00")#</dc:date>
				</item>
				</cfoutput>
			</cfloop>
		<cfelse>
			<cfloop collection="#stObjects#" item="obj">
				<cfoutput>
				<item>
					<title>#stObjects[obj].label#</title>
					<link>http://#cgi.http_host##application.url.conjurer#?objectid=#obj#</link>
					<description>#stObjects[obj].teaser#</description>
					<guid isPermaLink="false">guid</guid>
					<dc:subject>subject</dc:subject>
					<dc:date>#dateFormat(stObjects[obj].dateTimeLastUpdated,"yyyy-mm-dd")#T#timeFormat(stObjects[obj].dateTimeLastUpdated,"hh:mm:ss")##numberFormat((stTimeZone.utcHourOffset * -1),"+00")#:#numberFormat(stTimeZone.utcMinuteOffset,"00")#</dc:date>
				</item>
				</cfoutput>
			</cfloop>
		</cfif>
		<cfoutput>
		</channel>
	</rss>
	</cfoutput>
</cfsavecontent>

<cffile action="write" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#" output="#toString(stFeed)#" addnewline="no" nameconflict="OVERWRITE">