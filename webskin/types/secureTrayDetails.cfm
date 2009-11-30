<cfsetting enablecfoutputonly="true" />

<!--- 
@@displayName: Tray Details
@@description: The summary details of an object that are shown in the system tray.
 --->

<cfoutput>
<dl>	
	<dt>Label</dt>
	<dd>#stobj.label#</dd>
	
	<dt>View</dt>
	<dd>#application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.view)#</dd>
	
	<dt>Body View</dt>
	<dd>#application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.bodyView)#</dd>
	
	<cfset stLastUpdatedBy = application.fapi.getContentType("dmProfile").getProfile(stobj.lastupdatedby) />
	<dt>#getI18Property('lastupdatedby','label')#</dt>
	<dd>#stLastUpdatedBy.Label# (#application.fapi.prettyDate(stobj.datetimelastupdated)#)</dd>
	
</dl>
</cfoutput>
		
		
<cfsetting enablecfoutputonly="false" />