
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectObjects.cfm,v 1.30.2.3 2006/01/29 08:09:28 geoff Exp $
$Author: geoff $
$Date: 2006/01/29 08:09:28 $
$Name: milestone_3-0-1 $
$Revision: 1.30.2.3 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose teaser handler (teaser.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lobjectids" default="">
<cfparam name="output.labelsearch" default="">
<cfparam name="output.labelsearchcondition" default="">
<cfparam name="output.dmType" default="dmNews"> 
<cfparam name="form.dmType" default="#output.dmType#"> 
<cfparam name="formSubmitted" default="no">

<!--- get the min/max date for items --->
<cfquery name="q" datasource="#application.dsn#">
SELECT	min(datetimecreated) as mindate, max(datetimecreated) as maxdate
FROM 	#application.dbowner##form.dmType#
</cfquery>

<!--- check if valid date --->
<cfif NOT Len(q.mindate)>
	<cfset mindate = now()>
<cfelse>
	<cfset mindate = q.mindate>
</cfif>

<cfif NOT Len(q.maxdate)>
	<cfset maxdate = now()>
<cfelse>
	<cfset maxdate = q.maxdate>
</cfif>

<cfif formSubmitted EQ "yes">
	<!--- update plp data and move to next step --->
	<cfloop index="formItem" list="#form.fieldNames#">
		<cfset output[formItem] = form[formItem]>
	</cfloop>
	<cfset output.startDate = createDateTime(form.minYear,form.minMonth,form.minDay,0,0,0)>
	<cfset output.endDate = createDateTime(form.maxYear,form.maxMonth,form.MaxDay,0,0,0)>
<cfelse>
	<cfset output.startDate = createDateTime(year(minDate),month(minDate),day(minDate),0,0,0)>
	<cfset output.endDate = createDateTime(year(maxDate),month(maxDate),day(maxDate),0,0,0)>
	<cfset output.startDate = dateAdd('d',-30,output.startDate)>
	<cfset output.endDate = dateAdd('d',30,output.endDate)>
</cfif>

<!--- get all the types that has a schedule --->
<cfset aTypes = ArrayNew(1)>
<cfset i = 0>
<cfloop item="type" collection="#application.types#">
	<cfif StructKeyExists(application.types[type],"bSchedule") AND application.types[type].bSchedule>
		<cfset i = i + 1>
		<cfset aTypes[i] = StructNew()>
		<cfset aTypes[i].name = type>
		<cfif StructKeyExists(application.types[type],"displayName")>
			<cfset aTypes[i].displayName = application.types[type].displayName>
		<cfelse>
			<cfset aTypes[i].displayName = type>
		</cfif>
	</cfif>
</cfloop>

<cfif isDefined("form.wddx")>
	<cfif isWDDX(form.wddx)>
	<cfwddx input="#form.wddx#" action="wddx2js" toplevelvariable="aWDDX" output="output.objectJs">
	<cfset output.objectWDDX = form.wddx>
	</cfif>	
</cfif>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<cfif NOT thisstep.isComplete>
<!--- Build SQL  --->
<cfscript>
sql = "SELECT ObjectID, label, datetimelastupdated FROM #output.dmType#";
sql = sql & " WHERE 1 = 1 ";
if(structKeyExists(application.types[output.dmType].stProps,"status"))
	sql = sql & " AND status = 'approved'";
sql = sql & " AND datetimecreated >= #createodbcdate(output.startDate)#";
sql = sql & " AND datetimecreated <= #createodbcdate(output.endDate)#";

if (len(trim(output.labelsearch)))
{
	replace(output.labelsearch,"'","''","ALL"); //delimit single quotes.
	aKeyWords = listToArray(output.labelsearch,' ');
	sqlclause = '';
	switch (output.labelsearchcondition)
	{
		case "or" : case "and" :
		{
			for (i = 1;i LTE arrayLen(aKeyWords);i=i+1)
			{
				sqlclause = sqlclause & "label like '%#aKeyWords[i]#%'";
				if(i LT arrayLen(aKeyWords))
					sqlclause = sqlclause & " #output.labelsearchcondition# ";
			}
			if (len(sqlClause))
				sql = sql & " AND (#sqlclause#)";
			break;	
		}		
		case "exact" :
		{
			sql = sql & " AND label like '%#output.labelsearch#%'";
			break;
		}
	}	
}
sql = sql & " ORDER BY #output.orderby# #output.orderdir#";
</cfscript>

<cfquery name="qList" datasource="#application.dsn#">
#preserveSingleQuotes(sql)#
</cfquery>

<!--- This script block sorts out next/previous page stuff --->
<!--- this is the number of records to display per page --->
<cfset numRecords = 10>
<cfparam name="thisPage" default="1">
<cfif qList.recordCount GT 0>
	<!--- the query row which we start from --->
	<cfset startRow = ((thisPage*numRecords) + 1) - numRecords>
	<cfset endRow = (numRecords + startRow)-1>
	<cfset numPages = Ceiling(qList.recordcount/numRecords)>

	<!--- next/previous pages --->
	<cfif thisPage GT 1>
		<cfset prevPage = thisPage - 1>
	</cfif>

	<cfif thisPage LT numPages>
		<cfset nextPage = thisPage + 1>
	</cfif>
<cfelse>
	<cfset numpages = 1>
	<cfset thispage = 1>
	<cfset endrow = 1>
	<cfset startrow = 1>
</cfif>

<cfset oForm = createObject("component","#application.packagepath#.farcry.form")>

<widgets:plpWrapperContainer>
<cfsetting enablecfoutputonly="false"><cfoutput>
<script type="text/javascript">
#output.objectJS#

function updateArray(id,label)
{
	if (document.getElementById(id).checked)
		addData(id,label);
	else
		removeData(id);
	return true;
}

function addData(id,label)
	{
	var st = new Object();
	st.typename = '#output.dmType#';
	st.objectid = id;
	st.method = '';
	st.label = label;
	aWDDX.push(st);
	return true;
}

function removeData(id)
{
	for (var i = 0;i < aWDDX.length;i++)
	{
		if (aWDDX[i].objectid == id)
		{
			aWDDX.splice(i,1);
			return true;
		}
	}
	return false;
}

function serializeData(data, formField)
{
	wddxSerializer = new WddxSerializer();
	wddxPacket = wddxSerializer.serialize(data);
	if (wddxPacket != null) {
	   formField.value = wddxPacket;
	}
	else {
	   alert("#application.adminBundle[session.dmProfile.locale].notSerializeData#");
	}
}

var pageNav = 0;
function doSubmit(objForm){
	objForm.thisPage.selectedIndex = objForm.thisPage.selectedIndex + pageNav;
	pageNav = 0;
	serializeData(aWDDX,document.forms.editform.wddx);
	if(!objForm.plpAction.value)
		objForm.plpAction.value = 'none';
	objForm.submit();
}
<cfinclude template="/farcry/farcry_core/admin/includes/wddx.js">
</script>
<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" style="margin-top:-1.5em" onsubmit="doSubmit(document.editform);">
	<fieldset><h3>#application.adminBundle[session.dmProfile.locale].selectObjects#</h3>
		<label for="dmType"><b>#application.adminBundle[session.dmProfile.locale].selectObjTypeLabel#</b>
			<select id="dmType" name="dmType" onchange="doSubmit(document.editform);"><cfloop index="j" from="1" to="#ArrayLen(aTypes)#">
				<option value="#aTypes[j].name#"<cfif output.dmType EQ aTypes[j].name> selected="selected"</cfif>>#aTypes[j].displayName#</option></cfloop>		
			</select><br />
		</label>

		<label for="labelsearch"><b>#application.adminBundle[session.dmProfile.locale].titleKeywords#</b>
			<input type="text" value="#output.labelsearch#" name="labelsearch">
			<select name="labelsearchcondition">
				<option value="or" <cfif output.labelsearchcondition IS "or">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchAnyWords#
				<option value="and" <cfif output.labelsearchcondition IS "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchAllWords#
				<option value="exact" <cfif output.labelsearchcondition IS "exact">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchExactPhrase#
			</select><br />
		</label>

		<label for="labelStartDate"><b>#application.adminBundle[session.dmProfile.locale].dateRange#:</b>
			#oForm.renderDateSelect(startYear=year(output.startDate),endyear=year(output.endDate),selectedDate=output.startDate,elementNamePrefix='min',bDisplayMonthAsString=1)#<br />
			<b>#application.adminBundle[session.dmProfile.locale].toLabel#</b>
			#oForm.renderDateSelect(startYear=year(output.startDate),endyear=year(output.endDate),selectedDate=output.endDate,elementNamePrefix='max',bDisplayMonthAsString=1)#<br />
		</label>

		<label><b>#application.adminBundle[session.dmProfile.locale].orderBy#</b>
			<select id="orderby" name="orderby">
				<option value="label"<cfif output.orderby IS "label"> selected="selected"</cfif>>Label</option>
				<option value="datetimelastupdated"<cfif output.orderby IS "datetimelastupdated"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].dateObjLastUpdated#</option>
			</select>
			<select id="orderdir" name="orderdir">
				<option value="ASC" <cfif output.orderdir IS "ASC">selected</cfif>>#application.adminBundle[session.dmProfile.locale].ascending#</option>
				<option value="DESC" <cfif output.orderdir IS "DESC">selected</cfif>>#application.adminBundle[session.dmProfile.locale].descending#</option>
			</select><br />
		</label>
	
	<div class="f-submit-wrap">
	<input type="Submit" name="filter" value="#application.adminBundle[session.dmProfile.locale].filter#" class="f-submit" />
	</div>

	<div id="nextprev" style="width: 97%; float: left; text-align: right;">
		<cfif thisPage GT 1>
			<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].prev#" name="prev"  onclick="pageNav=-1;document.editform.submit();;" style="vertical-align: bottom;">
		</cfif>
		Page 
		<select name="thisPage" onchange="doSubmit(document.editform);">
			<cfloop from="1" to="#numPages#" index="i">
				<option value="#i#"<cfif i eq thisPage> selected="selected"</cfif>>#i#</option>
			</cfloop>
		</select> of #numPages#<cfif thisPage LT numpages> <input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].next#" onclick="pageNav=+1;document.editform.submit();" style="vertical-align: bottom;"></cfif>
	</div>	
	<table cellspacing="0" class="table-2">
	<tr>
		<th>#application.adminBundle[session.dmProfile.locale].select#</th>
		<th>#application.adminBundle[session.dmProfile.locale].label#</th>
		<th>#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#</th>
	</tr><cfloop query="qList" startrow="#startRow#" endrow="#endRow#">
	<cfset JSsafeLabel = replace(trim(qList.label),"""","","ALL")>
	<cfset JSsafeLabel = jsStringFormat(jsSafeLabel)>
	<tr>
		<td><input type="checkbox" id="#qList.objectid#" onClick="updateArray('#qList.objectid#','#jsSafeLabel#');" name="lObjectIDs" value="#qList.objectID#"></td>
		<td>#qList.label#</td>
		<td>#application.thisCalendar.i18nDateFormat(qList.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</td>
	</tr></cfloop>
	</table>
	
	<input type="hidden" name="ruleid" value="#output.objectid#">
	<input type="hidden" name="wddx" value="">
	<input type="hidden" name="formSubmitted" value="yes">
	</fieldset>
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>
<script type="text/javascript">
// loop over aWDDX to check any ones they have selected
for(i=0; i<aWDDX.length;i++){
	objCheck = document.getElementById(aWDDX[i]["objectid"]);
	if(objCheck)
		objCheck.checked = "checked";
}
</script></cfoutput>
</widgets:plpWrapperContainer>
<cfelse>
	<widgets:plpUpdateOutput>
</cfif>
<cfsetting enablecfoutputonly="yes">
