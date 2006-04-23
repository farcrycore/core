<cfsetting enablecfoutputonly="Yes">
<cfimport prefix="q4" taglib="/fourq/tags">
<!--- 
Don't run if intialising app
TODO
work out a better way than a harcoded variable for app initialisation!!!
 --->
<Cfif not isDefined("request.init") OR request.init eq 0>

<!--------------------------------------------------------------------
inialise all types structure
 - for typeid mapping
--------------------------------------------------------------------->
<!--- 
This is now defunct as it depends on Spectra type structure... what we need for fourq is the ability to determine the object typenames...  in fact this is the same as saying application.sttypes.dmEvents.. as you now specify simply dmEvents...

<!--- code to find all the types in this application --->
<cfif (isDefined("url.updateapp") AND url.updateapp) or not isDefined("application.stTypes")>
	<!--- find types... --->
	<cfa_objectTypeGetMultiple dataSource = "#request.cfa.datasource.dsn#"
		bRefreshCache = "1" bUseCache = "YES" r_stTypes = "stTypes">
		
	<!--- filter out all system types --->
	<cfloop collection="#stTypes#" item="id">
		<cfset bSystemType = BitMaskRead( stTypes[id].nSysAttributes, 1, 1 )>
		<cfif bSystemType>
			<cfset StructDelete( stTypes, id )>
		</cfif>
	</cfloop>
	
	<cfset application.stTypes = duplicate(stTypes)>
</cfif>
 --->

<!--------------------------------------------------------------------
Get the news hierachy id 
 - for daemon NewsRule
--------------------------------------------------------------------->
<!--- 
Defunct as Metadata is no longer built into multiple hierarchies...


<cfa_contentobjectgetmultiple
	typeid="EE70E6E3-B7B9-11D2-86C500C04FA3589C" bactiveonly="False"
	r_stobjects="stObjects" dtTypeCacheTimeout="#createtimespan(0,0,0,0)#">

<cfscript>
for( id in stObjects )
{
	application.daemon_news.newshierarchyid = id;
	if(stObjects[id].label eq "News") break;
}
</cfscript>
 --->
 
<!--------------------------------------------------------------------
Build NavIDs from Navigation Nodes 
--------------------------------------------------------------------->
<!--- 
TODO
Need an alternative to this ugly nav node lookup
--->
<!--- set up requested navid's application.navIds --->
<cfquery datasource="#application.dsn#" name="qNavIDs">
SELECT objectID FROM dmNavigation
</cfquery>
<cfset lobjectids=valueList(qNavIDs.objectid)>
<q4:contentobjectgetmultiple
	typeid="dmNavigation"
	typename="dmNavigation"
	lObjectIDs="#lobjectids#"
	r_stobjects="stNavNodes">

<cfscript>
	application.navid = StructNew();
	
	for(navId in stNavNodes)
	{
		if(StructKeyExists(stNavNodes[navid],"lNavIdAlias") and len(stNavNodes[navid].lNavIdAlias))
		{
			for( i=1; i le ListLen(stNavNodes[navid].lNavIdAlias); i=i+1 )
			{
				alias = Trim(ListGetAt(stNavNodes[navid].lNavIdAlias,i));
				if( not StructKeyExists( Application.navId, alias ) ) application.navid[alias] = navId;
						else application.navid[alias] = ListAppend(application.navid[alias], navId);
			}
		}
	}
</cfscript>

<!--------------------------------------------------------------------
inialise all permission types
 - for daemon Security Model
--------------------------------------------------------------------->
<cf_dmSec_PermissionGetMultiple r_aPermissions="aPerms">

<cfset Application.Permission = StructNew()>

<cfloop from="1" to="#ArrayLen(aPerms)#" index="i">
	<cfset perm=aPerms[i]>
	<cfif not StructKeyExists( application.permission, perm.permissionType )>
		<cfset application.permission[perm.permissionType] = StructNew()>
	</cfif>
	
	<cfset temp = application.permission[perm.permissionType]>
	<cfset temp[perm.permissionName] = duplicate(perm)>
</cfloop>

</cfif>

<cfsetting enablecfoutputonly="No">