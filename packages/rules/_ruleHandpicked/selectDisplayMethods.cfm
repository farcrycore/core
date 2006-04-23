<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectDisplayMethods.cfm,v 1.15.2.2 2005/12/28 05:55:36 paul Exp $
$Author: paul $
$Date: 2005/12/28 05:55:36 $
$Name: milestone_3-0-1 $
$Revision: 1.15.2.2 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose teaser handler (teaser.cfm) $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
--->
<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cffunction name="generateSelectHTML">
	<cfargument name="objectid" required="yes">
	<cfargument name="typename" required="yes">
	<cfargument name="method" required="yes">
	
	<cfset var qDisplayTypes = "">
	<cfset var html = "">
	<nj:listTemplates typename="#arguments.typename#" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
	<cfsavecontent variable="html"><cfoutput><select id="displayMethod_#arguments.objectid#" name="displayMethod_#arguments.objectid#" size="1" class="field" onChange="setDisplayMethod('#arguments.objectid#',document['forms']['editform']['displayMethod_#arguments.objectid#'].options[selectedIndex].value);"><cfloop query="qDisplayTypes"><option value="#methodName#"<cfif arguments.method IS qDisplayTypes.methodname> selected="selected"</cfif>>#qDisplayTypes.displayName#</option></cfloop></select></cfoutput></cfsavecontent>
	<cfreturn trim(html)>
</cffunction>

<cfif isDefined("form.wddx") AND isWDDX(form.wddx)>
	<cfwddx input="#form.wddx#" action="wddx2js" toplevelvariable="aWDDX" output="output.objectJs">
	<cfset output.objectWDDX = form.wddx>
</cfif>

<cfwddx input="#output.objectWDDX#" action="wddx2cfml" output="aWDDX">
<cfloop index="i" from="1" to="#arrayLen(aWDDX)#">
	<cfset aWDDX[i].selectHTML = generateSelectHTML(objectid=aWDDX[i].objectid,typename=aWDDX[i].typename,method=aWDDX[i].method)>
</cfloop>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>
		
<!--- defaults for this step --->
<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lObjectids" default="">

<cfif NOT thisstep.isComplete>
<cfwddx action="cfml2js" input="#aWDDX#" output="output.objectJS" toplevelvariable="aWDDX">

<cfsetting enablecfoutputonly="false">
<widgets:plpWrapperContainer><cfoutput>

<script type="text/javascript">
#output.objectJS#
function overviewHeader()
{
	var html = "<table><tr>";
	html += "<th>#application.adminBundle[session.dmProfile.locale].Label#<\/th>";
	html += "<th>#application.adminBundle[session.dmProfile.locale].ObjTypeLabel#<\/th>";
	html += "<th>#application.adminBundle[session.dmProfile.locale].displayMethodLabel#<\/th>";
	html += "<th>#application.adminBundle[session.dmProfile.locale].delete#<\/th>";
	html += "<th>#application.adminBundle[session.dmProfile.locale].move#<\/th>";
	html += "<\/tr>";
	return html;	
}

function deleteObject(id)
{
	if(confirm("#application.adminBundle[session.dmProfile.locale].confirmRemoveObj#"))
	{	
		for (var i = 0;i < aWDDX.length;i++)
		{
			if (aWDDX[i].objectid == id)
			{
				aWDDX.splice(i,1);
				//rebuild display
				buildOverview();
				return true;
			}
		}
	}	
	return false;
}

function renderNode(arrayName,index,radio)
{
	var html = '<tr>';
	html += "<td>"+arrayName[index].label+"<\/td>";
	html += "<td>"+arrayName[index].typename+"<\/td>";
	html += "<td id='select_"+index+"'><strong>"+arrayName[index].selecthtml+"<\/strong><\/td>";
	html += "<td align=\"center\"><img src=\"#application.url.farcry#/images/no.gif\" onclick=\"deleteObject('"+arrayName[index].objectid+"')\;\"><\/td>";
	html += "<td align=\"center\"><input value=\""+index+"\" type=\"radio\" name=\"" + radio + "\"><\/td>";
	html += "<\/tr>"
	return html;
}

function buildOverview()
{
	
	var objectsEM = document.getElementById('objectsOverview');
	var overviewHTML = overviewHeader();
	if (!aWDDX.length)
		overviewHTML = "<table><tr><td colspan=\"5\" align=\"center\"><strong>#application.adminBundle[session.dmProfile.locale].noObjSelected#<\/strong><\/td><\/tr><\/table>";
	else
	{	
		for(var i = 0;i < aWDDX.length;i++)
			overviewHTML += renderNode(aWDDX,i,'seq');
	}
	overviewHTML += "<\/table>";
	objectsEM.innerHTML = overviewHTML;	
}

//gets the selected index of a radio button array
function getSelectedIndex(radio)
{
	for(var i = 0;i < radio.length;i++)
	{
		if(radio[i].checked)
			return i;
	}

}

function reArrange(vArray,from,to,seq)
{
	//return if illegal to destination
	if (to >= vArray.length) return;
	if (to < 0) return;
	//save the dest object
	var stTemp = new Object();
	stTemp.objectid = vArray[to].objectid;
	stTemp.label = vArray[to].label;
	stTemp.typename = vArray[to].typename;
	stTemp.method = vArray[to].method;
	stTemp.selecthtml = vArray[to].selecthtml;
	
	vArray[to].objectid = vArray[from].objectid;
	vArray[to].typename = vArray[from].typename;
	vArray[to].label = vArray[from].label;
	vArray[to].method = vArray[from].method;
	vArray[to].selecthtml = vArray[from].selecthtml;
	
	vArray[from].objectid = stTemp.objectid;
	vArray[from].label = stTemp.label;
	vArray[from].typename = stTemp.typename;
	vArray[from].method = stTemp.method;
	vArray[from].selecthtml = stTemp.selecthtml;

	//refresh display
	buildOverview();
	selectRadioIndex('seq',seq);
	resetMethodSelections();
	return true;
	
}

function getSeqIndex(radioName)
{
	var emRadio = document.getElementsByName(radioName);
	for (var i = 0; i < emRadio.length; i++)
	{
		if (emRadio[i].checked)
			return i;
	}
}

function selectRadioIndex(radioName,index)
{
	var emRadio = document.getElementsByName(radioName);
	for (var i = 0; i < emRadio.length; i++)
	{
		if ([i]==index)
			emRadio[i].checked = true;
	}
	
}

 
function serializeData(data, formField) {

      wddxSerializer = new WddxSerializer();
      wddxPacket = wddxSerializer.serialize(data);
      if (wddxPacket != null) {
         formField.value = wddxPacket;
      }
      else {
         alert("Couldn't serialize data");
      }
   }


/*Resets display method as they are selected*/
  
function setDisplayMethod(objectid,method)
{
	for(var i = 0;i < aWDDX.length;i++)
	{
		if(aWDDX[i].objectid == objectid)
		{
			aWDDX[i].method = method;
			break;
		}
	}
}  



function resetMethodSelections()
{
	for(var i = 0;i < aWDDX.length;i++)
	{
		if(document.getElementById('displayMethod_' + aWDDX[i].objectid))
		{
			var em  = document.getElementById('displayMethod_' + aWDDX[i].objectid);
			for(var j = 0;j < em.options.length;j++)
			{	var bFound = 0;
				if(em.options[j].value == aWDDX[i].method)
				{	
					em.options[j].selected = true;
					bFound = 1;
					break;
				}	
			}
			if (bFound == 0)  //Set default value.
			{	
				em.options[0].selected = true;
				aWDDX[i].method = em.options[0].value;
			}	
				
		}		
	}
}

function doSubmit(objForm){
	serializeData(aWDDX,document.forms.editform.wddx);
	return true;
}
<cfinclude template="/farcry/farcry_core/admin/includes/wddx.js">	
</script>

<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" style="margin-top:-1.5em" onsubmit="return doSubmit(document.editform);">
	<fieldset>
		<h3>#application.adminBundle[session.dmProfile.locale].selectObjDisplayMethod#</h3>
	</fieldset>
	<input type="hidden" name="wddx" value="" />
	<table border="0" width="100%" style="border: 0! important;">
	<tr>
		<td><div id="objectsOverview"></div></td>	
		<td valign="middle" align="center">
			<input type="button" class="normalbttnstyle" value="&uarr;" onclick="reArrange(aWDDX,getSelectedIndex(document.forms['editform'].seq),getSelectedIndex(document.forms['editform'].seq) -1,getSeqIndex('seq')-1);" /><br />
			<input type="button" class="normalbttnstyle" value="&darr;" onclick="reArrange(aWDDX,getSelectedIndex(document.forms['editform'].seq),getSelectedIndex(document.forms['editform'].seq) +1,getSeqIndex('seq')+1);" /><br />
		</td>
	</tr>
	</table>
	&nbsp; <!--- added this nbsp to stop totally bizarre behaviour in IE ---> 
	<input type="hidden" name="ruleid" value="#output.objectid#" />
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>	
<script type="text/javascript">
buildOverview();
resetMethodSelections();
</script></cfoutput>	
</widgets:plpWrapperContainer>
<cfelse>
	<widgets:plpUpdateOutput onClick="serializeData(aWDDX,document.forms.editform.wddx);">
</cfif>