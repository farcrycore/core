<cfcomponent displayname="Queue Result" hint="Result for a background task" extends="types" output="false"
	bRefObjects="false" 
	bArchive="false" 
	bObjectBroker="false"
	bFriendly="false" 
	bAudit="false"
	bSystem="true"
	icon="fa-cogs">
	
	<cfproperty name="taskID" type="string" required="false" 
		ftSeq="1" ftWizardStep="Task Result" ftFieldset="Task Result" ftLabel="Task" 
		ftDisplayOnly="true" ftDisplayMethod="ftDisplayUUID">

	<cfproperty name="jobType" type="string" required="false" default="Unknown"
		ftSeq="2" ftWizardStep="Queued Task" ftFieldset="Queued Task" ftLabel="Job Type"
		ftDisplayOnly="true" dbIndex="getStatus:1" />
	
	<cfproperty name="jobID" type="uuid" required="false" 
		ftSeq="3" ftWizardStep="Task Result" ftFieldset="Task Result" ftLabel="Job" 
		ftDisplayOnly="true" ftDisplayMethod="ftDisplayUUID"
		dbIndex="byJobID:1,getStatus:2" />

	<cfproperty name="taskOwnedBy" type="string" required="false" 
		ftSeq="4" ftWizardStep="Task Result" ftFieldset="Task Result" ftLabel="Owned By" 
		ftDisplayOnly="true" dbIndex="getStatus:3" />

	<cfproperty name="wddxResult" type="longchar" required="false" 
		ftSeq="5" ftWizardStep="Task Result" ftFieldset="Task Result" ftLabel="Details" 
		ftDisplayOnly="true">

	<cfproperty name="resultTimestamp" type="date" required="false" 
		ftSeq="6" ftWizardStep="Task Result" ftFieldset="Task Result" ftLabel="Timestamp" 
		ftType="datetime" ftDefaultType="Evaluate" ftDefault="now()" 
		ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftShowTime="true" ftDisplayOnly="true" 
		dbIndex="true">
		
	<cfproperty name="resultTick" type="numeric" required="false" default="0" dbPrecision="15,0"
		ftLabel="Tick" hint="Used for ordering when timestamps are identical"
		dbIndex="byJobID:2" />
	
	
	<cffunction name="getColourHash" access="public" output="false" returntype="string" hint="Return a colour hash table for a specified UUID">
		<cfargument name="id" type="uuid" required="true" />
		<cfargument name="cellpadding" type="string" required="false" default="0" />
		<cfargument name="cellspacing" type="string" required="false" default="0" />
		<cfargument name="style" type="string" required="false" default="display:inline;font-size:13px;" />
		<!--- extra arguments are added as table attributes --->
		
		<cfset var colourisable = rereplace(arguments.id,"[^\dABCDEF]","","ALL") />
		<cfset var attrs = "" />
		<cfset var thisattr = "" />
		<cfset var html = "" />
		
		<cfset colourisable = colourisable & left(colourisable,6 - len(colourisable) mod 6) />
		
		<cfloop collection="#arguments#" item="thisattr">
			<cfset attrs = listappend(attrs,"#lcase(thisattr)#='#arguments[thisattr]#'"," ") />
		</cfloop>
		
		<cfsavecontent variable="html"><cfoutput>
			<table #attrs#>
				<tr>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,1,6)#;padding: 7px 7px 6px;"></td>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,7,6)#;padding: 7px 7px 6px;"></td>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,13,6)#;padding: 7px 7px 6px;"></td>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,19,6)#;padding: 7px 7px 6px;"></td>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,25,6)#;padding: 7px 7px 6px;"></td>
					<td width="8px" height="8px" style="background-color:###mid(colourisable,31,6)#;padding: 7px 7px 6px;"></td>
				</tr>
			</table>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
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
				#getColourHash(id=arguments.stMetadata.value,onclick="$j('###arguments.fieldname#details').toggle()",style="cursor:pointer;font-size:13px;")#
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
	
	<cffunction name="ftDisplayWDDXResult" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif len(arguments.stMetadata.value)>
			<skin:loadJS id="fc-jquery" />
			
			<cfsavecontent variable="html"><cfoutput>
				<a href="##" onclick="$j('###arguments.fieldname#details').toggle();return false;">show / hide details</a>
				<div id="#arguments.fieldname#details" style="display:none;"><cfdump var="#arguments.stMetadata.value#"></div>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset html = "None" />
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
</cfcomponent>