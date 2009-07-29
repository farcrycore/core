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
	
	<cfif stobj.locked>
		<dt>Locked:</dt>
		<dd>
			<span style='color:red'>#application.rb.formatRBString("workflow.labels.lockedwhen@label",tDT,"Locked ({1})")#</span>
			
			<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
			#application.rb.formatRBString('workflow.labels.lockedby@label',subS,'<span style=\"color:red\">Locked ({1})</span> by {2}')#
			
			<cfif application.fapi.getCurrentUsersProfile().userID EQ stobj.lockedby OR iDeveloperPermission>
				<a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='alert("TODO: Unlocking");return false;'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>
			</cfif>
			
		</dd>
	</cfif>
	
	<dt>#getI18Property('datetimelastupdated','label')#</dt>
	<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
	
	<dt>#getI18Property('lastupdatedby','label')#</dt>
	<dd>#stobj.lastupdatedby#</dd>
	
	<cfif structkeyexists(stObj,"status")>
		<dt>#getI18Property('Status','label')#</dt>
		<dd>#application.rb.getResource('workflow.constants.#stobj.status#@label',stObj.status)#</dd>
	</cfif>
	
	
</dl>
</cfoutput>
		
		
<cfsetting enablecfoutputonly="false" />