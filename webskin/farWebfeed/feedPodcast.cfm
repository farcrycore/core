<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: RSS web feed --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfcontent type="application/rss+xml" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
	xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
		<title>#stObj.title#</title>
		<link>#arguments.stParam.url#</link>
		<atom:link href="#arguments.stParam.itunespath#" rel="self" type="application/rss+xml" />
		<description><![CDATA[#stObj.description# ]]></description>
		<lastBuildDate>#lsdateformat(arguments.stParam.builddate,"ddd, dd mmm yyyy")# #lstimeformat(arguments.stParam.builddate,"HH:mm:ss")# GMT</lastBuildDate>
		<language>#replace(lcase(application.config.general.locale),"_","-")#</language>
		<generator>FarCry WebFeed</generator>
</cfoutput>

<cfif len(stObj.copyright)>
	<cfoutput><copyright>#stObj.copyright#</copyright></cfoutput>
</cfif>

<cfif len(stObj.feedimage)>
	<cfoutput>
		<image>
			<url>http://#cgi.http_host#/#application.url.imageRoot##stObj.feedimage#</url>
			<title>#stObj.title#</title>
			<link>#arguments.stParam.url#</link>
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
		<cfoutput><itunes:image href="http://#cgi.http_host#/#application.url.webroot##application.url.imageRoot##stObj.itunesimage#" /></cfoutput>
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
<cfloop query="arguments.stParam.qObjects">
	<skin:view objectid="#arguments.stParam.qObjects.objectid#" webskin="feedPodcast" stParam="#stObjParam#" />
</cfloop>

<cfoutput>
	</channel>
</rss>
</cfoutput>

<cfsetting enablecfoutputonly="false" />