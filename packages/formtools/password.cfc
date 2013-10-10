<!--- 	
	@@examples:

	<p>Change Password</p>
	<code>
		<cfproperty
			name="password" type="string" 
			ftSeq="12" ftfieldset="Your Login Details" required="yes" default="" 
			ftType="password" ftLabel="Password"
			ftValidation="required" />
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
	<cfproperty name="ftRenderType" default="changepassword" hint="This formtool offers a number of ways to render the input. (changepassword, confirmpassword, editpassword)" />
	<cfproperty name="ftValidateOldMethod" hint="The function that will be used to validate the old property value on form submission" />
	<cfproperty name="ftValidateNewMethod" hint="The function that will be used to validate the new property value on form submission" />
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.password" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfparam name="arguments.stMetadata.ftLabel" default="#arguments.stMetadata.name#" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="changepassword" />

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="changepassword">
				<cfsavecontent variable="html">
					<cfoutput>
						<div class="multiField">
							<ft:field label="Current password" labelAlignment="block" for="#arguments.fieldname#">
								<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							</ft:field>
							<ft:field label="New password" labelAlignment="block" for="#arguments.fieldname#New">
								<input type="password" name="#arguments.fieldname#New" id="#arguments.fieldname#New" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							</ft:field>
							<ft:field label="Re-enter new password" labelAlignment="block" for="#arguments.fieldname#Confirm">
								<input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							</ft:field>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfcase value="confirmpassword">
				<cfsavecontent variable="html">
					<cfoutput>				
						<div class="multiField">
							<ft:field label="Choose a password" labelAlignment="block" for="#arguments.fieldname#">
								<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							</ft:field>
							<ft:field label="Re-enter password" labelAlignment="block" for="#arguments.fieldname#Confirm">
								<input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
							</ft:field>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfdefaultcase>
				<cfsavecontent variable="html">
					<cfoutput>
						<input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="<cfif arguments.stMetadata.ftRenderType eq 'editpassword'>#arguments.stMetadata.value#</cfif>" class="textInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" />
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
		
		<cfset var stResult = "" />
		<cfset var stNewFieldPost = "" />
		
		<cfif structKeyExists(arguments.stFieldPost.stSupporting, "New") AND structKeyExists(arguments.stFieldPost.stSupporting, "Confirm")>

			<!--- Perform old-value validation --->
			<cfset stResult = validateOld(argumentcollection=arguments) />
			
			<cfif stResult.bSuccess>
				<!--- The new and confirm password must be non-blank and a case-sensitive match --->
				<cfif not len(arguments.stFieldPost.stSupporting.New) OR compare(arguments.stFieldPost.stSupporting.New,arguments.stFieldPost.stSupporting.Confirm)>
					<cfset stResult = failed(value="", message="Your new password confirmation did not match.") />
				<cfelse>
					<!--- Perform new-value validation against the value in the "New" field --->
					<cfset stNewFieldPost = StructCopy(arguments.stFieldPost) />
					<cfset stNewFieldPost.value = arguments.stFieldPost.stSupporting.New />
					<cfset stResult = validateNew(objectID=arguments.objectID,typename=arguments.typename,stFieldPost=stNewFieldPost,stMetadata=arguments.stMetaData) />
				</cfif>
			</cfif>
		<cfelseif structKeyExists(arguments.stFieldPost.stSupporting, "Confirm")>
			
			<!--- The new and confirm password must be non-blank and be equal including case --->
			<cfif not len(arguments.stFieldPost.value)>
				<cfset stResult = failed(value="", message="You have not entered a password") />
			<cfelseif not len(arguments.stFieldPost.value) OR compare(arguments.stFieldPost.value,arguments.stFieldPost.stSupporting.Confirm)>
				<cfset stResult = failed(value="", message="Your password confirmation did not match.") />
			<cfelse>
				<!--- Perform new-value validation --->
				<cfset stResult = validateNew(argumentCollection=arguments) />
			</cfif>
		<cfelse>
			<cfset stResult = passed(value=arguments.stFieldPost.value) />
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

	<cffunction name="validateOld" access="public" output="true" returntype="struct" hint="Validate the previous value of the password">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var o = createObject("component",application.stCOAPI['#arguments.Typename#'].packagepath) />
		<cfset var stResult = "" />
		<cfset var st = "" />

		<!--- If the property has a ftValidateOldMethod attribute and the type object provides the method, use it --->
		<cfif structKeyExists(arguments.stMetadata,"ftValidateOldMethod") and len(arguments.stMetadata.ftValidateOldMethod)
				and structKeyExists(o,arguments.stMetadata.ftValidateOldMethod)>
			<cfinvoke component="#o#" method="#arguments.stMetadata.ftValidateOldMethod#" argumentcollection="#arguments#" returnvariable="stResult" />
		<cfelse>
			<cfset st = o.getData(objectid=arguments.objectid) />
			
			<!--- Default is case-insensitive match (for backwards compatibility) --->
			<cfif arguments.stFieldPost.value EQ st[arguments.stMetadata.name]>
				<cfset stResult = passed(value=arguments.stFieldPost.value) />
			<cfelse>
				<!--- Return a blank value on failure so as not to reveal the stored password --->
				<cfset stResult = failed(value="", message="The current password you entered was incorrect") />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="validateNew" access="public" output="true" returntype="struct" hint="Validate the new value of the password">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var o = createObject("component",application.stCOAPI['#arguments.Typename#'].packagepath) />
		<cfset var stResult = "" />
		<cfset var st = "" />
		
		<!--- If the property has a ftValidateNewMethod attribute and the type object provides the method, use it --->
		<cfif structKeyExists(arguments.stMetadata,"ftValidateNewMethod") and len(arguments.stMetadata.ftValidateNewMethod)
				and structKeyExists(o,arguments.stMetadata.ftValidateNewMethod)>
			<cfinvoke component="#o#" method="#arguments.stMetadata.ftValidateNewMethod#" argumentcollection="#arguments#" returnvariable="stResult" />
		<cfelse>
			<!--- Default is to accept any new password --->
			<cfset stResult = passed(value=arguments.stFieldPost.value) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

</cfcomponent>