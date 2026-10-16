<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (RSS) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:buildLink objectid="#stObj.objectid#" r_url="objecturl" includeDomain="true" />

<cfoutput>
	<item>
		<title>#stObj[stParam.title]#</title>
		<link>#objecturl#</link>
		<guid>#objecturl#</guid>
		<pubDate>#lsdateformat(stObj[stParam.date],"ddd, dd mmm yyyy")# #lstimeformat(stObj[stParam.date],"HH:mm:ss")# GMT</pubDate>
		<description><![CDATA[#stObj[stParam.content]# ]]></description>
</cfoutput>

<cfif stParam.bAuthor>
	<cfset stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(stParam.author) and len(stParam.author.emailAddress)>
		<cfoutput><author>#stParam.author.emailAddress#<cfif len(stParam.author.firstname) or len(stParam.author.lastname)> (#encodeForXML(stParam.author.firstname)# #encodeForXML(stParam.author.lastname)#)</cfif></author></cfoutput>
	<cfelseif len(stParam.author.firstname) or len(stparam.author.lastname)>
		<cfoutput><dc:creator>#encodeForXML(stParam.author.firstname)# #encodeForXML(stParam.author.lastname)#</dc:creator></cfoutput>
	</cfif>
</cfif>

<cfif len(stParam.media)>
	<cfset stFileInfo = createobject("component","farcry.core.packages.farcry.file").getFileProperties("#application.fapi.getFileWebRoot()##stObj[stParam.media]#") />

	<cfoutput><enclosure url="http://#cgi.http_host##application.fapi.getFileWebRoot()##stObj[stParam.media]#" length="#stFileInfo.size#" type="#stFileInfo.mimetype#" /></cfoutput>
	
	<cfif len(stParam.itunessubtitle)>
		<cfoutput><itunes:subtitle>#stObj[stParam.itunessubtitle]#</itunes:subtitle></cfoutput>
	</cfif>
	
	<!--- iTunes elements --->
	<cfif stParam.bAuthor and not len(stParam.itunesauthor) and not structisempty(stParam.author) and len(stParam.author.emailAddress)>
		<cfoutput>
			<itunes:author>#encodeForXML(stParam.author.firstname)# #encodeForXML(stParam.author.lastname)#<cfif len(stParam.author.firstname) or len(stParam.author.lastname)> (#encodeForXML(stParam.author.emailAddress)#)</cfif></itunes:author>
		</cfoutput>
	</cfif>
	<cfif stParam.bAuthor and len(stParam.itunesauthor)>
		<cfoutput><itunes:author>#stObj[stParam.itunesauthor]#</itunes:author></cfoutput>
	</cfif>
	
	<cfif len(stParam.keywords)>
		<cfoutput><itunes:keywords>#stObj[stParam.ituneskeywords]#</itunes:keywords></cfoutput>
	</cfif>
	
	<cfif len(stParam.itunesduration)>
		<cfoutput><itunes:duration>#stObj[stParam.itunesduration]#</itunes:duration></cfoutput>
	</cfif>
</cfif>

<cfoutput>
	</item>
</cfoutput>

<cfsetting enablecfoutputonly="false" />