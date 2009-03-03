<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (RSS) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:buildLink objectid="#stObj.objectid#" r_url="objecturl" includeDomain="true" />

<cfoutput>
	<item>
		<title>#stObj[arguments.stParam.title]#</title>
		<link>#objecturl#</link>
		<guid>#objecturl#</guid>
		<pubDate>#lsdateformat(stObj[arguments.stParam.date],"ddd, dd mmm yyyy")# #lstimeformat(stObj[arguments.stParam.date],"HH:mm:ss")# GMT</pubDate>
		<description><![CDATA[#stObj[arguments.stParam.content]# ]]></description>
</cfoutput>

<cfif arguments.stParam.bAuthor>
	<cfset arguments.stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(arguments.stParam.author) and len(arguments.stParam.author.emailAddress)>
		<cfoutput><author>#arguments.stParam.author.emailAddress#<cfif len(arguments.stParam.author.firstname) or len(arguments.stParam.author.lastname)> (#arguments.stParam.author.firstname# #arguments.stParam.author.lastname#)</cfif></author></cfoutput>
	<cfelseif len(arguments.stParam.author.firstname) or len(arguments.stparam.author.lastname)>
		<cfoutput><dc:creator>#arguments.stParam.author.firstname# #arguments.stParam.author.lastname#</dc:creator></cfoutput>
	</cfif>
</cfif>

<cfif len(arguments.stParam.media)>
	<cfset stFileInfo = createobject("component","farcry.core.packages.farcry.file").getFileProperties("#application.fapi.getFileWebRoot()##stObj[arguments.stParam.media]#") />

	<cfoutput><enclosure url="http://#cgi.http_host##application.fapi.getFileWebRoot()##stObj[arguments.stParam.media]#" length="#stFileInfo.size#" type="#stFileInfo.mimetype#" /></cfoutput>
	
	<cfif len(arguments.stParam.itunessubtitle)>
		<cfoutput><itunes:subtitle>#stObj[arguments.stParam.itunessubtitle]#</itunes:subtitle></cfoutput>
	</cfif>
	
	<!--- iTunes elements --->
	<cfif arguments.stParam.bAuthor and not len(arguments.stParam.itunesauthor) and not structisempty(arguments.stParam.author) and len(arguments.stParam.author.emailAddress)>
		<cfoutput>
			<itunes:author>#arguments.stParam.author.firstname# #arguments.stParam.author.lastname#<cfif len(arguments.stParam.author.firstname) or len(arguments.stParam.author.lastname)> (#arguments.stParam.author.emailAddress#)</cfif></itunes:author>
		</cfoutput>
	</cfif>
	<cfif arguments.stParam.bAuthor and len(arguments.stParam.itunesauthor)>
		<cfoutput><itunes:author>#stObj[arguments.stParam.itunesauthor]#</itunes:author></cfoutput>
	</cfif>
	
	<cfif len(arguments.stParam.keywords)>
		<cfoutput><itunes:keywords>#stObj[arguments.stParam.ituneskeywords]#</itunes:keywords></cfoutput>
	</cfif>
	
	<cfif len(arguments.stParam.itunesduration)>
		<cfoutput><itunes:duration>#stObj[arguments.stParam.itunesduration]#</itunes:duration></cfoutput>
	</cfif>
</cfif>

<cfoutput>
	</item>
</cfoutput>

<cfsetting enablecfoutputonly="false" />