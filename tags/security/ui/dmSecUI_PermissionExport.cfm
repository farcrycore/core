<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	stPolicyStore = oAuthorisation.getPolicyStore();
</cfscript>

<cfquery name="qExport" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
SELECT * FROM #application.dbowner#dmPermission
</cfquery>

<cfset filename="permissions.wddx">

<cfoutput>

<CFHEADER NAME="content-disposition" VALUE="inline; filename=#filename#">
<cfcontent type="application/unknown" reset="yes">

<cfwddx action="CFML2WDDX" input="#qExport#" usetimezoneinfo="No">
<cfabort>
</cfoutput>

<cfsetting enablecfoutputonly="No">