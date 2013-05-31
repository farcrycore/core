<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Child Rows --->
<!--- @@cachestatus: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="url.relativeNLevel" default="0">
<cfparam name="url.bReloadBranch" default="false">
<cfparam name="url.loadCollapsed" default="false">
<cfparam name="url.responsetype" default="html">


<!--- root node --->
<cfset rootObjectID = stObj.objectid>

<!--- tree depth to load --->
<cfset treeLoadingDepth = 2>
<cfset bRenderRoot = true>

<!--- do not render the root when a relative nlevel has been passed in --->
<cfif url.relativeNLevel gt 0>
	<cfset bRenderRoot = false>
	<!--- the loading depth should be increased by 1 when when a relative nlevel has been passed in --->
	<cfset treeLoadingDepth = treeLoadingDepth + 1>
</cfif>
<!--- render the root when reloading a branch --->
<cfif url.bReloadBranch>
	<cfset bRenderRoot = true>
	<!--- the relative nlevel needs to be increased by 1 when reloading a branch --->
	<cfset url.relativeNLevel = url.relativeNLevel + 1>
</cfif>


<!--- initialize expanded tree nodes --->
<cfparam name="cookie.FARCRYTREEEXPANDEDNODES" default="">
<!--- add the root node if not loading collapsed --->
<cfif NOT url.loadCollapsed AND NOT listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
	<cfset cookie.FARCRYTREEEXPANDEDNODES = listAppend(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
</cfif>


<cfset oTree = createObject("component","farcry.core.packages.farcry.tree")>
<cfset qTree = oTree.getDescendants(objectid=rootObjectID, depth=treeLoadingDepth, bIncludeSelf=true)>

<!--- if no tree nodes were found it means the object is missing, since the tree lookup should always "includeSelf" --->
<cfif NOT qTree.recordcount>
	<cfexit method="exittemplate">
</cfif>

<!--- tree depth is relative to the root nlevel of the "page" --->
<cfset baseNLevel = qTree.nlevel>
<cfif NOT bRenderRoot>
	<cfset baseNLevel = baseNLevel - 1>
</cfif>

<cfset treeMaxLevel = baseNLevel + treeLoadingDepth>



<cfsavecontent variable="html">
	
	<cfloop query="qTree">

		<!--- look up the nav node --->
		<cfset stNav = application.fapi.getContentObject(typename="dmNavigation", objectid=qTree.objectid)>

		<cfset thisClass = "">
		<cfset bRootNode = stNav.objectid eq rootObjectID>
		<cfset bExpanded = false>
		<cfset expandable = 0>
		<cfset bUnexpandedAncestor = false>
		<cfset aLeafNodes = arrayNew(1)>
		<cfset childrenLoaded = false>

		<!--- find child folders --->
		<cfif qTree.recordCount gt qTree.currentRow + 1 AND qTree.nlevel[qTree.currentRow+1] gt qTree.nlevel>
			<cfset expandable = 1>
			<cfif qTree.nlevel lt treeMaxLevel>
				<cfset childrenLoaded = true>	
			</cfif>
		</cfif>
		<!--- find child leaves --->
		<cfif arrayLen(stNav.aObjectIDs) gt 0>
			<cfset expandable = 1>
			<cfif qTree.nlevel lt treeMaxLevel>
				<cfset aLeafNodes = oTree.getLeaves(qTree.objectid)>
				<cfset childrenLoaded = true>	
			</cfif>
		</cfif>

		<!--- determine if this node is currently expanded --->
		<cfif bRootNode AND NOT url.loadCollapsed>
			<cfset bExpanded = true>
		</cfif>
		<cfif listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, stNav.objectid, "|")>
			<cfset expandable = 1>
			<cfset bExpanded = true>
		</cfif>

		<!--- if this node is expanded then show it as collapsable --->
		<cfif bExpanded>
			<cfset thisClass = "fc-treestate-collapse">
		<cfelse>
			<cfset thisClass = "fc-treestate-expand">
		</cfif>


		<!--- tree indentation depth relative to the base nlevel of the page and the expandability of the node --->
		<cfset navIndentLevel = qTree.nlevel - baseNLevel - expandable + url.relativeNLevel + 1>


		<!--- check that all visible ancestors are expanded --->
		<cfset qAncestors = oTree.getAncestors(objectid=qTree.objectid, nlevel=qTree.nlevel-baseNLevel-1)>
		<cfloop query="qAncestors">
			<cfif NOT listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, qAncestors.objectid, "|") AND qAncestors.nlevel gt 0>
				<!--- unexpanded ancestor found, so this node is not visible --->
				<cfset bUnexpandedAncestor = true>
			</cfif>
		</cfloop>


		<cfif bRenderRoot OR qTree.objectid neq rootObjectID>


			<!--- if this node is expanded, or the parent nav node is expanded then this nav node will be visible --->
			<cfif bUnexpandedAncestor>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			<cfelseif url.loadCollapsed AND NOT bRootNode>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			<cfelseif qTree.parentid eq rootObjectID>
				<cfset thisClass = thisClass & " fc-treestate-visible">
			<cfelseif bExpanded OR listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, qTree.parentid, "|")>
				<cfset thisClass = thisClass & " fc-treestate-visible">
			<cfelse>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			</cfif>

			<!--- load children using ajax --->
			<cfif expandable AND NOT childrenLoaded>
				<cfset thisClass = thisClass & " fc-treestate-notloaded">
			</cfif>



			<!--- urls --->
			<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=#stNav.typename#&objectid=#stNav.objectid#&ref=overview">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stNav.objectid#&typename=#stNav.typename#">
			<cfset thisPreviewURL = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectid, urlparameters="flushcache=1&showdraft=1")>
			<cfset thisCreateURL = "#application.url.webtop#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stNav.objectid#&typename=dmNavigation&ref=overview">
			<cfset thisDeleteURL = "#application.url.webtop#/navajo/delete.cfm?objectid=#stNav.objectid#&ref=overview">

			<!--- vary the status labels and icon by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisFolderIcon = "icon-folder-close">
			<cfif bExpanded>
				<cfset thisFolderIcon = "icon-folder-open">
			</cfif>
			<cfset thisNodeIcon = "<span class='icon-stack'><i class='#thisFolderIcon#'></i></span>">

			<cfif stNav.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">
				<cfset thisNodeIcon = "<span class='icon-stack'><i class='#thisFolderIcon#'></i><i class='icon-pencil'></i></span>">

			<cfelseif stNav.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			<cfelse>
				<!--- object with other status --->
				<cfset thisStatusLabel = "<span class='label'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			</cfif>


			<cfoutput>
				<tr class="#thisClass#" data-objectid="#stNav.objectid#" data-nlevel="#qTree.nlevel#" data-indentlevel="#navIndentLevel-1#" data-nodetype="folder" data-parentid="#qTree.parentid#">
					<td class="fc-hidden-compact"><input type="checkbox" class="checkbox"></td>
					<td class="objectadmin-actions">
						<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" onclick="$fc.objectAdminAction('#stNav.label#', '#thisOverviewURL#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
						<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button" onclick="$fc.objectAdminAction('#stNav.label#', '#thisEditURL#', { onHidden: function(){ reloadTreeBranch('#stNav.objectid#'); } }); return false;"><i class="icon-pencil"></i> Edit</button>
						<a href="#thisPreviewURL#" class="btn fc-btn-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>

<div class="btn-group"> 
	<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="icon-caret-down only-icon"></i></button>
	<div class="dropdown-menu">
		<li class="fc-visible-compact"><a href="##" class="fc-btn-overview"><i class="icon-th icon-fixed-width"></i> Overview</a></li>
		<li class="fc-visible-compact"><a href="##" class="fc-btn-edit"><i class="icon-pencil icon-fixed-width"></i> Edit</a></li>
		<li class="fc-visible-compact"><a href="##" class="fc-btn-preview"><i class="icon-eye-open icon-fixed-width"></i> Preview</a></li>
		<li class="divider fc-visible-compact"></li>
		<li><a href="##" class="fc-add" onclick="$fc.objectAdminAction('Add Page', '#thisCreateURL#', { onHidden: function(){ reloadTreeBranch('#stNav.objectid#'); } }); return false;"><i class="icon-plus icon-fixed-width"></i> Add Page</a></li>
		<li><a href="##" class="fc-zoom"><i class="icon-zoom-in icon-fixed-width"></i> Zoom</a></li>

		<li class="divider"></li>
		<li><a href="##" class=""><i class="icon-trash icon-fixed-width"></i> Delete</a></li>

	</div>
</div>



					</td>
					<td class="fc-tree-title fc-nowrap">#repeatString('<i class="fc-icon-spacer"></i>', navIndentLevel)#<a class="fc-treestate-toggle" href="##"><i class="fc-icon-treestate"></i></a>#thisNodeIcon# <span>#stNav.label#</span></td>
					<td class="fc-nowrap-ellipsis fc-visible-compact">#application.fapi.getLink(type="dmNavigation", objectid=stNav.objectid)#</td>
					<td class="fc-hidden-compact">#thisStatusLabel#</td>
					<td class="fc-hidden-compact" title="#lsDateFormat(stNav.datetimelastupdated)# #lsTimeFormat(stNav.datetimelastupdated)#">#application.fapi.prettyDate(stNav.datetimelastupdated)#</td>
				</tr>
			</cfoutput>

		</cfif>



		<cfloop from="1" to="#arrayLen(aLeafNodes)#" index="i">

			<cfset stLeafNode = aLeafNodes[i]>
			<cfset stLeafNode.bHasVersion = false>
			<cfparam name="stLeafNode.status" default="">

			<!--- check for a versioned object of this leaf node --->
			<cfif structKeyExists(stLeafNode, "versionid") AND structKeyExists(stLeafNode, "status")>
				<cfquery name="qVersionedObject" datasource="#application.dsn#" >
					SELECT objectid,status,datetimelastupdated 
					FROM #application.dbowner##stLeafNode.typename# 
					WHERE versionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stLeafNode.objectid#">
				</cfquery>
				<cfif qVersionedObject.recordCount eq 1>
					<cfset stLeafNode.bHasVersion = true>
					<cfset stLeafNode.versionObjectid = qVersionedObject.objectID>
					<cfset stLeafNode.versionStatus = qVersionedObject.status>
					<cfset stLeafNode.versionDatetimelastupdated = qVersionedObject.datetimelastupdated>
				</cfif>
			</cfif>


			<!--- leaf nodes are indented 1 level deeper than nav nodes --->
			<cfset leafIndentLevel = navIndentLevel + 1>

			<cfset thisClass = "fc-treestate-hidden">
			<!--- if the parent nav node is expanded then the leaf will be visible --->
			<cfif bRootNode OR bExpanded>
				<cfset thisClass = "fc-treestate-visible">					
			</cfif>
			<!--- if the branch is loaded collapsed OR there is an unexpanded ancesotr then the leaf will be hidden --->
			<cfif url.loadCollapsed OR bUnexpandedAncestor>
				<cfset thisClass = "fc-treestate-hidden">
			</cfif>


			<!--- urls --->
			<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#&ref=overview">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stLeafNode.objectid#&typename=#stLeafNode.typename#">
			<cfset thisPreviewURL = application.fapi.getLink(typename=stLeafNode.typename, objectid=stLeafNode.objectid, urlparameters="flushcache=1&showdraft=1")>


			<!--- vary the status labels, icon, and edit URL by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i></span>">
			<cfif stLeafNode.bHasVersion>
				<!--- versioned object with multiple record --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.versionStatus#@label",stLeafNode.versionStatus)#</span> + <span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i><i class='icon-pencil'></i></span>">
				<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stLeafNode.versionObjectid#&typename=#stLeafNode.typename#">

			<cfelseif stLeafNode.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i><i class='icon-pencil'></i></span>">

			<cfelseif stLeafNode.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				
				<cfif structKeyExists(stLeafNode, "versionid") AND stLeafNode.status eq "approved">
					<!--- versioned object with approved only --->
					<cfset thisEditURL = "#application.url.webtop#/navajo/createDraftObject.cfm?objectid=#stLeafNode.objectid#&typename=#stLeafNode.typename#">
				</cfif>

			<cfelse>
				<!--- object with other status --->
				<cfset thisStatusLabel = "<span class='label'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
			</cfif>


			<!--- newest updated date --->
			<cfset lastupdated = stLeafNode.datetimelastupdated>
			<cfif stLeafNode.bHasVersion AND isValid("date", stLeafNode.versionDatetimelastupdated)>
				<cfset lastupdated = stLeafNode.versionDatetimelastupdated>
			</cfif>


			<cfoutput>
				<tr class="#thisClass#" data-objectid="#stLeafNode.objectid#" data-nlevel="#qTree.nlevel+1#" data-nodetype="leaf" data-parentid="#stNav.objectid#">
					<td class="fc-hidden-compact"><input type="checkbox" class="checkbox"></td>
					<td class="objectadmin-actions">
						<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" onclick="$fc.objectAdminAction('#stLeafNode.label#', '#thisOverviewURL#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
						<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button" onclick="$fc.objectAdminAction('#stLeafNode.label#', '#thisEditURL#'); return false;"><i class="icon-pencil"></i> Edit</button>
						<a href="#thisPreviewURL#" class="btn fc-btn-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>

<div class="btn-group"> 
	<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="icon-caret-down only-icon"></i></button>
	<div class="dropdown-menu">
		<li class="fc-visible-compact"><a href="##" class="fc-btn-overview"><i class="icon-th icon-fixed-width"></i> Overview</a></li>
		<li class="fc-visible-compact"><a href="##" class="fc-btn-edit"><i class="icon-pencil icon-fixed-width"></i> Edit</a></li>
		<li class="fc-visible-compact"><a href="##" class="fc-btn-preview"><i class="icon-eye-open icon-fixed-width"></i> Preview</a></li>
		<li class="divider fc-visible-compact"></li>
		<li><a href="##" class=""><i class="icon-trash icon-fixed-width"></i> Delete</a></li>

	</div>
</div>
					</td>
					<td class="fc-tree-title fc-nowrap">#repeatString('<i class="fc-icon-spacer"></i>', leafIndentLevel)#<i class="fc-icon-spacer"></i>#thisLeafIcon# #stLeafNode.label#</td>
					<td class="fc-nowrap-ellipsis fc-visible-compact">#application.fapi.getLink(type=stLeafNode.typename, objectid=stLeafNode.objectid)#</td>
					<td class="fc-hidden-compact">#thisStatusLabel#</td>
					<td class="fc-hidden-compact" title="#lsDateFormat(lastupdated)# #lsTimeFormat(lastupdated)#">#application.fapi.prettyDate(lastupdated)#</td>
				</tr>
			</cfoutput>

		</cfloop>



	</cfloop>

</cfsavecontent>

<!--- output response --->
<cfset out = html>

<cfif url.responsetype eq "json">
	<cfset stResponse = structNew()>
	<cfset stResponse["success"] = true>
	<cfset stResponse["html"] = trim(html)>
	<cfcontent reset="true" type="application/json">
	<cfset out = serializeJSON(stResponse)>
</cfif>

<cfoutput>#out#</cfoutput>


<cfsetting enablecfoutputonly="false">