<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfimport taglib="/fourq/tags/" prefix="q4">

<cfsetting enablecfoutputonly="Yes">


<!---
Guilty Parties : Nick Shearer (nick@daemon.com.au)
DAte : 13th November 2000

Description: moves a navigation node up or down

Usage
-----
takes objectID
	
Details
-------
checks the status of the current node, 

Revisions
---------
 --->

<cfparam name="url.objectId">
<cfparam name="url.direction">

<cfoutput>
<html>
<body>
<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>

<q4:contentobjectget objectId="#url.objectId#" r_stObject="stobj">

<cfscript>
	typename = stObj.typename;
</cfscript>

<!--- check permission to move --->
<nj:GetNavigation objectId="#url.objectId#" r_objectId="navid">

<cf_dmSec2_PermissionCheck
	reference1="dmNavigation"
	permissionName="Edit"
	objectid="#navid#"
	r_iState="iState">
	
<cfoutput>
	#URL.direction#
</cfoutput>	

	
<cfif iState neq 1>	
	<cfoutput><script>alert("You do not have permission to modify the node.");</script></cfoutput>
<cfelse>
	<!--- get the parent node --->
	<nj:TreeGetRelations
		get="parents"
		typename="#stObj.typename#"
		bInclusive="0"
		objectId="#stobj.objectId#"
		r_lObjectIds="navIdParent"
		r_stObject="stNavParent"
		>
		<!--- <nj:TreeGetRelations typename="#srcObj.typename#" objectId="#URL.srcObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1"> --->
	<cfif len(navIdParent)>
		<cfif stObj.typename IS "dmNavigation">
		

		<!--- get the number of children at this level --->
		<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetChildren">
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
			<cfinvokeargument name="objectid" value="#navIDParent#"/>
		</cfinvoke>
		<cfset bottom = qGetChildren.recordCount>
		<!--- Find the current position in the tree --->
		<cfloop query="qGetChildren">
			<cfif qGetChildren.objectID IS URL.objectID>
				<cfset thisPosition = qGetChildren.currentrow>
				<cfbreak>
			</cfif> 
		</cfloop> 
		<!--- lets get the new position  --->
		<cfscript>
			if( url.direction EQ "up" AND thisPosition NEQ 1)
				newPosition = thisPosition - 1;
			else if( url.direction eq "down" AND thisPosition LT bottom)
				newPosition = thisPosition + 1;
			else if ( url.direction eq "top" )
				newPosition = 1;
			else if( url.direction eq "bottom" )	
				newPosition = bottom;
		</cfscript>
		<!--- Now do the Move - ya jackass!! --->
		
		<cfinvoke component="fourq.utils.tree.tree" method="moveBranch" returnvariable="moveBranchRet">
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
			<cfinvokeargument name="objectid" value="#URL.objectID#"/>
			<cfinvokeargument name="parentid" value="#navIDParent#"/>
			<cfinvokeargument name="pos" value="#newPosition#"/>
		</cfinvoke>
		
			<nj:UpdateTree objectId="#navIDParent#">
		
		
		<cfelse>
		<cfscript>
		if( stobj.typename IS "dmNavigation") 
			key = "aNavChild"; else key = "aObjectIds";
		
		// find the position of the object within the parent that we are moving 
		pos = ListFind(ArrayToList(stNavParent[key]), stobj.objectID);
	
		//  find the objects new position 
		if( url.direction EQ "up" AND pos NEQ 1)
		{
			newPos = pos - 1;
			arraySwap( stNavParent[key], pos, newPos );
		}
		else if( url.direction eq "down" AND (pos lt ArrayLen(stNavParent[key])) )
		{
			newPos = pos + 1;
			arraySwap( stNavParent[key], pos, newPos );
		}
		else if ( url.direction eq "top" )
		{
			newPos = 1;
			arrayDeleteAt( stNavParent[key], pos );
			arrayInsertAt( stNavParent[key], newPos, url.objectID );
		}
		else if( url.direction eq "bottom" )
		{
			arrayDeleteAt( stNavParent[key], pos );
			arrayAppend( stNavParent[key], url.objectID );
		}
		</cfscript>
		</cfif>
		<cfscript>
			stNavParent.datetimecreated = createODBCDate("#datepart('yyyy',stNavParent.datetimecreated)#-#datepart('m',stNavParent.datetimecreated)#-#datepart('d',stNavParent.datetimecreated)#");
			stNavParent.datetimelastupdated = createODBCDate(now());
	</cfscript>
		<!--- update the parent object --->
		<q4:contentobjectdata objectid="#stNavParent.objectID#"	
	typename="#application.packagepath#.types.#stNavParent.typename#" stProperties="#stNavParent#">
		
		<!--- <cfa_contentobjectData objectId="#stNavParent.objectId#">
			<cfa_contentobjectproperty name="#key#" value="#stNavParent[key]#">
		</cfa_contentobjectData> --->
		
		<!--- update the tree frame --->
		<nj:UpdateTree objectId="#navid#" complete="0">
	</cfif>
</cfif>

<cfoutput>
<script>window.close();</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">