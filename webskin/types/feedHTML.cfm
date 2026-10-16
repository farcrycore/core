<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (HTML) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
	<div class="feeditem">
		<h2>#stObj[stParam.title]#</h2>
</cfoutput>

<cfoutput><dl class="item"></cfoutput>

<cfif len(stParam.keywords)>
	<cfoutput><dt>Keywords</dt><dd>#stObj[stParam.keywords]#</dd></cfoutput>
</cfif>

<cfif stParam.bAuthor>
	<cfset stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(stParam.author) and (len(stParam.author.firstname) or len(stParam.author.lastname))>
		<cfoutput>
			<dt>Author</dt>
			<dd>
				#encodeForHTML(stparam.author.firstname)# #encodeForHTML(stparam.author.lastname)#
				<cfif len(stparam.author.emailaddress)>
					(<a href="mailto:#stparam.author.emailaddress#">#encodeForHTML(stparam.author.emailaddress)#</a>)
				</cfif>
			</dd>
		</cfoutput>
	</cfif>
</cfif>

<cfoutput><dt>Content</dt></cfoutput>
<cfif find("<p>",stObj[stParam.content])>
	<cfoutput><dd>#stObj[stParam.content]#</dd></cfoutput>
<cfelse>
	<cfoutput><dd><p>#stObj[stParam.content]#</p></dd></cfoutput>
</cfif>
<cfif len(stParam.media)>
	<cfoutput><dt>Media</dt><dd><a href="#application.fapi.getFileWebRoot()##stObj[stParam.media]#">Download file</a><cfif len(stParam.itunesduration)>(stObj[stParam.duration)</cfif></dd></cfoutput>
</cfif>

<cfoutput>
			<dt>URL</dt>
			<dd><skin:buildLink objectid="#stObj.objectid#">full article</skin:buildLink></dd>
		</dl>
		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />