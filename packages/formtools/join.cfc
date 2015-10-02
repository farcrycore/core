<cfcomponent extends="farcry.core.packages.formtools.field" name="join" displayname="join" output="false" hint="Used to liase with join type fields (array and uuid)" bDocument="false"> 

	<cfproperty name="ftJoin" required="true" default="" options="comma seperated list of types" hint="A list of the user can select from. e.g 'dmImage,dmfile,dmflash'"/>
	<cfproperty name="ftAllowSelect" required="false" default="true" options="true,false" hint="Allows user to select existing records within the library picker"/>
	<cfproperty name="ftAllowCreate" required="false" default="true" options="true,false" hint="Allows user create new record within the library picker"/>
	<cfproperty name="ftAllowEdit" required="false" default="false" options="true,false" hint="Allows user edit new record within the library picker"/>
	<cfproperty name="ftRemoveType" required="false" default="remove" options="delete,remove" hint="remove will only remove from the join, delete will remove from the database. detach is a deprecated alias for remove."/>
	<cfproperty name="ftAllowRemoveAll" required="false" default="false" options="true,false" hint="Allows user to remove all items at once"/>
	
	<cfproperty name="ftLibraryData" default="" hint="Name of a function to return the library data. By default will look for ./webskin/typename/librarySelected.cfm"/><!--- Name of a function to return the library data --->
	<cfproperty name="ftLibraryDataTypename" default="" hint="Typename containing the function defined in ftLibraryData"/><!--- Typename containing the function defined in ftLibraryData --->	
	<cfproperty name="ftLibraryDataSQLWhere" required="false" default="" hint="A simple where clause filter for the library data result set. Must be in the form PROPERTY OPERATOR VALUE. For example, status = 'approved'"/>
	<cfproperty name="ftLibraryDataSQLOrderBy" required="false" default="datetimelastupdated desc" hint="Nominate a specific property to order library results by."/>
	
	<cfproperty name="ftLibraryEditWebskin" default="edit" hint="???"/>
	<cfproperty name="ftLibrarySelectedWebskin" default="librarySelected" type="string" hint="webskin to overwrite each record in list"/>
	<cfproperty name="ftLibrarySelectedListClass" default="arrayDetail" type="string" hint="overwrite the style class of the list"/>
	<cfproperty name="ftLibrarySelectedListStyle" default="" type="string" hint="write your own inline style for the class" />
	<cfproperty name="ftLibraryListItemWidth" default="" type="string" hint="???" />
	<cfproperty name="ftLibraryListItemHeight" default="" type="string" hint="???"/>

	<cfproperty name="ftRenderType" default="Library" options="Library, list, checkbox or radio" type="string" hint="Specify how to render the form element for the array, library pop-up, select dropdown, or list of checkbox or radio buttons."/>
	<cfproperty name="ftSelectSize" default="10" type="string" hint="Specify the number of items displayed of a select list."/>
	<cfproperty name="ftSelectMultiple" default="true" options="true,false" type="boolean" hint="Allow selection of multiple items from a select list. Values - true or false, if this property is omitted then allowing multiple select is default"/>
	<cfproperty name="ftAllowLibraryEdit" default="false" hint="???"/>
	<cfproperty name="ftFirstListLabel" default="-- SELECT --" hint="Used with ftRenderType, this is the value of the first element in the list"/>
	
	<cfproperty name="ftAllowBulkUpload" default="false" options="true,false" hint="Allows user to upload items in bulk. Only used for array properties." />
	
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">
				
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var oPrimary = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />
		<cfset var qArrayField = "" />
		<cfset var stActions = structNew() /><!--- Need to allow for earlier versions of farcry which had different naming conventions --->
		<cfset var libraryData = "" />
		<cfset var qLibraryList = "" />
		<cfset var lBulkUploadable = "" />

		<cfset arguments.stMetadata = prepMetadata(stObject = arguments.stObject, stMetadata = arguments.stMetadata) />

		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
		<skin:loadCSS id="fc-fontawesome" />

		<!--- SETUP stActions --->
		<cfset stActions.ftAllowSelect = arguments.stMetadata.ftAllowSelect />
		<cfset stActions.ftAllowCreate = arguments.stMetadata.ftAllowCreate />
		<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
		<cfset stActions.ftRemoveType = arguments.stMetadata.ftRemoveType />
		
		<cfif structKeyExists(arguments.stMetadata, "ftAllowAttach")>
			<cfset stActions.ftAllowSelect = arguments.stMetadata.ftAllowAttach />
		</cfif>
		<cfif structKeyExists(arguments.stMetadata, "ftAllowAdd")>
			<cfset stActions.ftAllowCreate = arguments.stMetadata.ftAllowAdd />
		</cfif>
		<cfif arguments.stMetadata.ftRemoveType EQ "detach">
			<cfset stActions.ftRemoveType = "remove" />
		</cfif>
		
		
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		
			<cfcase value="list">
				<cfif arguments.stMetadata.type EQ "array">
					<cfset joinItems = getJoinList(arguments.stObject[arguments.stMetadata.name]) />
				<cfelse>
					<cfset joinItems = arguments.stObject[arguments.stMetadata.name] />
					<cfset arguments.stMetadata.ftSelectSize = 1 />
				</cfif>
				
				<!-------------------------------------------------------------------------- 
				generate library data query to populate library interface 
				--------------------------------------------------------------------------->
				<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
				
					<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
						<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
					</cfif>
					<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
					
					<!--- use ftlibrarydata method from primary content type --->
					<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
						<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
							<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
							<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
						</cfinvoke>
						
						<cfif isStruct(libraryData)>
							<cfset qLibraryList = libraryData.q>
						<cfelse>
							<cfset qLibraryList = libraryData />
						</cfif>
					</cfif>
				<cfelse>
					<!--- if nothing exists to generate library data then cobble something together --->
					<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData(arguments.stMetadata.ftlibrarydatasqlwhere,arguments.stMetadata.ftlibrarydatasqlorderby) />
				</cfif>
		
				<cfsavecontent variable="returnHTML">
				<cfif isQuery(qLibraryList) AND qLibraryList.recordcount>
					<!--- If they didn't pass in ftStyle, use the old hard coded
						value for backwards compatibility  --->
					<cfif structKeyExists(arguments, "stMetadata") 
						and not structKeyExists(arguments.stMetadata, "ftStyle")>
						<cfset arguments.stMetadata.ftStyle = "width:auto" />
					</cfif>
					
					<cfoutput>
					<select  id="#arguments.fieldname#" name="#arguments.fieldname#" <cfif len(arguments.stMetadata.ftSelectSize)> size="#arguments.stMetadata.ftSelectSize#"</cfif> <cfif arguments.stMetadata.ftSelectMultiple>multiple="multiple"</cfif> style="#arguments.stMetadata.ftStyle#" class="selectInput #arguments.inputClass# #arguments.stMetadata.ftClass#">
					<cfif len(arguments.stMetadata.ftFirstListLabel) AND NOT arguments.stMetadata.ftSelectMultiple>
						<option value="">#arguments.stMetadata.ftFirstListLabel#</option>
					</cfif>
					<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#"<cfif listFindNoCase(joinItems,qLibraryList.objectid)> selected="selected"</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
					</select>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					
					</cfoutput>
					
					
				<cfelse>
					<!--- todo: i18n --->
					<cfoutput>
					<em>No options available.</em>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					</cfoutput>
				</cfif>
				
				</cfsavecontent>
			
			</cfcase>
			
			<cfcase value="radio,checkbox">
				<!-------------------------------------------------------------------------- 
				generate library data query to populate library interface 
				--------------------------------------------------------------------------->
				<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
					<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
						<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
					</cfif>
					<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
					
					<!--- use ftlibrarydata method from primary content type --->
					<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
						<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
							<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
							<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
						</cfinvoke>	
							
						<cfif isStruct(libraryData)>
							<cfset qLibraryList = libraryData.q>
						<cfelse>
							<cfset qLibraryList = libraryData />
						</cfif>		
						
					</cfif>
				</cfif>
				<!--- if nothing exists to generate library data then cobble something together --->
				<cfif NOT isDefined("qLibraryList")>
					<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
				</cfif>
	
				<cfsavecontent variable="returnHTML">
					<grid:div class="multiField">
						<cfif qLibraryList.recordcount>
							<cfoutput>
							
							<cfif arguments.stMetadata.ftRenderType eq 'radio' and len(arguments.stMetadata.ftFirstListLabel)>
								<label for="#arguments.fieldname#_none">
									<input type="#arguments.stMetadata.ftRenderType#" 
										id="#arguments.fieldname#_none" 
										name="#arguments.fieldname#" class="formCheckbox #arguments.stMetadata.ftclass#"
										<cfif isSimpleValue(arguments.stObject[arguments.stMetaData.Name]) and arguments.stObject[arguments.stMetaData.Name] EQ ""> checked="checked"</cfif> 
										value="" />
									<cfif isDefined("qLibraryList.label")>#arguments.stMetadata.ftFirstListLabel#</cfif>
								</label>
							</cfif>
							<cfloop query="qLibraryList">
								<label for="#arguments.fieldname#_#replace(qLibraryList.objectid,'-','','ALL')#">
									<input type="#arguments.stMetadata.ftRenderType#" 
										id="#arguments.fieldname#_#replace(qLibraryList.objectid,'-','','ALL')#" 
										name="#arguments.fieldname#" class="formCheckbox #arguments.stMetadata.ftclass#"
										<cfif isSimpleValue(arguments.stObject[arguments.stMetaData.Name]) and arguments.stObject[arguments.stMetaData.Name] EQ qLibraryList.objectid> 
										checked="checked"
										<cfelseif isArray(arguments.stObject[arguments.stMetaData.Name]) and listFindNoCase(getJoinList(arguments.stObject[arguments.stMetaData.Name]),qLibraryList.objectid)>
										checked="checked"
										</cfif> 
										value="#qLibraryList.objectid#" />
									<skin:view objectid="#qLibraryList.objectid#" webskin="#arguments.stMetadata.ftLibrarySelectedWebskin#" alternateHTML="#qLibraryList.label#" />
								</label>
							</cfloop>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />

							</cfoutput>
							
						<cfelse>
							<!--- todo: i18n --->
							<cfoutput>
							<em>No options available.</em>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
							</cfoutput>
						</cfif>
					</grid:div>
				</cfsavecontent>
			
			</cfcase>
		
			<cfdefaultcase>
				<cfif arguments.stMetadata.type EQ "array">
					<cfset joinItems = getJoinList(arguments.stObject[arguments.stMetadata.name]) />
				<cfelse>
					<cfset joinItems = arguments.stObject[arguments.stMetadata.name] />
				</cfif>
				
			
			
				<cfsavecontent variable="returnHTML">	
					<grid:div class="multiField">

					<cfif listLen(joinItems)>
						<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
							<cfset counter = 0 />
							<cfloop list="#joinItems#" index="i">
								<cfset counter = counter + 1 />
								<cftry>
									<skin:view objectid="#i#" webskin="librarySelected" r_html="htmlLabel" />
									<cfcatch type="any">
										<cfset htmlLabel = "<span title='#application.fc.lib.esapi.encodeForHTMLAttribute(cfcatch.message)#'>OBJECT NO LONGER EXISTS</span>" />
									</cfcatch>
								</cftry>
								<cfoutput>
								<li id="join-item-#arguments.stMetadata.name#-#i#" class="sort #iif(counter mod 2,de('oddrow'),de('evenrow'))#" serialize="#i#" style="border:1px solid ##ebebeb;padding:5px;zoom:1;">
									<table style="width:100%;">
									<tr>
									<td class="" style="cursor:move;padding:3px;"><i class="fa fa-sort"></i></td>
									<td class="" style="cursor:move;width:100%;padding:3px;">#htmlLabel#</td>
									<td class="" style="padding:3px;white-space:nowrap;">
										
										<cfif stActions.ftAllowEdit>
											<ft:button
												Type="button" 
												priority="secondary"
												class="small"
												value="Edit"
												text="Edit" 
												onClick="fcForm.openLibraryEdit('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
								
										</cfif>
										
										<cfif stActions.ftRemoveType EQ "delete">
											<ft:button
												Type="button" 
												priority="secondary"
												class="small"
												value="Delete" 
												text="Delete" 
												confirmText="Are you sure you want to delete this item? Doing so will immediately remove this item from the database." 
												onClick="fcForm.deleteLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
										<cfelseif stActions.ftRemoveType EQ "remove">
											<ft:button
												Type="button" 
												priority="secondary"
												class="small"
												value="Remove" 
												text="Remove" 
												confirmText="Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database." 
												onClick="fcForm.detachLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
								 
										</cfif>
										
									</td>
									</tr>
									</table>
								</li>
								</cfoutput>	
							</cfloop>
						<cfoutput></ul></cfoutput>
						
						<cfoutput><input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#joinItems#" /></cfoutput>
					<cfelse>
						<cfoutput><input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
					</cfif>
					
					<ft:buttonPanel style="border:none; text-align:left;">
						
					<cfoutput>

							<cfif arguments.stMetadata.ftAllowCreate>

								<cfif listLen(arguments.stMetadata.ftJoin) GT 1>
									<div class="btn-group">
										<a class="btn dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> Create &nbsp;&nbsp;<i class="fa fa-caret-down" style="margin-right:-4px;"></i></a>
										<ul class="dropdown-menu">
											<cfloop list="#arguments.stMetadata.ftJoin#" index="i">
												<li value="#trim(i)#"><a onclick="$j('###arguments.fieldname#-add-type').val('#trim(i)#'); fcForm.openLibraryAdd('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');">#application.fapi.getContentTypeMetadata(i, 'displayname', i)#</a></li>
											</cfloop>
										</ul>
									</div>
								<cfelse>
									<a class="btn" onclick="fcForm.openLibraryAdd('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');"><i class="fa fa-plus"></i> Create</a>
								</cfif>
								<input type="hidden" id="#arguments.fieldname#-add-type" value="#arguments.stMetadata.ftJoin#" />

							</cfif>
							
							<cfif arguments.stMetadata.ftAllowBulkUpload and arguments.stMetadata.type eq "array">

								<cfset lBulkUploadable = "" />
								<cfloop list="#arguments.stMetadata.ftJoin#" index="i">
									<cfif application.stCOAPI[i].bBulkUpload>
										<cfset lBulkUploadable = listappend(lBulkUploadable,i) />
									</cfif>
								</cfloop>

								<cfif listLen(lBulkUploadable) GT 1>
									<div class="btn-group">
										<a class="btn dropdown-toggle" data-toggle="dropdown"><i class="fa fa-cloud-upload"></i> Bulk Upload &nbsp;&nbsp;<i class="fa fa-caret-down" style="margin-right:-4px;"></i></a>
										<ul class="dropdown-menu">
											<cfloop list="#lBulkUploadable#" index="i">
												<li value="#trim(i)#"><a id="#arguments.fieldname#-bulkupload-btn" onclick="$j('###arguments.fieldname#-bulkupload-type').val('#trim(i)#'); fcForm.openLibraryBulkUpload('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');">#application.fapi.getContentTypeMetadata(i, 'displayname', i)#</a></li>
											</cfloop>
										</ul>
									</div>
									<input type="hidden" id="#arguments.fieldname#-bulkupload-type" value="#lBulkUploadable#" />
								<cfelseif len(lBulkUploadable)>
									<a class="btn" onclick="fcForm.openLibraryBulkUpload('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');"><i class="fa fa-cloud-upload"></i> Bulk Upload</a>
									<input type="hidden" id="#arguments.fieldname#-bulkupload-type" value="#lBulkUploadable#" />
								</cfif>

							</cfif>
							
							<cfif stActions.ftAllowSelect>
								<a class="btn" onclick="fcForm.openLibrarySelect('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');"><i class="fa fa-search"></i> Select</a>
							</cfif>
							
							<cfif listLen(joinItems) and arguments.stMetadata.ftAllowRemoveAll>
								
								<cfif stActions.ftRemoveType EQ "delete">
									<ft:button	Type="button" 
												priority="secondary"
												class="small"
												value="Delete All" 
												text="delete all" 
												confirmText="Are you sure you want to delete all the attached items?"
												onClick="fcForm.deleteAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />
								<cfelseif stActions.ftRemoveType EQ "remove">
									<ft:button	Type="button" 
												priority="secondary"
												class="small"
												value="Remove All" 
												text="remove all" 
												confirmText="Are you sure you want to remove all the attached items?"
												onClick="fcForm.detachAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />
									
								</cfif>
							</cfif>
						
					</cfoutput>
					</ft:buttonPanel>
					<cfoutput>
						<script type="text/javascript">
						$j(function() {
							fcForm.initSortable('#arguments.stobject.typename#','#arguments.stobject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');
						});
						</script>
					</cfoutput>
					</grid:div>
				</cfsavecontent>
			</cfdefaultcase>
			
			
		</cfswitch>
		
		<cfif structKeyExists(request, "hideLibraryWrapper") AND request.hideLibraryWrapper>
			<cfreturn "#returnHTML#" />
		<cfelse>
			<cfreturn "<div id='#arguments.fieldname#-library-wrapper'>#returnHTML#</div>" />	
		</cfif>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var returnHTML = ""/>
		<cfset var i = "" />
		<cfset var o = "" />
		<cfset var q = "" />
		<cfset var ULID = "" />
		<cfset var stobj = "" />
		<cfset var html = "" />
		<cfset var oData = "" />

		<cfset arguments.stMetadata = prepMetadata(stObject = arguments.stObject, stMetadata = arguments.stMetadata) />

		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		<cfparam name="arguments.stMetadata.ftJoin" default="">
		
		<!--- We need to get the Array Field Items as a query --->
		<cfset o = createObject("component",application.stcoapi[arguments.typename].packagepath)>
		
		<cfif arguments.stMetadata.type EQ "array">
			<cfset q = o.getArrayFieldAsQuery(objectid="#arguments.stObject.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftJoin="#stMetadata.ftJoin#")>
			
			<cfsavecontent variable="returnHTML">
			<cfoutput>
					
				<cfset ULID = "#arguments.fieldname#_list">
				
				<cfif q.RecordCount>
				 
					<div id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
						<cfloop query="q">
							<!---<li id="#arguments.fieldname#_#q.objectid#"> --->
								
								<div>
									<cfif listContainsNoCase(arguments.stMetadata.ftJoin,q.typename)>
										<cfset oData = createObject("component",application.stcoapi[q.typename].packagepath) />
										<cfset stobj = oData.getData(objectid=q.data) />
										<cfif FileExists("#application.path.project#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm")>
											<cfset html = oData.getView(stObject=stobj,template="#arguments.stMetadata.ftLibrarySelectedWebskin#") />
											#html#								
											<!---<cfinclude template="/farcry/projects/#application.projectDirectoryName#/webskin/#q.typename#/#arguments.stMetadata.ftLibrarySelectedWebskin#.cfm"> --->
										<cfelse>
											#stobj.label#
										</cfif>
									<cfelse>
										INVALID ATTACHMENT (#q.typename#)
									</cfif>
								</div>
														
							<!---</li> --->
						</cfloop>
					</div>
				</cfif>
	
					
			</cfoutput>
			</cfsavecontent>			
		<cfelseif len(arguments.stObject[arguments.stMetaData.Name])>
			<cfset stobj = application.fapi.getContentObject(objectid=arguments.stObject[arguments.stMetaData.Name])>
			<cfset returnHTML = application.fapi.getContentType("#stobj.typename#").getView(stObject=stobj, template=arguments.stMetaData.ftLibrarySelectedWebskin, alternateHtml=stobj.label) />
		</cfif>
		
		

		<cfreturn returnHTML>
	</cffunction>


	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var aField = ArrayNew(1) />
		<cfset var qArrayRecords = queryNew("blah") />
		<cfset var stResult = structNew()>
		<cfset var i = "" />
		<cfset var lColumn = "" />
		<cfset var qArrayRecordRow = queryNew("blah") />
		<cfset var stArrayData = structNew() />
		<cfset var iColumn = "" />
		<cfset var qCurrentArrayItem = queryNew("blah") />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<!---
		IT IS IMPORTANT TO NOTE THAT THE STANDARD ARRAY TABLE UI, PASSES IN A LIST OF DATA IDS WITH THEIR SEQ
		ie. dataid1:seq1,dataid2:seq2...
		 --->
		
		<cfif listLen(stFieldPost.value)>
			<!--- Remove any leading or trailing empty list items --->
			<cfif stFieldPost.value EQ ",">
				<cfset stFieldPost.value = "" />
			</cfif>
			<cfif left(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = right(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>
			<cfif right(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = left(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>	
					
			<cfquery datasource="#application.dsn#" name="qArrayRecords">
		    SELECT * 
		    FROM #application.dbowner##arguments.typename#_#stMetadata.name#
		    WHERE parentID = '#arguments.objectid#'
		    </cfquery>
		    	
			
			<cfloop list="#stFieldPost.value#" index="i">			
						
				<cfquery dbtype="query" name="qCurrentArrayItem">
			    SELECT * 
			    FROM qArrayRecords
			    WHERE data = '#listFirst(i,":")#'
			    <cfif listLast(i,":") NEQ listFirst(i,":")><!--- SEQ PASSED IN --->
			    	AND seq = '#listLast(i,":")#'
			    </cfif>
			    </cfquery>
			
				<!--- If it is an extended array (more than the standard 4 fields), we return the array as an array of structs --->
				<cfif listlen(qCurrentArrayItem.columnlist) GT 4>
					<cfset stArrayData = structNew() />
					
					<cfloop list="#qCurrentArrayItem.columnList#" index="iColumn">
						<cfif qCurrentArrayItem.recordCount>
							<cfset stArrayData[iColumn] = qCurrentArrayItem[iColumn][1] />
						<cfelse>
							<cfset stArrayData[iColumn] = "" />
						</cfif>
					</cfloop>
					
					<cfset stArrayData.seq = arrayLen(aField) + 1 />
					 
					<cfset ArrayAppend(aField,stArrayData)>
				<cfelse>
					<!--- Otherwise it is just an array of value --->
					<cfset ArrayAppend(aField, listFirst(i,":"))>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset stResult.value = aField>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


	<!------------------ 
	FILTERING FUNCTIONS
	 ------------------>	
	<cffunction name="getFilterUIOptions">
		<cfreturn "related to" />
	</cffunction>
		
	<cffunction name="displayFilterUI">
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var i = "" />
		<cfset var labelHTML = "" />
		

		<cfswitch expression="#arguments.filterType#">
			<cfcase value="related to">
				<cfparam name="arguments.stFilterProps.aRelated" default="#arrayNew(1)#" />
				<cfif arrayLen(arguments.stFilterProps.aRelated)>
					<cfloop from="1" to="#arrayLen(arguments.stFilterProps.aRelated)#" index="i">
						<skin:view objectid="#arguments.stFilterProps.aRelated[i]#" webskin="displayLabel" r_html="labelHTML" />
						<cfset resultHTML = listAppend(resultHTML, "#labelHTML#") />
					</cfloop>		
				</cfif>		
			</cfcase>		
		</cfswitch>
		<cfreturn resultHTML />
	</cffunction>
	

	<cffunction name="getFilterSQL">
		
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" default="relatedto" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var stArrayPropMetadata = application.fapi.getPropertyMetadata(arguments.filterTypename, arguments.filterProperty) />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="related to">
					<cfparam name="arguments.stFilterProps.aRelated" default="#arrayNew(1)#" />
					<cfif arrayLen(arguments.stFilterProps.aRelated)>

						<cfif stArrayPropMetadata.type EQ "array">
						
							<cfoutput>
								objectid IN (
									
									SELECT parentID
									FROM #arguments.filterTypename#_#arguments.filterProperty#
									WHERE data IN (#ListQualify(arrayToList(arguments.stFilterProps.aRelated),"'",",","ALL")#)
																						
								)
							</cfoutput>
						<cfelse>
							<cfoutput>#arguments.filterProperty# IN (#ListQualify(arrayToList(arguments.stFilterProps.aRelated),"'",",","ALL")#)</cfoutput>
						</cfif>
					</cfif>
				</cfcase>
				
			
			</cfswitch>
			
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>		
	
			
		
	<cffunction name="libraryCallback" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset var returnHTML = "" />
		<cfset var stobj = structnew() />
		<cfset var i = "" />
		<cfset var qArrayField = queryNew("blah") />
		<cfset var oPrimary = "" />
		<cfset var qLibraryList = queryNew("blah") />
		<cfset var ULID = "" />
		<cfset var HTML = "" />
		<cfset var stTemp = structNew() />
		<cfset var dataID = "" />
		<cfset var dataLabel = "" />
		<cfset var dataSEQ = "" />
		<cfset var dataTypename = "" />
		<cfset var oData = "" />
		<cfset var stO = structNew() />
		<cfset var libraryData = "" />
		
		<cfset arguments.stMetadata = prepMetadata(stObject = arguments.stObject, stMetadata = arguments.stMetadata) />
		
		<!---
		<cfset var oFourQ = createObject("component","farcry.core.packages.fourq.fourq")><!--- TODO: this needs to be removed when we add typename to array tables. ---> 
		 --->
		<cfparam name="arguments.stMetadata.ftLibrarySelectedWebskin" default="librarySelected" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="arrayDetail" type="string" />
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemWidth" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLibraryListItemHeight" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Library" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="10" type="numeric" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="string" />
		<cfparam name="arguments.stMetadata.ftAllowLibraryEdit" default="false">
		<cfparam name="arguments.stMetadata.ftLibraryEditWebskin" default="edit">
		<cfparam name="arguments.stMetadata.ftLibraryData" default="" /><!--- Name of a function to return the library data --->
		<cfparam name="arguments.stMetadata.ftLibraryDataTypename" default="" /><!--- Typename containing the function defined in ftLibraryData --->

		<!--- An array type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(arguments.stMetadata,"ftJoin") or not len(arguments.stMetadata.ftJoin)>
			<cfreturn "">
		</cfif>

		<!--- Make sure scriptaculous libraries are included. --->
		<cfset Request.InHead.ScriptaculousDragAndDrop = 1>
		<cfset Request.InHead.ScriptaculousEffects = 1>	
		
			
		<cfquery datasource="#application.dsn#" name="qArrayField">
		SELECT *
		FROM #arguments.typename#_#arguments.stMetaData.Name#
		WHERE parentID = '#arguments.stObject.objectID#'
		ORDER BY seq
		</cfquery>	
		
		<!--------------------------------------------- 
		RENDER TYPE SWITCH
			- select specific form element output
 		----------------------------------------------->
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="list">
				
				<!-------------------------------------------------------------------------- 
				generate library data query to populate library interface 
				--------------------------------------------------------------------------->
				<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
					<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
						<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
					</cfif>
					<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
					
					<!--- use ftlibrarydata method from primary content type --->
					<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
						<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
							<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
							<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
						</cfinvoke>	
							
						<cfif isStruct(libraryData)>
							<cfset qLibraryList = libraryData.q>
						<cfelse>
							<cfset qLibraryList = libraryData />
						</cfif>		
						
					</cfif>
				</cfif>
				<!--- if nothing exists to generate library data then cobble something together --->
				<cfif NOT isDefined("qLibraryList")>
					<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
				</cfif>
		
				<cfsavecontent variable="returnHTML">
				<cfif qLibraryList.recordcount>
					<cfoutput>
					<select  id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" multiple="#arguments.stMetadata.ftSelectMultiple#" class="selectInput #arguments.stMetadata.class#">
					<cfloop query="qLibraryList"><option value="#qLibraryList.objectid#"<cfif valuelist(qArrayField.data) contains qLibraryList.objectid> selected="selected"</cfif>><cfif isDefined("qLibraryList.label")>#qLibraryList.label#<cfelse>#qLibraryList.objectid#</cfif></option></cfloop>
					</select>
					</cfoutput>
					
				<cfelse>
					<!--- todo: i18n --->
					<cfoutput>
					<em>No options available.</em>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					</cfoutput>
				</cfif>
				
				</cfsavecontent>
			
			</cfcase>
			
			<cfcase value="radio">
				<!-------------------------------------------------------------------------- 
				generate library data query to populate library interface 
				--------------------------------------------------------------------------->
				<cfif structkeyexists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>	
					<cfif not structKeyExists(stMetadata, "ftLibraryDataTypename") OR not len(stMetadata.ftLibraryDataTypename)>
						<cfset stMetadata.ftLibraryDataTypename = arguments.typename />
					</cfif>
					<cfset oPrimary = application.fapi.getContentType(stMetadata.ftLibraryDataTypename) />
					
					<!--- use ftlibrarydata method from primary content type --->
					<cfif structkeyexists(oprimary, stMetadata.ftLibraryData)>
						<cfinvoke component="#oPrimary#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
							<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
							<cfinvokeargument name="qFilter" value="#queryNew('objectid')#" />
						</cfinvoke>	
							
						<cfif isStruct(libraryData)>
							<cfset qLibraryList = libraryData.q>
						<cfelse>
							<cfset qLibraryList = libraryData />
						</cfif>		
						
					</cfif>
				</cfif>
				<!--- if nothing exists to generate library data then cobble something together --->
				<cfif NOT isDefined("qLibraryList")>
					<cfset qLibraryList = createObject("component", application.types[listFirst(arguments.stMetadata.ftJoin)].typepath).getLibraryData() />
				</cfif>
	
				<cfsavecontent variable="returnHTML">
				<cfif qLibraryList.recordcount>
					<cfoutput>
					
					<cfif len(arguments.stMetadata.ftFirstListLabel)>
						<label for="#arguments.fieldname#_none">
							<input type="radio" 
								id="#arguments.fieldname#_none" 
								name="#arguments.fieldname#" class="formCheckbox #arguments.stMetadata.ftclass#"
								<cfif arguments.stObject[arguments.stMetaData.Name] EQ ""> checked</cfif> 
								value="" />
							<cfif isDefined("qLibraryList.label")>#arguments.stMetadata.ftFirstListLabel#</cfif>
						</label>
					</cfif>
					<cfloop query="qLibraryList">
						<label for="#arguments.fieldname#_#replace(qLibraryList.objectid,'-','','ALL')#">
							<input type="radio" 
								id="#arguments.fieldname#_#replace(qLibraryList.objectid,'-','','ALL')#" 
								name="#arguments.fieldname#" class="formCheckbox #arguments.stMetadata.ftclass#"
								<cfif arguments.stObject[arguments.stMetaData.Name] EQ qLibraryList.objectid> checked</cfif> 
								value="#qLibraryList.objectid#" />
							<skin:view objectid="#qLibraryList.objectid#" webskin="#arguments.stMetadata.ftLibrarySelectedWebskin#" alternateHTML="#qLibraryList.label#" />
						</label>
					</cfloop>
					</cfoutput>
					
				<cfelse>
					<!--- todo: i18n --->
					<cfoutput>
					<em>No options available.</em>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
					</cfoutput>
				</cfif>
				
				</cfsavecontent>
			
			</cfcase>
			
			<cfdefaultcase>
			
				<!--- ID of the unordered list. Important to use this so that the object can be referenced even if their are multiple objects referencing the same field. --->
				<cfset ULID = "#arguments.fieldname#_list">
				
				<cfsavecontent variable="returnHTML">
					
					<cfoutput>
					<ul id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#View" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
					</cfoutput>				
	
					<cfif qArrayField.Recordcount>
						
						<!-----------------------
						NEW ARRAY LAYOUT
						 ----------------------->					
						<cfloop query="qArrayField">
							
							<cfset dataID = qArrayField.data />
							<cfset dataSEQ = qArrayField.seq />
							<cfset dataTypename = qArrayField.typename />
							<cfset HTML = "" />
						
	 						<cfif isDefined("qArrayField.label") AND len(qArrayField.label)>
								<cfset variables.alternateHTML = qArrayField.Label />
							<cfelse>
								<cfset variables.alternateHTML = "" />
							</cfif>
					
							<!--- if typename is missing from query (ie. array data is corrupted) --->
							<cfif NOT len(dataTypename)>
								<cfset dataTypename=application.coapi.coapiUtilities.findtype(objectid=dataID) />
								<cfif NOT len(dataTypename)>
									<cfset HTML = "Object Not Found">
								</cfif>
							</cfif> 
							<cfif NOT len(HTML)>
								<cfif not structKeyExists(stO, dataTypename) >
									<cfset stO[dataTypename] = createObject("component",application.stcoapi[dataTypename].packagepath) />
								</cfif>
								<cfset HTML = stO[dataTypename].getView(objectID="#dataID#", template="#arguments.stMetadata.ftLibrarySelectedWebskin#", alternateHTML=variables.alternateHTML) />
								<cfif NOT len(trim(HTML))>
									<cfset stTemp = stO[dataTypename].getData(objectid=dataID) />
									<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
										<cfset HTML = stTemp.label />
									<cfelse>
										<cfset HTML = stTemp.objectid />
									</cfif>
								</cfif>
							</cfif>
							
							<cfoutput>							
							<li id="#arguments.fieldname#_#dataID#:#dataSEQ#" class="#ULID#handle" style="<cfif len(arguments.stMetadata.ftLibraryListItemWidth)>width:#arguments.stMetadata.ftLibraryListItemWidth#;</cfif><cfif len(arguments.stMetadata.ftLibraryListItemheight)>height:#arguments.stMetadata.ftLibraryListItemHeight#;</cfif>">
								<div class="buttonGripper"><p>&nbsp;</p></div>
															
								<input type="checkbox" name="#arguments.fieldname#Selected" id="#arguments.fieldname#Selected" class="checkboxInput #arguments.fieldname#Selected" value="#dataID#:#dataSEQ#" />
	
								<div class="#arguments.stMetadata.ftLibrarySelectedListClass#">
									<p>#HTML#</p>
								</div>
									
							</li>
							</cfoutput>
						</cfloop>
						
					</cfif>
	
					<cfoutput>
					</ul>
					</cfoutput>
					
				
				</cfsavecontent>
			</cfdefaultcase>
		</cfswitch>
		
 		<cfreturn ReturnHTML />

	</cffunction>

	<cffunction name="getJoinList" access="public" output="false" returntype="string">
		<cfargument name="values" type="array" required="true" />

		<cfset var joinItems = "" />

		<cfif arraylen(arguments.values) and issimplevalue(arguments.values[1])>
			<cfset joinItems = arrayToList(arguments.values) />
		<cfelseif arraylen(arguments.values)>
			<cfset joinItems = "" />
			<cfloop from="1" to="#arraylen(arguments.values)#" index="i">
				<cfset joinItems = listappend(joinItems,arguments.values[i].data) />
			</cfloop>
		</cfif>

		<cfreturn joinItems />
	</cffunction>
			
</cfcomponent>