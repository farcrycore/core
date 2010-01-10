<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@description: Generic delete method. Checks for associated objects and deletes them, deletes actual object --->

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

