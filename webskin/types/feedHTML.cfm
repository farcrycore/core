<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Web feed item (HTML) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
	<div class="feeditem">
		<h2>#stObj[arguments.stParam.title]#</h2>
</cfoutput>

<cfoutput><dl class="item"></cfoutput>

<cfif len(arguments.stParam.keywords)>
	<cfoutput><dt>Keywords</dt><dd>#stObj[arguments.stParam.keywords]#</dd></cfoutput>
</cfif>

<cfif arguments.stParam.bAuthor>
	<cfset arguments.stParam.author = createobject("component",application.stCOAPI.dmProfile.packagepath).getProfile(username=stObj.createdby) />
	
	<cfif not structisempty(arguments.stParam.author) and (len(arguments.stParam.author.firstname) or len(arguments.stParam.author.lastname))>
		<cfoutput>
			<dt>Author</dt>
			<dd>
				#arguments.stparam.author.firstname# #arguments.stparam.author.lastname#
				<cfif len(arguments.stparam.author.emailaddress)>
					(<a href="mailto:#arguments.stparam.author.emailaddress#">#arguments.stparam.author.emailaddress#</a>)
				</cfif>
			</dd>
		</cfoutput>
	</cfif>
</cfif>

<cfoutput><dt>Content</dt></cfoutput>
<cfif find("<p>",stObj[arguments.stParam.content])>
	<cfoutput><dd>#stObj[arguments.stParam.content]#</dd></cfoutput>
<cfelse>
	<cfoutput><dd><p>#stObj[arguments.stParam.content]#</p></dd></cfoutput>
</cfif>
<cfif len(arguments.stParam.media)>
	<cfoutput><dt>Media</dt><dd><a href="#application.fapi.getFileWebRoot()##stObj[arguments.stParam.media]#">Download file</a><cfif len(arguments.stParam.itunesduration)>(stObj[arguments.stParam.duration)</cfif></dd></cfoutput>
</cfif>

<cfoutput>
			<dt>URL</dt>
			<dd><skin:buildLink objectid="#stObj.objectid#">full article</skin:buildLink></dd>
		</dl>
		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />