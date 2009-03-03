<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (RSS) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:buildLink objectid="#stObj.objectid#" r_url="objecturl" includeDomain="true" />

<cfoutput>
	<entry>
		<title>#stObj[arguments.stParam.title]#</title>
		<link rel="alternate" href="#objecturl#"/>
		<id>http://#cgi.HTTP_HOST#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#</id>
		<updated>#lsdateformat(stObj.datetimelastupdated,"yyyy-mm-dd")#T#lstimeformat(stObj.datetimelastupdated,"HH:mm:ss")#Z</updated>
</cfoutput>

<cfif refind("<[^>]+>",stObj[arguments.stParam.content])>
	<cfoutput><content type="html"><![CDATA[#stObj[arguments.stParam.content]#]]></content></cfoutput>
<cfelse>
	<cfoutput><content><![CDATA[#stObj[arguments.stParam.content]#]]></content></cfoutput>
</cfif>

<cfif len(arguments.stParam.keywords)>
	<cfloop list="#stObj[arguments.stParam.keywords]#" index="category">
		<cfoutput><category term="#category#" /></cfoutput>
	</cfloop>
</cfif>

<cfif arguments.stParam.bAuthor>
	<cfset arguments.stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(arguments.stParam.author) and (len(arguments.stParam.author.firstname) or len(arguments.stParam.author.lastname))>
		<cfoutput>
			<author>
				<name>#arguments.stparam.author.firstname# #arguments.stparam.author.lastname#</name>
				<cfif len(arguments.stparam.author.emailaddress)><email>#arguments.stparam.author.emailaddress#</email></cfif>
			</author>
		</cfoutput>
	</cfif>
</cfif>

<cfif len(arguments.stParam.media)>
	<cfset stFileInfo = createobject("component","farcry.core.packages.farcry.file").getFileProperties("#application.fapi.getFileWebRoot()##stObj[arguments.stParam.media]#") />

	<cfoutput><link rel="enclosure" type="#stFileInfo.mimetype#" title="File" href="http://#cgi.http_host##application.fapi.getFileWebRoot()##stObj[arguments.stParam.media]#" length="#stFileInfo.size#" /></cfoutput>
</cfif>

<cfoutput>
	</entry>
</cfoutput>

<cfsetting enablecfoutputonly="false" />