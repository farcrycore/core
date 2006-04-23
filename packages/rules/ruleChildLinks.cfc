<!------------------------------------------------------------------------
ruleChildLinks (FarCry Core)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/farcry_core/packages/rules/ruleChildLinks.cfc,v 1.20 2004/05/22 06:19:51 paul Exp $
$Author: paul $
$Date: 2004/05/22 06:19:51 $
$Name: milestone_2-2-1 $
$Revision: 1.20 $

Contributors:
Paul Harrison (paul@daemon.com.au)
Geoff Bowers (modius@daemon.com.au)

Description:
List teasers for the current nodes children.  Children types restricted to
dmHTML and dmInclude.

Known Issues:
Teaser template listing is only from dmHTML.  But dmInclude is also a possible 
child object, so if a method is chosen that is not in dmInclude then it 
fails to display anything.
------------------------------------------------------------------------->
<cfcomponent displayname="Child Links Rule" extends="rules" hint="Displays teasers for any approved HTML objects that are children of the calling page.">

<cfproperty name="displayMethod" type="string" hint="Display method to render this news rule with." required="yes" default="displayTeaser">
<cfproperty name="intro" hint="Intro text to child links" type="string" required="false" default="">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

		<cfset stObj = this.getData(arguments.objectid)> 
				
		<cfif isDefined("form.updateRuleChildLinks")>
			<cfscript>
				stObj.displayMethod = form.displayMethod;
				stObj.intro = form.intro; 
			</cfscript>
			<q4:contentobjectdata typename="#application.rules.ruleChildLinks.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		
		<!--- get all the templates (displayTeaser*) --->
		<nj:listTemplates typename="dmHTML" prefix="displayTeaser" r_qMethods="qDisplayTypes">
		<nj:listTemplates typename="dmInclude" prefix="displayTeaser" r_qMethods="qIncludeDisplayTypes"> 
		<nj:listTemplates typename="dmLink" prefix="displayTeaser" r_qMethods="qLinkDisplayTypes"> 
	
		<!--- Join the two result sets --->
		<cfquery dbtype="query" name="qGetAllTemplates">
			SELECT * FROM qDisplayTypes UNION ALL
			SELECT * FROM qLinkDisplayTypes UNION ALL
			SELECT * FROM qIncludeDisplayTypes
		</cfquery> 
	
		<!--- Now we filter so we only get those that occur in both directories --->
		<cfquery dbtype="query" name="qGetUniqueTemplates">
			SELECT COUNT(methodName) AS methodCount,methodname,displayname FROM qGetAllTemplates
			GROUP BY methodname,displayname
			HAVING methodCount = 3
		</cfquery> 
	
		<cfif qGetUniqueTemplates.recordCount>
		<form action="" method="post">
		<table width="100%" >
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td colspan="2" align="center">
			<b>Select display method for this publishing rule: </b><br>
			<select name="displayMethod" size="1" class="field">
				<cfloop query="qGetUniqueTemplates">
					<option value="#methodName#" <cfif methodName is stObj.displayMethod>selected</cfif> >#displayName#</option>
				</cfloop>
			</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center" class="field"> 
				<b>Intro Text</b><br>
				<textarea rows="5" cols="50" name="intro">#stObj.intro#</textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center"><input class="normalbttnstyle" type="submit" value="go" name="updateRuleChildLinks"></td>
		</tr>
		</table>
		
		</form>
		<cfelse>
			<div align="center">There must be at least 1 common display method in /webskin/dmInclude, /webskin/dmLink and /webskin/dmHTML to use this rule.</div>
		
		</cfif>
			
	</cffunction> 
	

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<!--- assumes existance of request.navid  --->
		<cfparam name="request.navid">

		<cfset stObj = this.getData(arguments.objectid)> 
		
		<!--- get the children of this object --->
		<cfscript>
			qGetChildren = request.factory.oTree.getChildren(objectid=request.navid);
		</cfscript>

		<!--- if the intro text exists - append to aInvocations to be output as HTML --->
		<cfif len(stObj.intro) GT 0>
			<cfscript>
				arrayAppend(request.aInvocations,stObj.intro);
			</cfscript>
		</cfif>
		
		<cfif qGetChildren.recordcount GT 0>
			
			<!--- loop over children --->
			<cfloop query="qGetChildren">
				<!--- get child nav details --->
				<q4:contentobjectget objectid="#qGetChildren.objectID#" r_stobject="stCurrentNav">
				
				<!--- check for sim link --->
				<cfif len(stCurrentNav.externalLink)>
					<!--- get sim link details --->
					<cftry>
						<q4:contentobjectget objectid="#stCurrentNav.externalLink#" r_stobject="stCurrentNav">
						<cfcatch></cfcatch>
					</cftry>
				</cfif>
				
				<!--- loop over child/sim link nav node --->	
				<cfloop index="idIndex" from="1" to="#arrayLen(stCurrentNav.aObjectIds)#">
									
					<q4:contentobjectget objectid="#stCurrentNav.aObjectIds[idIndex]#" r_stobject="stObjTemp">
					
					<!--- request.lValidStatus is approved, or draft, pending, approved in SHOWDRAFT mode --->
					<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status) AND listContains("dmHTML,dmInclude,dmLink", stObjTemp.typename)>
					
						<!--- if in draft mode grab underlying draft page --->			
						<cfif IsDefined("stObjTemp.versionID") AND request.mode.showdraft>
							<cfquery datasource="#application.dsn#" name="qHasDraft">
								SELECT objectID,status from #application.dbowner##stObjTemp.typename# where versionID = '#stObjTemp.objectID#' 
							</cfquery>
							
							<cfif qHasDraft.recordcount gt 0>
								<cfset objId = qHasDraft.objectId>
							<cfelse>
								<cfset objId = stObjTemp.objectID>
							</cfif>
						<cfelse>
							<cfset objId = stObjTemp.objectID>
						</cfif>
						
						<cfscript>
							// populate the invoke structure for the container
						 	stInvoke = structNew();
							stInvoke.objectID = objID;
							stInvoke.typename = application.types[stObjTemp.typename].typePath;
							stInvoke.method = stObj.displayMethod; // nb. from rule
							// append to aInvocations
							arrayAppend(request.aInvocations,stInvoke);
						</cfscript>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		
	</cffunction> 

</cfcomponent>
