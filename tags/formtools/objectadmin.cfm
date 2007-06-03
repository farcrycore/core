<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.title" default="Type Admin" />
	<cfparam name="attributes.typename" default="" />
	<cfparam name="attributes.columnlist" default="label,datetimelastupdated" />

   <!---
        get multiple users in pagination
    --->


<!---<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=avnArticle&method=edit&ref=typeadmin&module=customlists/avnArticle.cfm" />
 --->


<cfparam name="form.Criteria" default="" />
<cfparam name="pluginURL" default="" /><!--- used in case we are in a plugin object admin --->


<cfparam name="session.objectadmin" default="#structnew()#" type="struct">

<cfparam name="attributes.title" default="#attributes.typename# Administration" type="string">
<cfparam name="attributes.ColumnList" default="" type="string">
<cfparam name="attributes.SortableColumns" default="" type="string">
<cfparam name="attributes.lFilterFields" default="" type="string">
<cfparam name="attributes.description" default="" type="string">
<cfparam name="attributes.datasource" default="#application.dsn#" type="string">
<cfparam name="attributes.aColumns" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.aCustomColumns" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.aButtons" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.bdebug" default="false" type="boolean">
<cfparam name="attributes.bFilterCategories" default="true" type="boolean">
<cfparam name="attributes.bFilterDateRange" default="true" type="boolean">
<cfparam name="attributes.bFilterProperties" default="true" type="boolean">
<cfparam name="attributes.permissionset" default="news" type="string">
<!--- attributes.query type="query" CF7 specific --->
<cfparam name="attributes.defaultorderby" default="datetimelastupdated" type="string">
<cfparam name="attributes.defaultorder" default="desc" type="string">
<cfparam name="attributes.id" default="#attributes.typename#" type="string">
<cfparam name="attributes.sqlorderby" default="datetimelastupdated desc" type="string" />
<cfparam name="attributes.sqlWhere" default="0=0" />
<cfparam name="attributes.lCategories" default="" />

<!--- admin configuration options --->
<cfparam name="attributes.numitems" default="#application.config.general.GENERICADMINNUMITEMS#" type="numeric">
<cfparam name="attributes.numPageDisplay" default="10" type="numeric">

<cfparam name="attributes.lButtons" default="*" type="string">
<cfparam name="attributes.bPaginateTop" default="true" type="boolean">
<cfparam name="attributes.bPaginateBottom" default="true" type="boolean">
<cfparam name="attributes.bSelectCol" default="true" type="boolean">
<cfparam name="attributes.bEditCol" default="true" type="boolean">
<cfparam name="attributes.bViewCol" default="true" type="boolean">
<cfparam name="attributes.bFlowCol" default="true" type="boolean">


<cfparam name="attributes.editMethod" default="edit" type="string">

<cfparam name="attributes.PackageType" default="types" type="string">

<cfparam name="attributes.module" default="customlists/#attributes.typename#.cfm">
<cfparam name="attributes.plugin" default="" />
<cfparam name="attributes.lCustomActions" default="" />


<cfif NOT structKeyExists(session.objectadmin, attributes.typename)>
	<cfset structInsert(session.objectadmin, attributes.typename, structnew())>
</cfif>

<cfif attributes.PackageType EQ "rules">
	<cfset PrimaryPackage = application.rules[attributes.typename] />
	<cfset PrimaryPackagePath = application.rules[attributes.typename].rulepath />
<cfelse>
	<cfset PrimaryPackage = application.types[attributes.typename] />
	<cfset PrimaryPackagePath = application.types[attributes.typename].typepath />
</cfif>


<cfif NOT structKeyExists(PrimaryPackage, "news")>

<!--- this seems to be a problem for custom types when it gets to invocation.cfm. the permission set is not carried
across and could potentially cause major stuff ups if news permissions (which is the default) is set to no for the
user --->
	<cfset structInsert(PrimaryPackage, "permissionset", "news", "yes")>
</cfif>

<cfset oTypeAdmin = createobject("component", "#application.packagepath#.farcry.objectadmin").init(stprefs=session.objectadmin[attributes.typename], attributes=attributes)>




<!--- check if the type has a status property --->
<!--- <cfset bUsesStatus = false>
<cfif structKeyExists(application.types[attributes.typename].STPROPS, "status")>
	<cfset bUsesStatus = true>
	<cfif not findNocase(attributes.ColumnList, "status") or not findNocase(attributes.ColumnList, "*")>
		<cfset attributes.ColumnList = listAppend(attributes.ColumnList,"status")>
	</cfif>
</cfif> --->




<!---
 get default grid data 
<cfset aDefaultColumns=oTypeAdmin.getDefaultColumns()>
<cfset aDefaultButtons=oTypeAdmin.getDefaultButtons()>

--->

<!--- refactored to here... 
<cfset session.objectadmin[attributes.typename]=oTypeadmin.getprefs()>
<cfset stpermissions=oTypeAdmin.getBasePermissions()>
<!--- <cfdump var="#session.objectadmin[attributes.typename]#"> --->
 /refactored --->



<cfoutput><h1>#attributes.title#</h1></cfoutput>

<cfset stPrefs = oTypeAdmin.getPrefs() />
<cfset stpermissions=oTypeAdmin.getBasePermissions()>





<ft:processform action="delete">
	<cfif isDefined("form.objectid") and len(form.objectID)>
		
		<cfloop list="#form.objectid#" index="i">
			<cfset o = createObject("component", PrimaryPackagePath) />
			<cfset stResult = o.delete(objectid=i) />
			
			<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>
				<cfoutput><div class="error">#stResult.message#</div></cfoutput>
			</cfif>
		</cfloop>
	</cfif>
</ft:processForm>

<ft:processform action="unlock">
	<cfif isDefined("form.objectid") and len(form.objectID)>
		
		<cfloop list="#form.objectid#" index="i">
			<cfset o = createObject("component", PrimaryPackagePath) />
			<cfset st = o.getData(objectid=i) />
			<cfset o.setlock(locked="false") />
		</cfloop>
	
	</cfif>
	
</ft:processForm>



<!--- IF javascript has set the selected objectid, set the form.objectid to it. --->
<cfif isDefined("FORM.selectedObjectID") and len(form.selectedObjectID)>
	<cfset form.objectid = form.selectedObjectID />
</cfif>

<cfparam name="session.objectadminFilterObjects" default="#structNew()#" />
<cfif not structKeyExists(session.objectadminFilterObjects, attributes.typename)>
	<cfset session.objectadminFilterObjects[attributes.typename] = structNew() />
</cfif>


<cfif len(attributes.lFilterFields)>

		<cfset oFilterType = createObject("component", PrimaryPackagePath) />
	

	

		<cfif not structKeyExists(session.objectadminFilterObjects[attributes.typename], "stObject")>
			
			<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectid="#createUUID()#") />
			
						
			<cfset session.objectadminFilterObjects[attributes.typename].stObject.label = "" />
			<cfset stResult = oFilterType.setData(stProperties=session.objectadminFilterObjects[attributes.typename].stObject, bSessionOnly=true) />
	
			<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
			
		</cfif>
		
		<ft:processform action="apply filter" url="refresh">
			<ft:processformObjects objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" bSessionOnly="true" />	
		</ft:processForm>
		
		<ft:processform action="clear filter" url="refresh">
			<cfset structDelete(session.objectadminFilterObjects, attributes.typename) />
		</ft:processForm>
		
		
		<cfset request.inHead.scriptaculouseffects = 1 />
		<!--- <cfdump var="#session.objectadminFilterObjects[attributes.typename].stObject#">
		<cfdump var="#attributes.lFilterFields#"> --->
		
		<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
		<cfset HTMLfiltersAttributes = "">
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
			<cfset HTMLfiltersAttributes = "<div style='display:inline;color:##000'>result filtered by:</div> " & HTMLfiltersAttributes >
		</cfif>
	

		<ft:form style="padding:0px; border-bottom: 1px solid ##000; ">
			<cfoutput>
			<div style="display:inline;color:##E17000">
				Listing Filter:
				<cfif HTMLfiltersAttributes eq "">
					<a onclick="Effect.toggle('filterForm','blind');">set</a>
				<cfelse>
					<a onclick="Effect.toggle('filterForm','blind');">edit</a> <ft:farcryButton value="clear filter" /><div style="font-size:90%;margin-left:10px;border:1px solid ##000;padding:2px;float:right;background-color:##fff">#HTMLfiltersAttributes# &nbsp;</div>
				</cfif>		
			</div>
			</cfoutput>
			<cfoutput><div id="filterForm" style="display:none;padding:5px;"></cfoutput>
				<ft:object objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" typename="#attributes.typename#" lFields="#attributes.lFilterFields#" lExcludeFields="" includeFieldset="false" />
				<ft:farcryButton value="apply filter" />
				<br/>
			<cfoutput></div></cfoutput>
		</ft:form>

	
	

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
						
						<cfcase value="string,nstring,list">	
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
									<cfelseif listcontains("numeric", PrimaryPackage.stProps[i].metadata.type)>
										<cfset whereValue = ReplaceNoCase(j,"'", "''", "all") />
										<cfoutput>AND #i# = #whereValue#</cfoutput>
									</cfif>
								</cfloop>
							</cfif>
						</cfdefaultcase>
						
						</cfswitch>
						
					</cfif>
				</cfloop>
			
		</cfsavecontent>

</cfif>



	<!------------------------
	SQL ORDER BY CLAUSE
	 ------------------------>
	<cfif len(attributes.sortableColumns)>
		<cfif isDefined("form.sqlOrderBy") and len(form.sqlOrderby)>
			<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = form.sqlOrderby />
		</cfif>
	</cfif>
	
	<cfif not structKeyExists(session.objectadminFilterObjects[attributes.typename], "sqlOrderBy") >
		<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = attributes.sqlorderby />
	</cfif>
	
			
	
	
	
	<cfset addURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#createUUID()#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#" />	
	<cfif Len(attributes.plugin)>
		<cfset addURL = addURL&"&plugin=#attributes.plugin#" />
		<cfset pluginURL = "&plugin=#attributes.plugin#" /><!--- we need this when using a plugin like farcrycms, to be able to redirect back to the plugin object admin instead of the project or core object admin --->
	</cfif>
	<ft:processForm action="add" url="#addURL#" />

	
	
	<ft:processForm action="overview">
		<!--- TODO: Check Permissions. --->
		<cfset EditURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#form.objectid#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#">
		<cfif Len(attributes.plugin)><cfset EditURL = EditURL&"&plugin=#attributes.plugin#"></cfif>
		<cflocation URL="#EditURL#" addtoken="false">
	</ft:processForm>
	
	<ft:processForm action="edit">
		<!--- TODO: Check Permissions. --->
		<cfset EditURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#form.objectid#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#">
		<cfif Len(attributes.plugin)><cfset EditURL = EditURL&"&plugin=#attributes.plugin#"></cfif>
		<cflocation URL="#EditURL#" addtoken="false">
	</ft:processForm>
	
	<ft:processForm action="view">
		<!--- TODO: Check Permissions. --->
		<cfoutput>
			<script language="javascript">
				var newWin = window.open("#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1","viewWindow","resizable=yes,menubar=yes,scrollbars=yes,width=800,height=600");
			</script>
		</cfoutput>
		<!--- <cflocation URL="#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1" addtoken="false" /> --->
	</ft:processForm>
	
	<cfif structKeyExists(application.stPlugins, "flow")>
		<ft:processForm action="flow">
			<!--- TODO: Check Permissions. --->
			<cflocation URL="#application.stPlugins.flow.url#/?startid=#form.objectid#&flushcache=1" addtoken="false" />
		</ft:processForm>
	</cfif>
	
	<ft:processForm action="requestapproval">
		<!--- TODO: Check Permissions. --->
		<cflocation URL="#application.url.farcry#/conjuror/changestatus.cfm?objectid=#form.objectid#&typename=#attributes.typename#&status=requestapproval&ref=typeadmin&module=#attributes.module##pluginURL#" addtoken="false" />
	</ft:processForm>
	
	<ft:processForm action="approve">
		<!--- TODO: Check Permissions. --->
		<cflocation URL="#application.url.farcry#/conjuror/changestatus.cfm?objectid=#form.objectid#&typename=#attributes.typename#&status=approved&ref=typeadmin&module=#attributes.module##pluginURL#" addtoken="false" />
	</ft:processForm>
	
	<ft:processForm action="createdraft">
		<!--- TODO: Check Permissions. --->
		<cflocation URL="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#form.objectID#" addtoken="false" />
	</ft:processForm>




	<!-----------------------------------------------
	    Form Actions for Type Admin Grid
	------------------------------------------------>
	<!--- TODO: retest permissions on form action, otherwise you can circumnavigate permissions with your own dummy form submission GB --->
	<cfscript>
	// response: action message container for objectadmin
	response="";
	message_error = "";
	
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
			if (form.status contains application.adminBundle[session.dmProfile.locale].approve)
				status = 'approved';
			else if (form.status contains application.adminBundle[session.dmProfile.locale].sendToDraft)
				status = 'draft';
			else if (form.status contains application.adminBundle[session.dmProfile.locale].requestApproval)
				status = 'requestApproval';
			else
				status = 'unknown';
			// pass list of objectids to comment template to add user comments
			statusurl = "#application.url.farcry#/conjuror/changestatus.cfm?typename=#attributes.typename#&status=#status#&objectID=#form.objectID#&finishURL=#URLEncodedFormat(cgi.script_name)#?#URLEncodedFormat(cgi.query_string)#";
			if (isDefined("stgrid.approveURL"))
				statusurl = statusurl & "&approveURL=#URLEncodedFormat(stGrid.approveURL)#";
		} else
			response = "#application.adminBundle[session.dmProfile.locale].noObjSelected#";
	}
	</cfscript>
	<!--- redirect user on status change --->
	<cfif len(statusurl)><cflocation url="#statusurl#" addtoken="false"></cfif>
	
	<cfscript>
	// unlock: unlock content items
	if (isDefined("form.unlock") AND isDefined("form.objectid")) {
		aObjectids = listToArray(form.objectid);
		//loop over all selected objects
		for(i = 1;i LTE arrayLen(aObjectids);i=i+1) {
			// set unlock permmission to false by default
			bAllowUnlock=false;
			// get content item data
			o=createobject("component", "#PrimaryPackagePath#");
			stObj = o.getData(objectid=aObjectids[i]);
			if(stObj.locked)
			{
				// allow owner of the object or the person who has locked the content item to unlock
				if (stObj.lockedby IS "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#"
					OR stObj.ownedby IS "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#") {
					bAllowUnlock=true;
				// allow users with approve permission to unlock
				} else if (stPermissions.iApprove eq 1) {
					bAllowUnlock=true;
				// if the user doesn't have permission, push error response
				} else {
					response=application.adminBundle[session.dmProfile.locale].noPermissionUnlockAll;
				}
			}
			if (bAllowUnlock) {
				// TODO: replace with types.setlock()
				oLocking=createObject("component",'#application.packagepath#.farcry.locking');
				oLocking.unLock(objectid=aObjectids[i],typename=stObj.typename);
				// TODO: i18n
				response="Content items unlocked.";
			}
		}
	}
	</cfscript>
	<!--- 
	// custom: custom button action
	--->
	<cfif NOT structisempty(form)>
		<cfif NOT isDefined("form.objectid")>
			<cfscript>
				form.objectid = createUUID();
			</cfscript>
		</cfif>
		<cfloop collection="#form#" item="fieldname">
			<!--- match for custom button action --->
			<cfif reFind("CB.*", fieldname) AND NOT reFind("CB.*_DATA", fieldname)>
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




<ft:form style="width: 100%;" Name="objectadmin">




	<!--- output user responses --->
	<cfif len(message_error)><cfoutput><p id="error" class="fade"><span class="error">#message_error#</span></p></cfoutput></cfif>
	<cfif len(response)><cfoutput><p id="response" class="fade">#response#</p></cfoutput></cfif>
	
	<!--- delete flag; modified to 1 on delete confirm --->
	<cfoutput><input name="delete" type="Hidden" value="0"></cfoutput>
	
	
	<cfscript>
	// todo:refactoring... get rid of it, tests being done in cfc now GB
	oAuthorisation=request.dmsec.oAuthorisation;
	</cfscript>
	<cfsavecontent variable="html_buttonbar">
	<cfoutput>
	<div class="">
	</cfoutput>
	
	<cfloop from="1" to="#arraylen(attributes.aButtons)#" index="i">
		
		<cfif attributes.lButtons EQ "*" or listFindNoCase(attributes.lButtons,attributes.aButtons[i].value)>
			<!--- (#attributes.aButtons[i].name#: #attributes.aButtons[i].permission#) --->
			<cfif NOT len(attributes.aButtons[i].permission) OR oAuthorisation.checkPermission(permissionName=attributes.aButtons[i].permission,reference="PolicyGroup") EQ 1>
				
				<cfif len(attributes.aButtons[i].onclick)> 
					<cfset onclickJS="#attributes.aButtons[i].onclick#" />
				<cfelse>
					<cfset onclickJS="" />
				</cfif>
				
				<ft:farcryButton value="#attributes.aButtons[i].value#" class="formButton"  onclick="#onclickJS#" />
				<!---<input type="#attributes.aButtons[i].type#" name="#attributes.aButtons[i].name#" value="#attributes.aButtons[i].value#" class="formButton"<cfif len(attributes.aButtons[i].onclick)> onclick="#attributes.aButtons[i].onclick#"</cfif> /> --->
			</cfif>
		</cfif>
	</cfloop>
	
	<cfoutput>
	</div>
	<br class="clearer" />
	</cfoutput>
	
	</cfsavecontent>
	
	<cfoutput>#html_buttonbar#</cfoutput>



<!--- output buttons for type admin pagination --->
<!---<cfif len(attributes.lButtons)>

	<cfoutput><div class="buttons"></cfoutput>
		
		<cfif listFindNoCase(attributes.lButtons, "add")>
			<ft:farcryButton value="add" />
		</cfif>
		
		<cfif listFindNoCase(attributes.lButtons, "unlock")>
			<ft:farcryButton value="unlock" />
		</cfif>
		
		<cfif listFindNoCase(attributes.lButtons, "delete")>
			<ft:farcryButton value="delete" onclick="if(confirm('Are you sure you wish to delete these objects?')){return true};{return false};" />
		</cfif>
		
	<cfoutput></div></cfoutput>

</cfif>	 --->



	<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
	<cfset sqlColumns="objectid,locked,lockedby,#attributes.columnlist#" />
	<!---<cfset bhasstatus=false />
	<!--- check if the type has a status property --->
	<cfif structKeyExists(application.types[attributes.typename].STPROPS, "status")>
		<cfif not findNocase(attributes.ColumnList, "status") or not findNocase(attributes.ColumnList, "*")>
			<cfset sqlColumns = listAppend(sqlColumns,"status")>
			<cfset bhasstatus=true />
		</cfif>
	</cfif> --->




	<cfset stRecordset = oFormtoolUtil.getRecordset(paginationID="#attributes.typename#", sqlColumns=sqlColumns, typename="#attributes.typename#", RecordsPerPage="#attributes.numitems#", sqlOrderBy="#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#", sqlWhere="#attributes.sqlWhere#", lCategories="#attributes.lCategories#", bCheckVersions=true) />	




<ft:pagination 
	paginationID="#attributes.typename#"
	qRecordSet="#stRecordset.q#"
	typename="#attributes.typename#"
	totalRecords="#stRecordset.countAll#" 
	currentPage="#stRecordset.currentPage#"
	Step="10"  
	pageLinks="#attributes.numPageDisplay#"
	recordsPerPage="#stRecordset.recordsPerPage#" 
	Top="#attributes.bPaginateTop#" 
	Bottom="#attributes.bPaginateBottom#"
	submissionType="form"> 


	<cfif len(attributes.SortableColumns)>
		<cfoutput><input type="hidden" id="sqlOrderBy" name="sqlOrderBy" value=""></cfoutput>
	</cfif>
	
	<cfoutput>
	<table width="100%">
		<tr>			
	</cfoutput>
	
	 		<cfif attributes.bSelectCol><cfoutput><th>Select</th></cfoutput></cfif>
	 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
		 		<cfoutput><th>Status</th></cfoutput>
			</cfif>
			<cfoutput><th>Action</th></cfoutput>
			<!---<cfif attributes.bEditCol><th>Edit</th></cfif>
			<cfif attributes.bViewCol><th>View</th></cfif>
			<cfif attributes.bFlowCol><th>Flow</th></cfif> --->
			
			<cfif arrayLen(attributes.aCustomColumns)>
				<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
					
					<cfif isStruct(attributes.aCustomColumns[i]) and structKeyExists(attributes.aCustomColumns[i], "title")>
						<cfoutput><th>#attributes.aCustomColumns[i].title#</th></cfoutput>
					<cfelse>
						<cfoutput><th>&nbsp;</th></cfoutput>
					</cfif>
					
				</cfloop>
			</cfif>
			
			<cfloop list="#attributes.columnlist#" index="i">				
					
				<cfif isDefined("PrimaryPackage.stProps.#trim(i)#.metadata.ftLabel")>
					<cfoutput><th>#PrimaryPackage.stProps[trim(i)].metadata.ftLabel#</th></cfoutput>
				<cfelse>
					<cfoutput><th>#i#</th></cfoutput>
				</cfif>
				
			</cfloop>
			
		<cfoutput>
		</tr>
		</cfoutput>
		
		
		<cfif len(attributes.SortableColumns)>
			<cfoutput>
			<tr>
			</cfoutput>
			
		 		<cfif attributes.bSelectCol><cfoutput><th>&nbsp;</th></cfoutput></cfif>	 	
		 			
		 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
			 		<cfoutput><th>&nbsp;</th></cfoutput>
				</cfif>
				<cfoutput><th>&nbsp;</th></cfoutput>
				<!---<cfif attributes.bEditCol><th>&nbsp;</th></cfif>
				<cfif attributes.bViewCol><th>&nbsp;</th></cfif>
				<cfif attributes.bFlowCol><th>&nbsp;</th></cfif> --->					
				<cfif arrayLen(attributes.aCustomColumns)>
					<cfset oType = createObject("component", PrimaryPackagePath) />
					<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
						<cfif structKeyExists(attributes.aCustomColumns[i],"sortable") and attributes.aCustomColumns[i].sortable>
							<cfoutput>
							<th>
							<select name="#attributes.aCustomColumns[i].property#sqlOrderBy" onchange="javascript:$('sqlOrderBy').value=this.value;submit();" style="width:80px;">
								<option value=""></option>
								<option value="#attributes.aCustomColumns[i].property# asc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# asc">selected</cfif>>asc</option>
								<option value="#attributes.aCustomColumns[i].property# desc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# desc">selected</cfif>>desc</option>
							</select>
							</th>
							</cfoutput>						
						<cfelse>
							<cfoutput><th>&nbsp;</th></cfoutput>
						</cfif>
					</cfloop>
				</cfif>
		
				<cfloop list="#attributes.columnlist#" index="i">
					<cfoutput><th></cfoutput>					
						<cfif listContainsNoCase(attributes.SortableColumns,i)>
							<cfoutput>
							<select name="#i#sqlOrderBy" onchange="javascript:$('sqlOrderBy').value=this.value;submit();" style="width:80px;">
								<option value=""></option>
								<option value="#i# asc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# asc">selected</cfif>>asc</option>
								<option value="#i# desc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# desc">selected</cfif>>desc</option>
							</select>
							</cfoutput>
						<cfelse>
							<cfoutput>&nbsp;</cfoutput>
						</cfif>
					<cfoutput></th></cfoutput>
				</cfloop>
			<cfoutput>
			</tr>
			</cfoutput>
		</cfif>

	
	
		
		<ft:paginateLoop r_stObject="st" bIncludeFields="true" bIncludeObjects="false" stpermissions="#stpermissions#" lCustomActions="#attributes.lCustomActions#">
			
				<cfoutput>
				<tr>
				</cfoutput>
				
					<cfif attributes.bSelectCol>
						<cfoutput><td nowrap="true">#st.select# #st.currentRow#</td></cfoutput>
					</cfif>
			 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
				 		<cfoutput><td nowrap="true">#st.status#</td></cfoutput>
					</cfif>
					<cfoutput><td>#st.action#</td></cfoutput>
					<!---<cfif attributes.bEditCol><td>#st.editLink#</td></cfif>
					<cfif attributes.bViewCol><td>#st.viewLink#</td></cfif>
					<cfif attributes.bFlowCol><td>#st.flowLink#</td></cfif> --->
					<cfif arrayLen(attributes.aCustomColumns)>
						<cfset oType = createObject("component", PrimaryPackagePath) />
						<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
							
							<cfif isStruct(attributes.aCustomColumns[i]) and structKeyExists(attributes.aCustomColumns[i], "webskin")>
								<cfset HTML = oType.getView(objectid="#st.stFields.objectid.value#", template="#attributes.aCustomColumns[i].webskin#")>
								<cfoutput><td>#HTML#</td></cfoutput>
							<cfelse>
								<cfoutput><td>&nbsp;</td></cfoutput>
							</cfif>
							
						</cfloop>
					</cfif>
					<cfloop list="#attributes.columnlist#" index="i">
						<cfif structKeyExists(st.stFields, i)>
							<cfoutput><td>#st.stFields[i].HTML#</td>	</cfoutput>			
						<cfelse>
							<cfoutput><td>-- not available --</td>	</cfoutput>			
						</cfif>
						
					</cfloop>
				<cfoutput>
				</tr>
				</cfoutput>
			
			
		</ft:paginateLoop>
	
	<cfoutput></table></cfoutput>



</ft:pagination> 




</ft:form>






</cfif>

<cfif thistag.executionMode eq "End">

</cfif> 

<!---
<cffunction name="getRecordset" access="public" output="No" returntype="struct">
	<cfargument name="typename" required="No" type="string" default="" />
	<cfargument name="sqlColumns" required="No" type="string" default="objectid" />
	<cfargument name="sqlWhere" required="No" type="string" default="" />
	<cfargument name="sqlOrderBy" required="No" type="string" default="label" />
	
	<cfargument name="CurrentPage" required="No" type="numeric" default="1" />
	<cfargument name="RecordsPerPage" required="No" type="numeric" default="5" />
	<cfargument name="PageLinksShown" required="No" type="numeric" default="10" />
	
	<cfset var stReturn = structNew() />
	<cfset var q = '' />
	<cfset var recordcount = '' />
	
	<cfif NOT len(arguments.sqlWhere)>
		<cfset arguments.sqlWhere = "0=0" />
	</cfif>
	
	<!--- query --->
	<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
	    <cfprocresult name="q" resultset="1">
	    <cfprocresult name="recordcount" resultset="2">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="objectid">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
	     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
	</cfstoredproc>
	
	
	<!------------------------------
	DETERMINE THE TOTAL PAGES
	 ------------------------------>
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
		
	<!------------------------------
	IF THE CURRENT PAGE IS GREATER THAN THE TOTAL PAGES, REDO THE RECORDSET FOR PAGE 1
	 ------------------------------>		
	<cfif arguments.CurrentPage GT stReturn.TotalPages and arguments.CurrentPage GT 1>
		
		<cfset arguments.CurrentPage = 1 />
		
		<!--- query --->
		<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
		    <cfprocresult name="q" resultset="1">
		    <cfprocresult name="recordcount" resultset="2">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="objectid">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
		     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
		</cfstoredproc>
	</cfif>			
	
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
	
	
	<!--- NOW THAT WE HAVE OUR QUERY, POPULATE THE RETURN STRUCTURE --->
	<cfset stReturn.q = q />
	<cfset stReturn.countAll = recordcount.countAll />
	<cfset stReturn.CurrentPage = arguments.CurrentPage />
	
	
	<cfset stReturn.Startpage = 1>
	<cfset stReturn.PageLinksShown = min(arguments.PageLinksShown, stReturn.TotalPages)>
	
	<cfif stReturn.CurrentPage + int(stReturn.PageLinksShown / 2) - 1 GTE stReturn.TotalPages>
		<cfset stReturn.StartPage = stReturn.TotalPages - stReturn.PageLinksShown + 1>
	<cfelseif stReturn.CurrentPage + 1 GT stReturn.PageLinksShown>
		<cfset stReturn.StartPage = stReturn.CurrentPage - int(stReturn.PageLinksShown / 2)>
	</cfif>
	
	<cfset stReturn.Endpage = stReturn.StartPage + stReturn.PageLinksShown - 1>
		
	<cfset stReturn.RecordsPerPage = arguments.RecordsPerPage />
	<cfset stReturn.typename = arguments.typename />
     
	<cfreturn stReturn />
</cffunction> --->



<cfsetting enablecfoutputonly="no">
