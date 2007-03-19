<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_types/delete.cfm,v 1.15 2005/08/10 02:43:21 geoff Exp $
$Author: geoff $
$Date: 2005/08/10 02:43:21 $
$Name: milestone_3-0-1 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: Generic delete method. Checks for associated objects and 
deletes them, deletes actual object and deletes object from any verity 
collection if needed$

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->

<cfparam name="application.config.verity.bUpdateCollectionOnDelete" default="1" type="boolean">
<!--- delete actual object --->
<cfset deleteData(stObj.objectId)>

<!--- Clean up containers --->
<cfset lTypesWithContainers = "dmHTML,dmInclude">
<cfif listContainsNoCase(lTypesWithContainers,stObj.typename)>
	<cfset oCon = createObject("component","#application.packagepath#.rules.container")>
	<cfset oCon.delete(objectid=stObj.objectid)>
</cfif>

<!--- delete categories --->
<cfset oCategories = createObject("component","#application.packagepath#.farcry.category")>
<cfset oCategories.deleteAssignedCategories(objectid=stObj.objectid)>

<!--- delete from verity collection as required --->
<cfif NOT isDefined("application.config.verity")>
	<cfset oConfig = createObject("component", "#application.packagepath#.farcry.config")>
	<cfset application.config.verity = oConfig.getConfig("verity")>
</cfif>
<cfset stCollections = application.config.verity.contenttype>
<cfif structKeyExists(stCollections,stObj.typename) and application.config.verity.bUpdateCollectionOnDelete>
	<cfset collectionName = lcase(application.applicationname & "_" & stObj.typename)>
	<cfset application.factory.oVerity.deleteFromCollection(collection=collectionName,objectid=stObj.objectid)>
</cfif>

<!--- if this objecttype is used in tree, then it may have been used as a related link in dmHTML_aRelatedIDs  --->
<cfif structKeyExists(application.types[stObj.typename],"bUseInTree")>
	<cfif isBoolean(application.types[stObj.typename].bUseInTree) AND application.types[stObj.typename].bUseInTree>
		<cfset oHTML = createObject("component",application.types["dmHTML"].typepath)>
		<cfset oHTML.deleteRelatedIds(objectid=stObj.objectid)>
	</cfif>
</cfif>

<!--- if this objecttype is used in tree, then it may have been used as a tree Item  --->
<cfif structKeyExists(application.types[stObj.typename],"bUseInTree")>
	
	<cfif isBoolean(application.types[stObj.typename].bUseInTree) AND application.types[stObj.typename].bUseInTree>
		
		<!--- Has the item been included in the tree? --->
		<cfquery datasource="#application.dsn#" name="qNavigationChildren">
		SELECT *
		FROM dmNavigation_aObjectIDs
		WHERE data = '#stObj.objectid#'
		</cfquery>
		
		<!--- Loop through any nav nodes that include the object we are deleting and remove its reference from is aObjectIDs  --->
		<cfif qNavigationChildren.recordCount>
			
			<cfset oNav = createObject("component",application.types["dmNavigation"].typepath) />
			
			<cfloop query="qNavigationChildren">
				<cfset stNav = oNav.getData(objectid=qNavigationChildren.parentID) />
							
				<cfset aDeleteObjectIds = ListToArray(stObj.objectid)>
			
				<cfset stNav.aObjectIDs.removeAll(aDeleteObjectIds) >
				<cfset stResult = oNav.setData(stproperties=stNav) />
			</cfloop>
		</cfif>

	</cfif>
</cfif>

