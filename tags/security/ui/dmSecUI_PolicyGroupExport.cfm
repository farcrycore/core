<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	stPolicyStore = oAuthorisation.getPolicyStore();
</cfscript>

<cfquery name="qExport" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
SELECT * FROM #application.dbowner#dmPolicyGroup
</cfquery>

<cfset filename="policyGroups.wddx">

<cfoutput>

<CFHEADER NAME="content-disposition" VALUE="inline; filename=#filename#">
<cfcontent type="application/unknown" reset="yes">

<cfwddx action="CFML2WDDX" input="#qExport#" usetimezoneinfo="No">
<cfabort>
</cfoutput>

<cfsetting enablecfoutputonly="No">