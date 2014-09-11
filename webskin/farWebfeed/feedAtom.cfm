<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Atom web  feed --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Get objects --->
<cfset qObjects = getFeedObjects(stObj=stObj) />

<!--- Get editor --->
<cfif len(stObj.editor)>
	<cfset stObj.editor = application.fapi.getConfig("general","sitetitle") />
</cfif>

<!--- Get last changed date --->
<cfquery dbtype="query" name="qLatest">
	select		max(datetimelastupdated) as latest
	from		qObjects
</cfquery>
<cfif qLatest.recordcount>
	<cfset builddate = qLatest.latest />
<cfelse>
	<cfset builddate = now() />
</cfif>
<cfset tz = getTimeZoneInfo() />
<cfset builddate = dateAdd('s',tz.utcTotalOffset,builddate) />

<!--- Get URL --->
<skin:buildLink objectid="#stObj.objectid#" r_url="feedurl" includeDomain="true" />
<cfif len(stObj.url)>
	<cfset linkbackurl = stObj.url />
<cfelse>
	<cfset linkbackurl = feedurl />
</cfif>

<!--- Get feed directory --->
<cfif not len(stObj.directory)>
	<cfset stObj.directory = "/feeds/#rereplace(stObj.title,'[^\w]+','-','ALL')#" />
</cfif>

<!--- Get feed paths --->
<cfif fileexists("#application.path.project#/www#stObj.directory#/rss.xml") or request.stObj.typename eq "dmCron">
	<cfset rsspath = "http://#cgi.http_host##stObj.directory#/rss.xml" />
	<cfset atompath = "http://#cgi.http_host##stObj.directory#/atom.xml" />
	<cfset itunespath = "itpc://#cgi.http_host##stObj.directory#/podcast.xml" />
<cfelse>
	<cfset rsspath = "#feedurl#&amp;view=feedRSS" />
	<cfset atompath = "#feedurl#&amp;view=feedAtom" />
	<cfset itunespath = replace("#feedurl#&amp;view=feedPodcast","http","itpc") />
</cfif>

<cfset request.mode.ajax = true />

<!--- <cfcontent type="application/atom+xml:UTF-8" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?> --->
<cfcontent type="text/xml; charset=utf-8" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
	<title>#stObj.title#</title>
	<generator>#stObj.generator#</generator>
</cfoutput>

<cfif len(stObj.subtitle)>
	<cfoutput><subtitle>#stObj.subtitle#</subtitle></cfoutput>
</cfif>

<cfoutput>
	<id>http://#cgi.HTTP_HOST#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#</id>
	<link href="#atompath#" rel="self" />
	<link href="#linkbackurl#" rel="self" type="application/atom+xml" />
	<updated>#lsdateformat(builddate,"yyyy-mm-dd")#T#lstimeformat(builddate,"HH:mm:ss")#Z</updated>
</cfoutput>

<cfif len(stObj.editor)>
	<cfoutput>
		<author>
			<name>#stObj.editor#</name>
			<cfif len(stObj.editoremail)><email>#stObj.editoremail#</email></cfif>
		</author>
	</cfoutput>
</cfif>

<cfloop list="#stObj.keywords#" index="category">
	<cfoutput><category term="#category#" /></cfoutput>
</cfloop>

<cfif len(stObj.atomicon)>
	<cfoutput><icon>http://#cgi.http_host##application.fapi.getImageWebRoot()##stObj.atomicon#</icon></cfoutput>
</cfif>

<cfif len(stObj.copyright)>
	<cfoutput><rights>#stObj.copyright#</rights></cfoutput>
</cfif>

<cfset stObjParam = structnew() />
<cfset stObjParam.directory = stObj.directory />
<cfset stObjParam.title = stObj.titleproperty />
<cfset stObjParam.content = stObj.contentproperty />
<cfset stObjParam.media = stObj.enclosurefileproperty />
<cfset stObjParam.date = stObj.dateproperty />
<cfset stObjParam.bAuthor = stObj.bAuthor />
<cfset stObjParam.keywords = stObj.keywordsproperty />
<cfloop query="qObjects">
	<skin:view objectid="#qObjects.objectid#" webskin="feedAtom" stParam="#stObjParam#" />
</cfloop>

<cfoutput></feed></cfoutput>

<cfsetting enablecfoutputonly="false" />