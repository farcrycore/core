<cfsetting enablecfoutputonly="Yes">

<cfif not isDefined("URL.objectID")>
	<cfthrow detail="URL.objectID not passed">
</cfif>

<cfparam name="url.returnto" default="#application.url.farcry#/inc/content_overview.html?sec=site" />
<cfparam name="url.ref" default="overview" />

<cfif not isDefined("url.typename")>
	<cfset url.typename = createObject("component", "farcry.core.packages.fourq.fourq").findType(objectid=url.objectid) />
</cfif>

<cfset oType = createObject("component", application.stcoapi[url.typename].packagepath) />

<cfset stResult = oType.delete(objectid="#url.objectID#") />



<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header>

<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>

	<cfoutput><div class="error">#stResult.message#</div></cfoutput>

<cfelse>
	
	<cfswitch expression="#url.ref#">
		<cfcase value="iframe">
			
			<cfoutput>
				<script type="text/javascript">
				if (parent.$fc.objectAdminActionDiv === undefined) {
					location = "#url.returnto#";
				} else {
					parent.$fc.objectAdminActionDiv.dialog('close');
				}
				</script>		
			</cfoutput>
		</cfcase>
		
		<cfdefaultcase>
			<cfoutput>
				<script type="text/javascript">
				// check if edited from Content or Site (via sidetree)
				if(parent['sidebar'].frames['sideTree'])
					parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
				
				if (parent.$fc.objectAdminActionDiv === undefined) {
					location = "#url.returnto#";
				} else {
					parent.$fc.objectAdminActionDiv.dialog('close');
				}
				</script>		
			</cfoutput>
		</cfdefaultcase>
	</cfswitch>

</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">