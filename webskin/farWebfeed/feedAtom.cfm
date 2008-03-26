<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Atom web  feed --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfcontent type="application/atom+xml" reset="true" /><cfoutput><?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
	<title>#stObj.title#</title>
	<generator>
		FarCry WebFeed
	</generator>
</cfoutput>

<cfif len(stObj.subtitle)>
	<cfoutput><subtitle>#stObj.subtitle#</subtitle></cfoutput>
</cfif>

<cfoutput>
	<id>http://#cgi.HTTP_HOST#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#</id>
	<link href="#arguments.stParam.atompath#" rel="self" />
	<link href="#arguments.stParam.url#" rel="self" type="application/atom+xml" />
	<updated>#lsdateformat(arguments.stParam.builddate,"yyyy-mm-dd")#T#lstimeformat(arguments.stParam.builddate,"HH:mm:ss")#Z</updated>
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
	<cfoutput><icon>http://#cgi.http_host#/#application.url.imageRoot##stObj.atomicon#</icon></cfoutput>
</cfif>

<cfif len(stObj.copyright)>
	<cfoutput><rights>#stObj.copyright#</rights></cfoutput>
</cfif>

<cfset stObjParam = structnew() />
<cfset stObjParam.directory = stObj.directory />
<cfset stObjParam.title = stObj.titleproperty />
<cfset stObjParam.content = stObj.contentproperty />
<cfset stObjParam.media = stObj.mediaproperty />
<cfset stObjParam.date = stObj.dateproperty />
<cfset stObjParam.bAuthor = stObj.bAuthor />
<cfset stObjParam.keywords = stObj.keywordsproperty />
<cfloop query="arguments.stParam.qObjects">
	<skin:view objectid="#arguments.stParam.qObjects.objectid#" webskin="feedAtom" stParam="#stObjParam#" />
</cfloop>

<cfoutput></feed></cfoutput>

<cfsetting enablecfoutputonly="false" />