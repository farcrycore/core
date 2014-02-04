<cfcomponent extends="types" displayname="Queued Task" output="false" hint="Tasks queued for background processing" 
	bRefObjects="false" 
	bArchive="false" 
	bObjectBroker="false"
	bFriendly="false" 
	bAudit="false"
	bSystem="true"
	icon="fa-cogs">
	
	<cfproperty name="objectid" ftLabel="Task ID" 
		ftDisplayMethod="ftDisplayUUID" />
	
	<cfproperty name="jobType" type="string" required="false" default="Unkown"
		ftSeq="1" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Job Type"
		ftDisplayOnly="true" dbIndex="getStatus:1" />
	
	<cfproperty name="jobID" type="uuid" required="false"
		ftSeq="2" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Job ID"
		ftDisplayOnly="true" ftDisplayMethod="ftDisplayUUID"
		dbIndex="byJobID:1,getStatus:2" />

	<cfproperty name="action" type="string" required="false"
		ftSeq="3" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Action"
		ftDisplayOnly="true" />
	
	<cfproperty name="taskOwnedBy" type="string" required="false"
		ftSeq="4" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Owned By"
		ftDisplayOnly="true" dbIndex="getStatus:3" />
	
	<cfproperty name="wddxDetails" type="longchar" required="false"
		ftSeq="5" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Details"
		ftDisplayOnly="true" ftDisplayMethod="displayWDDX" />

	<cfproperty name="wddxStackTrace" type="longchar" required="false"
		ftSeq="6" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Stack trace"
		ftDisplayOnly="true" ftDisplayMethod="displayWDDX" />

	<cfproperty name="taskStatus" type="string" required="false"
		ftSeq="7" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Status"
		ftType="list" ftList="queued:Queued,processing:Processing"
		ftDisplayOnly="true" dbIndex="getStatus:4" />

	<cfproperty name="taskTimestamp" type="date" required="false" 
		ftSeq="8" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Timestamp"
		ftType="datetime" ftDefaultType="Evaluate" ftDefault="now()" 
		ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" 
		ftShowTime="true"
		ftDisplayOnly="true"
		dbIndex="true" />

	<cfproperty name="threadID" type="uuid" required="false"
		ftSeq="9" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Thread"
		ftDisplayOnly="true" />
	
	
	<cffunction name="ftDisplayUUID" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var colourisable = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif len(arguments.stMetadata.value)>
			<cfset colourisable = rereplace(arguments.stMetadata.value,"[^\dABCDEF]","","ALL") />
			<cfset colourisable = colourisable & left(colourisable,6 - len(colourisable) mod 6) />
			
			<skin:loadJS id="fc-jquery" />
			
			<cfsavecontent variable="html"><cfoutput>
				<table cellpadding="0" cellspacing="0" onclick="$j('###arguments.fieldname#details').toggle()" style="cursor:pointer;font-size:13px;">
					<tr>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,1,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,7,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,13,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,19,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,25,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,31,6)#;padding: 7px 7px 6px;"></td>
					</tr>
				</table>
				<span id="#arguments.fieldname#details" style="display:none;">#arguments.stMetadata.value#</span>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset html = "N/A" />
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="ftDisplayTaskOwnedBy" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var stProfile = "" />
		
		<cfif len(arguments.stMetadata.value)>
			<cfset stProfile = application.fapi.getContentType(typename="dmProfile").getProfile(username=arguments.stMetadata.value) />
			
			<cfsavecontent variable="html"><cfoutput>
				<cfif len(stProfile.firstname) or len(stProfile.lastname)><span title="#arguments.stMetadata.value#">#stProfile.firstname# #stProfile.lastname#</span><cfelse>#arguments.stMetadata.value#</cfif>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset html = "Anonymous" />
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="displayWDDX" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif len(arguments.stMetadata.value)>
			<skin:loadJS id="fc-jquery" />
			
			<cfsavecontent variable="html"><cfoutput>
				<a href="##" onclick="$j('###arguments.fieldname#details').toggle(); return false;">show / hide details</a>
				<div id="#arguments.fieldname#details" style="display:none;"><cfdump var="#arguments.stMetadata.value#"></div>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset html = "None" />
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="ftDisplayThreadID" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var colourisable = "" />
		<cfset var stInfo	= '' />
		
		<cfif len(arguments.stMetadata.value)>
			<cfset colourisable = rereplace(mid(arguments.stMetadata.value,8,36),"[^\dABCDEF]","","ALL") />
			<cfset colourisable = colourisable & left(colourisable,6 - len(colourisable) mod 6) />
			
			<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
			
			<skin:loadJS id="fc-jquery" />
			
			<cfsavecontent variable="html"><cfoutput>
				<table cellpadding="0" cellspacing="0" onclick="$j('###arguments.fieldname#details').toggle()" style="cursor:pointer;">
					<tr>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,1,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,7,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,13,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,19,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,25,6)#;padding: 7px 7px 6px;"></td>
						<td width="8px" height="8px" style="background-color:###mid(colourisable,31,6)#;padding: 7px 7px 6px;"></td>
					</tr>
				</table>
				<div id="#arguments.fieldname#details" style="display:none;">
					<cfif isdefined("application.fc.lib.tasks.threads.#arguments.stMetadata.value#")>
						<cfset stInfo = duplicate(application.fc.lib.tasks.threads[arguments.stMetadata.value]) />
						
						Thread was created at #timeformat(stInfo.created,'hh:mmtt')#, #dateformat(stInfo.created,'d mmm yyyy')# (#application.fapi.prettyDate(stInfo.created)# ago).<br>
						
						<cfif isdefined("stInfo.task.objectid") and stInfo.task.objectid eq arguments.stObject.objectid>
							Processing on this task began at #timeformat(stInfo.timestamp,'hh:mmtt')#, #dateformat(stInfo.timestamp,'d mmm yyyy')# (#application.fapi.prettyDate(stInfo.timestamp)# ago).
						<cfelse>
							Processing on this task has finished.
						</cfif>
					<cfelse>
						Thread has stopped
					</cfif>
				</div>
			</cfoutput></cfsavecontent>
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
</cfcomponent>