<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">



<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-underscore" />
<skin:loadJS id="fc-backbone" />
<skin:loadJS id="fc-handlebars" />
<skin:loadJS id="farcry-form" />
<skin:loadJS id="fc-farcry-devicetype" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadJS id="fc-moment" />
<skin:loadCSS id="jquery-ui" />
<skin:loadCSS id="objectadmin-ie7" />


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.typename" default="" />
	<cfparam name="attributes.columnlist" default="label,datetimelastupdated" />

	<cfparam name="form.q" default="">
	<cfparam name="form.Criteria" default="" />

	<cfparam name="pluginURL" default="" /><!--- used in case we are in a plugin object admin --->

	<cfparam name="session.objectadmin" default="#structnew()#" type="struct">

	<cfparam name="attributes.title" default="" type="string">
	<cfif not len(attributes.title)>
		<cfset attributes.title = application.rb.getResource("coapi.#attributes.typename#.headings.typeadministration@text", application.rb.getResource("objectadmin.general.headings.typeadministration@text", "{1} Administration"))>
	</cfif>

	<cfparam name="attributes.ColumnList" default="" type="string">
	<cfparam name="attributes.SortableColumns" default="" type="string">
	<cfparam name="attributes.lFilterFields" default="" type="string">
	<cfparam name="attributes.bFilterValidation" default="0" type="boolean">
	<cfparam name="attributes.description" default="" type="string">
	<cfparam name="attributes.datasource" default="#application.dsn#" type="string">
	<cfparam name="attributes.aColumns" default="#arrayNew(1)#" type="array">
	<cfparam name="attributes.aCustomColumns" default="#arrayNew(1)#" type="array">
	<cfparam name="attributes.lCustomColumns" default="" type="string"><!--- A list of column label:webskin values --->
	<cfparam name="attributes.aButtons" default="#arrayNew(1)#" type="array">
	<cfparam name="attributes.bdebug" default="false" type="boolean">
	<cfparam name="attributes.bFilterCategories" default="true" type="boolean">
	<cfparam name="attributes.bFilterDateRange" default="true" type="boolean">
	<cfparam name="attributes.bFilterProperties" default="true" type="boolean">
	<cfparam name="attributes.permissionset" default="#attributes.typename#" type="string">
	<!--- attributes.query type="query" CF7 specific --->
	<cfparam name="attributes.defaultorderby" default="datetimelastupdated" type="string">
	<cfparam name="attributes.defaultorder" default="desc" type="string">
	<cfparam name="attributes.id" default="#attributes.typename#" type="string">
	<cfparam name="attributes.sqlorderby" default="datetimelastupdated desc" type="string" />
	<cfparam name="attributes.sqlWhere" default="" />
	<cfparam name="attributes.lCategories" default="" />
	<cfparam name="attributes.name" default="objectadmin" />

	<!--- admin configuration options --->
	<cfparam name="attributes.numitems" default="#application.fapi.getConfig("general","GENERICADMINNUMITEMS")#" type="numeric">
	<cfparam name="attributes.numPageDisplay" default="5" type="numeric">

	<cfparam name="attributes.lButtons" default="*" type="string">
	<cfparam name="attributes.lButtonsEmpty" default="add,bulk upload,undelete" type="string">
	<cfparam name="attributes.bPaginateTop" default="false" type="boolean">
	<cfparam name="attributes.bPaginateBottom" default="true" type="boolean">
	<cfparam name="attributes.bDisplayTotalRecords" default="true" type="boolean" />

	<cfparam name="attributes.bCheckAll" default="true" type="boolean" />
	<cfparam name="attributes.bSelectCol" default="true" type="boolean">
	<cfparam name="attributes.bEditCol" default="true" type="boolean">
	<cfparam name="attributes.bViewCol" default="true" type="boolean">
	<cfparam name="attributes.bFlowCol" default="true" type="boolean">
	<cfparam name="attributes.bPreviewCol" default="true" type="boolean">

	<cfparam name="attributes.previewWebskin" default="" type="string"><!--- Nominate a specific view for the preview; defaults to system default --->

	<cfparam name="attributes.editMethod" default="edit" type="string">
	<cfparam name="attributes.copyMethod" default="copy" type="string">

	<cfparam name="attributes.PackageType" default="types" type="string">

	<cfparam name="attributes.module" default="customlists/#attributes.typename#.cfm">
	<cfparam name="attributes.plugin" default="" />
	<cfparam name="attributes.lCustomActions" default="" />
	<cfparam name="attributes.stFilterMetaData" default="#structNew()#" />
	<cfparam name="attributes.bShowActionList" default="true" />
	<cfparam name="attributes.qRecordSet" default=""><!--- Used if the developer wants to pass in their own recordset --->

	<cfparam name="attributes.rbkey" default="coapi.#attributes.typename#.objectadmin" />
	<cfparam name="attributes.addUrlParams" default="#structnew()#" /><!--- if any extra params need to be passed into the add screen need to a struct e.g paramStruct.parentid='whatever'--->
	<cfparam name="attributes.copyUrlParams" default="#structnew()#" /><!--- if any extra params need to be passed into the copy screen need to a struct e.g paramStruct.parentid='whatever'--->
	<cfparam name="attributes.editUrlParams" default="#structnew()#" /><!--- if any extra params need to be passed into the edit screen need to a struct e.g paramStruct.parentid='whatever'--->

	<cfparam name="attributes.emptymessage" default="You do not currently have any content. Use the [Add] button above to begin." />

	<!--- Convert attributes.lCustomColumns to array of structs --->
	<cfif listLen(attributes.lCustomColumns)>
		<cfloop list="#attributes.lCustomColumns#" index="i">
			<cfset stCustomColumn = structNew() />
			<cfset stCustomColumn.title = listFirst(i,":") />
			<cfset stCustomColumn.webskin = listLast(i,":") />
			<cfset arrayAppend(attributes.aCustomColumns, stCustomColumn) />
		</cfloop>
	</cfif>

	<!--- I18 conversion off text output attributes --->
	<cfset attributes.description = application.rb.getResource("#attributes.rbkey#.description@text",attributes.description) />

	<cfif structkeyexists(application.stCOAPI[attributes.typename],"displayname") and len(application.stCOAPI[attributes.typename].displayname)>
		<cfset typelabel = application.stCOAPI[attributes.typename].displayname />
	<cfelse>
		<cfset typelabel = attributes.typename />
	</cfif>

	<cfif NOT structKeyExists(session.objectadmin, attributes.typename)>
		<cfset structInsert(session.objectadmin, attributes.typename, structnew())>
	</cfif>

	<cfset PrimaryPackage = duplicate(application.stCOAPI[attributes.typename]) />
	<cfset PrimaryPackagePath = application.stCOAPI[attributes.typename].packagepath />

	<cfif not len(attributes.sqlWhere)>
		<cfset attributes.sqlWhere = "0=0" />
	</cfif>

	<!--- Make sure the type is deployed --->
	<cfset alterType = createObject("component","farcry.core.packages.farcry.alterType") />

	<!--- Deploy type if it has been requested --->
	<cfif structkeyexists(url,"deploy") and url.deploy>
		<cfset application.fc.lib.db.deployType(typename=attributes.typename,bDropTable=true,dsn=application.dsn) />
		<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
	</cfif>

	<!--- If type isn't deployed, display error --->
	<cfif not structkeyexists(attributes,"qRecordSet") and not application.fc.lib.db.isDeployed(typename=attributes.typename,dsn=application.dsn)>

		<cfoutput>
			<h1><admin:resource key="#attributes.rbkey#@title" var1="#typelabel#">#attributes.title#</admin:resource></h1>
			<p>The '<cfif structkeyexists(application.stCOAPI[attributes.typename],"displayname")>#application.stCOAPI[attributes.typename].displayname#<cfelse>#listlast(application.stCOAPI[attributes.typename].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</p>
		</cfoutput>
		<cfexit method="exittag" />
		
	<cfelse>

		<cfset oTypeAdmin = createobject("component", "#application.packagepath#.farcry.objectadmin").init(stprefs=session.objectadmin[attributes.typename], attributes=attributes)>

		<cfif isDefined("attributes.r_oTypeAdmin")>
			<cfset caller[attributes.r_oTypeAdmin]=oTypeAdmin>
		</cfif>	
	</cfif>

</cfif>


<cfif thistag.executionMode eq "End">
	
	<skin:loadCSS id="fc-fontawesome" />
	
	<cfif len(attributes.title)>
		<cfoutput>
		<h1>
			<cfif len(application.stCOAPI[attributes.typename].icon)>
				<i class="fa #application.stCOAPI[attributes.typename].icon#"></i>
			<cfelse>
				<i class="fa fa-file-o"></i>
			</cfif>
			<admin:resource key="#attributes.rbkey#@title" var1="#typelabel#">#attributes.title#</admin:resource>
		</h1>
		</cfoutput>
	</cfif>
	
	<cfset stPrefs = oTypeAdmin.getPrefs() />
	<cfset stpermissions=oTypeAdmin.getBasePermissions()>
	
	
	<!--- IF javascript has set the selected objectid, set the form.objectid to it. --->
	<cfif isDefined("FORM.selectedObjectID") and len(form.selectedObjectID)>
		<cfset form.objectid = form.selectedObjectID />
	</cfif>
	
	
	<ft:processform action="delete" url="refresh">
		<cfif isDefined("form.objectid") and len(form.objectID)>
			
			<cfloop list="#form.objectid#" index="i">
				<cfset o = application.fapi.getContentType(attributes.typename) />
				<cfset stDeletingObject = o.getData(objectid=i) />
				<cfset stResult = o.delete(objectid=i) />
				
				<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>
					<skin:bubble title="Error deleting - #stDeletingObject.label#" bAutoHide="true" tags="type,#attributes.typename#,error">
						<cfoutput>#stResult.message#</cfoutput>
					</skin:bubble>
				<cfelse>
					<skin:bubble title="Deleted - #stDeletingObject.label# <a class='undo-delete' href='#application.url.webtop#/index.cfm?typename=dmArchive&bodyView=webtopBody&archivetype=#attributes.typename#' style='margin-left:10px;'>undo</a>" bAutoHide="true" tags="type,#attributes.typename#,deleted,info" />
				</cfif>
			</cfloop>
		</cfif>
	</ft:processForm>
	
	<ft:processform action="unlock" url="refresh"> 
		<cfif isDefined("form.objectid") and len(form.objectID)>
			
			<cfloop list="#form.objectid#" index="i">
				<cfset application.fapi.getContentType(attributes.typename).setlock(objectid="#i#", locked="false") />
			</cfloop>
		
		</cfif>
		
	</ft:processForm>


	<cfparam name="session.objectadminFilterObjects" default="#structNew()#" />
	<cfif not structKeyExists(session.objectadminFilterObjects, attributes.typename)>
		<cfset session.objectadminFilterObjects[attributes.typename] = structNew() />
	</cfif>

	<!--- set the quick filter in the session and always start at page 1 for new searches --->
	<cfif isDefined("form.btnsearch") and form.btnsearch eq 1>
		<cfset session.objectadminFilterObjects[attributes.typename].q = form.q />
		<cfset session.ftpagination[attributes.typename] = 1 />
	</cfif>

	<!--- clear the quick filter from the session and reset the pagingation --->
	<cfif isDefined("form.clearfilter") and form.clearfilter eq 1>
		<cfset form.q = "">
		<cfset session.objectadminFilterObjects[attributes.typename] = structNew() />
		<cfset session.objectadminFilterObjects[attributes.typename].q = "" />
		<cfset session.ftpagination[attributes.typename] = 1 />
	</cfif>

	<cfparam name="session.objectadminFilterObjects.#attributes.typename#.q" default="" />


	<cfif len(attributes.lFilterFields) OR len(session.objectadminFilterObjects[attributes.typename].q)>

			<cfset oFilterType = createObject("component", PrimaryPackagePath) />

			<cfif not structKeyExists(session.objectadminFilterObjects[attributes.typename], "stObject")>
				
				<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectid="#application.fc.utils.createJavaUUID()#") />
				
							
				<cfset session.objectadminFilterObjects[attributes.typename].stObject.label = "" />
				
				<!--- The default filter doesn't incorporate the default values specified in stFilterMetadata. This loop handles that gap. --->
				<cfloop collection="#attributes.stFilterMetadata#" item="prop">
					<cfif structkeyexists(attributes.stFilterMetadata[prop],"ftDefault")>
						<cfset session.objectadminFilterObjects[attributes.typename].stObject[prop] = attributes.stFilterMetadata[prop].ftDefault />
					</cfif>
				</cfloop>
				<cfset stResult = oFilterType.setData(stProperties=session.objectadminFilterObjects[attributes.typename].stObject, bSessionOnly=true) />
			</cfif>
			
			<ft:processform action="apply filter" url="refresh">
				<ft:processformObjects objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" bSessionOnly="true" stPropMetadata="#attributes.stFilterMetadata#" />
			</ft:processForm>
			
			<ft:processform action="clear filter" url="refresh">
				<cfset structDelete(session.objectadminFilterObjects, attributes.typename) />
				<cfset session.ftpagination[attributes.typename] = 1 />
			</ft:processForm>


			<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
	
	
		<!------------------------
		SQL WHERE CLAUSE
		 ------------------------>
	
			<cfsavecontent variable="attributes.sqlWhere">
				
				<cfoutput>
					#attributes.sqlWhere#
				</cfoutput>	
					
					
					<cfloop list="#attributes.lFilterFields#" index="i">
						<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
							<cfswitch expression="#PrimaryPackage.stProps[i].metadata.ftType#">
							
							<cfcase value="string,nstring,list,uuid">	
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset whereValue = ReplaceNoCase(trim(LCase(j)),"'", "''", "all") />
										<cfoutput>AND lower(#i#) LIKE '%#whereValue#%'</cfoutput> 
									</cfloop>
								</cfif>
							</cfcase>
							
							<cfcase value="boolean">	
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset whereValue = ReplaceNoCase(j,"'", "''", "all") />
										<cfoutput>AND lower(#i#) = '#j#'</cfoutput>
									</cfloop>
								</cfif>
							</cfcase>
							
							<cfcase value="category">
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset attributes.lCategories = listAppend(attributes.lCategories, trim(j)) />
									</cfloop>
								</cfif>
							</cfcase>
		
							<cfdefaultcase>	
								
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
								
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfif listcontains("string,nstring,longchar", PrimaryPackage.stProps[i].metadata.type)>
											<cfset whereValue = ReplaceNoCase(trim(j),"'", "''", "all") />
											<cfoutput>AND lower(#i#) LIKE '%#whereValue#%'</cfoutput> 
										<cfelseif listcontains("numeric,integer", PrimaryPackage.stProps[i].metadata.type)>
											<cfset whereValue = ReplaceNoCase(j,"'", "''", "all") />
											<cfif isNumeric(whereValue)>
												<cfoutput>AND #i# = #whereValue#</cfoutput>
											</cfif>
										</cfif>
									</cfloop>
								</cfif>
							</cfdefaultcase>
							
							</cfswitch>
							
						</cfif>
					</cfloop>

				<!--- simple search --->
				<cfoutput>
					<cfif len(session.objectadminFilterObjects[attributes.typename].q) AND (listLen(attributes.lFilterFields) OR structKeyExists(PrimaryPackage.stProps, "label") OR structKeyExists(PrimaryPackage.stProps, "title") OR structKeyExists(PrimaryPackage.stProps, "name"))>
						AND ( 1=2
							<cfloop list="#listPrepend(attributes.lFilterFields, "label,title,name")#" index="i">
								<cfif structKeyExists(PrimaryPackage.stProps, i) AND listFindNoCase("string,nstring,list,uuid", PrimaryPackage.stProps[i].metadata.ftType)>
									<cfset whereValue = replaceNoCase(trim(lcase(session.objectadminFilterObjects[attributes.typename].q)),"'", "''", "all") />
									OR lower(#i#) LIKE '%#whereValue#%'
								</cfif>
							</cfloop>
						)
					</cfif>
				</cfoutput>

			</cfsavecontent>
	
	</cfif>
	
	
	
	<!------------------------
	SQL ORDER BY CLAUSE
	 ------------------------>
	<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = "" />
	<cfif len(attributes.sortableColumns)>
		<cfif isDefined("form.sqlOrderBy") and len(form.sqlOrderby)>
			<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = form.sqlOrderby />
		</cfif>
	</cfif>
	
	<cfif not len(session.objectadminFilterObjects[attributes.typename].sqlOrderBy) >
		<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = attributes.sqlorderby />
	</cfif>
	
			

	<!------------------------
	GENERATE THE RECORDSET
	 ------------------------>
	<cfif isQuery(attributes.qRecordSet)>
		<cfset stRecordSet.q = attributes.qRecordSet>
		
		<cfquery dbtype="query" name="stRecordset.q">
			select		*
			from		stRecordset.q
			where		#preservesinglequotes(attributes.sqlWhere)#
			<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy neq "datetimelastupdated desc">order by	#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#</cfif>
		</cfquery>

		<cfset stRecordSet.countAll = stRecordset.q.recordCount />
		<cfset stRecordSet.currentPage = 0 />
		<cfset stRecordSet.recordsPerPage = attributes.numitems />

	<cfelse>

		<cfset oFormtoolUtil = createObject("component", application.fc.utils.getPath(package="farcry", component="formtools")) />
		
		<cfset sqlColumns="objectid,locked,lockedby" />		
	
		<cfif len(attributes.columnlist)>
			<cfset sqlColumns = listAppend(sqlColumns, attributes.columnlist) />
		</cfif>

		<cfset stRecordset = oFormtoolUtil.getRecordset(paginationID="#attributes.typename#", sqlColumns=sqlColumns, typename="#attributes.typename#", RecordsPerPage="#attributes.numitems#", sqlOrderBy="#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#", sqlWhere="#attributes.sqlWhere#", lCategories="#attributes.lCategories#", bCheckVersions=true) />	
	</cfif>


	<!------------------------
	PROCESS THE FORM
	 ------------------------>
	
	<!--- Various URLs --->
	<cfif Len(attributes.plugin)>
		<cfset pluginURL = "&plugin=#attributes.plugin#" /><!--- we need this when using a plugin like farcrycms, to be able to redirect back to the plugin object admin instead of the project or core object admin --->
	</cfif>
	
	<cfset addURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#application.fc.utils.createJavaUUID()#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=iframe&module=#attributes.module##pluginURL#" />
	<cfif not structIsEmpty(attributes.addUrlParams)>
		<cfloop collection="#attributes.addUrlParams#" item="key">
			<cfset addURL="#addURL#&#key#=#attributes.addUrlParams[key]#">
		</cfloop>
	</cfif>	
	
	<cfif structkeyexists(form,"objectid")>
		<cfset EditURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#listfirst(form.objectid)#&typename=#attributes.typename#&method=#attributes.editMethod#&module=#attributes.module##pluginURL#">
		
		<cfif attributes.bViewCol>
			<cfset EditURL = "#EditURL#&ref=closeDialog" />
		<cfelse>
			<cfset EditURL = "#EditURL#&ref=iframe" />
		</cfif>
		
		<cfif not structIsEmpty(attributes.editUrlParams)>
			<cfloop collection="#attributes.editUrlParams#" item="key">
				<cfset EditURL="#EditURL#&#key#=#attributes.editUrlParams[key]#">
			</cfloop>
		</cfif>
		
		<cfset copyURL = '#application.url.webtop#/conjuror/invocation.cfm?objectid=#listfirst(form.objectid)#&typename=#attributes.typename#&method=#attributes.copyMethod#&ref=iframe&module=#attributes.module##pluginURL#&editURL=#application.fc.lib.esapi.encodeForURL(editURL)#' />
		<cfif not structIsEmpty(attributes.copyUrlParams)>
			<cfloop collection="#attributes.copyUrlParams#" item="key">
				<cfset copyURL="#copyURL#&#key#=#attributes.copyUrlParams[key]#">
			</cfloop>
		</cfif>
	</cfif>
	
	<ft:processForm action="add">
		<skin:onReady>
			<cfoutput>
				$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#addURL#');
			</cfoutput>
		</skin:onReady>
	</ft:processForm>
	
	<ft:processForm action="copy">
		
		<skin:onReady>
			<cfoutput>
				<cfif structkeyexists(form,"objectid")>
					$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#copyURL#');
				<cfelse>
					<cfset message_error = "No Objects Selected">
				</cfif>	
			</cfoutput>
		</skin:onReady>		
	</ft:processForm>
	
	<ft:processForm action="overview">
		<!--- TODO: Check Permissions. --->
		<cfset overviewURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#form.objectid#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=iframe&module=#attributes.module##pluginURL#">
		<skin:onReady>
			<cfoutput>
				$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#overviewURL#');
			</cfoutput>
		</skin:onReady>
	</ft:processForm>
	
	<ft:processForm action="edit">
		<skin:onReady>
			<cfoutput>
				$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#EditURL#');
			</cfoutput>
		</skin:onReady>
	</ft:processForm>
	
	<ft:processForm action="view">
		<!--- TODO: Check Permissions. --->
		<cfif structkeyexists(form,"objectid")>
		<cfoutput>
			<script type="text/javascript">
				var newWin = window.open("#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1","viewWindow","resizable=yes,menubar=yes,scrollbars=yes,width=800,height=600,location=yes");
			</script>
		</cfoutput>
		<cfelse>
			<cfset message_error = "No Objects Selected">	
		</cfif>
		<!--- <cflocation URL="#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1" addtoken="false" /> --->
	</ft:processForm>

	<cfif structKeyExists(application.stPlugins, "flow")>
		<ft:processForm action="flow">
			<!--- TODO: Check Permissions. --->
			<skin:onReady>
				<cfoutput>
					<cfif structkeyexists(form,"objectid")>
						$fc.objectAdminAction('Flow', '#application.stPlugins.flow.url#/?startid=#form.objectid#&flushcache=1');
					<cfelse>
						<cfset message_error = "No Objects Selected">	
					</cfif>	
				</cfoutput>
			</skin:onReady>
		</ft:processForm>
	</cfif>
	
	<ft:processForm action="requestapproval,request approval">
		<!--- TODO: Check Permissions. --->
		<skin:onReady>
			<cfoutput>
				<cfif structkeyexists(form,"objectid")>
					$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=requestapproval');.
				<cfelse>
					<cfset message_error = "No Objects Selected">	
				</cfif>
			</cfoutput>
		</skin:onReady>
	</ft:processForm>
	
	<ft:processForm action="approve">
		<!--- TODO: Check Permissions. --->
		<skin:onReady>
			<cfoutput>
				<cfif structkeyexists(form,"objectid")>
					$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=approved');
				<cfelse>
					<cfset message_error = "No Objects Selected">	
				</cfif>
			</cfoutput>
		</skin:onReady>
	</ft:processForm>
	
	<ft:processForm action="createdraft,create draft">
		<!--- TODO: Check Permissions. --->
		<cflocation URL="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#form.objectID#" addtoken="false" />
	</ft:processForm>
	
	<ft:processForm action="Send to Draft">
		<!--- TODO: Check Permissions. --->
		<cfif structkeyexists(form,"objectid")>
			<skin:onReady>
				<cfoutput>
					$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=draft');
				</cfoutput>
			</skin:onReady>
		<cfelse>
			<cfset message_error = "No Objects Selected">	
		</cfif>	
	</ft:processForm>
	
	<!-----------------------------------------------
	    FORM ACTIONS FOR TYPE ADMIN GRID
	------------------------------------------------>
	<!--- TODO: retest permissions on form action, otherwise you can circumnavigate permissions with your own dummy form submission GB --->
	<cfscript>
	// response: action message container for objectadmin
	response="";
	if (not isDefined("message_error")){
		message_error = "";
	}

	
	// add: content item added
	// JS window.location from button press
		
	// delete: content items deleted
	if (isDefined("form.delete") AND form.delete AND isDefined("form.objectid")){
		objType = CreateObject("component","#PrimaryPackagePath#");
		aDeleteObjectID = ListToArray(form.objectid);
	
		for(i=1;i LTE Arraylen(aDeleteObjectID);i = i+1){
			returnstruct = objType.delete(aDeleteObjectID[i]);
			if(StructKeyExists(returnstruct,"bSuccess") AND NOT returnstruct.bSuccess)
				message_error = message_error & returnstruct.message;
		}
	}
	</cfscript>
	
	<!---// dump: content items to dump
	// TODO: implement object dump code! --->
	<cfif isDefined("form.dump") AND isDefined("form.objectid") AND len(form.objectid)>
		<!---response="DUMP (field: #form.dump#)actioned for: #form.objectid#."; --->
		<cfsavecontent variable="response">
			<cfloop list="#form.objectid#" index="i">
				<cfset st = createObject("component", PrimaryPackagePath).getData(objectid=i) />
				<cfdump var="#st#" expand="false" label="Dump of #st.label#">
			</cfloop>
			
		</cfsavecontent>
	</cfif>
	
	<cfscript>
	// status: change status of the selected content items
	// todo: make three unique buttons, match on buttontype *not* resource bundle label
	statusurl="";
	if (isDefined("form.status")) {
		if (isDefined("form.objectID")) {
			if (form.status contains 'Approve') {
				status = 'approved';
			}	
			else if (form.status contains 'Send to Draft') {
				status = 'draft';
			}
			else if (form.status contains 'Request Approval') {
				status = 'requestApproval';
			}
			else {
				status = 'unknown';
			}
			// pass list of objectids to comment template to add user comments
			statusurl = "#application.url.farcry#/conjuror/changestatus.cfm?typename=#attributes.typename#&status=#status#&objectID=#form.objectID#&finishURL=#application.fc.lib.esapi.encodeForURL(cgi.script_name)#?#application.fc.lib.esapi.encodeForURL(cgi.query_string)#";
			if (isDefined("stgrid.approveURL")) {
				statusurl = statusurl & "&approveURL=#application.fc.lib.esapi.encodeForURL(stGrid.approveURL)#";
			}
		} else {
			response = "#application.rb.getResource('objectadmin.messages.noobjectselected@text','No content items were selected for this operation')#";
		}
	}
	</cfscript>
	<!--- redirect user on status change --->
	<cfif len(statusurl)><cflocation url="#statusurl#" addtoken="false"></cfif>
	
	<!--- 
	// custom: custom button action
	--->
	<cfif NOT structisempty(form)>
		<cfif NOT isDefined("form.objectid")>
			<cfscript>
				form.objectid = application.fc.utils.createJavaUUID();
			</cfscript>
		</cfif>
		<cfloop collection="#form#" item="fieldname">
			<!--- match for custom button action --->
			<cfif reFind("^CB.*", fieldname) AND NOT reFind("^CB.*_DATA", fieldname) and structKeyExists(form, "#fieldname#_data")>
				<cfset wcustomdata=evaluate("form.#fieldname#_data")>
				<cfwddx action="wddx2cfml" input="#wcustomdata#" output="stcustomdata">
				<cfif len(stcustomdata.method)>
					<cflocation url="#application.url.farcry#/conjuror/invocation.cfm?objectid=#form.objectID#&typename=#attributes.typename#&ref=typeadmin&method=#stcustomdata.method#" addtoken="false">
				<cfelse>
					<cflocation url="#stcustomdata.url#" addtoken="false">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	
	
	<cfset HTMLfiltersAttributes = "">
	<cfif len(attributes.lFilterFields)>
		<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
		
		<cfloop list="#attributes.lFilterFields#" index="criteria">
			<cfif session.objectadminFilterObjects[attributes.typename].stObject[criteria] neq "">
				<cfset thisCriteria = lcase(criteria)>
				<cfif isDefined("application.types.#attributes.typename#.stProps.#criteria#.metadata.ftLabel")>
					<cfset thisCriteria = lcase(application.types[attributes.typename].stProps[criteria].metadata.ftLabel)>
				</cfif>
				<cfset HTMLfiltersAttributes = listAppend(HTMLfiltersAttributes," "&lcase(thisCriteria)&" ",'&')>
			</cfif>
		</cfloop>
	
		
		<cfif trim(HTMLfiltersAttributes) neq "">
			<cfset HTMLfiltersAttributes = "<div style='display:inline;color:##000'>#application.rb.getResource('objectadmin.messages.currentlybeingfilteredby@text','Currently being filtered by')#:</div> " & HTMLfiltersAttributes >
		</cfif>
	</cfif>
	

	<cfif len(attributes.description)>
		<cfoutput>#attributes.description#</cfoutput>
	</cfif>
	


	<!--- ONLY SHOW THE FILTERING IF WE HAVE RECORDS OR IF WE ARE ALREADY FILTERING --->
	<cfif listLen(attributes.lFilterFields) AND attributes.lFilterFields neq "label">
		<ft:form Name="#attributes.name#Filter" Validation="#attributes.bFilterValidation#">	
			<cfif NOT (isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1)>
				<ft:button type="button" value="Filter" icon="fa fa-search" class="small" priority="primary" style="" text="#application.rb.getResource('objectadmin.messages.Filtering@text','Show Filter')#" onclick="$j('##filterForm').toggle('blind');" />
			</cfif>
				
			<cfoutput>
			<div id="filterForm" style="<cfif not listLen(HTMLfiltersAttributes)>display:none;</cfif>clear:both;">
				<grid:div class="fc-shadowbox" style="width:730px;">
					<h3>#application.rb.getResource('objectadmin.filtering.heading@title','Advanced Filtering')#</h3>
					<ft:object objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" typename="#attributes.typename#" lFields="#attributes.lFilterFields#" lExcludeFields="" includeFieldset="false" stPropMetaData="#attributes.stFilterMetaData#" bValidation="#attributes.bFilterValidation#" />
					
					<ft:buttonPanel style="margin-bottom:0px;">
						<ft:button value="Apply Filter" rbkey="#attributes.rbkey#.applyfilter" class="small" />
						<cfif len(HTMLfiltersAttributes)>	
							<ft:button value="Clear Filter" validate="false" rbkey="#attributes.rbkey#.clearfilter" class="small" />
						</cfif>
					</ft:buttonPanel>
				</grid:div>
				<br style="clear:both;" />
			</div>
			</cfoutput>
		</ft:form>
	</cfif>


	<cfif isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1>
		<cfoutput>
			<form id="farcry-objectadmin-form" action="" method="post" class="input-prepend input-append pull-right" style="position: relative; z-index:2"  data-intro="Perform complex searches with advanced filtering options" data-position="left">
				<cfif len(attributes.lFilterFields) AND attributes.lFilterFields neq "label">
					<button type="button" class="btn fc-tooltip" onclick="$j('##filterForm').toggle('blind'); " style="height: 30px; border-radius:0" data-toggle="tooltip" data-placement="top" title="" data-original-title="#application.rb.getResource('objectadmin.filtering.heading@title','Advanced Filtering')#"><b class="fa fa-filter only-icon"></b></button>
				</cfif>
				<input id="farcry-objectadmin-q" name="q" class="span2" type="text" placeholder="#application.rb.getResource('objectadmin.filtering.search@placeholder','Search...')#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(session.objectadminFilterObjects[attributes.typename].q)#" style="width: 240px;"data-intro="Quick search field" data-position="bottom">
				<cfif len(session.objectadminFilterObjects[attributes.typename].q)>
					<button type="button" class="btn" onclick="$j('##farcry-objectadmin-q').val(''); $j('##clearfilter').val('1'); $j('##farcry-objectadmin-form').submit();" style="height: 30px; border-radius:0; font-size: 20px; font-weight: bold; padding: 4px 10px;">&times;</button>
					<input type="hidden" id="clearfilter" name="clearfilter" value="0">
				</cfif>
				<button type="submit" class="btn btn-primary" name="btnsearch" value="1" style="height: 30px; border-radius:0"><b class="fa fa-search only-icon"></b></button>
			</form>				
		</cfoutput>
	</cfif>
			
	
	<ft:form Name="#attributes.name#">
	
		<!--- output user responses --->
		<cfif len(message_error)><cfoutput><p id="error" class="fade"><span class="error">#message_error#</span></p></cfoutput></cfif>
		<cfif len(response)><cfoutput><p id="response" class="fade">#response#</p></cfoutput></cfif>
		
		<!--- delete flag; modified to 1 on delete confirm --->
		<cfoutput><input name="delete" type="Hidden" value="0"></cfoutput>
		
		<cfsavecontent variable="html_buttonbar">
		
			<ft:buttonPanel style="text-align:left;" class="farcry-button-bar btn-group">
				<cfloop from="1" to="#arraylen(attributes.aButtons)#" index="i">
					
					
					<cfif attributes.lButtons EQ "*" or listFindNoCase(attributes.lButtons,attributes.aButtons[i].value)>
					
						<!--- IF NO RECORDSET THEN ONLY THE ADD BUTTON SHOULD BE DISPLAYED --->
						<cfif stRecordset.q.recordCount OR listfindnocase(attributes.lButtonsEmpty,attributes.aButtons[i].value)>

							<cfif not len(attributes.aButtons[i].permission) or (isboolean(attributes.aButtons[i].permission) and attributes.aButtons[i].permission) or (not isboolean(attributes.aButtons[i].permission) and application.security.checkPermission(permission=attributes.aButtons[i].permission) EQ 1)>
								
								<cfif len(attributes.aButtons[i].onclick)> 
									<cfset onclickJS="#attributes.aButtons[i].onclick#" />
								<cfelse>
									<cfset onclickJS="" />
								</cfif>
								<cfif not structKeyExists(attributes.aButtons[i], "confirmText")> 
									<cfset attributes.aButtons[i].confirmText = "" />
								</cfif>
								<cfif structkeyexists(attributes.aButtons[i],"text")>
									<cfset buttontext = attributes.aButtons[i].text />
								<cfelse>
									<cfset buttontext = attributes.aButtons[i].value />
								</cfif>

								<cfset icon = "">
								<cfset class = "">
								<cfif isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1>
									<!--- bootstrap --->
									<cfif structkeyexists(attributes.aButtons[i],"icon")>
										<cfset icon =  attributes.aButtons[i].icon />
									<cfelse>
										<cfswitch expression="#attributes.aButtons[i].value#">
											<cfcase value="Add">
												<cfset class = "btn-primary">
											</cfcase>
										</cfswitch>
									</cfif>
								</cfif>
								
								<cfif not structkeyexists(attributes.aButtons[i],"hint")>
									<cfset attributes.aButtons[i].hint = "" />
								</cfif>
								
								<ft:button text="#buttontext#" value="#attributes.aButtons[i].value#" title="#attributes.aButtons[i].hint#" class="#class#" icon="#icon#" rbkey="objectadmin.buttons.#rereplace(attributes.aButtons[i].value,'[^\w]+','','ALL')#" onclick="#onclickJS#" confirmText="#attributes.aButtons[i].confirmText#" />
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
				
			</ft:buttonPanel>
		</cfsavecontent>
		


		<cfoutput>
			#html_buttonbar#
			<div class="farcry-objectadmin-body">
		</cfoutput>
		
		<skin:pop tags="#attributes.typename#"><cfoutput>
			<div class="alert <cfif listfindnocase(message.tags,'info')> alert-info<cfelseif listfindnocase(message.tags,'error')> alert-error<cfelseif listfindnocase(message.tags,'success')> alert-success</cfif>">
				<button type='button' class='close' data-dismiss='alert'>&times;</button>
				<cfif len(trim(message.title))><strong>#message.title#</strong></cfif>
				<cfif len(trim(message.message))>#message.message#</cfif>
			</div>
		</cfoutput></skin:pop>


		<cfset bShowStatus = false>

		<cfif stRecordset.q.recordCount>
			<skin:pagination
				paginationID="#attributes.typename#"
				qRecordSet="#stRecordset.q#"
				typename="#attributes.typename#"
				totalRecords="#stRecordset.countAll#" 
				currentPage="#stRecordset.currentPage#"
				Step="1"  
				pageLinks="#attributes.numPageDisplay#"
				recordsPerPage="#stRecordset.recordsPerPage#" 
				submissionType="form"
				oddRowClass="alt"
				evenRowClass=""
				r_stObject="st"
				top="#attributes.bPaginateTop#"
				bottom="#attributes.bPaginateBottom#"
				bDisplayTotalRecords="#attributes.bDisplayTotalRecords#">

		
			<cfif st.bFirst>
				<cfif len(attributes.SortableColumns)>
					<cfoutput><input type="hidden" id="sqlOrderBy" name="sqlOrderBy" value="#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#"></cfoutput>
				</cfif>
				<cfif len(session.objectadminFilterObjects[attributes.typename].q)>
					<cfoutput><input type="hidden" name="q" value="#application.fc.lib.esapi.encodeForHTMLAttribute(session.objectadminFilterObjects[attributes.typename].q)#"></cfoutput>
				</cfif>
				
				<cfoutput>

				<cfif isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1>
					<table width="100%" class="farcry-objectadmin table table-striped table-hover">
				<cfelse>
					<table width="100%" class="objectAdmin">
				</cfif>

				<thead>
					<tr class="#st.currentRowClass#">			
				</cfoutput>
				
				 		<cfif attributes.bSelectCol><cfoutput><th style="width:1.5em;"><cfif attributes.bCheckAll><input type="checkbox" id="checkall" name="checkall" onclick="checkUncheckAll(this);" title="Check All" /><cfelse>Select</cfif></th></cfoutput></cfif>
				 		
						
						<cfif attributes.bShowActionList>
							<cfoutput><th style="width:10em;">#application.rb.getResource('objectadmin.columns.action@label','Action')#</th></cfoutput>
						</cfif>
						
						<cfif structKeyExists(st,"bHasMultipleVersion") AND NOT listFindNoCase(attributes.columnlist, "status")>
							<cfset bShowStatus = true>
							<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
								<cfif structKeyExists(attributes.aCustomColumns[i], "property") AND listFindNoCase(attributes.aCustomColumns[i].property, "status")>
								<cfset bShowStatus = false>
								</cfif>
							</cfloop>
							<cfif bShowStatus>
					 			<cfoutput><th style="width:9em;">#application.rb.getResource('objectadmin.columns.status@label',"Status")#</th></cfoutput>
							</cfif>
						</cfif>
						
						<cfset o = createobject("component",PrimaryPackagepath) />
						
						<cfif arrayLen(attributes.aCustomColumns)>
							<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
								
								<cfif isstruct(attributes.aCustomColumns[i])>
								
									<cfif structKeyExists(attributes.aCustomColumns[i], "title")>
										<cfoutput><th>#application.rb.getResource("objectadmin.columns.#rereplace(attributes.aCustomColumns[i].title,'[^\w\d]','','ALL')#@label",attributes.aCustomColumns[i].title)#</th></cfoutput>
									<cfelse>
										<cfoutput><th>&nbsp;</th></cfoutput>
									</cfif>
									
								<cfelse><!--- Normal field --->
									
									<cfset headerColumnStyle = "">
									<cfif isDefined("PrimaryPackage.stProps.#attributes.aCustomColumns[i]#.metadata.ftType") AND PrimaryPackage.stProps[#attributes.aCustomColumns[i]#].metadata.ftType eq "datetime">
										<cfset headerColumnStyle = "width: 8em;">
									</cfif>

									<cfset orderField = listFirst(session.objectadminFilterObjects[attributes.typename].sqlOrderBy, " ")>
									<cfset orderDirection = listLast(session.objectadminFilterObjects[attributes.typename].sqlOrderBy, " ")>

									<cfset sortableClass = "">
									<cfset sortableDirection = "">
									<cfif listFindNoCase(attributes.sortableColumns, attributes.aCustomColumns[i])>
										<cfset sortableClass = "objectadmin-sortable">
										<cfif orderField eq attributes.aCustomColumns[i]>
											<cfset sortableDirection = orderDirection>
										<cfelse>
											<cfset sortableDirection = "DESC">
										</cfif>
									</cfif>

									<cfoutput>
										<th class="#sortableClass#" data-field="#attributes.aCustomColumns[i]#" data-direction="#sortableDirection#" data-form="#request.farcryForm.name#" style="#headerColumnStyle#">
											<span>
												<cfif isDefined("PrimaryPackage.stProps.#trim(attributes.aCustomColumns[i])#.metadata.ftLabel")>
													#o.getI18Property(attributes.aCustomColumns[i],"label")#
												<cfelse>
													#attributes.aCustomColumns[i]#
												</cfif>

												<cfif orderField eq attributes.aCustomColumns[i]>
													<cfif orderDirection eq "ASC">
														<i class="fa fa-caret-up"></i>
													<cfelseif orderDirection eq "DESC">
														<i class="fa fa-caret-down"></i>
													</cfif>
												</cfif>
											</span>
										</th>
									</cfoutput>
									
									<!--- If this field is in the column list (and it should be) remove it so it won't get displayed elsewhere --->
									<cfif listcontainsnocase(attributes.columnlist,attributes.aCustomColumns[i])>
										<cfset attributes.columnlist = listdeleteat(attributes.columnlist,listfindnocase(attributes.columnlist,attributes.aCustomColumns[i])) />
									</cfif>
									
								</cfif>
								
							</cfloop>
						</cfif>
						
						<cfloop list="#attributes.columnlist#" index="i">

							<cfif isDefined("PrimaryPackage.stProps.#trim(i)#")>

								<cfset headerColumnStyle = "">
								<cfif isDefined("PrimaryPackage.stProps.#trim(i)#.metadata.ftType") AND PrimaryPackage.stProps[#trim(i)#].metadata.ftType eq "datetime">
									<cfset headerColumnStyle = "width: 8em;">
								</cfif>
								<cfif i eq "status">
									<cfset headerColumnStyle = "width: 9em;">								
								</cfif>

								<cfset orderField = listFirst(session.objectadminFilterObjects[attributes.typename].sqlOrderBy, " ")>
								<cfset orderDirection = listLast(session.objectadminFilterObjects[attributes.typename].sqlOrderBy, " ")>

								<cfset sortableClass = "">
								<cfset sortableDirection = "">
								<cfif listFindNoCase(attributes.sortableColumns, i)>
									<cfset sortableClass = "objectadmin-sortable">
									<cfif orderField eq i>
										<cfset sortableDirection = orderDirection>
									<cfelse>
										<cfset sortableDirection = "DESC">
									</cfif>
								</cfif>

								<cfoutput>
									<th class="#sortableClass#" data-field="#i#" data-direction="#sortableDirection#" data-form="#request.farcryForm.name#" style="#headerColumnStyle#">
									<span>
										<cfif isDefined("PrimaryPackage.stProps.#trim(i)#.metadata.ftLabel")>
											#application.rb.getResource("objectadmin.columns.#rereplace(i,'[^\w\d]','','ALL')#@heading", o.getI18Property(i,"label"))#
										<cfelse>
											#i#
										</cfif>

										<cfif orderField eq i>
											<cfif orderDirection eq "ASC">
												<i class="fa fa-caret-up"></i>
											<cfelseif orderDirection eq "DESC">
												<i class="fa fa-caret-down"></i>
											</cfif>
										</cfif>
									</span>
									</th>
								</cfoutput>

							</cfif>

						</cfloop>
						
					<cfoutput>
					</tr>
					</cfoutput>
					

					<cfif len(attributes.SortableColumns) AND NOT (isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1)>
						<cfoutput>
						<tr>
						</cfoutput>
						
					 		<cfif attributes.bSelectCol><cfoutput><th>&nbsp;</th></cfoutput></cfif>	 	
					 			
							<cfif attributes.bShowActionList>
								<cfoutput><th>&nbsp;</th></cfoutput>
							</cfif>
					 		<cfif structKeyExists(st,"bHasMultipleVersion")>
						 		<cfoutput><th>&nbsp;</th></cfoutput>
							</cfif>			
							<cfif arrayLen(attributes.aCustomColumns)>
								<cfset oType = createObject("component", PrimaryPackagePath) />
								<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
									<cfif isstruct(attributes.aCustomColumns[i])>
										<cfif structKeyExists(attributes.aCustomColumns[i],"sortable") and attributes.aCustomColumns[i].sortable>
											<cfoutput>
											<th>
											<select name="#attributes.aCustomColumns[i].property#sqlOrderBy" onchange="javascript:$j('##sqlOrderBy').attr('value',this.value);btnSubmit('#request.farcryForm.name#', 'sort');" style="width:80px;">
												<option value=""></option>
												<option value="#attributes.aCustomColumns[i].property# asc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# asc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.asc@label">asc</admin:resource></option>
												<option value="#attributes.aCustomColumns[i].property# desc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# desc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.desc@label">desc</admin:resource></option>
											</select>
											</th>
											</cfoutput>						
										<cfelse>
											<cfoutput><th>&nbsp;</th></cfoutput>
										</cfif>
									<cfelse>
										<cfif listContainsNoCase(attributes.SortableColumns,attributes.aCustomColumns[i])><!--- Normal property in sortablecolumn list --->
											<cfoutput>
											<th>
											<select name="#attributes.aCustomColumns[i]#sqlOrderBy" onchange="javascript:$j('##sqlOrderBy').attr('value',this.value);btnSubmit('#request.farcryForm.name#', 'sort');" style="width:80px;">
												<option value=""></option>
												<option value="#attributes.aCustomColumns[i]# asc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i]# asc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.asc@label">asc</admin:resource></option>
												<option value="#attributes.aCustomColumns[i]# desc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i]# desc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.desc@label">desc</admin:resource></option>
											</select>
											</th>
											</cfoutput>
										<cfelse>
											<cfoutput><th>&nbsp;</th></cfoutput>
										</cfif>
									</cfif>
								</cfloop>
							</cfif>
					
							<cfloop list="#attributes.columnlist#" index="i">

								<cfif isDefined("PrimaryPackage.stProps.#trim(i)#")>
									<cfoutput><th></cfoutput>					
										<cfif listContainsNoCase(attributes.SortableColumns,i)>
											<cfoutput>
											<select name="#i#sqlOrderBy" onchange="javascript:$j('##sqlOrderBy').attr('value',this.value);btnSubmit('#request.farcryForm.name#', 'sort');" style="width:80px;">
												<option value=""></option>
												<option value="#i# asc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# asc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.asc@label">asc</admin:resource></option>
												<option value="#i# desc"<cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# desc"> selected="selected"</cfif>><admin:resource key="#attributes.rbkey#.desc@label">desc</admin:resource></option>
											</select>
											</cfoutput>
										<cfelse>
											<cfoutput>&nbsp;</cfoutput>
										</cfif>
									<cfoutput></th></cfoutput>
								</cfif>

							</cfloop>
						<cfoutput>
						</tr>
						</cfoutput>
					</cfif>
			
					<cfoutput>
					</thead>
					</cfoutput>
				</cfif>
				
				
				<cfset stObjectAdminData = getObjectAdminData(st=duplicate(st), typename="#attributes.typename#", stPermissions="#stPermissions#") />
				<cfset st = application.fapi.structMerge(st,stObjectAdminData) />


				<cfif isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1>
					<cfset st.currentRowClass = "">
				</cfif>
					
						<cfoutput>
						<tr class="#st.currentRowClass#">
						</cfoutput>
						
							<cfif attributes.bSelectCol>
								<cfoutput>
								<td style="white-space:nowrap;">
									#st.select# 
									<!--- #st.recordSetRow#			 --->					
									<cfif structKeyExists(st,"locked") AND st.locked neq 0>
										<i class="fa fa-lock fa-lg"></i>
									</cfif>
								</td>
								</cfoutput>
							</cfif>
							<cfif attributes.bShowActionList>
								<cfoutput><td class="objectadmin-actions" nowrap="nowrap" style="" <cfif st.bFirst>data-intro="Overview, Edit, Preview" data-position="right"</cfif>>#st.action#</td></cfoutput>
							</cfif>

				 			<cfset statusOutput = "">
				 			<cfif structKeyExists(st, "status")>
					 			<cfset statusOutput = application.rb.getResource("constants.status.#st.status#@label",st.status)>
								<cfif isDefined("request.fc.inwebtop") AND request.fc.inwebtop eq 1>
						 			<cfif st.status eq "draft">
							 			<cfset statusOutput = "<span class='label label-warning'>" & statusOutput & "</span>">
							 		<cfelseif st.status eq "approved">
							 			<cfset statusOutput = "<span class='label label-info'>" & statusOutput & "</span>">
							 		<cfelseif st.status eq "draft/approved">
							 			<cfset statusOutput = "<span class='label label-warning'>" & statusOutput & "</span>">
							 			<cfset statusOutput = replace(statusOutput, " + ", "</span> + <span class='label label-info'>", "one")>
							 		<cfelse>
							 			<cfset statusOutput = "<span class='label'>" & statusOutput & "</span>">
						 			</cfif>
						 		</cfif>
				 			</cfif>

					 		<cfif structKeyExists(st,"bHasMultipleVersion") AND bShowStatus eq true>
						 		<cfoutput><td style="white-space:nowrap;">#statusOutput#</td></cfoutput>
							</cfif>
	
							<cfif arrayLen(attributes.aCustomColumns)>
								<cfset oType = createObject("component", PrimaryPackagePath) />
								<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
									
									<cfif isstruct(attributes.aCustomColumns[i])>
										<cfif structKeyExists(attributes.aCustomColumns[i], "webskin")>
											<cfset HTML = oType.getView(objectid="#st.objectid#", template="#attributes.aCustomColumns[i].webskin#")>
											<cfoutput><td>#HTML#</td></cfoutput>
										<cfelse>
											<cfoutput><td>&nbsp;</td></cfoutput>
										</cfif>
									<cfelse><!--- Normal field --->
										<cfif structKeyExists(st, attributes.aCustomColumns[i])>
											<ft:object objectID="#st.objectid#" typename="#attributes.typename#" lFields="#attributes.aCustomColumns[i]#" format="display" r_stFields="stFields" />
							
											<cfoutput><td>#stFields[attributes.aCustomColumns[i]].html#</td></cfoutput>			
										<cfelse>
											<cfoutput><td>-- not available --</td>	</cfoutput>			
										</cfif>
									</cfif>
									
								</cfloop>
							</cfif>

							<cfif len(attributes.columnList)>
								<cfparam name="st.typename" default="#attributes.typename#" />
								<ft:object stObject="#st#" lFields="#attributes.columnlist#" format="display" r_stFields="stFields" />
							
								<cfloop list="#attributes.columnlist#" index="i">

									<cfif isDefined("PrimaryPackage.stProps.#trim(i)#")>

										<cfif structKeyExists(stFields, i)>
											<cfif i eq "status">
												<cfset stFields[i].HTML = statusOutput>
											</cfif>
											<cfoutput><td>#stFields[i].HTML#</td></cfoutput>			
										<cfelse>
											<cfoutput><td>-- not available --</td>	</cfoutput>			
										</cfif>

									</cfif>
									
								</cfloop>	
							</cfif>
						<cfoutput>
						</tr>
						</cfoutput>
					
					
			<cfif st.bLast>
				<cfoutput></table></cfoutput>
			</cfif>
		
		<!--- </ft:pagination>  --->
		</skin:pagination>
		
	
	<cfelse>
		<cfif listLen(HTMLfiltersAttributes) OR len(session.objectadminFilterObjects[attributes.typename].q)>
			<cfoutput><div class="alert alert-error">No results matched your filter</div></cfoutput>
		<cfelse>
			<cfoutput><div class="alert alert-info"><admin:resource key="#attributes.rbkey#.emptymessage@text" var1="#typelabel#">#attributes.emptymessage#</admin:resource></div></cfoutput>
		</cfif>
		
	</cfif>
	
	<cfoutput></div></cfoutput>
	
	</ft:form>

	<cfoutput>
		<!--- load handlebars templates --->
		<skin:hbs template="preview-dialog">

		<script src="#application.url.webtop#/app/views/PreviewView.js" type="text/javascript"></script>
		<script type="text/javascript">
			App = {};

			$j(function(){


				App.previewView = new PreviewView({
					attachTo: ".farcry-objectadmin",
					previewURL: "http://#cgi.http_host#/",
					currentDevice: "#application.fc.lib.device.getDeviceType()#",
					bUseTabletWebskins: #application.fc.lib.device.isTabletWebskinsEnabled()#,
					bUseMobileWebskins: #application.fc.lib.device.isMobileWebskinsEnabled()#,
					deviceWidth: {
						desktop: #application.fapi.getConfig("device", "desktopWidth")#,
						tablet: #application.fapi.getConfig("device", "tabletWidth")#,
						mobile: #application.fapi.getConfig("device", "mobileWidth")#
					}
				});
				App.previewView.render();

				$j(".farcry-objectadmin").on("click", "th.objectadmin-sortable span", function() {
					var f = $j(this).closest("form");
					var th = $j(this).parent();
					var sortOrder = th.data("field");
					if (th.data("direction") == "DESC") {
						sortOrder += " ASC";
					}
					else {
						sortOrder += " DESC";
					}
					f.find("##sqlOrderBy").val(sortOrder);
					btnSubmit(th.data("form"), 'sort');
				});
			});
		</script>
	</cfoutput>

</cfif> 

<cffunction name="getObjectAdminData" returntype="struct">
	
	<cfargument name="st" required="true" type="struct" hint="A struct containing the current rows data" />
	<cfargument name="typename" required="false" default="" hint="The typename if the listing is supposed to be limited to the one type.">
	<cfargument name="stPermissions" required="false" default="#structNew()#" type="struct" hint="A struct containing the permissions" />
	
	<cfset var stObjectAdminData = structNew() />
	<cfset var lWorkflowTypenames = "" />

	<cfif len(arguments.typename) AND application.stcoapi[arguments.typename].bWorkflow>
		<cfset lWorkflowTypenames = application.fapi.getContentType("farWorkflow").getWorkflowList(arguments.typename) />
	</cfif>

	<cfset stObjectAdminData.select = "<input type='checkbox' name='objectid' value='#arguments.st.objectid#' onclick='setRowBackground(this);updateSelectedObjectIDs(this);' class='formCheckbox' />" />



	<cfif structKeyExists(arguments.st, "bHasMultipleVersion") AND arguments.st.bHasMultipleVersion>
		<cfset stObjectAdminData.status = "draft/approved" />
	<cfelseif structKeyExists(arguments.st, "status")>
		<cfset stObjectAdminData.status = arguments.st.status>
	</cfif>
	
	
	<cfif structIsEmpty(arguments.stPermissions)>
		<sec:CheckPermission permission="Create" type="#attributes.typename#" objectid="#arguments.st.objectid#" result="arguments.stPermissions.iCreate" />
		<sec:CheckPermission permission="Delete" type="#attributes.typename#" objectid="#arguments.st.objectid#" result="arguments.stPermissions.iDelete" />
		<sec:CheckPermission permission="RequestApproval" type="#attributes.typename#" objectid="#arguments.st.objectid#" result="arguments.stPermissions.iRequestApproval" />
		<sec:CheckPermission permission="Approve" type="#attributes.typename#" objectid="#arguments.st.objectid#" result="arguments.stPermissions.iApprove" />
		<sec:CheckPermission permission="Edit" type="#attributes.typename#" objectid="#arguments.st.objectid#" result="arguments.stPermissions.iEdit" />
		<sec:CheckPermission permission="ObjectDumpTab" result="arguments.stPermissions.iDumpTab" />
		<sec:CheckPermission permission="Developer" result="arguments.stPermissions.iDeveloper" />
	</cfif>
	
	<cfsavecontent variable="ActionDropdown">
		
		<cfset overviewURL = "#application.url.farcry#/edittabOverview.cfm?typename=#attributes.typename#&method=#attributes.editMethod#&ref=iframe&module=#attributes.module#">
		<cfif Len(attributes.plugin)>
			<cfset overviewURL = listAppend(overviewURL,'plugin=#attributes.plugin#', '&') />
		</cfif>	
		
		<cfset editURL = "#application.url.farcry#/conjuror/invocation.cfm?typename=#attributes.typename#&method=#attributes.editMethod#&ref=iframe&module=#attributes.module#">
		
		<cfif not structIsEmpty(attributes.editUrlParams)>
			<cfloop collection="#attributes.editUrlParams#" item="key">
				<cfset EditURL="#EditURL#&#key#=#attributes.editUrlParams[key]#">
			</cfloop>
		</cfif>	
		<cfif Len(attributes.plugin)>
			<cfset editURL = listAppend(editURL,'plugin=#attributes.plugin#', '&') />
		</cfif>	
		
		<cfset createDraftURL = "#application.url.farcry#/navajo/createDraftObject.cfm?ref=iframe&method=#attributes.editMethod#">
		<cfif not structIsEmpty(attributes.editUrlParams)>
			<cfloop collection="#attributes.editUrlParams#" item="key">
				<cfset createDraftURL="#createDraftURL#&#key#=#attributes.editUrlParams[key]#">
			</cfloop>
		</cfif>	
		
		<cfif attributes.bViewCol>	
			<ft:button value="Overview" text="" title="Open up the overview screen for this object" icon="fa fa-th" type="button" onclick="$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#overviewURL#&objectid=#arguments.st.objectid#');" />
		</cfif>
		<cfif attributes.bEditCol>
	
			<!--- We do not include the Edit Link if workflow is available for this content item. The user must go to the overview page. --->
			<cfif not listLen(lWorkflowTypenames)>	
				<cfif structKeyExists(arguments.st,"locked") AND arguments.st.locked neq 0 AND arguments.st.lockedby neq '#application.security.getCurrentUserID()#'>
					<ft:button value="Unlock" text="" title="Unlock this object" style="margin-left:0px;" icon="fa fa-unlock" class="" type="submit" selectedObjectID="#arguments.st.objectid#" />
				<cfelseif structKeyExists(arguments.stPermissions, "iEdit") AND arguments.stPermissions.iEdit>
					<cfif structKeyExists(arguments.st,"bHasMultipleVersion")>
						<cfif NOT(arguments.st.bHasMultipleVersion) AND arguments.st.status EQ "approved">
							<ft:button value="Create Draft Object" text="#application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#" title="Create a draft version of this object and begin editing" icon="fa fa-pencil"  class="btn-edit" type="button" onclick="$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#createDraftURL#&objectid=#arguments.st.objectid#');" />
						<cfelseif arguments.st.bHasMultipleVersion>
							<!--- Still go to the create draft page but that page will find the already existing draft and not create a new one. --->
							<ft:button value="Edit Draft" text="#application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#" title="Edit the draft version of this object" type="button" icon="fa fa-pencil" class="btn-edit" onclick="$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#createDraftURL#&objectid=#arguments.st.objectid#');" />
						<cfelse>
							<ft:button value="Edit" text="#application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#" title="Edit this object" type="button" icon="fa fa-pencil" class="btn-edit" onclick="$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#editURL#&objectid=#arguments.st.objectid#');" />
						</cfif>
					<cfelse>
						<ft:button value="Edit" text="#application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#" title="Edit this object" type="button" icon="fa fa-pencil" class="btn-edit" onclick="$fc.objectAdminAction('#application.rb.getResource("objectadmin.modal.heading@text", 'Administration')#', '#editURL#&objectid=#arguments.st.objectid#');" />
					</cfif>
				</cfif>
			</cfif>	

		</cfif>

		<cfif attributes.bPreviewCol>
			<cfif len(attributes.previewWebskin)>
				<cfoutput><a href="#application.fapi.getLink(type=attributes.typename, objectid=arguments.st.objectid, view=attributes.previewWebskin)#" class="btn fc-btn-preview" target="_blank" title="Preview"><i class="fa fa-eye only-icon"></i></a></cfoutput>
			<cfelse>
				<cfoutput><a href="#application.fapi.getLink(type=attributes.typename, objectid=arguments.st.objectid)#" class="btn fc-btn-preview" target="_blank" title="Preview"><i class="fa fa-eye only-icon"></i></a></cfoutput>
			</cfif>		
		</cfif>
		
		<cfif len(attributes.lCustomActions)>
			<cfoutput><div class="btn-group"></cfoutput>
			
				<ft:button value="toggle" text="" icon=" ,fa-caret-down" dropdownToggle="true" type="button" />
				
				<cfoutput><div class="dropdown-menu"></cfoutput>
			
					<cfif listLen(attributes.lCustomActions)>
						<cfloop list="#attributes.lCustomActions#" index="i">
							<cfoutput>
								<li>
									<ft:button value="#listFirst(i, ":")#" text="#listLast(i, ":")#" renderType="link" selectedObjectID="#arguments.st.objectid#" />
								</li>
							</cfoutput>
						</cfloop>
					</cfif>
					
				<cfoutput></div></cfoutput>
				
			<cfoutput></div></cfoutput>
			
		</cfif>		

	</cfsavecontent>
	
	<cfset stObjectAdminData.action = ActionDropdown />
	
	<cfreturn stObjectAdminData />
</cffunction>

<cfsetting enablecfoutputonly="false">