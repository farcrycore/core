<cfsetting enablecfoutputonly="Yes">

<cfif not isDefined("URL.objectID")>
	<cfthrow detail="URL.objectID not passed">
</cfif>

<cfif not isDefined("url.typename")>
	<cfset url.typename = createObject("component", "farcry.core.packages.fourq.fourq").findType(objectid=url.objectid) />
</cfif>

<cfset oType = createObject("component", application.stcoapi[url.typename].packagepath) />

<cfset stResult = oType.delete(objectid="#url.objectID#") />


<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>

	<cfoutput><div class="error">#stResult.message#</div></cfoutput>

<cfelse>

	<cfoutput>
		<script type="text/javascript">
		// check if edited from Content or Site (via sidetree)
		if(parent['sidebar'].frames['sideTree'])
			parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
		
		window.location = "#application.url.farcry#/inc/content_overview.html?sec=site";
		</script>		
	</cfoutput>
</cfif>

	
<cfsetting enablecfoutputonly="No">