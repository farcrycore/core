<cfimport taglib="/fourq/tags" prefix="q4">

<cfsetting enablecfoutputonly="No">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/treeGetRelations.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 
Takes an object and gets it relations.

Relies upon the deployment of NTM stored procs and fourq.utils.tree.tree component

|| USAGE ||
<nj:TreeGetRelations
	objectId="0"
	get="Children"
	r_lObjectIds="lObjectIds"
	bInclusive="1">

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [attributes.objectId]: objectId to work from
-> [attributes.get]: what type of relationship to get [ ancestors, children, descendants ] 
                     where:
                          ancestors are all the parent nodes with child this
						  children are first level descendants of aNavChidlren
						  descendants are all nodes under objectId using aNavChidlren
						  parents... (what is this? how is it different to ancestors?)
						  root... (new for farcry, gets rootnode for typename)
-> [attributes.typename] typename for tree
-> [attributes.bInclusive]: whether to include the current node
<- [attributes.r_stObjects]: Objects found as structure
<- [attributes.r_lObjectIds]: Objects found as list of ids

|| HISTORY ||
$Log: treeGetRelations.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.8  2002/09/16 06:28:09  geoff
updated deprecated application.fourq.packagpath with application.packagepath

Revision 1.7  2002/09/10 04:53:47  geoff
no message

Revision 1.6  2002/08/23 00:36:52  geoff
no message

Revision 1.5  2002/08/22 00:09:38  geoff
no message

Revision 1.4  2002/07/18 04:39:44  geoff
no message

Revision 1.3  2002/07/16 07:24:48  geoff
*** empty log message ***

Revision 1.2  2002/07/09 04:36:41  geoff
no message

Revision 1.1.1.1  2002/06/27 07:30:11  geoff
Geoff's initial build


|| END FUSEDOC ||
--->

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
	<cfinvoke component="fourq.utils.tree.tree" method="getRootNode" typename="#attributes.typename#" returnvariable="qRoot">
<!--- <cfdump var="#qRoot#"> --->
<cfset lObjectIds = qRoot.ObjectID>
</cfif>

<cfif attributes.get eq "children">
<!--- 
TODO
not too elegant
need to call tag or fourq function that has status as an option somehow
--->
<cfif attributes.typename is "dmNavigation">
	<cfinvoke component="fourq.utils.tree.tree" method="getChildren" objectid="#attributes.objectid#" returnvariable="qChildren">
<cfelse>	
	
	<cfquery name="qChildren" datasource="#application.dsn#">
		select a.data AS objectID, b.title AS objectname from #attributes.typename#_aObjectIds a
		JOIN #attributes.typename# b ON a.data = b.objectID
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
	SELECT objectid FROM #attributes.typename#
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
	<cfinvoke component="fourq.utils.tree.tree" method="getAncestors" objectid="#attributes.objectid#" returnvariable="qAncestors" typename="dmNavigation">
	<!--- <cfdump var="#qAncestors#" label="qAncestors"> --->
	<cfset lobjectIDs="#ValueList(qAncestors.objectid)#">

<!--- 	<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Not implemented yet, get='#attributes.get#'.">
	<!--- ancestors --->
	<cfset thisObjectId = attributes.objectId>
	<cfset recordCount=1>
	
	<cfloop condition="recordCount eq 1">
		<!--- loop while get navchildren has nav parent, sql --->
		<cfquery name="qGetParent" datasource="#request.cfa.datasource.dsn#">
			SELECT p1.objectId FROM properties p1, properties p2
			WHERE p1.objectId = p2.objectId
				AND (p1.propertyname like 'ANAVCHILD%' OR p1.propertyname like 'AOBJECTIDS%')
				AND p1.chardata = <cfqueryparam value="#thisObjectId#" cfsqltype="CF_SQL_VARCHAR">
				AND p2.propertyname = 'VERSIONID'
				AND p2.chardata is NULL
		</cfquery>
		
		<cfif qGetParent.recordCount eq 0>
		<cfquery name="qGetParent" datasource="#request.cfa.datasource.dsn#">
		SELECT p1.objectId FROM properties p1
			WHERE (p1.propertyname like 'ANAVCHILD%' OR p1.propertyname like 'AOBJECTIDS%')
				AND p1.chardata = <cfqueryparam value="#thisObjectId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		</cfif>
	
		<!--- throw spaz if more than one parent, ordered by level--->
		<cfif qGetParent.recordCount gt 1>
			<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Object has more than one parent, objectId='#attributes.objectId#'.">
		</cfif>
		
		<cfset thisObjectId = qGetParent.objectId>
		
		<cfset lObjectIds=ListAppend(lObjectIds, thisObjectId)>
		
		<cfset recordCount=qGetParent.recordCount>
	</cfloop>
 --->	
	<cfelseif attributes.get eq "descendants">
	<!--- descendants --->
	<!--- loop while get children, non ordered list/stobjects --->
	
		<cfinvoke  component="fourq.utils.tree.tree" method="getDescendants" returnvariable="getDescendantsRet">
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
		<cfinvokeargument name="objectid" value="#attributes.objectid#"/>
	</cfinvoke>
	<cfset lObjectIds = valueList(getDescendantsRet.objectID)>
	<cfelseif attributes.get eq "parents">
	<cfif attributes.typename is "dmNavigation">
		<!--- TODO - invocation of getParentID is barfing.  Ask geoff if ok to mod stored proc. 
		Do cfquery  for time being --->
<!--- 		<cfinvoke component="fourq.utils.tree.tree" method="getParentID" objectid="#attributes.objectid#" returnvariable="qGetParent"> --->
		<cfquery name="qGetParent" datasource="#application.dsn#">
			select  parentid AS objectID from nested_tree_objects 
		    where objectid  = '#attributes.objectid#'
		</cfquery>	
	<cfelse>	
		<!--- TODO - MAJOR hack here.  --->
		<!--- This is the list of #typename#_aObjectIds tables that we look
		 for the parent. This list is in ascending search order --->
		<cfset searchList = "dmNavigation,dmHTML">
		<cfset loop = true>
		<cfset listIndex = 1>
		<cfloop condition="loop">
				
			<cfquery name="qGetParent" datasource="#application.dsn#">
				SELECT objectID FROM #listGetAt(searchlist,listIndex)#_aObjectIds 
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
			
	
	<!--- parents OLD CODE--->
<!--- 	<cfquery name="qGetParent" datasource="#request.cfa.datasource.dsn#">
		SELECT p1.objectId FROM properties p1, properties p2
			WHERE p1.objectId = p2.objectId
				AND (p1.propertyname like 'ANAVCHILD%' OR p1.propertyname like 'AOBJECTIDS%')
				AND p1.chardata = <cfqueryparam value="#attributes.objectId#" cfsqltype="CF_SQL_VARCHAR">
				AND p2.propertyname = 'VERSIONID'
				AND p2.chardata is NULL
	</cfquery>
	
	<cfif qGetParent.recordCount eq 0>
		<cfquery name="qGetParent" datasource="#request.cfa.datasource.dsn#">
		SELECT p1.objectId FROM properties p1
			WHERE (p1.propertyname like 'ANAVCHILD%' OR p1.propertyname like 'AOBJECTIDS%')
				AND p1.chardata = <cfqueryparam value="#attributes.objectId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
 --->
 	<!--- throw spaz if more than one parent, ordered by level--->
	<cfif qGetParent.recordCount gt 1>
		<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Object has more than one parent, objectId='#attributes.objectId#'.">
	</cfif>
	
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