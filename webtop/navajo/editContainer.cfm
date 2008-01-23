<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/navajo/editContainer.cfm,v 1.26 2005/07/19 03:59:21 pottery Exp $
$Author: pottery $
$Date: 2005/07/19 03:59:21 $
$Name: milestone_3-0-1 $
$Revision: 1.26 $ 

|| DESCRIPTION || 
$Description: Container management editing interface. $
$TODO: Still a lot of tidying up to do here GB/PH$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
$Developer: Paul Harrison (paul@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/admin" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

<!--- required parameters --->
<cfparam name="URL.containerID">

<!--- default parameters --->
<cfparam name="URL.mode" default="update">
<cfparam name="form.dest" default="">

<cfscript>
// instantiate components
	oRules = createObject("component","#application.packagepath#.rules.rules");
	oCon = createObject("component","#application.packagepath#.rules.container");

// begin: process form actions
	// process mirror/reflection update
	message="";
	if (isDefined("form.mirrorAction")) {
		if (isDefined("form.reflectionid") AND len(form.reflectionid)) {
			oCon.setReflection(objectid=URL.containerID,mirrorid=form.reflectionid);
		} else {
			oCon.deleteReflection(objectid=URL.containerID);
		}
		// update form action information
		message="<p><strong>Container Updated.</strong></p>";
	}
	
	if (isDefined("form.skinAction"))
	{
		form.objectid=URL.containerid;
		oCon.setData(form);
		message = "<p><strong>Display method has been updated</strong></p>";
	}
// /end: process form actions

	//get the container data
	stObj = oCon.getData(objectid=URL.containerID);

	// check for mirror, and set mode
	// TODO: fix this, forcing to mirror view for prototype only
	if (len(trim(stobj.mirrorid))) {
		stMirror = oCon.getReflection(mirrorid=stobj.mirrorid, containerid=URL.containerid);
		if (structkeyexists(stMirror, "objectid"))
			URL.mode = "mirror";
	}
	
	// TODO: move this to a new container.getActiveRules() method, perhaps? GB
	qActiveRules = queryNew("objectID,typename");
	for(index=1;index LTE arrayLen(stObj.aRules);index=index+1)
	{
		queryAddRow(qActiveRules,1);
		ruletype = oCon.findType(objectid=stObj.aRules[index]);
		querySetCell(qActiveRules,"objectID",stObj.aRules[index]);
		querySetCell(qActiveRules,"typename",ruletype);
	}
	
	// if mode is update but no active rules set to configure
	if (url.mode eq "update" AND qActiveRules.recordcount eq 0)
		url.mode="configure";
	
	//gets all core and custom rules
	qRules = oRules.getRules();
</cfscript>

<cfset bDisplaySkins = false>
<cfif directoryExists("#application.path.project#\webskin\container")>
	<nj:listTemplates typename="container" prefix="" r_qMethods="qContainerSkins">
	<cfif qContainerSkins.recordCount>
		<cfset bDisplaySkins = true>
	</cfif>
</cfif>


<!--- //****************************************************************
	Start Presentation & Output
******************************************************************// --->
<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<link href="#application.url.farcry#/css/tabs.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../includes/synchtab.js"></script>
	<cfinclude template="../includes/editcontainer_js.cfm">
</head>
<body>
</cfoutput>


<!-------------------------------------------------------------- 
    Begin: Container Tab Options
--------------------------------------------------------------->
<cfoutput>
<div id="Header">
	<span class="title">Container Management</span><br />
	<span class="description">You are editing: #removechars(stobj.label, 1, 36)#</span>
	<div class="mainTabArea" align="right">
</cfoutput>

	<farcry:tabs>
	<!--- i18n: need some bundle action for mirror/reflection --->
	<cfswitch expression="#url.mode#">

	<cfcase value="update">
		<cfif NOT len(trim(stobj.mirrorid))>
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="#application.adminBundle[session.dmProfile.locale].containerContent#">	
			<cfif bDisplaySkins>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=skin&containerID=#URL.containerID#" target="" text="Skin">
			</cfif>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="#application.adminBundle[session.dmProfile.locale].configureRulesList#">
		</cfif>
		<cfif len(stobj.bshared) and stobj.bshared>
			<!--- don't show reflection options for shared container --->
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=mirror" target="" text="Reflection">
		</cfif>
	</cfcase>
	
	<cfcase value="skin">
		<cfif NOT len(trim(stobj.mirrorid))>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="#application.adminBundle[session.dmProfile.locale].containerContent#">	
			<cfif bDisplaySkins>
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?mode=skin&containerID=#URL.containerID#" target="" text="Skin">
			</cfif>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="#application.adminBundle[session.dmProfile.locale].configureRulesList#">
		</cfif>
		<cfif len(stobj.bshared) and stobj.bshared>
			<!--- don't show reflection options for shared container --->
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=mirror" target="" text="Reflection">
		</cfif>
	</cfcase>

	<cfcase value="configure">
		<cfif NOT len(trim(stobj.mirrorid))>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="#application.adminBundle[session.dmProfile.locale].containerContent#">
			<cfif bDisplaySkins>
				<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=skin&containerID=#URL.containerID#" target="" text="Skin">
			</cfif>
			<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="#application.adminBundle[session.dmProfile.locale].configureRulesList#">
		</cfif>
		<cfif len(stobj.bshared) and stobj.bshared>
			<!--- don't show reflection options for shared container --->
		<cfelse>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=mirror" target="" text="Reflection">
		</cfif>
	</cfcase>

	<cfcase value="mirror">
		<cfif NOT len(trim(stobj.mirrorid))>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update" target="" text="#application.adminBundle[session.dmProfile.locale].containerContent#">
			<cfif bDisplaySkins>
				<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=skin&containerID=#URL.containerID#" target="" text="Skin">
			</cfif>
			<farcry:tabitem class="tab" href="#CGI.SCRIPT_NAME#?mode=configure&containerID=#URL.containerID#" target="" text="#application.adminBundle[session.dmProfile.locale].configureRulesList#">
		</cfif>
		<farcry:tabitem class="activetab" href="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=mirror" target="" text="Reflection">
	</cfcase>

	</cfswitch>
	</farcry:tabs>

<cfoutput>
	</div>
</div>
</cfoutput>
<!-------------------------------------------------------------- 
    /End: Container Tab Options
--------------------------------------------------------------->

<cfswitch expression="#URL.mode#"> 

<cfcase value="mirror">
	<!--- get shared container list for form --->
	<cfset qReflections=oCon.getSharedContainers()>
	
	<cfoutput>
	<div class="tabTitle" id="EditFrameTitle" align="center">
	<!--- i18n: needs some bundle action for mirror --->
	<cfif isDefined("stMirror.objectid")>This container is mirroring the content of another container:<br /> &nbsp; &raquo; #stmirror.label#<cfelse>This container is unique for this page.</cfif>
	</div>
	</cfoutput>

	<cfoutput><div id="background"></cfoutput>

	<cfoutput>
	<!--- form action message --->
	#message#
	<p><strong>Mirrored Container Prototype:</strong> Choose a shared container to be used for this container instance.  This will override the unique container settings and use the mirrored container instead. Select NO REFLECTION to remove container mirroring.</p>	
	
	<form action="" method="post">
	<fieldset>
		<legend title="Container Reflection">Container Reflection</legend>
		<select name="reflectionid">
		<option value="">NO REFLECTION</option>
		<cfloop query="qReflections">
		<option value="#qReflections.objectid#" <cfif qreflections.objectid eq stobj.mirrorid>SELECTED</cfif>>#qReflections.label#</option></cfloop>
		</select>
	<input type="submit" name="mirrorAction" value="Update Reflection Details">
	</fieldset>
	</form>
<!--- 	
	<cfdump var="#stobj#" label="This Container">
	<cfif isdefined("stMirror")><cfdump var="#stMirror#" label="The Mirrored Container"></cfif>
 --->	
 	</div>
	</cfoutput>
</cfcase>

<cfcase value="skin">
	<cfoutput>
	<fieldset>
		<legend title="Container Reflection">Select a display method for this container</legend>
	<form action="" method="post">
	<select name="displayMethod">
	<option value="">None</option>
	</cfoutput>
	<cfoutput query="qContainerSkins">
		<option value="#qContainerSkins.methodname#" <cfif stObj.displayMethod IS qContainerSkins.methodName>selected</cfif>>#qContainerSkins.displayname#</option>
	</cfoutput>
	<cfoutput>
	</select>
	<input type="submit" name="skinAction" value="Update Display Method">
	</form>
	</fieldset>
	</cfoutput>
</cfcase>


<cfcase value="update">
	<!---
	 set a default value for 'updateType' 
	 - so we know which update method to invoke when we first get to this page 
	 ie. default to the first rule
	--->
	<cfscript>
		if(arrayLen(stObj.aRules) GT 0 AND NOT isDefined("form.ruleID"))
			updateType = stObj.aRules[1];
		else if(isDefined("form.ruleID"))
			updateType = form.ruleID;	
	</cfscript>	

	<cfoutput>
	<div class="tabTitle" id="EditFrameTitle" align="center">
		<form action="" method="post">
			#application.adminBundle[session.dmProfile.locale].containerActiveRules# 
			<select name="ruleID" onChange="form.submit();" class="field">
			<cfif arrayLen(stObj.aRules) GT 0>
				<cfloop query="qActiveRules" >
					<option value="#objectID#" <cfif updateType IS objectID>selected</cfif>><cfif structKeyExists(application.rules[typename],'displayname')>#evaluate("application.rules." & typename & ".displayname")#<cfelse>#typename#</cfif></option>	
				</cfloop>
			<cfelse>
				<option>#application.adminBundle[session.dmProfile.locale].noContainerRules#</option>
			</cfif>
			</select>
		</form>
	</div>
	</cfoutput>
	<!--- 
	*********************************************************************
		Now show the update form 
	*********************************************************************
	--->
	<cfif arrayLen(stObj.aRules) GT 0>
		<!--- get the typename for the current rule --->
		<cfquery dbtype="query" name="qGetRuleTypename">
			SELECT typename FROM qActiveRules where objectID = '#updateType#'
		</cfquery> 
		<!---
		*********************************************************************
			Call the update method for the selected rule - this displays the form
		*********************************************************************
		 --->
		<cfoutput><div id="background"></cfoutput>
		<!--- TODO: these outputs are a whitespace nightmare.. 
	   		but it appears some rules are not properly written and require this method to be 
	   		wrapped in OUTPUTs to display.  We need to update the lot at some point. GB --->
			<cfoutput><cfinvoke component="#application.rules[qGetRuleTypename.typename].rulepath#" method="update" objectID="#updateType#"></cfoutput>
		<cfoutput></div></cfoutput>
	</cfif>	
</cfcase>
<cfdefaultcase>
	
	<!--- 
	*********************************************************************
		This updates the rule list for the container
	*********************************************************************
	 --->
	<cfif isDefined("form.update")>
		<cfscript>
			function IsCFUUID(str)
			{  		
				return REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str);
			}
		
	
			//reinit aRules array for re-sequencing
			stObj.aRules = arrayNew(1); 
			for(i=1;i LTE listLen(form.dest);i=i+1)
			{
				key = listGetAt(form.dest,i);
				if (NOT IsCFUUID(key))
				{
					// Get the properties for this type - and create a rule instance --->
					obj = createObject("Component", application.rules[key].rulePath);
				 	typeProps = obj.getProperties();
			 		stProps = structNew();
			 		stProps.objectid = createUUID();
					for(j=1;j LTE arrayLen(typeProps);j=j+1)
					{
						if (structKeyExists(typeProps[j],"default"))
							"stProps.#typeProps[j].name#" = "#typeProps[j].default#";
					}
					o = createObject("component","#application.rules[key].rulePath#");
					o.createData(stProperties=stProps);
					arrayAppend(stObj.aRules,stProps.objectID);
				}
				else
					arrayAppend(stObj.aRules,key);	
			}
		//now update the container object 
		oCon.setData(stProperties=stObj);
		</cfscript>	
		<cflocation url="#CGI.SCRIPT_NAME#?containerID=#URL.containerID#&mode=update"> 
		
	</cfif>
	<!--- 
	************************************************************************************				
		Display the interface for selecting, ordering rules	
	************************************************************************************
	 --->
	<cfoutput>
	<div id="background">
	<form name="form" action="" method="post">
	<table  align="center" width="100%">
	<tr>
		<td  align="left">
			<table border="0" cellspacing="0" cellpadding="5" align="center">
			<tr>
				<td  align="center" valign="top">
					<strong>#application.adminBundle[session.dmProfile.locale].availableRuleTypes#</strong><br>
					<select name="source" size="12" style="font-size:7pt; border: 0px none;" onchange="renderHint(this.value);" >
						<cfloop query="qRules">
							<option value="#rulename#" ><cfif structKeyExists(application.rules[rulename],'displayname')>#evaluate("application.rules." & rulename & ".displayname")#<cfelse>#rulename#</cfif>
						</cfloop>
					</select>
				</td>
				<td valign="middle" align="center">
					<input type="button" name="B1" value="   >>>>    " class="normalBttnStyle"  onClick="move(this.form.source,this.form.dest)"><br><br>
				</td>
				<td valign="top" align="center">		
						<strong>#application.adminBundle[session.dmProfile.locale].activeRules#</strong><br>
						<select multiple name="dest" size="12"  style="font-size:7pt;">
						<cfloop query="qActiveRules">
							<!--- need check here for displayname key --->
							<option value="#qActiveRules.objectid#">#evaluate("application.rules." & typename & ".displayname")#
						</cfloop>
						</select>
				</td>
				<td valign="middle" align="left">
					<input class="normalBttnStyle"  type="button" value="&##8593;"
					onClick="moveindex(this.form.dest.selectedIndex,-1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="&##8595;"
					onClick="moveindex(this.form.dest.selectedIndex,+1)"><br><br>
					<input class="normalBttnStyle"  type="button" value="#application.adminBundle[session.dmProfile.locale].deleteRule#"
					 onClick="deleteRule(this.form.dest);">
				</td>	
			</tr>		
			
			<tr>
				<td colspan="4" align="center">
					<input class="normalbttnstyle" name="update" type="submit" value="#application.adminBundle[session.dmProfile.locale].commitChanges#" onclick="selectAll(this.form.dest);">
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	</form>
	<!--- Rule hint will be dynamically populated here --->
	<div align="center">
		<span id="rulehint"></span>
	</div>
	
	</div>
	</cfoutput>
</cfdefaultcase>	
</cfswitch>

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">