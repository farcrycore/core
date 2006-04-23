<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	stResult = request.dmsec.oAuthorisation.reInitPermissionsCache();
	
</cfscript>
 <cfdump var="#stResult#"> 