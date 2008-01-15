

<cfcomponent extends="field" name="password" displayname="password" hint="Used to liase with password type fields"> 
	
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
		<cfparam name="arguments.stMetadata.ftRenderType" default="changepassord" />
	
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="changepassword">
				<cfsavecontent variable="html">
					<cfoutput>
						<fieldset>
							<legend>#arguments.stMetadata.ftLabel#</legend>
							<div class="fieldsection optional">
								<label class="fieldsectionlabel" for="#arguments.fieldname#">Current Password</label>
								<div class="fieldwrap"><input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></div>
								<br class="fieldsectionbreak" />
							</div>
							
							<div class="fieldsection optional">
								<label class="fieldsectionlabel" for="#arguments.fieldname#New">New Password</label>
								<div class="fieldwrap"><input type="password" name="#arguments.fieldname#New" id="#arguments.fieldname#New" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></div>
								<br class="fieldsectionbreak" />
							</div>
							
							<div class="fieldsection optional">
								<label class="fieldsectionlabel" for="#arguments.fieldname#Confirm">Confirm New Password</label>
								<div class="fieldwrap"><input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></div>
								<br class="fieldsectionbreak" />
							</div>
						</fieldset>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfcase value="confirmpassword">
				<cfsavecontent variable="html">
					<cfoutput>
						<fieldset>
							<legend>#arguments.stMetadata.ftLabel#</legend>							
							<div class="fieldsection optional">
								<label class="fieldsectionlabel" for="#arguments.fieldname#New">Password</label>
								<div class="fieldwrap"><input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></div>
								<br class="fieldsectionbreak" />
							</div>
							
							<div class="fieldsection optional">
								<label class="fieldsectionlabel" for="#arguments.fieldname#Confirm">Confirm Password</label>
								<div class="fieldwrap"><input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></div>
								<br class="fieldsectionbreak" />
							</div>
						</fieldset>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfcase value="enterpassword">
				<cfsavecontent variable="html">
					<cfoutput><input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></cfoutput>
				</cfsavecontent>
			</cfcase>
			<cfcase value="editpassword">
				<cfsavecontent variable="html">
					<cfoutput><style>form.formtool label.passwordlabel { display: block; }</style><input type="password" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></cfoutput>
				</cfsavecontent>
			</cfcase>
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
		
		<cfset var o = "" />
		<cfset var st = "" />
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftRenderType" default="changepassord" />
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="changepassword">
				<cfset o = createObject("component",application.stCOAPI['#arguments.Typename#'].packagepath)>
				<cfset st = o.getData(objectid=arguments.objectid)>
				<!--- --------------------------- --->
				<!--- Perform any validation here --->
				<!--- --------------------------- --->
		
				<cfset stResult.value = st[arguments.stMetadata.name]>
				
				<cfif arguments.stFieldPost.value EQ st[arguments.stMetadata.name]>
					<cfif len(arguments.stFieldPost.stSupporting.New) AND arguments.stFieldPost.stSupporting.New EQ arguments.stFieldPost.stSupporting.Confirm>
						<cfset stResult.value = arguments.stFieldPost.stSupporting.New>
					</cfif>		
				</cfif>
			</cfcase>
			<cfcase value="confirmpassword">
				<cfset o = createObject("component",application.stCOAPI['#arguments.Typename#'].packagepath)>
				<cfset st = o.getData(objectid=arguments.objectid)>
				<!--- --------------------------- --->
				<!--- Perform any validation here --->
				<!--- --------------------------- --->
		
				<cfset stResult.value = st[arguments.stMetadata.name]>
				
				<cfif arguments.stFieldPost.value EQ st[arguments.stMetadata.name]>
					<cfif len(arguments.stFieldPost.value) AND arguments.stFieldPost.value EQ arguments.stFieldPost.stSupporting.Confirm>
						<cfset stResult.value = arguments.stFieldPost.value>
					</cfif>		
				</cfif>
			</cfcase>
			<cfcase value="enterpassword">
				<cfset stResult.value = arguments.stFieldPost.value />
			</cfcase>
			<cfcase value="editpassword">
				<cfset stResult.value = arguments.stFieldPost.value />
			</cfcase>
		</cfswitch>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent>