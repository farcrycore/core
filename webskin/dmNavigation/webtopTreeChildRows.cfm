<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Child Rows --->
<!--- @@cachestatus: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="url.relativeNLevel" default="0">
<cfparam name="url.responsetype" default="html">


<!--- root node --->
<cfset rootObjectID = stObj.objectid>

<!--- tree depth to load --->
<cfset treeLoadingDepth = 2>
<cfset bRenderRoot = true>

<!--- only render the root when a relative nlevel has not been passed in --->
<cfif url.relativeNLevel gt 0>
	<cfset bRenderRoot = false>
</cfif>


<!--- expanded tree nodes --->
<cfparam name="cookie.fctreestatenodes" default="">


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
		<cfset expandable = 0>

		<!--- find child folders --->
		<cfif qTree.recordCount gt qTree.currentRow + 1 AND qTree.nlevel[qTree.currentRow+1] gt qTree.nlevel>
			<cfset expandable = 1>
		</cfif>
		<!--- find child leaves --->
		<cfif arrayLen(stNav.aObjectIDs) gt 0>
			<cfset expandable = 1>
		</cfif>

		<!--- set the appropriate class for expandable folders  --->
		<cfif expandable>
			<cfset thisClass = thisClass & "fc-treestate-expand">
		</cfif>
		<!--- if this node is already expanded then show it as collapsable --->
		<cfif expandable AND stNav.objectid eq rootObjectID>
<!--- TODO: if above, OR the nav objectid is in the list of expanded nodes --->			
			<cfset thisClass = "fc-treestate-collapse">
		</cfif>

		<!--- tree indentation depth relative to the base nlevel of the page and the expandability of the node --->
		<cfset navIndentLevel = qTree.nlevel - baseNLevel - expandable + url.relativeNLevel + 1>


		<!--- get leaf nodes for the appropriate depth --->
		<cfset navChildrenAjax = false>
		<cfif qTree.nlevel lt treeMaxLevel>
			<cfset aLeafNodes = oTree.getLeaves(qTree.objectid)>
		<cfelse>
			<cfset aLeafNodes = arrayNew(1)>
			<cfset navChildrenAjax = true>
		</cfif>


		<!--- output tree nodes other than the root node --->
		<cfif (bRenderRoot eq true) OR (bRenderRoot eq false AND qTree.objectid neq rootObjectID)>

			<!--- if this is the root node, or the parent nav node is expandedthen this nav node will be visible --->
			<cfif stNav.objectid eq rootObjectID OR qTree.parentid eq rootObjectID OR listFindNoCase(cookie.fctreestatenodes, qTree.parentid)>
				<cfset thisClass = thisClass & " fc-treestate-visible">
			<cfelse>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			</cfif>

			<cfif navChildrenAjax AND expandable>
				<cfset thisClass = thisClass & " fc-treestate-loadchildren">
			</cfif>

			<!--- urls --->
			<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?objectid=#stNav.objectid#&ref=overview">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?objectid=#stNav.objectid#&typename=#stNav.typename#">
			<cfset thisPreviewURL = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectid, urlparameters="flushcache=1&showdraft=1")>

			<!--- vary the status labels and icon by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisFolderIcon = "<span class='icon-stack'><i class='icon-folder-close'></i></span>">
			<cfif stNav.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">
				<cfset thisFolderIcon = "<span class='icon-stack'><i class='icon-folder-close'></i><i class='icon-pencil'></i></span>">

			<cfelseif stNav.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			<cfelse>
				<!--- object with other status --->
				<cfset thisStatusLabel = "<span class='label'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			</cfif>


			<cfoutput>
				<tr class="#thisClass#" data-objectid="#stNav.objectid#" data-nlevel="#qTree.nlevel#" data-indentlevel="#navIndentLevel-1#" data-nodetype="folder" data-parentid="#qTree.parentid#">
					<td><input type="checkbox" class="checkbox"></td>
					<td class="objectadmin-actions">
						<button class="btn fc-tooltip" onclick="$fc.objectAdminAction('#stNav.label#', '#thisOverviewURL#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
						<button class="btn btn-edit" type="button" onclick="$fc.objectAdminAction('#stNav.label#', '#thisEditURL#'); return false;"><i class="icon-pencil"></i> Edit</button>
						<a href="#thisPreviewURL#" class="btn fc-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>
						<button class="btn" type="button"><i class="icon-caret-down only-icon"></i></button>
					</td>
					<td class="fc-tree-title">#repeatString('<i class="fc-icon-spacer"></i>', navIndentLevel)#<a class="fc-treestate-toggle" href="##"><i class="fc-icon-treestate"></i></a>#thisFolderIcon# <span>#stNav.label#</span></td>
					<td>#thisStatusLabel#</td>
					<td title="#lsDateFormat(stNav.datetimelastupdated)# #lsTimeFormat(stNav.datetimelastupdated)#">#application.fapi.prettyDate(stNav.datetimelastupdated)#</td>
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
			<cfif stNav.objectid eq rootObjectID OR listFindNoCase(cookie.fctreestatenodes, stNav.objectid)>
				<cfset thisClass = "fc-treestate-visible">
			</cfif>


			<!--- urls --->
			<cfset thisOverviewURL = "#application.url.webtop#/edittabOverview.cfm?objectid=#stLeafNode.objectid#&ref=overview">
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
					<td><input type="checkbox" class="checkbox"></td>
					<td class="objectadmin-actions">
						<button class="btn fc-tooltip" onclick="$fc.objectAdminAction('#stLeafNode.label#', '#thisOverviewURL#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
						<button class="btn btn-edit" type="button" onclick="$fc.objectAdminAction('#stLeafNode.label#', '#thisEditURL#'); return false;"><i class="icon-pencil"></i> Edit</button>
						<a href="#thisPreviewURL#" class="btn fc-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>
						<button class="btn" type="button"><i class="icon-caret-down only-icon"></i></button>
					</td>
					<td class="fc-tree-title">#repeatString('<i class="fc-icon-spacer"></i>', leafIndentLevel)#<i class="fc-icon-spacer"></i>#thisLeafIcon# #stLeafNode.label#</td>
					<td>#thisStatusLabel#</td>
					<td title="#lsDateFormat(lastupdated)# #lsTimeFormat(lastupdated)#">#application.fapi.prettyDate(lastupdated)#</td>
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