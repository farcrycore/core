
<cfcomponent displayname="Child Links Rule" extends="rules" hint="Displays teasers for any approved HTML objects that are children of the calling page.">

<cfproperty name="displayMethod" type="string" hint="Display method to render this news rule with." required="yes" default="displayTeaser">
<cfproperty name="intro" hint="Intro text to child links" type="string" required="false" default="">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

		<cfset stObj = this.getData(arguments.objectid)> 
				
		<cfif isDefined("form.updateRuleChildLinks")>
			<cfscript>
				stObj.displayMethod = form.displayMethod;
				stObj.intro = form.intro; 
			</cfscript>
			<q4:contentobjectdata typename="#application.packagepath#.rules.ruleChildLinks" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		
		<!--- get all the templates (displayTeaser*) --->
		<nj:listTemplates typename="dmHTML" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
		<form action="" method="post">
		<table width="100%" >
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td colspan="2" align="center">
			<b>Select display method for this publishing rule: </b><br>
			<select name="displayMethod" size="1" class="field">
				<cfloop query="qDisplayTypes">
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
			
	</cffunction> 
	

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<!--- assumes existance of request.navid  --->
		<cfparam name="request.navid">

		<cfset stObj = this.getData(arguments.objectid)> 
		
		<!--- get the children of this object --->
		<cfinvoke  component="fourq.utils.tree.tree" method="getChildren" returnvariable="qGetChildren">
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
			<cfinvokeargument name="objectid" value="#request.navid#"/>
		</cfinvoke>

		<!--- If the intro text exists - append to aInvocations to be output as HTML --->
		<cfif len(stObj.intro) GT 0>
			<cfscript>
				arrayAppend(request.aInvocations,stObj.intro);
			</cfscript>
		</cfif>
		<cfif qGetChildren.recordcount GT 0>
			<cfloop query="qGetChildren">
				<q4:contentobjectget objectid="#qGetChildren.objectID#" r_stobject="stCurrentNav">
				<cfloop index="idIndex" from="1" to="#arrayLen(stCurrentNav.aObjectIds)#">
					<q4:contentobjectget objectid="#stCurrentNav.aObjectIds[idIndex]#" r_stobject="stObjTemp">
					<!--- request.lValidStatus is approved, or draft, pending, approved in SHOWDRAFT mode --->
					<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status) AND stObjTemp.typename eq "dmHTML">
							<cfscript>
							// populate the invoke structure for the container
							 	stInvoke = structNew();
								stInvoke.objectID = stObjTemp.objectID;
								stInvoke.typename = stObjTemp.typename;
								stInvoke.method = stObj.displayMethod; // nb. from rule
							// append to aInvocations
								arrayAppend(request.aInvocations,stInvoke);
							</cfscript>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- <cfdump var="#request.aInvocations#"> --->
	</cffunction> 

</cfcomponent>
