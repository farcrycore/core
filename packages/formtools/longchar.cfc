<cfcomponent extends="field" name="longchar" displayname="longchar" hint="Used to liase with longchar type fields"> 
	
	<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.longchar" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var bfieldvisible = 0 />
		<cfset var fieldvisibletoggletext = "show..." />
		<cfset var fieldstyle = "" />
		<cfset var onkeyup = "" />
		<cfset var onkeydown = "" /> 
		
		<cfparam name="arguments.stMetadata.ftToggle" default="false">
		<cfparam name="arguments.stMetadata.ftStyle" default="">
		<cfparam name="arguments.stMetadata.ftLimit" default="0">
		
		<cfif arguments.stMetadata.ftToggle>
			<cfset Request.InHead.ScriptaculousEffects = 1>
			
			<cfif not len(arguments.stMetadata.value)>
				<cfset bfieldvisible = 0>
				<cfset fieldvisibletoggletext = "show...">
				<cfset fieldStyle = "display:none;">
			<cfelse>
				<cfset bfieldvisible = 1>
				<cfset fieldvisibletoggletext = "remove...">
				<cfset fieldStyle = "">
			</cfif>
								
			<skin:htmlHead>
				<cfoutput>
					<script language="javascript">
					var bfieldvisible#arguments.fieldname# = #bfieldvisible#;
					
					function toggle#arguments.fieldname#(){
							
						if (bfieldvisible#arguments.fieldname# == 0){
							Effect.BlindDown('#arguments.fieldname#DIV');
							$('#arguments.fieldname#includelabel').innerHTML = 'remove...';
							bfieldvisible#arguments.fieldname# = 1;
						} else {
							Effect.BlindUp('#arguments.fieldname#DIV');
							$('#arguments.fieldname#includelabel').innerHTML = 'show...';
							bfieldvisible#arguments.fieldname# = 0;
						}
						
						//return true;
					}					

					</script>
				</cfoutput>
			</skin:htmlHead>

		</cfif>
		
		<cfif CGI.HTTP_USER_AGENT contains "MSIE" or CGI.HTTP_USER_AGENT contains "gecko">
			<cfset bIsGoodBrowser = "1">
		<cfelse>
			<cfset bIsGoodBrowser = "0">
		</cfif>
		
		<cfif arguments.stMetadata.ftLimit>
			<skin:htmlHead>
				<cfoutput>
					<script language="javascript">
						<!--  to hide script contents from old browsers
						function UpdateCounter_#arguments.fieldname#(FormName, FieldName) {
						
							counter = (window.document.forms[FormName][FieldName].value.length);
							if (counter < #arguments.stMetadata.ftLimit#){
							<cfif bIsGoodBrowser>
								objCounter = document.getElementById("dm_ct_countDown_" + FieldName);
								objCounter.innerText = counter;
								objCounter.innerHTML = counter;
							<cfelse>
								window.document.forms[FormName][FieldName].value = counter;
								oldvalue = window.document.forms[FormName][FieldName].value;
							</cfif>
							} else {
							<cfif bIsGoodBrowser>
								<!--- (8:Backspace) (45:Insert) (46:Delete) (33-40:Up,Down,Left,Right,PgUp,PgDown,Home,End) --->
								if (!(event.keyCode == "8" || event.keyCode == "46" || (event.keyCode >= "33" && event.keyCode <= "40"))) {
									event.returnValue=false;
								}
								objCounter = document.getElementById("dm_ct_countDown_" + FieldName);
								objCounter.innerText = "#arguments.stMetadata.ftLimit#";
								objCounter.innerHTML = "#arguments.stMetadata.ftLimit#";
							<cfelse>
								if (counter > #arguments.stMetadata.ftLimit#) {
										window.document.forms[FormName][FieldName].value = oldvalue;
								}
								window.document.forms[FormName][FieldName].value = "#arguments.stMetadata.ftLimit#";
							</cfif>
							}
						}
						// end hiding contents from old browsers  -->
					</script>
				</cfoutput>
			</skin:htmlHead>
		</cfif>
				
		<cfsavecontent variable="html">
			<!--- Place custom code here! --->
			
			<cfif arguments.stMetadata.ftToggle>
				<cfoutput>
				<div>
					<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1" onclick="javascript:toggle#arguments.fieldname#();" <cfif bfieldvisible>checked="true"</cfif> >
					<input type="hidden" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="0">
					<span id="#arguments.fieldname#includelabel">#fieldvisibletoggletext#</span>
				</div>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<input type="hidden" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1">
				</cfoutput>
			</cfif>	
			
			<cfoutput>
				<div id="#arguments.fieldname#DIV" style="#fieldStyle#">
					<div>
						<cfif arguments.stMetadata.ftLimit>	
							<cfset onKeyUp = "javascript:UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#', '#arguments.FieldName#')" />
							<cfset onKeyDown = "javascript:UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#', '#arguments.FieldName#')" />
							<cfif bIsGoodBrowser>
								<p id="dm_ct_Text_#arguments.fieldname#"><span id="dm_ct_countDown_#arguments.fieldname#">0</span>/#arguments.stMetadata.ftLimit#</p>
							<cfelse>
								<p id="dm_ct_Text_#arguments.fieldname#"><input id="dm_ct_countDown_#arguments.fieldname#" disabled type="text" name="counter" size="#len(arguments.stMetadata.ftLimit)#" value="#arguments.stMetadata.ftLimit# characters Max">/#arguments.stMetadata.ftLimit#</p>
							</cfif>
							
							<script type="text/javascript">
							<!--  to hide script contents from old browsers
								UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#','#arguments.FieldName#');
							// end hiding contents from old browsers  -->
							</script>
						</cfif>
						<textarea name="#arguments.fieldname#" id="#arguments.fieldname#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" onkeyup="#onKeyUp#" onkeydown="#onKeyDown#">#arguments.stMetadata.value#</textarea>
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		
		<cfsavecontent variable="html">
			<!--- Place custom code here! --->
			<cfoutput>#ReplaceNoCase(arguments.stMetadata.value, chr(10), "<br>" , "All")#</cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="false" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfparam name="stFieldPost.stSupporting.Include" default="true">
		
		<cfif ListGetAt(stFieldPost.stSupporting.Include,1)>
		
			<cfif len(trim(arguments.stFieldPost.Value))>
				<cfset stResult.value = trim(arguments.stFieldPost.Value)>
			<cfelse>
				<cfset stResult.value = "">
			</cfif>
			
		<cfelse>
			<cfset stResult.value = "">
		</cfif>

		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 