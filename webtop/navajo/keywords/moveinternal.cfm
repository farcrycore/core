<cfprocessingDirective pageencoding="utf-8">

<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm" />

<cfparam name="url.objectId" />
<cfparam name="url.direction" />

<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
	<cfset qparentObject = application.factory.oTree.getParentID(objectid=url.objectid,dsn=application.dsn) />
	<cfset parentObjectID = qParentObject.parentid />
	<cfset qGetChildren = application.factory.oTree.getChildren(dsn=application.dsn,objectid=parentObjectID) />
	<cfset bottom = qGetChildren.recordCount />
	<cfloop query="qGetChildren">
		<cfif qGetChildren.objectid[currentrow] eq url.objectID>
			<cfset thisPosition = currentrow />
			<cfbreak />
		</cfif>
	</cfloop>
	
	<!--- get the new position --->
	<cfif url.direction is "up" AND thisPosition NEQ 1>
		<cfset newPosition = thisPosition - 1 />
	<cfelseif url.direction is "down" AND thisPosition LT bottom>
		<cfset newPosition = thisPosition + 1 />
	<cfelseif url.direction is "top">
		<cfset newPosition = 1 />
	<cfelseif url.direction eq "bottom">
		<cfset newPosition = bottom />
	</cfif>
	
	<!--- make the move	--->
	<cfset application.factory.oTree.moveBranch(dsn=application.dsn,objectid=url.objectid,parentid=parentobjectid,pos=newposition) />
	<farcry:logevent objectid="#url.objectid#" type="categorisation" event="movenode" notes="object moved to child position #newposition#" />
</cflock>

<cfoutput>
<script type="text/javascript">
	parent.location.reload();
</script>
</cfoutput>