<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/admin/" prefix="admin">

<admin:header title="Verity: Build Indices">

<cfscript>
oConfig = createObject("component", "#application.packagepath#.farcry.config");
if (NOT isDefined("application.config.verity"))
	application.config.verity = oConfig.getConfig("verity");
stCollections = application.config.verity.contenttype;
</cfscript>		

<!--- get system Verity information --->		
<cffile action="READ" variable="wVerityMX" file="C:\CFusionMX\lib\neo-verity.xml">
<cfwddx action="WDDX2CFML" input="#wVerityMX#" output="verityMX">

<!--- <cfdump var="#verityMX#">
<cfabort> --->

<!--- build indices... --->
<cfoutput><h3>Building Collections</h3></cfoutput>
<cfloop collection="#stCollections#" item="key">

	<!--- does the collection exist? --->
	<cfif NOT structKeyExists(veritymx[3], key)>
		<!--- if not, create colection --->
		<cfoutput>Creating #key#...<br></cfoutput>
		<cfflush />
		<cfcollection action="CREATE" collection="#key#" path="C:\CFusionMX\verity\collections" language="English">
		<!--- clear lastupdated, if it exists --->
		<cfset structDelete(stCollections[key], "lastupdated")>
	</cfif>

	<!--- build index --->
	<cfquery datasource="#application.dsn#" name="q">
	SELECT *
	FROM #key#
	WHERE 1 = 1
	<cfif structKeyExists(stCollections[key], "lastupdated")>
		AND datetimelastupdated > #stCollections[key].lastupdated#
	</cfif>
	<cfif structKeyExists(application.types[key].stProps, "status")>
		AND status = 'approved'
	</cfif>
	</cfquery>
	
	<cfoutput>Updating #q.recordCount# records for #key#...(#arrayToList(application.config.verity.contenttype[key].aprops)#)<br></cfoutput>
	<cfflush />
	<cfindex action="UPDATE" query="q" body="#arrayToList(application.config.verity.contenttype[key].aprops)#" key="objectid" title="label" collection="#key#">
	
	<!--- update config file with lastupdated --->
	<cfset stCollections[key].lastupdated = now()>
</cfloop>

<cfscript>
application.config.verity.contenttype = stCollections;
oConfig.setConfig(configName="verity",stConfig=application.config.verity);
</cfscript>

<cfoutput>
<p>Verity config updated.</p>
<p>All done.</p>
</cfoutput>

<admin:footer>
<cfsetting enablecfoutputonly="No">

