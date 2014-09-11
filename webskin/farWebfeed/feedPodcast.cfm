<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: RSS web feed --->

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

<!--- <cfcontent type="application/rss+xml:UTF-8" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?> --->
<cfcontent type="text/xml; charset=utf-8" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
	xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
		<title>#stObj.title#</title>
		<link>#linkbackurl#</link>
		<atom:link href="#itunespath#" rel="self" type="application/rss+xml" />
		<description><![CDATA[#stObj.description# ]]></description>
		<lastBuildDate>#lsdateformat(builddate,"ddd, dd mmm yyyy")# #lstimeformat(builddate,"HH:mm:ss")# GMT</lastBuildDate>
		<language>#replace(lcase(application.fapi.getConfig("general","locale")),"_","-")#</language>
		<generator>#stObj.generator#</generator>
</cfoutput>

<cfif len(stObj.copyright)>
	<cfoutput><copyright>#stObj.copyright#</copyright></cfoutput>
</cfif>

<cfif len(stObj.feedimage)>
	<cfoutput>
		<image>
			<url>http://#cgi.http_host##application.fapi.getImageWebRoot()##stObj.feedimage#</url>
			<title>#stObj.title#</title>
			<link>#linkbackurl#</link>
		</image>
	</cfoutput>
</cfif>

<cfif len(stObj.editoremail)>
	<cfoutput><managingEditor>#stObj.editoremail#<cfif len(stObj.editor)> (#stObj.editor#)</cfif></managingEditor></cfoutput>
<cfelseif len(stObj.editor)>
	<cfoutput><dc:creator>#stObj.editor#</dc:creator></cfoutput>
</cfif>

<cfif len(stObj.skiphours)>
	<cfoutput><skipHours></cfoutput>
	<cfloop list="#stObj.skiphours#" index="hour">
		<cfoutput><hour>#hour#</hour></cfoutput>
	</cfloop>
	<cfoutput></skipHours></cfoutput>
</cfif>

<cfif len(stObj.skipdays)>
	<cfoutput><skipDays></cfoutput>
	<cfloop list="#stObj.skipdays#" index="day">
		<cfoutput><day>#day#</day></cfoutput>
	</cfloop>
	<cfoutput></skipDays></cfoutput>
</cfif>

<!--- ITUNES ELEMENTS --->
<cfif len(stObj.enclosurefileproperty)>
	<cfif len(stObj.subtitle)>
		<cfoutput><itunes:subtitle>#stObj.subtitle#</itunes:subtitle></cfoutput>
	</cfif>

	<!--- Author --->
	<cfoutput>
		<itunes:author>#stObj.itunesauthor#</itunes:author>
	</cfoutput>
	
	<!--- Categories --->
	<cfloop list="#stObj.itunescategories#" index="itunecat">
		<cfif find(">",itunecat)>
			<cfoutput>
				<itunes:category text="#xmlformat(trim(listfirst(itunecat,'>')))#">
					<itunes:category text="#xmlformat(trim(listlast(itunecat,'>')))#" />
				</itunes:category>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<itunes:category text="#xmlformat(trim(itunecat))#" />
			</cfoutput>
		</cfif>
	</cfloop>
	
	<!--- Image --->
	<cfif len(stObj.itunesimage)>
		<cfoutput><itunes:image href="http://#cgi.http_host##application.fapi.getImageWebRoot()##stObj.itunesimage#" /></cfoutput>
	</cfif>
	
	<!--- Keywords --->
	<cfif len(stObj.keywords)>
		<cfoutput><itunes:keywords>#stObj.keywords#</itunes:keywords></cfoutput>
	</cfif>
	
	<!--- Owner --->
	<cfif not len(stObj.editor) or not len(stObj.editoremail)>
		<cfoutput>
			<itunes:owner>
				<cfif len(stObj.editor)><itunes:name>#stObj.editor#</itunes:name></cfif>
				<cfif len(stObj.editoremail)><itunes:email>#stObj.editoremail#</itunes:email></cfif>
			</itunes:owner>
		</cfoutput>
	</cfif>
	
	<!--- Subtitle --->
	<cfif len(stObj.subtitle)>
		<cfoutput><itunes:subtitle>#stObj.subtitle#</itunes:subtitle></cfoutput>
	</cfif>
</cfif>

<cfset stObjParam = structnew() />
<cfset stObjParam.directory = stObj.directory />
<cfset stObjParam.title = stObj.titleproperty />
<cfset stObjParam.content = stObj.contentproperty />
<cfset stObjParam.media = stObj.enclosurefileproperty />
<cfset stObjParam.date = stObj.dateproperty />
<cfset stObjParam.bAuthor = stObj.bAuthor />
<cfset stObjParam.keywords = stObj.keywordsproperty />
<cfset stObjParam.itunessubtitle = stObj.itunessubtitleproperty />
<cfset stObjParam.itunesduration = stObj.itunesdurationproperty />
<cfloop query="qObjects">
	<skin:view objectid="#qObjects.objectid#" webskin="feedPodcast" stParam="#stObjParam#" />
</cfloop>

<cfoutput>
	</channel>
</rss>
</cfoutput>

<cfsetting enablecfoutputonly="false" />