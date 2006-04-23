<html><head>
<cfoutput>
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
<link href="#application.url.farcry#/css/tabs.css" rel="stylesheet" type="text/css">
</cfoutput>
<script type="text/javascript" src="includes/synchtab.js"></script>
</head>
<body>
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/" prefix="farcry">

<cfparam name="URL.mode" default="update">
<cfparam name="form.dest" default="">


<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
sortitems = 1;  

function moveindex(index,to) {
var list = document.form.dest;
var total = list.options.length-1;
if (index == -1) return false;
if (to == +1 && index == total) return false;
if (to == -1 && index == 0) return false;
var items = new Array;
var values = new Array;
for (i = total; i >= 0; i--) {
	items[i] = list.options[i].text;
	values[i] = list.options[i].value;
}
for (i = total; i >= 0; i--) {
if (index == i) {
	list.options[i + to] = new Option(items[i],values[i], 0, 1);
	list.options[i] = new Option(items[i + to], values[i + to]);
	i--;
}
else {
	list.options[i] = new Option(items[i], values[i]);
   }
}
list.focus();
}

function move(fbox,tbox)
{	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			fbox.options[i].value = "";
			fbox.options[i].text = "";
	   }
	}
	BumpUp(fbox);
}

function takeoff(fbox,tbox)
{	//alert(tempcount);
	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			fbox.options[i].value = "";
			fbox.options[i].text = "";
	   }
	}
	BumpUp(fbox);
}


function BumpUp(box)
{
	for(var i=0; i<box.options.length; i++)
	{
		if(box.options[i].value == "")
		{
			for(var j=i; j<box.options.length-1; j++) {
				box.options[j].value = box.options[j+1].value;
				box.options[j].text = box.options[j+1].text;
			}
		var ln = i;
		break;
   		}
	}
	if(ln < box.options.length)  {
		box.options.length -= 1;
		BumpUp(box);
   }
}

function confirmDelete(){
	var msg = "Are you sure you wish to delete this package ?";
	if (confirm(msg))
		return true;
	else
		return false;
}				


function selectAll(dest){
	for (var i = 0; i < dest.options.length; i++) { 
		dest.options[i].selected = true;
	}
 }
 
// End -->
</script>


<!--- This is for convenience - we set up a list and a query object of the active rules for this object - bit clunky i know --->
<q4:contentObjectGet typename="#application.packagepath#.rules.container" objectID="#URL.containerID#" r_stObject="stObj">  
<cfset qActiveRules = queryNew("objectID,typename")>
<cfset thisRow = 1>
<cfloop from="1" to="#arrayLen(stObj.aRules)#" index="i">
	<cfset newRow = queryAddRow(qActiveRules,1)>
	<cfinvoke component="fourq.fourq" returnvariable="rule" method="findType" objectID="#stObj.aRules[i]#">
	<cfset temp = querySetCell(qActiveRules,"objectID",stObj.aRules[i],thisRow)>
	<cfset temp = querySetCell(qActiveRules,"typename",rule,thisRow)>
	<cfset thisRow = thisRow + 1>
</cfloop>
<cfset activeRulesList = valueList(qActiveRules.typename)>

<cfoutput>

<div id="Header">
<span class="title">FarCry</span><br/>
<span class="description">Tell it to someone who cares</span>
<div class="mainTabArea" align="right">
	<farcry:tabs>
		<cfif URL.mode IS "update">
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="Container Content">
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="Container Content"></cfif>
		<cfif URL.mode IS "configure">
		<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="Configure Rules List">
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="Configure Rules List">
</cfif>
	</farcry:tabs>
</div>
	
</div>
</cfoutput>

<cfif URL.mode IS "update">

<cfoutput>

<!--- set a default value for 'updateType' - so we know which update method to invoke when we first get to this page --->
<cfif arrayLen(stObj.aRules) GT 0 AND NOT isDefined("form.ruleID")>
	<cfset updateType = stObj.aRules[1]>
<cfelseif isDefined("form.ruleID")>
	<cfset updateType = form.ruleID>	
</cfif>	


	<div class="tabTitle" id="EditFrameTitle" align="center">
		<form action="" method="post">
		Active Rules For This Container 

		<select name="ruleID" onChange="form.submit();" class="field">
		<cfif arrayLen(stObj.aRules) GT 0>
			<cfloop query="qActiveRules" >
				<option value="#objectID#" <cfif updateType IS objectID>selected</cfif>>#typename#</option>	
			</cfloop>
		<cfelse>
			<option>No rules Selected for this container</option>
		</cfif>
		</select>
		</form>
		</div>

</cfoutput>

<!--- Now show the update form --->
<cfif arrayLen(stObj.aRules) GT 0>
	<cfquery dbtype="query" name="qGetRuleTypename">
		SELECT typename FROM qActiveRules where objectID = '#updateType#'
	</cfquery> 
	<div id="background">
	<cfinvoke component="#application.packagepath#.rules.#qGetRuleTypename.typename#" method="update" objectID="#updateType#">
	</div>
	
</cfif>	

<cfelse>

<cfif isDefined("form.update")>
	<!--- Go thru and remove any rule types that have been removed - both from the DB and the aRules array --->
	<cfloop query="qActiveRules">
		<cfif NOT listContainsNoCase(form.dest,qActiveRules.typename) AND len(typename) GT 0>
			
			<q4:contentobjectdelete typename="#application.packagepath#.rules.#qActiveRules.typename#" objectID="#qActiveRules.objectID#">
			<cfloop from="#arrayLen(stObj.aRules)#" to="1" index="i" step="-1">
				<cfif stObj.aRules[i] IS objectID>
					<cfset temp = arrayDeleteAt(stObj.aRules,i)>
				</cfif>
			</cfloop>
		</cfif>	
	</cfloop>
	
		<!--- Now we are checking to see if any new ones have been added to the list - if so we create a new instance of that rule type --->
	<cfloop list="#form.dest#" index="thisType">
		<cfif NOT listContainsNoCase(activeRulesList,thisType)>
			<!--- Get the properties for this type - and create a rule instance --->
			<cfscript>
			 obj = createObject("Component", "#application.packagepath#.rules.#thisType#");
			 typeProps = obj.getProperties();
			 stProps = structNew();
			 stProps.objectid = createUUID();
			</cfscript>
			<cfloop from="1" to="#arrayLen(typeProps)#" index="objID">
				<Cfif structKeyExists(typeProps[objID],"default")>
						<cfset "stProps.#typeProps[objID].name#" = "#typeProps[objID].default#">
				</Cfif>
			</cfloop>
			<cfdump var="#stProps#" label="#thisType#">
			<q4:contentObjectCreate typename="#application.packagepath#.rules.#thisType#" stProperties="#stProps#">  
			<cfset temp = arrayAppend(stObj.aRules,stProps.objectID)>
		</cfif>
	</cfloop>
	<!--- now update the container object --->
	
	<q4:contentobjectdata typename="#application.packagePath#.rules.container" stProperties="#stObj#" objectID="#stObj.objectID#"> 
	<cflocation url="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update"> 
	
</cfif>


<cfinvoke component="#application.packagepath#.rules.rules" method="getRules" returnvariable="qRules"/>



<cfoutput>
<div id="background">
<form name="form" action="" method="post">
<table  align="center" width="100%">
<tr>
		<td  align="left">
			<table border="0" cellspacing="0" cellpadding="5" align="center">
			<tr>
				<td  align="center" valign="top">
					<strong>Available Rule Types</strong><br>
					<select name="source" size="8" style="font-size:7pt; border: 0px none;width:35mm;">
						<cfloop query="qRules">
							<cfif NOT listContainsNoCase(activeRulesList,qRules.rulename)>
								<option value="#rulename#">#rulename#
							</cfif>
						</cfloop>
					</select>
				</td>
				<td valign="middle" align="center">
					<input type="button" name="B1" value="   >>>>   " class="normalBttnStyle"  onClick="move(this.form.source,this.form.dest)"><br><br>
					<input class="normalBttnStyle"  type="button" value="   <<<<   " onclick="takeoff(this.form.dest,this.form.source)" name="B2"><br><br>
				</td>
				<td valign="top" align="center">		
						<strong>Active Rules</strong><br>
						<select multiple name="dest" size="8"  style="font-size:7pt;width:35mm;">
						<cfloop query="qActiveRules">
							<option value="#typename#">#typename#
						</cfloop>
						</select>
				</td>
				<td valign="middle" align="left">
					<input class="normalBttnStyle"  type="button" value="&##8593;"
					onClick="moveindex(this.form.dest.selectedIndex,-1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="&##8595;"
					onClick="moveindex(this.form.dest.selectedIndex,+1)">
				</td>	
			</tr>		
			<tr>
				<td colspan="4" align="center">
					<input class="normalbttnstyle" name="update" type="submit" value="OK" onclick="selectAll(this.form.dest);">
				</td>
			</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</div>
</cfoutput>

</cfif>
</body>
</html>