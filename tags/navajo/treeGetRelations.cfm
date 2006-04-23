<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/treeGetRelations.cfm,v 1.10 2003/07/15 07:04:15 brendan Exp $
$Author: brendan $
$Date: 2003/07/15 07:04:15 $
$Name: b131 $
$Revision: 1.10 $

|| DESCRIPTION || 

$Description: Takes an object and gets it relations. Relies upon the deployment of NTM stored procs and #application.packagepath#.farcry.tree component $
$TODO: $


Relies upon the deployment of NTM stored procs and #application.packagepath#.farcry.tree component

|| USAGE ||
<nj:treeGetRelations
	objectId="0"
	get="Children"
	r_lObjectIds="lObjectIds"
	bInclusive="1">

|| DEVELOPER ||
$Developer: Matt Dawson (mad@daemon.com.au)$

|| ATTRIBUTES ||
$in: [attributes.objectId]: objectId to work from$
$in: [attributes.get]: what type of relationship to get [ ancestors, children, descendants ] :$
$in: [attributes.typename] typename for tree$
$in: [attributes.bInclusive]: whether to include the current node$
$out:[attributes.r_stObjects]: Objects found as structure$
$out:[attributes.r_lObjectIds]: Objects found as list of ids$
--->

<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfparam name="attributes.objectId" default="">
<cfparam name="attributes.lobjectIds" default="#attributes.objectId#">
<cfparam name="attributes.get">
<cfparam name="attributes.typename" default="dmNavigation">
<cfparam name="attributes.bInclusive">
<cfparam name="attributes.bIncludeObjects" default="1">
<cfparam name="attributes.lStatus" default="">
<cfparam name="attributes.lTypeIds" default="">

<cfparam name="attributes.r_stObjects" default="">
<cfparam name="attributes.r_stObject" default="">
<cfparam name="attributes.r_lObjectIds" default="">
<cfparam name="attributes.r_ObjectId" default="">

<cfif attributes.bInclusive>
	<cfset lObjectIds=attributes.objectId>
<cfelse>
	<cfset lObjectIds="">
</cfif>


<!--- internal structures to generate
lobjectids
stObjects
stObject
 --->
<!--- <cfquery datasource="#application.dsn#" name="q">
select * from nested_tree_objects
</cfquery>
<cfdump var="#q#">
 ---> 
<cfif attributes.get eq "root">
	<cfinvoke component="#application.packagepath#.farcry.tree" method="getRootNode" typename="#attributes.typename#" returnvariable="qRoot">
<!--- <cfdump var="#qRoot#"> --->
<cfset lObjectIds = qRoot.ObjectID>
</cfif>

<cfif attributes.get eq "children">
<!--- 
TODO
not too elegant
need to call tag or fourq function that has status as an option somehow
--->
<cfif attributes.typename eq "">
	<cfset attributes.typename = "dmnavigation">
</cfif>
<cfif attributes.typename is "dmNavigation">
	<cfinvoke component="#application.packagepath#.farcry.tree" method="getChildren" objectid="#attributes.objectid#" returnvariable="qChildren">
<cfelse>	
	<cfquery name="qChildren" datasource="#application.dsn#">
		select a.data AS objectID, b.title AS objectname from #application.dbowner##attributes.typename#_aObjectIDs a
		JOIN #application.dbowner##attributes.typename# b ON a.data = b.objectID
	    where a.objectID =  '#attributes.objectID#'
	</cfquery>
</cfif>
<!--- <cfdump var="#qChildren#" label="qChildren"> --->
<!--- 
get data from COAPI
TODO
this should be a COAPI call and *not* a straight SQL shortcut 
--->

<cfquery datasource="#application.dsn#" name="qObjects">
	SELECT objectid FROM #application.dbowner##attributes.typename#
	WHERE
	objectid IN (<cfif qChildren.recordCount GT 0>#QuotedValueList(qChildren.objectid)#</cfif><cfif attributes.bInclusive><cfif qChildren.recordCount GT 0>,</cfif>'#attributes.objectid#'</cfif>)
	<cfif len(attributes.lstatus)>
		AND status = '#attributes.lstatus#'
	</cfif>
</cfquery>

<cfset lobjectIDs="#ValueList(qObjects.objectid)#">

<!--- <cfabort> --->
</cfif>



<cfloop index="attributes.objectId" list="#attributes.lobjectIds#">

	<!--- children --->
	<cfif attributes.get eq "children">
	
<!--- 	<!--- if objectid is 0 we are looking for root nodes --->
	<cfif attributes.objectId neq '0'>
		<!--- get object set lObjectIds to aNavChild, ordered by aNavChild --->
		<cfa_contentobjectGet objectId="#attributes.objectId#" r_stObject="stObj">
	
		<cfif not isStruct(stObj) OR structIsEmpty(stObj)>
			<!---cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Unable to find object, objectId='#attributes.objectId#'."--->
		</cfif>
		
		<cfif structKeyExists(stObj,"aNavChild")>
			<cfif len(attributes.lStatus)>
			
			<cfquery name="qStatusedChildren" datasource="#request.cfa.datasource.dsn#">
				SELECT p.objectId
					FROM properties p
					WHERE p.objectId IN ('#ListChangeDelims(ArrayToList(stObj.aNavChild),"','",",")#')
						AND p.propertyName = 'STATUS'
						AND p.chardata IN ('#ListChangeDelims(attributes.lStatus,"','",",")#')
			</cfquery>
				
				<cfset lObjectIds=listAppend(lObjectIds,ValueList(qStatusedChildren.objectId))>
			
			<cfelse>
				<cfset lObjectIds=listAppend(lObjectIds,ArrayToList( stObj.aNavChild ))>
			</cfif>
		</cfif>
		
		<cfif attributes.bIncludeObjects AND structKeyExists(stObj,"aObjectIds") AND arraylen(stObj.aObjectIds)>
			<cfif len(attributes.lStatus)>
				
				<cfquery name="qStatusedChildren" datasource="#request.cfa.datasource.dsn#">
					SELECT p.objectId
						FROM properties p
						WHERE p.objectId IN ('#ListChangeDelims(ArrayToList(stObj.aObjectIds),"','",",")#')
							AND p.propertyName = 'STATUS'
							AND p.chardata IN ('#ListChangeDelims(attributes.lStatus,"','",",")#')
				</cfquery>

				<cfset lObjectIds=listAppend(lObjectIds,ValueList(qStatusedChildren.objectId))>
			<cfelse>
				<cfset lObjectIds=listAppend(lObjectIds,ArrayToList( stObj.aObjectIds ))>
			</cfif>
		</cfif>
		
	<cfelse>
		<!--- get nodes that aren't pointed to by anything (root nodes) --->
		<cfquery name="qGetParentLess" datasource="#request.cfa.datasource.dsn#">
			SELECT *
				FROM objects o
				WHERE o.typeId = '#application.daemon_navigationTypeId#' AND
				        (SELECT COUNT(*)
				      FROM properties p
				      WHERE p.propertyname LIKE 'ANAVCHILD%' AND 
				           p.chardata = o.objectId) = 0
		</cfquery>
		
		<cfset lObjectIds=ValueList( qGetParentLess.objectId )>
	</cfif> --->
	
	<cfelseif attributes.get eq "ancestors">
<!--- 	
	TODO
	if its a dmNavigation object we can go straight to the tree table
	Otherwise we have to look up the parent somehow.
	The parent could be either a dmNavigation or dmHTML object
 --->	
	<cfinvoke component="#application.packagepath#.farcry.tree" method="getAncestors" objectid="#attributes.objectid#" returnvariable="qAncestors" typename="dmNavigation">
	<!--- <cfdump var="#qAncestors#" label="qAncestors"> --->
	<cfset lobjectIDs="#ValueList(qAncestors.objectid)#">


	<cfelseif attributes.get eq "descendants">
	<!--- descendants --->
	<!--- loop while get children, non ordered list/stobjects --->
	
		<cfinvoke  component="#application.packagepath#.farcry.tree" method="getDescendants" returnvariable="getDescendantsRet">
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
		<cfinvokeargument name="objectid" value="#attributes.objectid#"/>
	</cfinvoke>
	<cfset lObjectIds = valueList(getDescendantsRet.objectID)>
	<cfelseif attributes.get eq "parents">
	<cfif attributes.typename is "dmNavigation">
		<!--- TODO - invocation of getParentID is barfing.  Ask geoff if ok to mod stored proc. 
		Do cfquery  for time being --->
<!--- 		<cfinvoke component="#application.packagepath#.farcry.tree" method="getParentID" objectid="#attributes.objectid#" returnvariable="qGetParent"> --->
		<cfquery name="qGetParent" datasource="#application.dsn#">
			select  parentid AS objectID from #application.dbowner#nested_tree_objects 
		    where objectid  = '#attributes.objectid#'
		</cfquery>	
	<cfelse>	
		<!--- TODO - MAJOR hack here.  --->
		<!--- This is the list of #typename#_aObjectIDs tables that we look
		 for the parent. This list is in ascending search order --->
		<cfset searchList = "dmNavigation,dmHTML">
		<cfset loop = true>
		<cfset listIndex = 1>
		<cfloop condition="loop">
				
			<cfquery name="qGetParent" datasource="#application.dsn#">
				SELECT objectID FROM #application.dbowner##listGetAt(searchlist,listIndex)#_aObjectIDs 
				WHERE data = '#attributes.objectID#'	
			</cfquery>	
			<cfif qGetParent.recordCount GT 0>
				<cfset loop = false>
			</cfif>
			<cfif listIndex IS listLen(searchList)>
				<cfset loop = false>
			</cfif> 
			<cfset listIndex = listIndex + 1>
		</cfloop>
	</cfif>	
		<!--- TODO - err must devise strategy to get parents of non dmNavigation Nodes --->
			


 	<!--- throw spaz if more than one parent, ordered by level--->
	<!--- <cfif qGetParent.recordCount gt 1>
		<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Object has more than one parent, objectId='#attributes.objectId#'.">
	</cfif> --->
	
	<cfset lObjectIds=qGetParent.objectId>
	
	<cfelse>
	<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Unknown attribute value passed, get='#attributes.get#'.">
	
	</cfif>

</cfloop>


<!--------------------------------------------------------------------
Filter results by type
TODO
change to typenames as opposed to Spectra TypeIDs
--------------------------------------------------------------------->
<cfif len(attributes.lTypeIds)>
<!--- temp break --->
<cfthrow errorcode="navajo" detail="treeGetRelations: ltypeids attribute is not yet implemented for fourq.">

<cfquery name="qFilter" datasource="#request.cfa.datasource.dsn#">
SELECT o.objectId
	FROM objects o
	WHERE o.typeId IN ('#ListChangeDelims(attributes.lTypeIds,"','",",")#')
	AND o.objectId IN ('#ListChangeDelims(lObjectIds,"','",",")#')
</cfquery>
<cfset lObjectIds = ValueList(qFilter.objectId )>
</CFIF>


<!--------------------------------------------------------------------
Build return result structures
--------------------------------------------------------------------->
<cfif len(attributes.r_ObjectID)>
	<cfset SetVariable("caller.#attributes.r_ObjectId#", listgetat(lObjectIds,1))>
</cfif>

<cfif len(attributes.r_lObjectIds)>
	<cfset SetVariable("caller.#attributes.r_lObjectIds#", lObjectIds)>
</cfif>

<cfif len(attributes.r_stObjects)>
	<q4:contentobjectGetMultiple lObjectIds="#lObjectIds#" r_stObjects="stObjects" typename="#application.packagepath#.types.#attributes.typename#">
	<cfset SetVariable("caller.#attributes.r_stObjects#", stObjects)>
</cfif>

<cfif len(attributes.r_stObject)>
	<cfif listlen(lObjectIds)>
		<q4:contentobjectGet ObjectId="#listgetat(lObjectIds,1)#" r_stObject="stObject">
	<cfelse>
		<cfset stObject=structnew()>
	</cfif>
	<cfset SetVariable("caller.#attributes.r_stObject#", stObject)>
</cfif>

<cfsetting enablecfoutputonly="No">