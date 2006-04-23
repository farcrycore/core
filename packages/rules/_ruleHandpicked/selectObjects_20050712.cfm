
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectObjects_20050712.cfm,v 1.1 2005/07/25 03:33:36 guy Exp $
$Author: guy $
$Date: 2005/07/25 03:33:36 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose teaser handler (teaser.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Guy Phanvongsa (paul@daemon.com.au) $
--->

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfoutput>
<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lobjectids" default="">
<cfparam name="output.labelsearch" default="">
<cfparam name="output.labelsearchcondition" default="">
<cfparam name="output.dmType" default="dmNews">

<cfdump var="#output#">

<cffunction name="getMinTypeDate">
	<cfargument name="typename">
	<cfquery name="q" datasource="#application.dsn#">
		SELECT min(datetimecreated) as mindate
		FROM #application.dbowner##arguments.typename#
	</cfquery>
	<!--- check if there is a min date --->
	<cfif not len(q.mindate)>
		<cfset mindate = now()>
	<cfelse>
		<cfset mindate = q.mindate>
	</cfif>
	<cfreturn mindate>
</cffunction>	

<cffunction name="getMaxTypeDate">
	<cfargument name="typename">
	<cfquery name="q" datasource="#application.dsn#">
		SELECT max(datetimecreated) as maxdate
		FROM #application.dbowner##arguments.typename#
	</cfquery>
	<!--- check if there is a max date --->
	<cfif not len(q.maxdate)>
		<cfset maxdate = now()>
	<cfelse>
		<cfset maxdate = q.maxdate>
	</cfif>
	<cfreturn maxdate>
</cffunction>	


<cfset minDate = getMinTypeDate(output.dmType)>
<cfset maxDate = getMaxTypeDate(output.dmType)>
<cfset output.startYear = year(minDate)>
<cfset output.endYear = year(maxDate)>

<cfif isDefined("form.formSubmitted")>
	<!--- update plp data and move to next step --->
	<cfloop index="FormItem" list="#FORM.FieldNames#">
		<cfset "output.#FormItem#" = Evaluate("FORM.#FormItem#")>
	</cfloop>
	<cfset output.startDate = createDateTime(output.minYear,output.minMonth,output.minDay,0,0,0)>
	<cfset output.endDate = createDateTime(output.maxYear,output.maxMonth,output.MaxDay,0,0,0)>
<cfelse>
	<cfset output.startDate = createDateTime(year(minDate),month(minDate),day(minDate),0,0,0)>
	<cfset output.endDate = createDateTime(year(maxDate),month(maxDate),day(maxDate),0,0,0)>
	<cfset output.startDate = dateAdd('d',-1,output.startDate)>
	<cfset output.endDate = dateAdd('d',1,output.endDate)>
</cfif>


<cfoutput>

<cfif isDefined("form.wddx")>
	<cfwddx input="#form.wddx#" action="wddx2js" toplevelvariable="aWDDX" output="output.objectJs">
	<cfset output.objectWDDX = form.wddx>
</cfif>
<cfdump var="#output#">
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


function updateSelection()
{
	for (var i = 0;i < aWDDX.length;i++)
	{
		if(document.getElementById(aWDDX[i].objectid))
		{
			document.getElementById(aWDDX[i].objectid).checked=true;
			selectRow('row'+aWDDX[i].objectid);
		}	
	}
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
  
var rowcolor="red";

function selectRow(id){
em = document.getElementById(id);
if (em.style.color != rowcolor)
	em.style.color="red";
else
	em.style.color="black";
}	
<cfinclude template="/farcry/farcry_core/admin/includes/wddx.js">
</script>
</cfoutput>
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>


<cfif NOT isDefined("FORM.search")>
	<tags:plpNavigationMove>
<cfelse>
	<cfloop index="FormItem" list="#FORM.FieldNames#">
		<cfset "output.#FormItem#" = Evaluate("FORM.#FormItem#")>
	</cfloop>	
</cfif>


<cfif NOT thisstep.isComplete>


<cfparam name="FORM.thisPage" default="1">

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

<!--- <cfdump var="#sql#"> --->

<cfquery name="recordset" datasource="#application.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>
<cfdump var="#recordset#">

<!--- This script block sorts out next/previous page stuff --->
<cfscript>
	numRecords = 20; //this is the number of records to display per page
	thisPage = FORM.thisPage;
	if (recordSet.recordCount GT 0)
	{
		startRow = ((thisPage*numRecords) + 1) - numRecords; //the query row which we start from
		endRow = (numRecords + startRow)-1;
		numPages = recordSet.recordcount/numRecords;
		numPages = ceiling(numPages); // the number of 'pages' of results
		if (thisPage GT 1){
			prevPage = thisPage - 1; 
		}	//the next page to advance to  
		if (thisPage LT numPages){
			nextPage = thisPage + 1;
		}	 // the previous page to go back to	
	}else
	{	numpages = 1;
		thispage = 1;
		endrow=1;
		startrow=1;
	}
	oForm = createObject("component","#application.packagepath#.farcry.form");
</cfscript>


<cfoutput>

	<style type="text/css">
		border {border:thin solid Black; }
	</style>

	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].selectObjects#</div>
	<div class="FormTable" align="center" style="width:90%">

	<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" onSubmit="serializeData(aWDDX,document['forms'].editform.wddx);">
	<input type="hidden" name="wddx" value="">
	<input type="hidden" name="formSubmitted" value="">
 	<table width="100%">
	
	<tr>
		<td>
			<table style="width:100%" border="1" >
				<tr>
					<td>
						<strong>#application.adminBundle[session.dmProfile.locale].selectObjTypeLabel#</strong>
					</td>
					<td>
						<select name="dmType" onChange="serializeData(aWDDX,document['forms'].editform.wddx);document['forms']['editform'].submit();">
						<cfloop collection="#application.types#" item="type">
							<cfif structKeyExists(application.types[type],"BSCHEDULE")>
								<option value="#type#" <cfif output.dmType IS type>selected</cfif>><cfif structKeyExists(application.types[type],'displayName')>#application.types[type]['displayName']#<cfelse>#type#</cfif></option>
							</cfif> 
						</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td width="20%">
						<strong>#application.adminBundle[session.dmProfile.locale].titleKeywords#</strong>
					</td>
					<td>
						<input type="Text" value="#output.labelsearch#" name="labelsearch">
						<select name="labelsearchcondition">
							<option value="or" <cfif output.labelsearchcondition IS "or">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchAnyWords#
							<option value="and" <cfif output.labelsearchcondition IS "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchAllWords#
							<option value="exact" <cfif output.labelsearchcondition IS "exact">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchExactPhrase#
						</select>
					</td>
				</tr>
				<tr>
					<td valign="top">
						<strong>#application.adminBundle[session.dmProfile.locale].dateRange#</strong>
					</td>
				
					<td valign="top">
							#oForm.renderDateSelect(startYear=output.startyear,endyear=output.endyear,selectedDate=output.startDate,elementNamePrefix='min',bDisplayMonthAsString=1)#
							<strong >#application.adminBundle[session.dmProfile.locale].toLabel#</strong>
							#oForm.renderDateSelect(startYear=output.startyear,endyear=output.endyear,selectedDate=output.endDate,elementNamePrefix='max',bDisplayMonthAsString=1)#
					</td>

				</tr>
				<tr>
					<td>
						<strong>#application.adminBundle[session.dmProfile.locale].orderBy#</strong>
					</td>
					<td>
						<select name="orderby">
							<option value="label" <cfif output.orderby IS "label">selected</cfif>>Label</option>
							<option value="datetimelastupdated" <cfif output.orderby IS "datetimelastupdated">selected</cfif>>#application.adminBundle[session.dmProfile.locale].dateObjLastUpdated#</option>
						</select>
						<select name="orderdir">
							<option value="ASC" <cfif output.orderdir IS "ASC">selected</cfif>>#application.adminBundle[session.dmProfile.locale].ascending#</option>
							<option value="DESC" <cfif output.orderdir IS "DESC">selected</cfif>>#application.adminBundle[session.dmProfile.locale].descending#</option>
						</select>
						
					</td>
				</tr>
				<tr><td colspan="2" align="center"><input type="button" onClick="serializeData(aWDDX,document['forms'].editform.wddx);document['forms']['editform'].submit();" name="search" value="#application.adminBundle[session.dmProfile.locale].filter#"></td></tr>
			</table>
		</td>
	</tr>										
	
	</table>
	
	<table class="border" width="100%" style="border:thin solid Black;" >
	<tr>
		<td colspan="3">
			<table width="100%" cellspacing="0" class="border">
			<tr >
				<td>#recordSet.recordcount# items</td>
				<td align="right" valign="middle">
					<cfif thisPage GT 1>
						<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].prev#" name="prev"  onclick="serializeData(aWDDX,document['forms'].editform.wddx);document['forms'].editform.thisPage.selectedIndex--;document['forms'].editform.submit();" >
					</cfif>
					Page 
					<select name="thisPage" onChange="serializeData(aWDDX,document['forms'].editform.wddx);document['forms'].editform.submit();">
						<cfloop from="1" to="#numPages#" index="i">
							<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
						</cfloop>
					</select> of #numPages#
					<cfif thisPage LT numpages>
						<input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].next#" onclick="serializeData(aWDDX,document['forms'].editform.wddx);document['forms'].editform.thisPage.selectedIndex++;document['forms'].editform.submit();">
					</cfif>
				</td>
			</tr>		
			</table>
		</td>
	</tr>
		<tr>
			<td>
				#application.adminBundle[session.dmProfile.locale].select#
			</td>
			<td>
				#application.adminBundle[session.dmProfile.locale].label#
			</td>
			<td>
				#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#
			</td>
		</tr>
		<cfloop query="recordSet" startrow="#startRow#" endrow="#endRow#">
		<tr id="row#recordSet.objectID#">
			<td>
				
				<cfset JSsafeLabel = replace(trim(recordset.label),"""","","ALL")>
				<cfset JSsafeLabel = jsStringFormat(jsSafeLabel)>
				<input id="#recordset.objectid#" onClick="selectRow('row#recordset.objectid#');updateArray(this.id,'#jsSafeLabel#');" type="checkbox" name="lObjectIDs" value="#objectID#">
			</td>
			<td>
				#label#
			</td>
			<td>
				#application.thisCalendar.i18nDateFormat(datetimelastupdated,session.dmProfile.locale,application.mediumF)# 
				<!--- i18n #dateformat(,"dd-mmm-yyyy")# --->
			</td>
		</tr>
		</cfloop>
	</table>
	</div>
	<div class="FormTableClear">
		<tags:plpNavigationButtons onClick="serializeData(aWDDX,document['forms'].editform.wddx);">
	</div>
	</form>
	

<script>
	updateSelection();
</script>
</cfoutput>
	
<cfelse>
	<tags:plpUpdateOutput>
</cfif>
<cfsetting enablecfoutputonly="yes">
