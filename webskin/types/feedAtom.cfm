<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (RSS) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:buildLink objectid="#stObj.objectid#" r_url="objecturl" includeDomain="true" />

<cfoutput>
	<entry>
		<title>#stObj[stParam.title]#</title>
		<link rel="alternate" href="#objecturl#"/>
		<id>http://#cgi.HTTP_HOST#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#</id>
		<updated>#lsdateformat(stObj.datetimelastupdated,"yyyy-mm-dd")#T#lstimeformat(stObj.datetimelastupdated,"HH:mm:ss")#Z</updated>
</cfoutput>

<cfif refind("<[^>]+>",stObj[stParam.content])>
	<cfoutput><content type="html"><![CDATA[#stObj[stParam.content]#]]></content></cfoutput>
<cfelse>
	<cfoutput><content><![CDATA[#stObj[stParam.content]#]]></content></cfoutput>
</cfif>

<cfif len(stParam.keywords)>
	<cfloop list="#stObj[stParam.keywords]#" index="category">
		<cfoutput><category term="#category#" /></cfoutput>
	</cfloop>
</cfif>

<cfif stParam.bAuthor>
	<cfset stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(stParam.author) and (len(stParam.author.firstname) or len(stParam.author.lastname))>
		<cfoutput>
			<author>
				<name>#encodeForXML(stparam.author.firstname)# #encodeForXML(stparam.author.lastname)#</name>
				<cfif len(stparam.author.emailaddress)><email>#encodeForXML(stparam.author.emailaddress)#</email></cfif>
			</author>
		</cfoutput>
	</cfif>
</cfif>

<cfif len(stParam.media)>
	<cfset stFileInfo = createobject("component","farcry.core.packages.farcry.file").getFileProperties("#application.fapi.getFileWebRoot()##stObj[stParam.media]#") />

	<cfoutput><link rel="enclosure" type="#stFileInfo.mimetype#" title="File" href="https://#cgi.http_host##application.fapi.getFileWebRoot()##stObj[stParam.media]#" length="#stFileInfo.size#" /></cfoutput>
</cfif>

<cfoutput>
	</entry>
</cfoutput>

<cfsetting enablecfoutputonly="false" />