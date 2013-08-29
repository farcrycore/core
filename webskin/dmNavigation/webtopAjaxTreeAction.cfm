<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Action --->
<!--- @@cachestatus: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="url.sourceobjectid" default="">
<cfparam name="url.targetobjectid" default="">
<cfparam name="url.action" default="">


<cfset oTree = createObject("component","farcry.core.packages.farcry.tree")>


<cfset stResponse = structNew()>
<cfset stResponse["success"] = true>


<!--- validate action --->
<cfif NOT listFindNoCase("copy,move,delete", url.action)>
	<cfset stResponse["success"] = false>
	<cfset stResponse["message"] = "There was an error with the tree action">
<cfelseif NOT isValid("uuid", url.sourceobjectid)>
	<cfset stResponse["success"] = false>
	<cfset stResponse["message"] = "There was an error with the tree action object">
<cfelseif listFindNoCase("copy,move", url.action) AND NOT isValid("uuid", url.targetobjectid)>
	<cfset stResponse["success"] = false>
	<cfset stResponse["message"] = "There was an error with the tree action target object">
</cfif>

<!--- get the object --->
<cfset stSourceObject = application.fapi.getContentObject(objectid=url.sourceobjectid)>


<!--- process the action --->
<cfif stResponse["success"] eq true AND NOT isDefined("stSourceObject.bDefaultObject")>

	<cfif url.action eq "copy" OR url.action eq "move">
		<!--- get the target object --->
		<cfset stTargetObject = application.fapi.getContentObject(typename="dmNavigation", objectid=url.targetobjectid)>
		
		<cfif NOT isDefined("stTargetObject.bDefaultObject")>

			<!--- check the source/target position --->
			<nj:treeGetRelations get="ancestors" bInclusive="1" objectId="#url.targetobjectid#" r_lObjectIds="lAncestorIds">
			<cfif url.sourceobjectid eq url.targetobjectid OR listFindNoCase(lAncestorIds, url.sourceobjectid)>
				<cfset stResponse["success"] = false>
				<cfset stResponse["message"] = application.rb.getResource('sitetree.messages.destinationNodeCantBeChild@text','Destination node cannot be a child of or same as the source node')>
			</cfif>

			<!--- check permission --->
			<cfset hasPermission = false>
			<cfif application.security.checkPermission(permission="delete",object=url.sourceobjectid) AND application.security.checkPermission(permission="create",object=url.targetobjectid)>
				<cfset hasPermission = true>
			</cfif>

			<cfif stResponse["success"] eq true AND hasPermission>
			
				
				<cfif stSourceObject.typename eq "dmNavigation">

					<cfif url.action eq "move">
						<!--- move the branch in the NTM --->
					 	<cftry> 
							<!--- exclusive lock to prevent corruption --->
							<cflock scope="application" type="EXCLUSIVE" timeout="1" throwontimeout="yes">
								<cfset application.factory.oTree.moveBranch(dsn=application.dsn, objectid=url.sourceobjectid, parentID=url.targetobjectid)>
							</cflock>

							<cfcatch>
								<cfset stResponse["success"] = false>
								<cfset stResponse["message"] = application.rb.getResource('sitetree.messages.branchLockoutBlurb@text','Another editor is currently modifying the hierarchy. Please refresh the site overview tree and try again.')>
							</cfcatch>
						</cftry> 
					</cfif>

					<cfif url.action eq "copy">
						<cfset stResponse["success"] = false>
						<cfset stResponse["message"] = "NOT IMPLEMENTED YET">
					</cfif>
					
				<cfelse>

					<!--- for leaf nodes look up the parent --->
					<cfset oNav = application.fapi.getContentType(typename="dmNavigation")>
					<cfset qGetParent = oNav.getParent(objectid=url.sourceobjectid)>

					<cfif qGetParent.recordCount AND isValid("uuid", qGetParent.parentID)>
						<cfset stSourceObjectParent = application.fapi.getContentObject(typename="dmNavigation", objectid=qGetParent.parentID)>

						<cfif NOT isDefined("stSourceObjectParent.bDefaultObject")>

							<cfif url.action eq "move">
								<cfset itemPos = arrayFindNoCase(stSourceObjectParent.aObjectIDs, url.sourceobjectid)>
								<cfif itemPos gt 0>
									<!--- remove the source item from its parent --->
									<cfset arrayDeleteAt(stSourceObjectParent.aObjectIDs, itemPos)>
									<cfset stSourceObjectParent.datetimelastupdated = now()>
									<cfset oNav.setData(stProperties=stSourceObjectParent,auditNote="Child moved")>
									<!--- insert the source item into its target node --->
									<cfset arrayAppend(stTargetObject.aObjectIDs, url.sourceobjectid)>
									<cfset stTargetObject.datetimelastupdated = now()>
									<cfset oNav.setData(stProperties=stTargetObject,auditNote="Child moved")>
								<cfelse>
									<cfset stResponse["success"] = false>
									<cfset stResponse["message"] = "Source node not found">
								</cfif>

							</cfif>

							<cfif url.action eq "copy">
								<cfset stResponse["success"] = false>
								<cfset stResponse["message"] = "NOT IMPLEMENTED YET">
							</cfif>
							
						</cfif>
					<cfelse>
						<cfset stResponse["success"] = false>
						<cfset stResponse["message"] = "Parent not found">
					</cfif>

				</cfif>

			</cfif>

		</cfif>

	<cfelseif url.action eq "delete">

		<cfset thisTypename = application.fapi.findType(objectid=url.sourceobjectid)>
		<cfset oType = application.fapi.getContentType(typename=thisTypename)>
		<cfset stResult = oType.delete(objectid=url.sourceobjectID)>

		<cfif isDefined("stResult.bSuccess") AND NOT stResult.bSuccess>
			<cfset stResponse["success"] = false>
			<cfset stResponse["message"] = stResult.message>
		</cfif>

	</cfif>


</cfif>

<!--- output response --->
<cfif request.mode.ajax>
	<cfcontent reset="true" type="application/json">		
</cfif>
<cfoutput>#serializeJSON(stResponse)#</cfoutput>


<cfsetting enablecfoutputonly="false">