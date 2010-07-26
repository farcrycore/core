<!--- @@description:
	<p>Renders a text area</p> --->

<!--- @@examples:
	<p>Basic</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Contact"
 			name="address"
	 		type="longchar"
	 		hint="address of occupant"
	 		required="false"
	 		default=""
	 		ftLabel="Address"
 			ftType="longchar"/>
	</code> 
	<p>Textarea with limited characters with character counter</p>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Contact"
 			name="address"
	 		type="longchar"
	 		hint="address of occupant"
	 		required="false"
	 		default=""
	 		ftLabel="Home address"
 			ftType="longchar"
			ftLimit="150"/>
--->

<cfcomponent extends="field" name="longchar" displayname="longchar" hint="Used to liase with longchar type fields"> 

	<cfproperty name="ftStyle" required="false" default="" hint="The style for the text area" />
	<cfproperty name="ftLimit" required="false" default="" hint="Limits the amount of data the user can input. Provides a counter above text area" />
	
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
		<cfset var bIsGoodBrowser = "" />
		
		<cfparam name="arguments.stMetadata.ftStyle" default="">
		<cfparam name="arguments.stMetadata.ftLimit" default="0">
		
		
		<cfif CGI.HTTP_USER_AGENT contains "MSIE" or CGI.HTTP_USER_AGENT contains "gecko">
			<cfset bIsGoodBrowser = "1">
		<cfelse>
			<cfset bIsGoodBrowser = "0">
		</cfif>
		
		<cfif isBoolean(arguments.stMetadata.ftLimit) and arguments.stMetadata.ftLimit>
			<skin:htmlHead>
				<cfoutput>
					<script language="javascript">
						<!--  to hide script contents from old browsers
						function UpdateCounter_#arguments.fieldname#(FormName, FieldName) {
						
							counter = (window.document.forms[FormName][FieldName].value.length);
							if (counter > #arguments.stMetadata.ftLimit#) {
								window.document.forms[FormName][FieldName].value = window.document.forms[FormName][FieldName].value.substr(0,#arguments.stMetadata.ftLimit#);
								counter = #arguments.stMetadata.ftLimit#;
								alert("The text was too long and has been truncated to #arguments.stMetadata.ftLimit# characters");
							}		
							if (counter <= #arguments.stMetadata.ftLimit#){
							<cfif bIsGoodBrowser>
								objCounter = document.getElementById("dm_ct_countDown_" + FieldName);
								objCounter.innerText = counter;
								objCounter.innerHTML = counter;
							<cfelse>
								window.document.forms[FormName][FieldName].value = counter;
								oldvalue = window.document.forms[FormName][FieldName].value;
							</cfif>
							} 					
							else {
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
			
			<cfoutput>
				<div class="multiField">
					<div id="#arguments.fieldname#DIV" style="#fieldStyle#;">
						<div class="blockLabel">
						<cfif isBoolean(arguments.stMetadata.ftLimit) and arguments.stMetadata.ftLimit>							
							<cfset onKeyUp = "javascript:UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#', '#arguments.FieldName#')" />
							<cfset onKeyDown = "javascript:UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#', '#arguments.FieldName#')" />
							<textarea name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" onkeyup="#onKeyUp#" onkeydown="#onKeyDown#">#arguments.stMetadata.value#</textarea>
							
							<cfif bIsGoodBrowser>
								<p style="clear:both;" id="dm_ct_Text_#arguments.fieldname#"><span id="dm_ct_countDown_#arguments.fieldname#">0</span>/#arguments.stMetadata.ftLimit#</p>
							<cfelse>
								<p style="clear:both;" id="dm_ct_Text_#arguments.fieldname#"><input id="dm_ct_countDown_#arguments.fieldname#" disabled type="text" name="counter" size="#len(arguments.stMetadata.ftLimit)#" value="#arguments.stMetadata.ftLimit# characters Max">/#arguments.stMetadata.ftLimit#</p>
							</cfif>
							<script type="text/javascript">
							<!--  to hide script contents from old browsers
								UpdateCounter_#arguments.fieldname#('#request.farcryForm.name#','#arguments.FieldName#');
							// end hiding contents from old browsers  -->
							</script>
						<cfelse>
							<textarea name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" onkeyup="#onKeyUp#" onkeydown="#onKeyDown#">#arguments.stMetadata.value#</textarea>
						</cfif>
						</div>
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

		<cfset var html = "" />
		
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
		<cfparam name="arguments.stFieldPost.stSupporting.Include" default="true">
		
		<cfif ListGetAt(arguments.stFieldPost.stSupporting.Include,1)>
		
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