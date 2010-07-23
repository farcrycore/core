<!--- 	
	@@examples:

	<p>Change Password</p>
	<code>
		<cfproperty
			name="password" type="string" 
			ftSeq="12" ftfieldset="Your Login Details" required="yes" default="" 
			ftType="password" ftLabel="Password" ftValidation="required" />
	</code>

	<p>Confirm Password</p>
	<code>
		<cfproperty
			name="password" type="string" 
			ftSeq="12" ftfieldset="Your Login Details" required="yes" default="" 
			ftType="password" ftRenderType="confirmPassword" ftLabel="Password" 
			ftValidation="required" />
	</code>

 --->

<cfcomponent extends="field" name="password" displayname="password" hint="Used to liase with password type fields"> 
	<cfproperty name="ftRenderType" default="changepassword" hint="This formtool offers a number of ways to render the input. (changepassword, confirmPassword)" />
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.password" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
		<cfset var html = "" />
		
		
		<cfparam name="arguments.stMetadata.ftLabel" default="#arguments.stMetadata.name#" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="changepassword" />

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="changepassword">
				<cfsavecontent variable="html">
					<cfoutput>
								
						<div class="multiField">
							<label class="blockLabel" for="#arguments.fieldname#" style="width:100%;">Current password
								<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							 </label>
							
							<label class="blockLabel" for="#arguments.fieldname#New" style="width:100%;margin-top:5px;">New password
								<input type="password" name="#arguments.fieldname#New" id="#arguments.fieldname#New" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							 </label>
							
							<label class="blockLabel" for="#arguments.fieldname#Confirm" style="width:100%;margin-top:5px;">Re-enter new password
								<input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							 </label>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfcase value="confirmpassword">
				<cfsavecontent variable="html">
					<cfoutput>				
						<div class="multiField">
							<label class="blockLabel" for="#arguments.fieldname#" style="width:100%;">Choose a password
								<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							 </label>
							
							<label class="blockLabel" for="#arguments.fieldname#Confirm" style="width:100%;margin-top:5px;">Re-enter password
								<input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							 </label>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfdefaultcase>
				<cfsavecontent variable="html">
					<cfoutput>
						<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
					</cfoutput>
				</cfsavecontent>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		
		<cfset var html = "" />
		
		
		<cfsavecontent variable="html">
			<cfoutput><a href="##" onclick="alert('#arguments.stMetadata.value#');">****************</a></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var o = createObject("component",application.stCOAPI['#arguments.Typename#'].packagepath) />
		<cfset var st = o.getData(objectid=arguments.objectid) />
		
		<!--- Default the password to the current value --->
		<cfset var stResult = passed(value=st[arguments.stMetadata.name]) />

		
		<cfif structKeyExists(arguments.stFieldPost.stSupporting, "New") AND structKeyExists(arguments.stFieldPost.stSupporting, "Confirm")>

			<cfif arguments.stFieldPost.value EQ st[arguments.stMetadata.name]>
				<cfif len(arguments.stFieldPost.stSupporting.New) AND arguments.stFieldPost.stSupporting.New EQ arguments.stFieldPost.stSupporting.Confirm>
					<cfset stResult = passed(value=arguments.stFieldPost.stSupporting.New) />
				<cfelse>
					<cfset stResult = failed(value="#stResult.value#", message="Your new password confirmation did not match.") />
				</cfif>	
			<cfelse>
				<cfset stResult = failed(value="#stResult.value#", message="The current password you entered was incorrect") />
			</cfif>
		<cfelseif structKeyExists(arguments.stFieldPost.stSupporting, "Confirm")>
			
			<cfif len(arguments.stFieldPost.value) AND arguments.stFieldPost.value EQ arguments.stFieldPost.stSupporting.Confirm>
				<cfset stResult = passed(value=arguments.stFieldPost.value) />
			<cfelse>
				<cfset stResult = failed(value="#stResult.value#", message="Your password confirmation did not match.") />
			</cfif>	
		<cfelse>
			<cfset stResult = passed(value=arguments.stFieldPost.value) />
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent>