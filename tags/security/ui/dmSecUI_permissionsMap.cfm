<cfoutput>
<style type="text/css" >
	UL { /*list-style-type: none;list-style-image: url(#application.url.farcry#/images/treeImages/crystalIcons/NavApproved.gif)*/ }
</style>
</cfoutput>

<cffunction name="isPermissionsSet" hint="checks whether permissions are set in the permmision barnacle.">
	<cfargument name="q" hint="This is assumed to be a query of dmPermissionBarnacle">
	<cfargument name="objectid">
	<cfset bPermsSet = false>
	<cfquery name="q" dbtype="query">
		SELECT * FROM arguments.q 
		WHERE reference1 = '#arguments.objectid#'
	</cfquery>
	<cfif q.recordcount>
		<cfset bPermsSet =true>
	</cfif>
	<cfreturn bPermsSet>
</cffunction>

<cfquery name="qPerms" datasource="#application.dsn#">
	SELECT * from dmPermissionBarnacle
</cfquery>

<cfscript>
	oTree = createObject("component","#application.packagepath#.farcry.tree");
	qDesc = oTree.getDescendants(objectid='#application.navid.root#',dsn=application.dsn,bIncludeSelf=1);
</cfscript>

<cfoutput><span class="formtitle">Permissions Map</span><p></cfoutput>
<cfscript>
	for (i = 1;i LTE qDesc.recordCount;i=i+1)
	{
		if (i EQ 1)
			writeoutput("<ul>");
		if (isPermissionsSet(qPerms,qDesc.objectid[i]))
			writeoutput("<li><a href='#application.url.farcry#/navajo/permissions.cfm?objectId=#qDesc.objectid[i]#'>#qDesc.objectname[i]#</a></li>");
		else			
			writeoutput("<li>#qDesc.objectname[i]#</li>");
		if (qDesc.nLevel[i+1] GT qDesc.nlevel[i])
			writeoutput("<ul>");
		else if (qDesc.nLevel[i+1] LT qDesc.nlevel[i] OR i EQ qDesc.recordCount)
		{	
			if (i NEQ qDesc.recordCount)
				ulCount = qDesc.nLevel[i] - qDesc.nLevel[i+1];	
			else 
				ulCount = 1;	
			writeoutput(repeatString('</UL>',ulCount));
		}	
			
	}		
			
</cfscript>

