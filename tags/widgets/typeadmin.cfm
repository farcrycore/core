<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/typeadmin.cfm,v 1.38.2.5 2006/03/15 04:03:40 jason Exp $
$Author: jason $
$Date: 2006/03/15 04:03:40 $
$Name: milestone_3-0-1 $
$Revision: 1.38.2.5 $

|| DESCRIPTION || 
$Description: Generic administration screen for content types. $

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au)$

|| USAGE ||
Pass in structures for properties and methods...
<cf_typeadmin
	typename="Daemon_Test"
	description="News Object"
	handlerRoot="/#application.applicationname#/handlers"
	metadata = "RunVerityUpdates"
	Properties="#stProperties#"
	Methods="#stMethods#" /> 

OR use child tags to build properties and methods...
<cf_typeadmin
	typename="dmNews">
	<cf_typeadmincolumn title="Edit" columntype="expression" />
	<cf_typeadmincolumn title="Locked" columntype="evaluate" />
	<cf_typeadminbutton buttontype="add" />
	<cf_typeadminbutton buttontype="delete" />
</cf_typeadmin>

OR a combination of the two.

|| ATTRIBUTES ||
-> [typename]: the name of the type (required)
-> [title]: Title for the admin.  Defaults to content type component display name.
-> [description]: brief description of the content type.  Defaults to content type component hint.
-> [bFilterCategories]: display filter options by category
-> [bFilterDateRange]: display filter options by datetimelastupdated, datetimecreated
-> [bFilterProperties]: display filter options by LIKE on varchar properties
-> [datasource]: application COAPI datasource. Defaults to application.dsn
-> [permissionset]: prefix for a standard set of content type permissions
-> [aColumns]: data for grid column data. Defaults to sytem attributes
-> [aButtons]: data for grid button data. Defaults to basic set aDefaultButtons
-> [query]: content object recordset to render. Defaults to all for content type
-> [orderby]: data column to order content by. Defaults to datetimelastupdated (may look for URL.orderby)
-> [finishURL]: URL to return user to on completion of activity. Can we default this to the current cgi.script_path??

|| KNOWN ISSUES ||
If you pass in a prepared query as an attribute, this may be overridden by applying a category filter.
Selecting for specific categories re-runs the query rather than attempting filter on the passed in query.
If you are providing a data subset that needs to be protected disable the category filter option.
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<!--- make sure tag is correctly implemented --->
<cfif NOT thisTag.HasEndTag>
	<cfabort showerror="<strong>cf_typeadmin requires a closing tag.</strong><br /><strong>Usage:</strong><br />&lt;cf_typeadmin&gt;&lt;/cf_typeadmin&gt; or &lt;cf_typeadmin/&gt;">
</cfif>

<cfswitch expression="#thisTag.ExecutionMode#">
<cfcase value="start">
<!--- required attributes --->
<cfparam name="attributes.typename" type="string">

<!--- optional attributes --->
<cfparam name="attributes.title" default="#attributes.typename# Administration" type="string">
<cfparam name="attributes.description" default="" type="string">
<cfparam name="attributes.datasource" default="#application.dsn#" type="string">
<cfparam name="attributes.aColumns" default="#arrayNew(1)#" type="array">
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

<!--- admin configuration options --->
<cfparam name="attributes.numitems" default="#application.config.general.GENERICADMINNUMITEMS#" type="numeric">
<cfparam name="attributes.numPageDisplay" default="5" type="numeric">

<!--- validation checks --->
<cfparam name="errormessage" default="">
<!--- SESSION parameters: 
	gather specific filter settings and required parameters 

	These environment params are also required:
	 - application.adminBundle[session.dmProfile.locale]
	 - application.thisCalendar
	 - session.dmSec.authentication.userlogin
	 - session.dmSec.authentication.userDirectory
--->
<!--- grab or create typeadmin prefs structure in session cache --->
<!--- remove all filters --->
<cfif isDefined("URL.killFilter")>
	<cfset session.typeadmin = StructNew()>
</cfif>

<cfparam name="session.typeadmin" default="#structnew()#" type="struct">

<cfif NOT structKeyExists(session.typeadmin, attributes.id)>
	<cfset structInsert(session.typeadmin, attributes.id, structnew())>
</cfif>

<cfif NOT structKeyExists(application.types[attributes.typename], attributes.permissionset)>
<!--- this seems to be a problem for custom types when it gets to invocation.cfm. the permission set is not carried
across and could potentially cause major stuff ups if news permissions (which is the default) is set to no for the
user --->
	<cfset structInsert(application.types[attributes.typename], "permissionset", attributes.permissionset, "yes")>
</cfif>

<!--- instantiate typeadmin component --->
<cfset oTypeAdmin = createobject("component", "#application.packagepath#.farcry.typeadmin").init(stprefs=session.typeadmin[attributes.typename], attributes=attributes)>
<cfif isDefined("url.orderby")>
	<cfset oTypeAdmin.setPref("orderby", url.orderby)>
	<!--- <cfset structUpdate(session.typeadmin[attributes.typename], "orderby", url.orderby)> --->
</cfif>
<cfif isDefined("url.order")>
	<cfset oTypeAdmin.setPref("order", url.order)>
	<!--- <cfset structUpdate(session.typeadmin[attributes.typename], "order", url.order)> --->
</cfif>
<cfif isDefined("url.pg")>
	<cfset oTypeAdmin.setPref("pg", url.pg)>
	<!--- <cfset structUpdate(session.typeadmin[attributes.typename], "pg", url.pg)> --->
</cfif>

<!--- CATGEORIES --->
<cfif isDefined("form.button_Filter_Category")>
	<cfset oTypeAdmin.setCategoryFilter(form.categoryid)>
	<!--- remove specific category filter --->
<cfelseif isDefined("URL.killCatID")>
	<cfset oTypeAdmin.deleteCategoryFilter(URL.killCatID)>
</cfif>

<!--- KEYWORDS --->
<cfif isDefined("form.button_Filter_Keyword")>
	<cfif form.keywords NEQ "" AND form.keywords_field NEQ "">
	<cfif NOT FindNoCase("~",form.keywords) AND NOT FindNoCase("^",form.keywords)>
		<cfset oTypeAdmin.setKeywordFilter(form.keywords_field, form.keywords)>
	<cfelse>
		<cfset errormessage = errormessage & "Please remove the characters '~' and/or '^' from keyword.<br />">
	</cfif>

	</cfif>
	<!--- remove specific keyword filter --->
<cfelseif isDefined("URL.killKeyword")>
	<cfset oTypeAdmin.deleteKeywordFilter(URL.killKeyword)>
</cfif>

<!--- DATERANGE --->
<cfif isDefined("form.button_Filter_DateRange")>
	<cfif form.daterange NEQ "" AND ListLen(form.daterange,"-") LTE 2>
		<cfif NOT IsDate(trim(ListFirst(form.daterange,"-")))>
			<cfset errormessage = errormessage & "From date #ListFirst(form.daterange,'-')# is an incorrect date format please enter yyyy/mm/dd.<br />">
		</cfif>

		<cfif ListLen(form.daterange,"-") EQ 2>
			<cfif NOT IsDate(trim(ListLast(form.daterange,"-")))>
				<cfset errormessage = errormessage & "To date #ListLast(form.daterange,'-')# is an incorrect date format please enter yyyy/mm/dd.<br />">
			</cfif>
		</cfif>

		<cfif errormessage EQ "">
			<cfset oTypeAdmin.setDateRangeFilter(form.daterange_field, form.daterange)>
		</cfif>
	</cfif>
<cfelseif isDefined("URL.killdaterange")>
	<cfset oTypeAdmin.deleteDateRangeFilter(URL.killdaterange)>
</cfif>

<!--- remove all filters --->
<!--- <cfif isDefined("URL.killFilter")>
	<cfset oTypeAdmin.deleteAllFilter()>
</cfif> --->

<!--- get default grid data --->
<cfset aDefaultColumns=oTypeAdmin.getDefaultColumns()>
<cfset aDefaultButtons=oTypeAdmin.getDefaultButtons()>

<!--- refactored to here... --->
<cfset session.typeadmin[attributes.typename]=oTypeadmin.getprefs()>
<cfset stpermissions=oTypeAdmin.getBasePermissions()>
<!--- <cfdump var="#session.typeadmin[attributes.typename]#"> --->
<!--- /refactored --->

</cfcase>

<cfcase value="end">
<!-----------------------------------------------
     Child Tag Data
------------------------------------------------>
<!--- grab associated data from child tags when they exist --->
<cfif IsDefined("thisTag.aColumns")>
	<cfset oTypeAdmin.setAttribute("aColumns", thisTag.aColumns)>
	<!--- <cfset attributes.aColumns=thisTag.aColumns> --->
</cfif>
<cfif IsDefined("thisTag.aButtons")>
	<cfset oTypeAdmin.setAttribute("aButtons", thisTag.aButtons)>
	<!--- <cfset attributes.aButtons=thisTag.aButtons> --->
</cfif>

<!-----------------------------------------------
    Form Actions for Type Admin Grid
------------------------------------------------>
<!--- TODO: retest permissions on form action, otherwise you can circumnavigate permissions with your own dummy form submission GB --->
<cfscript>
// response: action message container for typeadmin
response="";
message_error = "";

// add: content item added
// JS window.location from button press
	
// delete: content items deleted
if (isDefined("form.delete") AND form.delete AND isDefined("form.objectid")){
	objType = CreateObject("component","#application.types[attributes.typename].typepath#");
	aDeleteObjectID = ListToArray(form.objectid);

	for(i=1;i LTE Arraylen(aDeleteObjectID);i = i+1){
		returnstruct = objType.delete(aDeleteObjectID[i]);
		if(StructKeyExists(returnstruct,"bSuccess") AND NOT returnstruct.bSuccess)
			message_error = message_error & returnstruct.message;
	}
}

// dump: content items to dump
// TODO: implement object dump code!
if (isDefined("form.dump") AND isDefined("form.objectid"))
	response="DUMP (field: #form.dump#)actioned for: #form.objectid#.";

// status: change status of the selected content items
// todo: make three unique buttons, match on buttontype *not* resource bundle label
statusurl="";
if (isDefined("form.status")) {
	if (isDefined("form.objectID")) {
		if (form.status contains application.rb.getResource("approve"))
			status = 'approved';
		else if (form.status contains application.rb.getResource("sendToDraft"))
			status = 'draft';
		else if (form.status contains application.rb.getResource("requestApproval"))
			status = 'requestApproval';
		else
			status = 'unknown';
		// pass list of objectids to comment template to add user comments
		statusurl = "#application.url.farcry#/conjuror/changestatus.cfm?typename=#attributes.typename#&status=#status#&objectID=#form.objectID#&finishURL=#URLEncodedFormat(cgi.script_name)#?#URLEncodedFormat(cgi.query_string)#";
		if (isDefined("stgrid.approveURL"))
			statusurl = statusurl & "&approveURL=#URLEncodedFormat(stGrid.approveURL)#";
	} else
		response = "#application.rb.getResource("noObjSelected")#";
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
		o=createobject("component", "#application.types[attributes.typename].typePath#");
		stObj = o.getData(objectid=aObjectids[i]);
		if(stObj.locked)
		{
			// allow owner of the object or the person who has locked the content item to unlock
			if (stObj.lockedby IS "#application.security.getCurrentUserID()#"
				OR stObj.ownedby IS "#application.security.getCurrentUserID()#") {
				bAllowUnlock=true;
			// allow users with approve permission to unlock
			} else if (stPermissions.iApprove eq 1) {
				bAllowUnlock=true;
			// if the user doesn't have permission, push error response
			} else {
				response=application.rb.getResource("noPermissionUnlockAll");
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

<!----------------------------------------------
    Prepare Recordset
----------------------------------------------->
<cfset recordset=oTypeAdmin.getRecordSet()>

<!--- determine key pagination variables --->
<cfset pgtotal=otypeadmin.gettotalpages()>
<cfset startrow=otypeadmin.getstartrow()>
<cfset endrow=otypeadmin.getendrow()>

<!------------------------------------
   Output Type Admin Grid 
-------------------------------------->
<cfsavecontent variable="grid">
<cfoutput>
<div id="genadmin-wrap">
<h1>#attributes.title#</h1>

<!--- output user responses --->
<cfif len(message_error)><p id="error" class="fade"><span class="error">#message_error#</span></p></cfif>
<cfif len(response)><p id="response" class="fade">#response#</p></cfif>

<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="typeadmin" id="typeadmin">
<!--- delete flag; modified to 1 on delete confirm --->
<input name="delete" type="Hidden" value="0">
</cfoutput>

<!--- hidden fields for custom buttons --->
<cfloop from="1" to="#arraylen(attributes.aButtons)#" index="i">
	<cfif attributes.aButtons[i].buttontype eq "custom">
	<!--- add hidden field to hold custom button data --->
		<cfoutput><input type="hidden" name="#attributes.aButtons[i].name#_data" value="#attributes.aButtons[i].customdata#" />
		</cfoutput>
	</cfif>
</cfloop>


<!--- filters: tab container --->
<cfoutput>
<div class="tab-container" id="container1">
	<cfif attributes.bFilterCategories OR attributes.bFilterProperties OR attributes.bFilterDateRange>
		<ul class="tabs2">
			<li class="first"><strong>Filter by</strong>:</li>
			<cfif attributes.bFilterCategories><li onclick="return showPane('pane1', this)" id="tab1"><a href="##pane1-ref">Category</a></li></cfif>
			<cfif attributes.bFilterProperties><li onclick="return showPane('pane2', this)" id="tab2"><a href="##pane2-ref">Keyword</a></li></cfif>
			<cfif attributes.bFilterDateRange><li onclick="return showPane('pane3', this)" id="tab3" class="last"><a href="##pane3-ref">Date range</a></li></cfif>
		</ul>
	</cfif>
</cfoutput>

<cfoutput><div class="tab-panes-linkslist"></cfoutput>

<!------------------------------------
	// category filter panel 
-------------------------------------->
<cfif attributes.bFilterCategories>
	<cfoutput>
		<a name="pane1-ref"></a>
		<div id="pane1">
			#oTypeAdmin.panelCategoryFilter()#
			<hr />
		</div>
	</cfoutput>
</cfif>

<cfif attributes.bFilterProperties>
	<cfoutput>
		<a name="pane2-ref"></a>
		<div id="pane2">
			#oTypeAdmin.panelKeywordFilter()#
			<hr />
		</div>
	</cfoutput>
</cfif>

<cfif attributes.bFilterDateRange>
	<cfoutput>
		<a name="pane3-ref"></a>
		<div id="pane3">
			#oTypeAdmin.panelDateRangeFilter()#
			<hr />
		</div>
	</cfoutput>
</cfif>

<cfoutput>
	</div>
	<p>Displaying <strong>#startrow#-#endrow#</strong> of <strong>#recordset.recordcount#</strong> results.
	<cfif attributes.bFilterCategories OR attributes.bFilterProperties OR attributes.bFilterDateRange><cfif session.typeadmin[attributes.typename].filter_daterange NEQ "" OR session.typeadmin[attributes.typename].filter_lKeywords NEQ "" OR session.typeadmin[attributes.typename].lCategoryIDs NEQ "">
		<strong>Filters Applied</strong> | <a href="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#&killFilter">Remove All Filters</a><cfelse>
		<strong>No Filters Applied</strong></cfif></cfif>
	</p>
</div>
<!--- collapse filter containing div --->
<script type="text/javascript">setupPanes('container1');</script>
</cfoutput>

<!--- pagination widget, based on attributes.numitems and session.typeadmin[attributes.typename].pg --->
<cfset urlParameters = "">
<cfif isDefined("url.module")>
	<cfset urlParameters = "&module=#url.module#">
</cfif>
<cfif StructKeyExists(url,"lib")>
	<cfset urlParameters = urlParameters&"&lib="&url.lib>
</cfif>
<cfparam name="url.pg" default="#session.typeadmin[attributes.typename].pg#" />
<cfsavecontent variable="html_pagination">
<cfoutput><div class="pagination">
  <h5></cfoutput>
	<widgets:paginationDisplay
        QueryRecordCount="#recordset.recordcount#"
        FileName="#cgi.script_name#"
        MaxresultPages="#attributes.numPageDisplay#"
        MaxRowsAllowed="#attributes.numitems#"
        bEnablePageNumber="true"
        LayoutNumber="4"
        FirstLastPage="numeric"
        Layout_Previous="Previous"
        Layout_Next="Next"
		CurrentPageWrapper_Start="<span>"
		CurrentPageWrapper_End="</span>"
        ExtraURLString="#urlParameters#">
<cfoutput></h5>
</div></cfoutput>
</cfsavecontent>
<!--- if more than one page, show pagination --->
<cfif endrow lte recordset.recordcount AND recordset.recordcount gt 0><cfoutput>#html_pagination#</cfoutput></cfif>


<cfscript>
// todo:refactoring... get rid of it, tests being done in cfc now GB
oAuthorisation=application.factory.oAuthorisation;
</cfscript>
<!--- button bar widget --->
<cfsavecontent variable="html_buttonbar">
<cfoutput>
<div class="utilBar f-subdued">
<cfloop from="1" to="#arraylen(attributes.aButtons)#" index="i">
<!--- (#attributes.aButtons[i].name#: #attributes.aButtons[i].permission#) --->
<cfif NOT len(attributes.aButtons[i].permission) OR oAuthorisation.checkPermission(permissionName=attributes.aButtons[i].permission,reference="PolicyGroup") EQ 1>
	<input type="#attributes.aButtons[i].type#" name="#attributes.aButtons[i].name#" value="#attributes.aButtons[i].value#" class="#attributes.aButtons[i].class#"<cfif len(attributes.aButtons[i].onclick)> onclick="#attributes.aButtons[i].onclick#"</cfif> />
</cfif>
</cfloop>
</div>
<br class="clear" />
</cfoutput>
</cfsavecontent>
<cfoutput>#html_buttonbar#</cfoutput>
<cfoutput><cfif errormessage NEQ "">
<h5 class='fade-FFDADA' id='errortext'><span style='color:##c00'>#errormessage#</span></h5></cfif>
<table class="table-2" cellspacing="0">
	<tr>
</cfoutput>
<!--- generate grid headers --->
<cfloop from="1" to="#arraylen(attributes.aColumns)#" index="i">
	<!--- provisions for column ordering --->
	<cfif NOT structkeyexists(attributes.aColumns[i], "orderby")>
		<cfset structInsert(attributes.aColumns[i], "orderby", "")>
	</cfif>
	<!--- provide reverse orderby order option --->
	<cfif session.typeadmin[attributes.typename].order contains "desc">
		<cfset order="asc">
	<cfelse>
		<cfset order="desc">
	</cfif>
	<!--- table headings --->
	<cfif len(attributes.aColumns[i].orderby)>
	<cfoutput>
	<th scope="col"<cfif attributes.aColumns[i].orderby eq session.typeadmin[attributes.typename].orderby> class="order-#session.typeadmin[attributes.typename].order#"</cfif>><a href="#cgi.SCRIPT_NAME#?orderby=#attributes.aColumns[i].orderby#&order=<cfif attributes.aColumns[i].orderby eq session.typeadmin[attributes.typename].orderby>#order#<cfelse>desc</cfif><cfif isDefined("url.module")>&module=#url.module#</cfif>">#attributes.aColumns[i].title#</a></th></cfoutput>
	<cfelse>
	<cfoutput>
	<th scope="col">#attributes.aColumns[i].title#</th></cfoutput>
	</cfif>
</cfloop>
<cfoutput>
	</tr>
</cfoutput>

<!--- generate grid records --->
<cfif recordset.recordcount eq 0>
	<!--- todo: i18n update --->
	<cfoutput><tr><td colspan="#arraylen(attributes.aColumns)#" style="text-align: center;">No content items available.</td></tr></cfoutput>
<cfelse>
<cfloop query="recordset" startrow="#startrow#" endrow="#endrow#">
	<cfoutput>
	<tr#iif(recordset.currentrow mod 2, de(" class=""alt"""), de(""))#></cfoutput>
	<cfloop from="1" to="#arraylen(attributes.aColumns)#" index="i">
		<cfset showMultipleVersionIdicator = "">
		<cfif isDefined("recordset.bHasMultipleVersion") AND recordset.bHasMultipleVersion AND attributes.aColumns[i].title EQ "label">
			<cfset showMultipleVersionIdicator = " *">
		</cfif>
		<cftry>
		<cfswitch expression="#attributes.aColumns[i].columntype#">
			<cfcase value="evaluate">
				<cfoutput>
				<td <cfif len(attributes.aColumns[i].style)>style="#attributes.aColumns[i].style#"</cfif>>#evaluate(attributes.aColumns[i].value)##showMultipleVersionIdicator#</td></cfoutput>
			</cfcase>
			<cfcase value="expression">
				<cfoutput>
				<td <cfif len(attributes.aColumns[i].style)>style="#attributes.aColumns[i].style#"</cfif>>#evaluate(DE(attributes.aColumns[i].value))##showMultipleVersionIdicator#</td></cfoutput>
			</cfcase>
			<cfcase value="value">
				<cfoutput>
				<td <cfif len(attributes.aColumns[i].style)>style="#attributes.aColumns[i].style#"</cfif>>#evaluate("recordset.#attributes.aColumns[i].value#")##showMultipleVersionIdicator#</td></cfoutput>
			</cfcase>
			<cfcase value="render">
				<cfoutput>
				<td <cfif len(attributes.aColumns[i].style)>style="#attributes.aColumns[i].style#"</cfif>>
					<ft:object objectid="#recordset.objectid#" lfields="#attributes.aColumns[i].value#" intable="0" includeLabel="0" format="display" r_stFields="stFields" includefieldset="false" />
					[#ListChangeDelims(stFields[attributes.aColumns[i].value].html, " ] [" , ",")#]
					#showMultipleVersionIdicator#
				</td></cfoutput>
			</cfcase>
			<cfdefaultcase>
				<cfoutput>
				<td>#attributes.aColumns[i].value##showMultipleVersionIdicator#</td></cfoutput>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch>
			<!--- catch awkward data fizzles --->
				<cfoutput>--fizzle--</td></cfoutput>
		</cfcatch>
		</cftry>
	</cfloop>
	<cfoutput>
	</tr></cfoutput>
</cfloop>
</cfif>
<cfoutput>
	</table></cfoutput>

<!--- pagination widget, based on attributes.numitems and session.typeadmin[attributes.typename].pg --->
<!--- if more than one page, show pagination --->
<cfif endrow lte recordset.recordcount AND recordset.recordcount gt 0><cfoutput>#html_pagination#</cfoutput></cfif>

<!--- button bar widget --->
<cfoutput>#html_buttonbar#</cfoutput>

<cfoutput>
</form>
</div>
</cfoutput>

<!--- debugging output --->
<cfif attributes.bdebug>
	<cfdump var="#form#" label="Form Variables">
	<cfdump var="#url#" label="URL Variables">
	<cfdump var="#oTypeAdmin.getPrefs()#" label="User Prefs">
	<cfdump var="#attributes.aColumns#" expand="false" label="Column Data">
	<cfdump var="#recordset#" expand="false" label="Recordset Data">
</cfif>
</cfsavecontent>

<!--- prepare content for output --->
<cfset thistag.GeneratedContent=grid>
</cfcase>
</cfswitch>

<!--- function library --->
<cfscript>
/**
 * Case-insensitive function for removing duplicate entries in a list.
 * Based on dedupe by Raymond Camden
 * 
 * @param list 	 List to be modified. 
 * @return Returns a list. 
 * @author Jeff Howden (jeff@members.evolt.org) 
 * @version 1, March 21, 2002 
 */
function ListDeleteDuplicatesNoCase(list)
{
  var i = 1;
  var delimiter = ',';
  var returnValue = '';
  if(ArrayLen(arguments) GTE 2)
    delimiter = arguments[2];
  list = ListToArray(list, delimiter);
  for(i = 1; i LTE ArrayLen(list); i = i + 1)
    if(NOT ListFindNoCase(returnValue, list[i], delimiter))
      returnValue = ListAppend(returnValue, list[i], delimiter);
  return returnValue;
}

/**
 * Deletes a var from a query string.
 * Idea for multiple args from Michael Stephenson (michael.stephenson@adtran.com)
 * 
 * @param variable 	 A variable, or a list of variables, to delete from the query string. 
 * @param qs 	 Query string to modify. Defaults to CGI.QUERY_STRING. 
 * @return Returns a string. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1.1, February 24, 2002 
 */
function queryStringDeleteVar(variable){
	//var to hold the final string
	var string = "";
	//vars for use in the loop, so we don't have to evaluate lists and arrays more than once
	var ii = 1;
	var thisVar = "";
	var thisIndex = "";
	var array = "";
	//if there is a second argument, use that as the query string, otherwise default to cgi.query_string
	var qs = cgi.query_string;
	if(arrayLen(arguments) GT 1)
		qs = arguments[2];
	//put the query string into an array for easier looping
	array = listToArray(qs,"&");		
	//now, loop over the array and rebuild the string
	for(ii = 1; ii lte arrayLen(array); ii = ii + 1){
		thisIndex = array[ii];
		thisVar = listFirst(thisIndex,"=");
		//if this is the var, edit it to the value, otherwise, just append
		if(not listFind(variable,thisVar))
			string = listAppend(string,thisIndex,"&");
	}
	//return the string
	return string;
}

/**
 * Changes a var in a query string.
 * 
 * @param name 	 The name of the name/value pair you want to modify. (Required)
 * @param value 	 The new value for the name/value pair you want to modify. (Required)
 * @param qs 	 Query string to modify. Defaults to CGI.QUERY_STRING. (Optional)
 * @return Returns a string. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 2, September 5, 2002 
 */
function QueryStringChangeVar(variable,value){
	//var to hold the final string
	var string = "";
	//vars for use in the loop, so we don't have to evaluate lists and arrays more than once
	var ii = 1;
	var thisVar = "";
	var thisIndex = "";
	var array = "";
	var changedIt = 0;
	//if there is a third argument, use that as the query string, otherwise default to cgi.query_string
	var qs = cgi.query_string;
	if(arrayLen(arguments) GT 2)
		qs = arguments[3];

	//put the query string into an array for easier looping
	array = listToArray(qs,"&");
	//now, loop over the array and rebuild the string
	for(ii = 1; ii lte arrayLen(array); ii = ii + 1){
		thisIndex = array[ii];
		thisVar = listFirst(thisIndex,"=");
		//if this is the var, edit it to the value, otherwise, just append
		if(thisVar is variable){
			string = listAppend(string,thisVar & "=" & value,"&");
			changedIt = 1;
		}
		else{
			string = listAppend(string,thisIndex,"&");
		}
	}
	//if it was not changed, add it!
	if(NOT changedIt)
		string = listAppend(string,variable & "=" & value,"&");
	//return the string
	return string;
}

</cfscript>
<cfsetting enablecfoutputonly="No">