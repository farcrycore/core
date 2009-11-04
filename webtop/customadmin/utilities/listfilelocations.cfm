<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: List file locations --->
<!--- @@description: This utility finds file and image properties and generates SQL code to update them. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset stFileProps = structnew() />

<cfparam name="form.newlocation" default="" />
<cfparam name="form.runsql" default="false" />
<cfparam name="form.properties" default="" />

<cfloop collection="#application.stCOAPI#" item="thistype">
	<cfif listcontains("type,rule",application.stCOAPI[thistype].class)>
		<cfloop collection="#application.stCOAPI[thistype].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#thistype#.stProps.#thisprop#.metadata.ftType") and listcontains("image,file",application.stCOAPI[thistype].stProps[thisprop].metadata.ftType)>
				<cfparam name="stFileProps[thistype]" default="#structnew()#" />
				<cfparam name="stFileProps[thistype][thisprop]" default="#application.stCOAPI[thistype].stProps[thisprop].metadata#" />
			</cfif>
		</cfloop>
	</cfif>
</cfloop>

<cfset sql = "" />
<cfif len(form.newlocation)>
	<cfloop collection="#stFileProps#" item="thistype">
		<cfloop collection="#stFileProps[thistype]#" item="thisprop">
			<cfif listcontains(form.properties,"#thistype#.#thisprop#")>
				<cfset sql = sql & "update #thistype##chr(13)##chr(10)#" />
				<cfif stFileProps[thistype][thisprop].ftType eq "file">
					<cfset sql = sql & "set #thisprop#='#form.newlocation##application.url.fileroot#'" />
				<cfelse>
					<cfset sql = sql & "set #thisprop#='#form.newlocation#'" />
				</cfif>
				<cfset sql = sql & " + #thisprop##chr(13)##chr(10)#where #thisprop#<>'' and not #thisprop# like 'http://%'" >
				<cfif structkeyexists(application.stCOAPI[thistype].stProps,"status")>
					<cfset sql = sql & " and status='approved';" />
				<cfelse>
					<cfset sql = sql & ";" />
				</cfif>
				<cfset sql = sql & "#chr(13)##chr(10)##chr(13)##chr(10)#" />
			</cfif>
		</cfloop>
	</cfloop>
</cfif>

<admin:header />

<cfoutput><h1>#application.fapi.getResource("webtop.utilities.listfilelocations@title","List file locations")#</h1></cfoutput>
<admin:resource key="webtop.utilities.listfilelocations.explanation@text"><cfoutput>
	<p>FarCry 5.2 introduced a number of CDN features:</p>
	<ul>
		<li>approved public files are now streamed directly from the web server instead of through ColdFusion, which improves performance significantly</li>
		<li>draft and secured files are stored in a secure directory and will only be streamed to the user if they have permission</li>
	</ul>
	<p>For applications where files need to be moved manually, this script will generate SQL for manual DB updates. This SQL assumes that the file and image directories are copied directly into the CDN root.</p>
</cfoutput></admin:resource>

<cfoutput>
	<form action="" method="POST">
		<ul>
</cfoutput>
<cfloop collection="#stFileProps#" item="thistype">
	<cfoutput><li><strong>#thistype#</strong><ul></cfoutput>
	<cfloop collection="#stFileProps[thistype]#" item="thisprop">
		<cfoutput><li><input type="checkbox" name="properties" id="#thistype#_#thisprop#" value="#thistype#.#thisprop#"<cfif listcontains(form.properties,"#thistype#.#thisprop#")> checked</cfif> /> <label for="#thistype#_#thisprop#">#stFileProps[thistype][thisprop].ftType# - #thisprop#</label></li></cfoutput>
	</cfloop>
	<cfoutput></ul></li></cfoutput>
</cfloop>
<cfoutput>
		</ul>
		<label for="newlocation">New location</label><input type="text" name="newlocation" id="newlocation" value="#form.newlocation#" /><br />
		<label for="runsql">Run SQL</label><input type="checkbox" name="runsql" value="1"<cfif form.runsql> checked</cfif> /><br />
		<input type="submit" name="generate" value="Generate" />
	</form>
</cfoutput>

<cfif len(sql)>
	<cfoutput><textarea cols="70" rows="10">#sql#</textarea></cfoutput>
</cfif>
	
<admin:footer />

<cfsetting enablecfoutputonly="false" />