

<cfcomponent name="field" displayname="datetime" hint="Field component to liase with all datetime types"> 
		
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.datetime" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftStyle" default="width:160px;">
		<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd mmm yyyy">
		<cfparam name="arguments.stMetadata.ftTimeFormatMask" default="hh:mm tt">
		<cfparam name="arguments.stMetadata.ftCalendarFormatMask" default="%d %b %Y %I:%M %p">
		<cfparam name="arguments.stMetadata.ftToggleOffDateTime" default="0">
		
		<cfset Request.InHead.Calendar = 1>
		
		<cfif arguments.stMetadata.ftToggleOffDateTime>
			<cfset Request.InHead.ScriptaculousEffects = 1>

			
			<cfsavecontent variable="ToggleOffDateTimeJS">
				<cfoutput>
					<script language="javascript">
					function toggle#arguments.fieldname#(){
						//if ($('#arguments.fieldname#include').checked == false) {
						//	$('#arguments.fieldname#include').checked = true;	
						//}
						//else {
						//	$('#arguments.fieldname#include').checked = false;		
						//}
						Effect.toggle('#arguments.fieldname#','appear');
						Effect.toggle('#arguments.fieldname#DatePicker','appear');
						//return true;
					}
					

					</script>
				</cfoutput>
			</cfsavecontent>
			
			<cfhtmlhead text="#ToggleOffDateTimeJS#">
		</cfif>
			

		<cfif len(arguments.stMetadata.value) AND DateDiff('yyyy', now(), arguments.stMetadata.value) GT 100>
			<cfset datetimefieldvisible = 0>
			<cfset datetimefieldvisibletoggletext = "show...">
			<cfset arguments.stMetadata.ftStyle = "#arguments.stMetadata.ftStyle#;display:none;">
		<cfelse>
			<cfset datetimefieldvisible = 1>
			<cfset datetimefieldvisibletoggletext = "remove...">
		</cfif>		

		
		<cfsavecontent variable="html">
			<cfoutput>
				<cfif arguments.stMetadata.ftToggleOffDateTime>
					<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1" onclick="javascript:toggle#arguments.fieldname#();" <cfif datetimefieldvisible>checked="true"</cfif> >
					<input type="hidden" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="0">
				<cfelse>
					<input type="hidden" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1">
				</cfif>	
				<input type="Text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)# #TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeFormatMask)#" style="#arguments.stMetadata.ftstyle#" />
				<a id="#arguments.fieldname#DatePicker" <cfif datetimefieldvisible EQ 0>style="display:none;"</cfif>><img src="#application.url.farcry#/js/DateTimePicker/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>
				
				
				<script type="text/javascript">
				  Calendar.setup(
				    {
					  inputField	: "#arguments.fieldname#",         // ID of the input field
				      ifFormat		: "#arguments.stMetadata.ftCalendarFormatMask#",    // the date format
				      button		: "#arguments.fieldname#DatePicker",       // ID of the button
				      showsTime		: true
				    }
				  );
				</script>				
			
				
					
				
			</cfoutput>
		</cfsavecontent>		
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftDateMask" default="d-mmm-yy">
		<cfparam name="arguments.stMetadata.ftTimeMask" default="short">
		<cfparam name="arguments.stMetadata.ftShowTime" default="false">
		
		<cfsavecontent variable="html">
			<cfif len(arguments.stMetadata.value)>
				<cfoutput>#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateMask)#</cfoutput>
				<cfif arguments.stMetadata.ftShowTime>
					<cfoutput> #TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeMask)# </cfoutput>
				</cfif>				
			</cfif>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfparam name="stFieldPost.stSupporting.Include" default="true">
		
		<cfif ListGetAt(stFieldPost.stSupporting.Include,1)>
		
			<cfif len(trim(arguments.stFieldPost.Value))>
				<cfset stResult.value = CreateODBCDateTime("#arguments.stFieldPost.Value#")>
			<cfelse>
				<cfset stResult.value = "">
			</cfif>
			
		<cfelse>
			<cfset stResult.value = CreateODBCDateTime("#DateAdd('yyyy',200,now())#")>
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 


<!--- 			db.boolean = "INT";
			db.date = "DATETIME";
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "LONGTEXT";	
			 --->