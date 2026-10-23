

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!---
ENVIRONMENT VARIABLES
 --->


<cfset oUD = application.security.userdirectories[stobj.userdirectory] />
<cfset userID = application.factory.oUtils.listSlice(stobj.username,1,-2,"_") />
<cfset aUserGroups = oUD.getUserGroups(userID) />

<cfset groups = "">
<cfloop from="1" to="#arraylen(aUserGroups)#" index="i">
	<cfset groups = listappend(groups,"#aUserGroups[i]#_#stobj.userdirectory#") />
</cfloop>
<cfset lRoleIDs = application.fapi.getContentType("farRole").groupsToRoles(groups) />

<ft:form style="width:100%;">
<cfoutput>
	<h1>
		#encodeForHTML(stobj.firstName)# #encodeForHTML(stobj.lastname)# Webtop Security

		<ft:button value="Print" type="button" onClick="window.print();" class="hidden-print" />
	</h1>
</cfoutput>

<cfif len(lRoleIDs)>

	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-jquery-ui" />
	<skin:loadCSS id="jquery-ui" />

	<skin:htmlHead><cfoutput>
		<style type="text/css">
			##webtopTree .fa { position:relative; font-size: 16px; line-height: 14px; top: -2px; }
			##webtopTree .nodelabel { font-size: 13px; line-height: 14px; color: inherit; }
		</style>
		<style type="text/css" media="print">
		  @page { size: landscape; }
		</style>
	</cfoutput></skin:htmlHead>


	<!--- the full webtop tree (structure, rbkeys and labels), security ignored, for the rows --->
	<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />

	<!--- this user's roles, for the column order and headers --->
	<cfquery datasource="#application.dsn#" name="qRoles">
		SELECT 	objectid, title
		FROM 	#application.dbowner#farRole
		WHERE 	objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lRoleIDs#">)
		ORDER BY title
	</cfquery>

	<!--- what each role actually sees, from the resolver (honours each role's visibility mode), plus the combined set the user gets --->
	<cfset aRoles = arrayNew(1) />
	<cfset stVisible = structNew() />
	<cfset stCombined = structNew() />
	<cfloop query="qRoles">
		<cfset arrayAppend(aRoles, { id = qRoles.objectid, title = qRoles.title }) />
		<cfset stRoleKeys = structNew() />
		<cfloop list="#application.factory.oWebtop.getVisibleItemKeys(role=qRoles.objectid)#" index="thisKey">
			<cfset stRoleKeys[thisKey] = true />
			<cfset stCombined[thisKey] = true />
		</cfloop>
		<cfset stVisible[qRoles.objectid] = stRoleKeys />
	</cfloop>


	<ft:field label="Webtop Access">
		<cfif application.security.checkPermission(permission="admin",role="#lRoleIDs#")>
			<cfoutput><i class="fa fa-check-circle fa-fw webtop-preview-shown"></i></cfoutput>
		<cfelse>
			<cfoutput><i class="fa fa-times-circle fa-fw webtop-preview-hidden"></i></cfoutput>
		</cfif>
		<ft:fieldHint><cfoutput>Green shows the page is visible to the role, red that it is hidden. The Combined column is what this user actually sees.</cfoutput></ft:fieldHint>
	</ft:field>

	<ft:field label="Access Permissions" bMultiField="true">
		<cfoutput>
		<div id="webtopPreview">
			<div>
				<cfloop array="#aRoles#" index="thisRole"><div class="webtop-preview-col webtop-preview-head">#encodeForHTML(thisRole.title)#</div></cfloop>
				<div class="webtop-preview-col webtop-preview-head">Combined</div>
			</div>
			<div class="webtop-preview-clear"></div>
			<ul id="webtopTree">
				<li>
					<span class="nodelabel">Webtop</span>
					<cfloop array="#aRoles#" index="thisRole"><div class="webtop-preview-col">#previewCell(true)#</div></cfloop>
					<div class="webtop-preview-col">#previewCell(true)#</div>
		</cfoutput>
		<cfset renderPreviewNodes(stWebtop) />
		<cfoutput>
				</li>
			</ul>
		</div>
		</cfoutput>
	</ft:field>


	<skin:onReady><cfoutput>
		$j("##webtopTree").treeview({ animated: "fast" });
	</cfoutput></skin:onReady>


<cfelse>
	<cfoutput><div class="alert alert-error">NO ROLES ASSIGNED TO THIS USER.</div></cfoutput>
</cfif>




</ft:form>



<cffunction name="renderPreviewNodes" output="true" returntype="void" hint="Recursively renders the webtop tree rows with a visible/hidden cell per role plus a combined cell">
	<cfargument name="node" required="true" />

	<cfset var childid = "" />
	<cfset var child = "" />
	<cfset var rbkey = "" />
	<cfset var thisRole = "" />

	<cfif NOT (structKeyExists(arguments.node, "childorder") AND listLen(arguments.node.childorder))>
		<cfreturn />
	</cfif>

	<cfoutput><ul></cfoutput>
	<cfloop list="#arguments.node.childorder#" index="childid">
		<cfset child = arguments.node.children[childid] />
		<cfset rbkey = child.rbkey />
		<cfoutput>
			<li>
				<span class="nodelabel">#encodeForHTML(child.label)#</span>
				<cfloop array="#aRoles#" index="thisRole"><div class="webtop-preview-col">#previewCell(structKeyExists(stVisible[thisRole.id], rbkey))#</div></cfloop>
				<div class="webtop-preview-col">#previewCell(structKeyExists(stCombined, rbkey))#</div>
		</cfoutput>
		<cfset renderPreviewNodes(child) />
		<cfoutput>
			</li>
		</cfoutput>
	</cfloop>
	<cfoutput></ul></cfoutput>
</cffunction>


<cffunction name="previewCell" output="false" returntype="string" hint="Returns a solid-green visible icon or a faded-red hidden icon">
	<cfargument name="shown" type="boolean" required="true" />

	<cfif arguments.shown>
		<cfreturn '<i class="fa fa-check-circle fa-fw webtop-preview-shown" title="visible"></i>' />
	<cfelse>
		<cfreturn '<i class="fa fa-times-circle fa-fw webtop-preview-hidden" title="hidden"></i>' />
	</cfif>
</cffunction>
