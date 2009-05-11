

<cfcomponent name="File" displayname="File" Extends="field" hint="Field component to liase with all File types"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.file" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var previewURL = "" />
		<cfset var uploadScript = "" />
		<cfset var swftag = "" />
		<cfset var browseScript = "" />
		<cfset var i = 0 />
		<cfset var facade = "" />
		
		<cfparam name="arguments.stMetadata.ftstyle" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" /><!--- html, flash, jquery --->
		
		<skin:htmlHead library="extCoreJS" />
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="html">
				<skin:htmlHead id="ftCheckFileName">
					<cfoutput>
						<script type="text/javascript">
							function ftCheckFileName(id){
								var currentText = Ext.get(id).dom.value;	
								var aCurrentExt = currentText.split(".");	
									
								var newText = Ext.get(id + 'NEW').dom.value;	
								var aNewExt = newText.split(".");	
								
								if (currentText.length > 0 && newText.length > 0) {
									if (aCurrentExt.length > 1 && aNewExt.length > 1){						
										if (aCurrentExt[aCurrentExt.length - 1] != aNewExt[aNewExt.length - 1]){
											Ext.get(id + 'NEW').dom.value = '';
											alert('You must either delete the old file or upload a new one with the same extension (' + aCurrentExt[aCurrentExt.length - 1] + ')');
										}
									}
								}
							}
						</script>
					</cfoutput>
				</skin:htmlHead>
				
				<cfsavecontent variable="html">
					<cfoutput>
						<table border="1">
						<tr>
							<td valign="top">
								<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
								<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
								<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" />
							</td>
							
							<cfif len(#arguments.stMetadata.value#)>
								<td valign="top">
									<div id="#arguments.fieldname#previewfile">
										<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
											<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
											#listLast(arguments.stMetadata.value, "/")#
										<cfelse>
											<a href="#application.fapi.getFileWebRoot()##arguments.stMetadata.value#" target="preview">#listlast(arguments.stMetadata.value, "/")#</a>
										</cfif>
										
										<ft:farcryButton type="button" value="Delete File" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};Ext.get('#arguments.fieldname#DELETE').dom.value=Ext.get('#arguments.fieldname#').dom.value;Ext.get('#arguments.fieldname#').dom.value='';Ext.get('#arguments.fieldname#previewfile').hide();" />
										
									</div>
								</td>
							</cfif>				
							
						</tr>
						</table>
					</cfoutput>					
				</cfsavecontent>
			</cfcase>
			
			<cfcase value="jquery">
				<cfparam name="arguments.stMetadata.ftFacade" default="#application.url.webtop#/facade/jqueryupload/upload.cfm" />
				<cfparam name="arguments.stMetadata.ftFileTypes" default="*.jpg;*.JPG;*.jpeg;*.JPEG;" /><!--- *.abc; *.xyz --->
				<cfparam name="arguments.stMetadata.ftStartMessage" default="Upload file here." />
				<cfparam name="arguments.stMetadata.ftMaxSize" default="-1" />
				<cfparam name="arguments.stMetadata.ftErrorSizeMessage" default="Maximum filesize is #arguments.stMetadata.ftMaxSize# kb" />
				<cfparam name="arguments.stMetadata.ftCompleteMessage" default="File upload complete" />
				<cfparam name="arguments.stMetadata.ftAfterUploadJSScript" default="" />
				
				
				
				<cfset facade = "#arguments.stMetadata.ftFacade#?#session.urltoken#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#urlencodedformat(arguments.stMetadata.value)#&farcryProject=#application.applicationName#">
				
				<skin:htmlHead><cfoutput>
					<script type="text/javascript" src="#application.url.webtop#/facade/jqueryupload/jquery-1.2.1.min.js"></script>
					<script type="text/javascript" src="#application.url.webtop#/facade/jqueryupload/jquery.flash.js"></script>
					<script type="text/javascript" src="#application.url.webtop#/facade/jqueryupload/jquery.jqUploader.js"></script>
				</cfoutput></skin:htmlHead>
				<cfsavecontent variable="html">
					<cfoutput>
						<table style="border:0 none;">
						<tr>
							<td valign="top" style="border:0 none;">
								<cfif arguments.stMetadata.ftMaxSize gt 0><input name="MAX_FILE_SIZE" value="#arguments.stMetadata.ftMaxSize#" type="hidden" /></cfif>
								<!--- <input type="hidden" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" /> --->
								<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" />
								<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
								<script type="text/javascript">
									jQ121("###arguments.fieldname#").jqUploader({ 
										src:'#application.url.webtop#/facade/jqueryupload/jqUploader.swf', 
										uploadScript:'http://#cgi.http_host##application.url.webtop#/facade/jqueryupload/upload.cfm?objectid=#arguments.stObject.objectid#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#arguments.stMetadata.value#&#session.urltoken#', 
										startMessage:'#jsstringformat(arguments.stMetadata.ftStartMessage)#', 
										endMessage:'#jsstringformat(arguments.stMetadata.ftCompleteMessage)#', 
										errorSizeMessage:'#arguments.stMetadata.ftErrorSizeMessage#',
										varName:'#arguments.fieldname#',
										afterFunction:function(containerId,filename,varname){
											$con = jQ121('##'+varname).empty().append("Your file ("+filename+") has been uploaded.");
											$con.append("<input type='hidden' name='"+varname+"' value='#arguments.stMetadata.ftDestination#/"+filename.replace(/[^\w\d\.]/g,'')+"' />");
											jQ121("###arguments.fieldname#previewfile").hide();
											jQ121("###arguments.fieldname#DELETE").val("");
											#arguments.stMetadata.ftAfterUploadJSScript#
										} ,
										allowedExt: "#arguments.stMetadata.ftFileTypes#"
									});
								</script>
							</td>
							
							<cfif len(#arguments.stMetadata.value#)>
								<td valign="top" style="border:0 none;">
									<div id="#arguments.fieldname#previewfile">
										<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
											<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
											#listLast(arguments.stMetadata.value, "/")#
										<cfelse>
											<a href="#application.fapi.getFileWebRoot()##arguments.stMetadata.value#" target="preview">#listlast(arguments.stMetadata.value, "/")#</a>
										</cfif>
										
										<ft:farcryButton type="button" value="Delete File" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};Ext.get('#arguments.fieldname#DELETE').dom.value=Ext.get('#arguments.fieldname#').dom.value;Ext.get('#arguments.fieldname#').dom.value='';Ext.get('#arguments.fieldname#previewfile').hide();" />
										
									</div>
								</td>
							</cfif>	
						</tr>
						</table>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			
			<cfdefaultcase><!--- value="flash" --->
				<cfparam name="arguments.stMetadata.ftFacade" default="#application.url.webtop#/facade/fileupload/upload.cfm" />
				<cfparam name="arguments.stMetadata.ftFileTypes" default="*.*" />
				<cfparam name="arguments.stMetadata.ftFileDescription" default="File Types" />
				<cfparam name="arguments.stMetadata.ftMaxSize" default="-1" />
				<cfparam name="arguments.stMetadata.ftOnComplete" default="" />
				
				<cfset facade = "#arguments.stMetadata.ftFacade#?#session.urltoken#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#urlencodedformat(arguments.stMetadata.value)#&farcryProject=#application.applicationName#">
				
				<cfsavecontent variable="html">
					<cfoutput>
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
						<cfif len(arguments.stMetadata.value)>
							<div id="#arguments.fieldname#previewfile">
								<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
									<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
									#listLast(arguments.stMetadata.value, "/")#
								<cfelse>
									<a href="#application.fapi.getFileWebRoot()##arguments.stMetadata.value#" target="preview">#listlast(arguments.stMetadata.value, "/")#</a>
								</cfif>
								
								<ft:farcryButton type="button" value="Delete File" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};Ext.get('#arguments.fieldname#DELETE').dom.value=Ext.get('#arguments.fieldname#').dom.value;Ext.get('#arguments.fieldname#').dom.value='';Ext.get('#arguments.fieldname#previewfile').hide();" />
							</div>
						</cfif>
						<div style="width:420px;height:100px;">
							<cfform name="myform" width="420" format="Flash" timeout="100">
								<ft:flashUpload name="file" actionFile="#facade#" value="#arguments.stMetadata.value#" filetypes="#listchangedelims(arguments.stMetadata.ftFileTypes,';')#" fileDescription="#arguments.stMetadata.ftFileDescription#" maxsize="#arguments.stMetadata.ftMaxSize#" onComplete="getURL('javascript:updateField(\'#arguments.fieldname#\',#arguments.fieldname#.text)');#arguments.stMetadata.ftOnComplete#">
									<ft:flashUploadInput chooseButtonLabel="Browse" uploadButtonLabel="Upload" />
								</ft:flashUpload>
							</cfform>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfdefaultcase>
		</cfswitch>
	
		<cfreturn html>
	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><a target="_blank" href="#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.typename#&fieldname=#arguments.stmetadata.name#">#arguments.stMetadata.value#</a></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var filePath = "" />
		<cfset var stResult = structNew()>	
		<cfset var uploadFileName = "" />
		<cfset var qDuplicates = queryNew("blah") />
		<cfset var cleanFileName = "" />
		<cfset var newFileName = "" />
		<cfset var lFormField = "" />
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfparam name="arguments.stMetadata.ftDestination" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" />
		
		<cfif len(arguments.stMetadata.ftDestination) and right(arguments.stMetadata.ftDestination,1) EQ "/">
			<cfset arguments.stMetadata.ftDestination = left(arguments.stMetadata.ftDestination, (len(arguments.stMetadata.ftDestination) - 1)) />
		</cfif>
	
		<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(stObj,"status") or stObj.status eq "approved")>
			<cfset filePath = application.path.defaultFilePath />
		<cfelse>
			<cfset filePath = application.path.secureFilePath />
		</cfif>
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfif NOT DirectoryExists("#filePath##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#filePath##arguments.stMetadata.ftDestination#">
		</cfif>	
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#Delete"]) AND fileExists("#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#")>
			
			<!--- create media archive directory as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive#">
			</cfif>
			
			<!--- create typename/property directory archive as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.stMetadata.ftDestination#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#">
			</cfif>
			
			<!--- generate media archive entry --->
		 	<cffile 
			   action = "move"
			   source = "#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#"
			   destination = "#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#listLast(FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete'], '/')#">
	
		</cfif>
			
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="html">
				<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
			
			
					<cfif structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#") AND  len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
						<!--- This means there is currently a file associated with this object. We need to override this file --->
						
						<cfset lFormField = replace(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"], '\', '/', "all")>			
						<cfset uploadFileName = listLast(lFormField, "/") />
						
						<cffile action="UPLOAD"
							filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
							destination="#filePath##arguments.stMetadata.ftDestination#"		        	
							nameconflict="MakeUnique" />
						<cffile action="rename" source="#filePath##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" destination="#uploadFileName#" />
						<cfset newFileName = uploadFileName>
					<cfelse>
						<!--- There is no image currently so we simply upload the image and make it unique  --->
						<cffile action="UPLOAD"
							filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
							destination="#filePath##arguments.stMetadata.ftDestination#"		        	
							nameconflict="MakeUnique">
						<cfset newFileName = cffile.ServerFile>
					</cfif>
		
			
					
					<!--- Replace all none alphanumeric characters --->
					<cfset cleanFileName = reReplaceNoCase(newFileName, "[^a-z0-9.\-\_]","", "all") />
					
					<!--- If the filename has changed, rename the file
					Note: doing a quick check to make sure the cleanfilename doesnt exist. If it does, prepend the count+1 to the end.
					 --->
					<cfif cleanFileName NEQ newFileName>
						<cfif fileExists("#filePath##arguments.stMetadata.ftDestination#/#cleanFileName#")>
							<cfdirectory action="list" directory="#filePath##arguments.stMetadata.ftDestination#" filter="#listFirst(cleanFileName, '.')#*" name="qDuplicates" />
							<cfif qDuplicates.RecordCount>
								<cfset cleanFileName = "#listFirst(cleanFileName, '.')##qDuplicates.recordCount+1#.#listLast(cleanFileName,'.')#">
							</cfif>
							 
						</cfif>
						
						<cffile action="rename" source="#filePath##arguments.stMetadata.ftDestination#/#newFileName#" destination="#cleanFileName#" />
					</cfif>			
											
					<!--- </cfif> --->
					<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#cleanFileName#">
		
					
				</cfif>
			</cfcase>
		
			<cfdefaultcase><!--- value="flash" --->
				<cfif structkeyexists(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") and len(session["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
					<cfset stResult.value = session['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
					<cfset structdelete(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") />
				<cfelseif structkeyexists(form,"#stMetadata.FormFieldPrefix##stMetadata.Name#")>
					<cfset stResult.value = form['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
				</cfif>
			</cfdefaultcase>
		
		</cfswitch>
	
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="onDraft" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var oldPath = application.path.defaultFilePath />
		<cfset var newPath = application.path.secureFilePath />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		
		<!--- Draft content should always be secured --->
		<cfif len(arguments.stObject[arguments.stMetadata.name]) and arguments.previousStatus eq "approved" and not arguments.stMetadata.ftSecure and fileexists("#oldPath##arguments.stObject[arguments.stMetadata.name]#")>
			<cffile action="move" source="#oldPath##arguments.stObject[arguments.stMetadata.name]#" destination="#newPath##arguments.stObject[arguments.stMetadata.name]#" />
		</cfif>
	</cffunction>
	
	<cffunction name="onApproved" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var oldPath = application.path.secureFilePath />
		<cfset var newPath = application.path.defaultFilePath />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		
		<!--- Approved content should be moved to public if not secured --->
		<cfif len(arguments.stObject[arguments.stMetadata.name]) and not arguments.stMetadata.ftSecure and fileexists("#oldPath##arguments.stObject[arguments.stMetadata.name]#")>
			<cffile action="move" source="#oldPath##arguments.stObject[arguments.stMetadata.name]#" destination="#newPath##arguments.stObject[arguments.stMetadata.name]#" />
		</cfif>
	</cffunction>
	
	
	<cffunction name="getFileLocation" access="public" output="false" returntype="struct" hint="Returns information used to access the file: type (stream | redirect), path (file system path | absolute URL), filename, mime type">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		<cfset var stResult = structnew() />
		<cfset var i = "" />
		
		<!--- Get the object if not passed in --->
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
		</cfif>
		
		<!--- Determine which property to use if not passed in --->
		<cfif not structkeyexists(arguments,"stMetadata")>
			<!--- Name of the file field has not been sent. We need to loop though the type to determine which field contains the file path --->
			<cfloop list="#structKeyList(application.types[arguments.stObject.typename].stprops)#" index="i">
				<cfif application.fapi.getPropertyMetadata(arguments.stObject.typename,i,"ftType","") EQ "file">
					<cfset arguments.stMetadata = application.types[arguments.stObject.typename].stprops[i].metadata />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<!--- Throw an error if the field couldn't be determined --->
			<cfif not structkeyexists(arguments,"stMetadata")>
				<cfthrow type="core.tags.farcry.download" message="File not found." detail="Fieldname for the file reference could not be determined." />
			</cfif>
		</cfif>
		
		<!--- Throw an error if the field is empty --->
		<cfif NOT len(arguments.stObject[arguments.stMetadata.name])>
			<cfthrow type="core.tags.farcry.download" message="File not found." detail="Fieldname for the file reference was empty." />
		</cfif>
		
		<!--- Ensure that the first character of the path in the DB is a  "/" --->
		<cfif left(arguments.stObject[arguments.stMetadata.name],1) NEQ "/">
			<cfset arguments.stObject[arguments.stMetadata.name] = "/#arguments.stObject[arguments.stMetadata.name]#" />
		</cfif>
		<!--- Replace any  "\" with "/" for compatibility with everything --->
		<cfset arguments.stObject[arguments.stMetadata.name] = replace(arguments.stObject[arguments.stMetadata.name],"\","/","all")>
		
		<!--- Determine the ACTUAL filename --->
		<cfset stResult.filename = listLast(arguments.stObject[arguments.stMetadata.name],"/")>
		
		<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved")>
			<!--- check file exists --->
			<cfif NOT fileExists("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfthrow type="core.tags.farcry.download" message="File not found." detail="The physical file is missing." />
			</cfif>
			
			<!--- Objects that are not ALWAYS secured and have been approved should be available under the webroot --->
			<cfset stResult.type = "redirect" />
			<cfset stResult.path = "#application.fapi.getFileWebRoot()##arguments.stObject[arguments.stMetadata.name]#" />
			
			<!--- determine mime type --->
			<cfset stResult.mimeType=getPageContext().getServletContext().getMimeType("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#") />
		<cfelse>
			<!--- Everything else must be streamed from a path --->
			<cfset stResult.type = "stream" />
			
			<!--- check file exists --->
			<cfif fileExists("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfset stResult.path = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
			<cfelse>
				<cfif fileexists("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#")>
					<cfset stResult.path = "#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfelse>
					<cfthrow type="core.tags.farcry.download" message="File not found." detail="The physical file is missing." />
				</cfif>
			</cfif>
			
			<!--- determine mime type --->
			<cfset stResult.mimeType=getPageContext().getServletContext().getMimeType("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent> 
