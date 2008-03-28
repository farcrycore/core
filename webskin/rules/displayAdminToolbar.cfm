<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Rule management toolbar --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<ft:object stObject="#stObj#" format="display" r_stFields="stProps" />

<cfset aProps = arraynew(1) />
<cfloop collection="#stProps#" item="prop">
	<cfif len(stProps[prop].html) gt 0 and (not structkeyexists(stProps[prop],"ftDefault") or stProps[prop].value neq stProps[prop].ftDefault) and (not structkeyexists(stProps[prop],"default") or stProps[prop].value neq stProps[prop].default)>
		<cfif len(stProps[prop].html) lt 20>
			<cfset arrayappend(aProps,"#stProps[prop].ftLabel#=#stProps[prop].html#") />
		<cfelse>
			<cfset arrayappend(aProps,"#stProps[prop].ftLabel#=#left(rereplace(stProps[prop].html,"<[^>]*>","","ALL"),20)#...") />
		</cfif>
	</cfif>
</cfloop>

<cfset redirecturl = "#cgi.script_name#" />
<cfif isdefined("url.objectid")>
	<cfset redirecturl = "#redirecturl#?objectid=#url.objectid#" />
<cfelseif isdefined("url.type") and isdefined("url.view")>
	<cfset redirecturl = "#redirecturl#?type=#url.type#&view=#url.method#" />
</cfif>

<extjs:iframeDialog />

<cfoutput>
	<div class="ruleadmin">
		<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace" target="_blank" title="Configure rule" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #application.stCOAPI[stObj.typename].displayname#',630,600,true,function(){ reloadContainer('#request.thiscontainer#'); });return false;">
			<img src="#application.url.farcry#/images/crystal/22x22/actions/view_text.png" border="0" alt="Edit rule" />
		</a>
		<cfif arguments.stParam.index gt 1>
			<a href="#redirecturl#&rule_id=#stObj.objectid#&rule_index=#arguments.stParam.index#&rule_action=moveup" title="Move up" onclick="reloadContainer('#request.thiscontainer#', { rule_id:'#stObj.objectid#', rule_index:'#arguments.stParam.index#', rule_action:'moveup', ajax:'true' }); return false;">
				<img src="#application.url.farcry#/images/crystal/22x22/actions/up.png" border="0" alt="Move up" />
			</a>
		</cfif>
		<cfif arguments.stParam.index lt arguments.stParam.arraylen>
			<a href="#redirecturl#&rule_id=#stObj.objectid#&rule_index=#arguments.stParam.index#&rule_action=movedown" title="Move down" onclick="reloadContainer('#request.thiscontainer#', { rule_id:'#stObj.objectid#', rule_index:'#arguments.stParam.index#', rule_action:'movedown', ajax:'true' }); return false;">
				<img src="#application.url.farcry#/images/crystal/22x22/actions/down.png" border="0" alt="Move down" style="" />
			</a>
		</cfif>
		<a href="#redirecturl#&rule_id=#stObj.objectid#&rule_index=#arguments.stParam.index#&rule_action=delete" onclick="if (confirm('Are you sure you want to delete this rule?')) { reloadContainer('#request.thiscontainer#', { rule_id:'#stObj.objectid#', rule_index:'#arguments.stParam.index#', rule_action:'delete', confirm:'true', ajax:'true' }); return false; } else return false;" title="Delete">
			<img src="#application.url.farcry#/images/crystal/22x22/actions/stop.png" border="0" alt="Delete" />
		</a>
		<div class="title">
			<div class="type">RULE</div>
			<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace" target="_blank" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #application.stCOAPI[stObj.typename].displayname#',630,600,true,function(){ reloadContainer('#request.thiscontainer#'); });return false;" title="{<cfif arraylen(aProps)>#htmleditformat(arraytolist(aProps,", "))#</cfif>}">#application.stCOAPI[stObj.typename].displayname#</a>
		</div>
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />