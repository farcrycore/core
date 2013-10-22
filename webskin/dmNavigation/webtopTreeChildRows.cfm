<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Child Rows --->
<!--- @@cachestatus: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="url.relativeNLevel" default="0">
<cfparam name="url.bReloadBranch" default="false">
<cfparam name="url.bLoadRoot" default="false">
<cfparam name="url.bLoadCollapsed" default="false">
<cfparam name="url.bIgnoreExpandedNodes" default="false">
<cfparam name="url.bLoadLeafNodes" default="true">

<cfparam name="cookie.FARCRYTREEEXPANDEDNODES" default="">
<cfparam name="url.disableNode" default="">
<cfparam name="url.expandedNodes" default="#cookie.FARCRYTREEEXPANDEDNODES#">
<cfparam name="url.expandTo" default="">

<cfparam name="stParam.disableNode" default="#url.disableNode#">
<cfparam name="stParam.expandedNodes" default="#url.expandedNodes#">
<cfparam name="stParam.bLoadLeafNodes" default="#url.bLoadLeafNodes#">


<cfset oTree = createObject("component","farcry.core.packages.farcry.tree")>


<!--- root node --->
<cfset rootObjectID = stObj.objectid>

<!--- tree depth to load --->
<cfset treeLoadingDepth = 2>
<cfset bRenderRoot = true>

<!--- when a relative nlevel has been passed in, do not render the root and  --->
<cfif url.relativeNLevel neq 0>
	<cfset bRenderRoot = false>
	<!--- the loading depth should be increased by 1 when when a relative nlevel has been passed in --->
	<cfset treeLoadingDepth = treeLoadingDepth + 1>
</cfif>
<!--- when reloading a branch, render the root and indent by 1 --->
<cfif url.bReloadBranch>
	<cfset bRenderRoot = true>
</cfif>
<!--- when loading the root, render the root and don't indent --->
<cfif url.bLoadRoot>
	<cfset bRenderRoot = true>
	<cfset url.relativeNLevel = 0>
</cfif>
<!--- increase the relative nlevel when the root is not being rendered / branch is not being reloaded--->
<cfif NOT bRenderRoot>
	<cfset url.relativeNLevel = url.relativeNLevel + 1>
</cfif>


<!--- PROTECTED TREE NODES --->
<cfset lProtectedNavIDs = "">
<cfset lProtectedNavIDs = listAppend(lProtectedNavIDs, application.fapi.getNavID("root"))>
<cfset lProtectedNavIDs = listAppend(lProtectedNavIDs, application.fapi.getNavID("home"))>
<cfset lProtectedNavIDs = listAppend(lProtectedNavIDs, application.fapi.getNavID("hidden"))>


<!--- set up expanded tree nodes --->
<cfif len(url.expandTo) AND isValid("uuid", url.expandTo)>
	<!--- find the expandTo node that was passed in and get its ancestors --->
	<cfset qExpandToAncestors = oTree.getAncestors(objectid=url.expandTo, bIncludeSelf=false)>
	<cfset stParam.disableNode = url.expandTo>
	<cfset stParam.expandedNodes = valueList(qExpandToAncestors.objectid, "|")>
	<cfset url.bIgnoreExpandedNodes = false>
<cfelse>
	<!--- only update the expanded nodes cookie if no expandTo node was passed in --->
	<!--- add the root node if not loading collapsed --->
	<cfif NOT url.bLoadCollapsed AND NOT listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
		<cfset cookie.FARCRYTREEEXPANDEDNODES = listAppend(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
		<cfset stParam.expandedNodes = cookie.FARCRYTREEEXPANDEDNODES>
	</cfif>
</cfif>


<!--- get tree data --->
<cfset qTree = oTree.getDescendants(objectid=rootObjectID, depth=treeLoadingDepth, bIncludeSelf=true)>

<!--- if no tree nodes were found it means the object is missing, since the tree lookup should always "includeSelf" --->
<cfif NOT qTree.recordcount>
	<cfexit method="exittemplate">
</cfif>

<!--- tree depth is relative to the root nlevel of the "page" --->
<cfset baseNLevel = qTree.nlevel>
<cfset treeMaxLevel = baseNLevel + treeLoadingDepth>
<cfif NOT bRenderRoot>
	<cfset baseNLevel = baseNLevel + 1>
</cfif>


<cfset stResponse = structNew()>
<cfset stResponse["success"] = true>
<cfset stResponse["rows"] = arrayNew(1)>



<cfloop query="qTree">

	<!--- look up the nav node --->
	<cfset stNav = application.fapi.getContentObject(typename="dmNavigation", objectid=qTree.objectid)>

	<cfset thisClass = "">
	<cfset bRootNode = stNav.objectid eq rootObjectID>
	<cfset bProtectedNode = false>
	<cfset bDisabled = false>
	<cfset bExpanded = false>
	<cfset expandable = 0>
	<cfset bUnexpandedAncestor = false>
	<cfset aLeafNodes = arrayNew(1)>
	<cfset childrenLoaded = false>

	<!--- find child folders --->
	<cfif qTree.nRight - qTree.nLeft gt 1>
		<cfset expandable = 1>
		<cfif qTree.nlevel lt treeMaxLevel>
			<cfset childrenLoaded = true>	
		</cfif>
	</cfif>
	<!--- find child leaves --->
	<cfif stParam.bLoadLeafNodes>
		<cfif arrayLen(stNav.aObjectIDs) gt 0>
			<cfset expandable = 1>
			<cfif qTree.nlevel lt treeMaxLevel>
				<cfset aLeafNodes = oTree.getLeaves(qTree.objectid)>
				<cfset childrenLoaded = true>	
			</cfif>
		</cfif>
	</cfif>

	<!--- determine if this node is protected from destructive operations --->
	<cfif listFindNoCase(lProtectedNavIDs, stNav.objectid)>
		<cfset bProtectedNode = true>
	</cfif>

	<!--- determine if this node is disabled --->
	<cfif stParam.disableNode eq stNav.objectid>
		<cfset bDisabled = true>
		<cfset expandable = 0>
	</cfif>


	<!--- determine if this node is currently expanded --->
	<cfif expandable eq 1 AND bRootNode AND NOT url.bLoadCollapsed>
		<cfset bExpanded = true>
	</cfif>
	<cfif expandable eq 1 AND listFindNoCase(stParam.expandedNodes, stNav.objectid, "|") AND NOT url.bIgnoreExpandedNodes>
		<cfset bExpanded = true>
	</cfif>

	<!--- if this node is expanded then show it as collapsable --->
	<cfif expandable eq 1>
		<cfif bExpanded>
			<cfset thisClass = "fc-treestate-collapse">
		<cfelse>
			<cfset thisClass = "fc-treestate-expand">
		</cfif>
	</cfif>


	<!--- tree indentation depth relative to the base nlevel of the page and the expandability of the node --->
	<cfset navSpacers = (1 - expandable) + qTree.nlevel - baseNLevel + url.relativeNLevel>


	<!--- check that all visible ancestors are expanded --->
	<cfset qAncestors = oTree.getAncestors(objectid=qTree.objectid, nlevel=qTree.nlevel-baseNLevel-1)>
	<cfloop query="qAncestors">
		<cfif NOT listFindNoCase(stParam.expandedNodes, qAncestors.objectid, "|") AND qAncestors.nlevel gt 0>
			<!--- unexpanded ancestor found, so this node is not visible --->
			<cfset bUnexpandedAncestor = true>
		</cfif>
	</cfloop>


	<cfif bRenderRoot OR qTree.objectid neq rootObjectID>

		<!--- if this node is expanded, or the parent nav node is expanded then this nav node will be visible --->
		<cfif qTree.parentid eq rootObjectID AND NOT url.bIgnoreExpandedNodes>
			<cfset thisClass = thisClass & " fc-treestate-visible">
		<cfelseif bUnexpandedAncestor>
			<cfset thisClass = thisClass & " fc-treestate-hidden">
		<cfelseif url.bLoadCollapsed AND NOT bRootNode>
			<cfset thisClass = thisClass & " fc-treestate-hidden">
		<cfelseif qTree.parentid eq rootObjectID>
			<cfset thisClass = thisClass & " fc-treestate-visible">
		<cfelseif bExpanded OR (listFindNoCase(stParam.expandedNodes, qTree.parentid, "|") AND NOT url.bIgnoreExpandedNodes)>
			<cfset thisClass = thisClass & " fc-treestate-visible">
		<cfelse>
			<cfset thisClass = thisClass & " fc-treestate-hidden">
		</cfif>

		<!--- load children using ajax --->
		<cfif expandable AND NOT childrenLoaded>
			<cfset thisClass = thisClass & " fc-treestate-notloaded">
		</cfif>

		<!--- disabled node --->
		<cfif bDisabled>
			<cfset thisClass = thisClass & " fc-treestate-disabled">
		</cfif>

		<!--- urls --->
		<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=#stNav.typename#&objectid=#stNav.objectid#&ref=overview">
		<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stNav.objectid#&typename=#stNav.typename#">
		<cfset thisPreviewURL = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectid, urlparameters="flushcache=1&showdraft=1")>
		
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


		<!--- build nav node object --->
		<cfset stFolderRow = structNew()>
		<cfset stFolderRow["objectid"] = stNav.objectid>
		<cfset stFolderRow["typename"] = stNav.typename>
		<cfset stFolderRow["class"] = thisClass>
		<cfset stFolderRow["nlevel"] = qTree.nlevel>
		<cfset stFolderRow["nodetype"] = "folder">
		<cfset stFolderRow["protectednode"] = bProtectedNode>
		<cfset stFolderRow["parentid"] = qTree.parentid>
		<cfset stFolderRow["label"] = stNav.label>
		<cfset stFolderRow["datetimelastupdated"] = "#lsDateFormat(stNav.datetimelastupdated)# #lsTimeFormat(stNav.datetimelastupdated)#">
		<cfset stFolderRow["prettydatetimelastupdated"] = application.fapi.prettyDate(stNav.datetimelastupdated)>
		<cfset stFolderRow["expandable"] = expandable>
		<cfset stFolderRow["statuslabel"] = thisStatusLabel>
		<cfset stFolderRow["locked"] = false>
		<cfset stFolderRow["nodeicon"] = thisNodeIcon>
		<cfset stFolderRow["editURL"] = "#application.url.webtop#/edittabEdit.cfm?typename=#stNav.typename#&objectid=#stNav.objectid#">
		<cfset stFolderRow["previewURL"] = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectid, urlparameters="flushcache=1&showdraft=1")>
		<cfset stFolderRow["spacers"] = javaCast("int", navSpacers)>


		<!--- add nav node data to response array --->
		<cfset arrayAppend(stResponse["rows"], stFolderRow)>

	</cfif>


	<cfif stParam.bLoadLeafNodes>
		
		<cfloop from="1" to="#arrayLen(aLeafNodes)#" index="i">

			<cfset stLeafNode = aLeafNodes[i]>
			<cfset stLeafNode.bHasVersion = false>
			<cfparam name="stLeafNode.status" default="">
			<cfparam name="stLeafNode.locked" default="false">
			<cfparam name="stLeafNode.versionObjectid" default="">

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


			<!--- leaf nodes are indented 2 "spaces" deeper than nav nodes (one for the expander icon, one for the extra level of indentation) --->
			<cfset leafSpacers = navSpacers + 2>

			<cfset thisClass = "fc-treestate-hidden">
			<!--- if the parent nav node is expanded then the leaf will be visible --->
			<cfif bRootNode OR bExpanded>
				<cfset thisClass = "fc-treestate-visible">					
			</cfif>
			<!--- if the branch is loaded collapsed OR there is an unexpanded ancesotr then the leaf will be hidden --->
			<cfif url.bLoadCollapsed OR bUnexpandedAncestor>
				<cfset thisClass = "fc-treestate-hidden">
			</cfif>
		
		
			<!--- urls --->
			<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#&ref=overview">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stLeafNode.objectid#&typename=#stLeafNode.typename#">
			<cfset thisPreviewURL = application.fapi.getLink(typename=stLeafNode.typename, objectid=stLeafNode.objectid, urlparameters="flushcache=1&showdraft=1")>
			
		
			<!--- vary the status labels, icon, and edit URL by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file-alt'></i></span>">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#">
			<cfif stLeafNode.bHasVersion>
				<!--- versioned object with multiple records --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.versionStatus#@label",stLeafNode.versionStatus)#</span> + <span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file-alt'></i><i class='icon-pencil'></i></span>">
				<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.versionObjectid#">

			<cfelseif stLeafNode.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file-alt'></i><i class='icon-pencil'></i></span>">

			<cfelseif stLeafNode.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				
				<cfif structKeyExists(stLeafNode, "versionid") AND stLeafNode.status eq "approved">
					<!--- versioned object with approved only --->
					<cfset thisEditURL = "#application.url.webtop#/navajo/createDraftObject.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#">
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


			<!--- build leaf node object --->
			<cfset stLeafRow = structNew()>
			<cfset stLeafRow["objectid"] = stLeafNode.objectid>
			<cfset stLeafRow["typename"] = stLeafNode.typename>
			<cfset stLeafRow["class"] = thisClass>
			<cfset stLeafRow["nlevel"] = qTree.nlevel + 1>
			<cfset stLeafRow["nodetype"] = "leaf">
			<cfset stLeafRow["parentid"] = stNav.objectid>
			<cfset stLeafRow["versionobjectid"] = stLeafNode.versionObjectid>
			<cfset stLeafRow["label"] = stLeafNode.label>
			<cfset stLeafRow["datetimelastupdated"] = "#lsDateFormat(lastupdated)# #lsTimeFormat(lastupdated)#">
			<cfset stLeafRow["prettydatetimelastupdated"] = application.fapi.prettyDate(stLeafNode.datetimelastupdated)>
			<cfset stLeafRow["expandable"] = 0>
			<cfset stLeafRow["statuslabel"] = thisStatusLabel>
			<cfset stLeafRow["locked"] = stLeafNode.locked>
			<cfset stLeafRow["nodeicon"] = thisLeafIcon>
			<cfset stLeafRow["editURL"] = thisEditURL>
			<cfset stLeafRow["previewURL"] = application.fapi.getLink(typename=stLeafNode.typename, objectid=stLeafNode.objectid, urlparameters="flushcache=1&showdraft=1")>
			<cfset stLeafRow["spacers"] = javaCast("int", leafSpacers)>

			<!--- add leaf node to response array --->
			<cfset arrayAppend(stResponse["rows"], stLeafRow)>


		</cfloop>

	</cfif>

</cfloop>


<!--- output response --->
<cfif request.mode.ajax>
	<cfcontent reset="true" type="application/json">		
</cfif>
<cfoutput>#serializeJSON(stResponse)#</cfoutput>


<cfsetting enablecfoutputonly="false">