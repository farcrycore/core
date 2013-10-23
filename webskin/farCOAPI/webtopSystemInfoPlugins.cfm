<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Plugins --->
<!--- @@seq: 200 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset coreLastModified = createdatetime(1970,1,1,0,0,0) />
<cfdirectory action="list" directory="#expandpath('/farcry/core')#" recurse="true" type="file" name="q" />
<cfloop query="q">
	<cfif coreLastModified lt q.dateLastModified>
		<cfset coreLastModified = q.dateLastModified />
	</cfif>
</cfloop>


<cfloop list="#application.plugins#" index="thisplugin">
	<cfif directoryExists(expandpath("/farcry/plugins/#thisplugin#"))>
		<cfset pluginName = thisplugin />
		<cfset pluginStatus = "Unknown Status" />
		<cfif fileexists(expandpath("/farcry/plugins/#thisplugin#/install/manifest.cfc"))>
			<cfset o = createobject("component","farcry.plugins.#thisplugin#.install.manifest") />
			<cfset pluginName = o.name />
			<cfif structkeyexists(o,"getStatus")>
				<cfset pluginStatus = o.getStatus() />
			</cfif>
		</cfif>

		<cfset pluginLastModified = createdatetime(1970,1,1,0,0,0) />
		<cfdirectory action="list" directory="#expandpath('/farcry/plugins/#thisplugin#')#" recurse="true" type="file" name="q" />
		<cfloop query="q">
			<cfif pluginLastModified lt q.dateLastModified>
				<cfset pluginLastModified = q.dateLastModified />
			</cfif>
		</cfloop>
		
		<ft:field label="#pluginName#">
			<cfoutput>
				<div class="span3" style="color:<cfif pluginStatus eq 'Unknown Status'>##C09853<cfelseif pluginStatus eq 'Good'>##468847<cfelse>##B94A48</cfif>">#pluginStatus#</div>
				<div class="span3">last modified: #lcase(timeformat(pluginLastModified,'hh:mmtt'))#, #dateformat(pluginLastModified,'d mmm yyyy')#</div>
			</cfoutput>
		</ft:field>
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false">