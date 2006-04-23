<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleHandpicked.cfc,v 1.23 2004/12/17 07:35:26 paul Exp $
$Author: paul $
$Date: 2004/12/17 07:35:26 $
$Name: milestone_2-3-2 $
$Revision: 1.23 $

|| DESCRIPTION || 
$Description: Hand-pick and display individual object instances with a specified displayTeaser* handler. Restricted to those components with metadata bScheduled=true. $

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent displayname="Handpicked Rule" extends="rules" hint="Hand-pick and display individual object instances with a specified displayTeaser* handler. Restricted to those components with metadata bScheduled=true." bCustomRule="0">
<cfproperty name="intro" hint="A provision for intro text to any handpicked rule" type="longchar">
<cfproperty name="objectWDDX" type="longchar"  hint="Array of WDDX Packets containing an stParams stucture.stParams has objectID and method specified as well as any other keys for use with the selected method " required="no" default="">

	<cffunction name="cfml2wddx" hint="A wrapper to cfwddx - converts cfml to wddx">
		<cfargument name="stInput">
		<cftry>
			<cfwddx action="cfml2wddx" input="#arguments.stInput#" output="stWDDXOut">
		<cfcatch>
			<cfset stWDDXOut = arrayNew(1)>
		</cfcatch>
		</cftry>		
		<cfreturn stWDDXOut>
	</cffunction>
	
	<cffunction name="wddx2cfml" hint="A wrapper to cfwddx - converts wddx to cfml">
		<cfargument name="stInput">
			<cftry>
				<cfwddx action="wddx2cfml" input="#arguments.stInput#" output="stWDDXOut">
			<cfcatch>
				<cfset stWDDXOut = arrayNew(1)>
			</cfcatch>
			</cftry>
		<cfreturn stWDDXOut>
	</cffunction>

	<cffunction name="cleanUUID">
		<cfargument name="objectID" type="uuid">
		<cfset rObjectID = trim(replace(arguments.objectID,"-","","ALL"))> 
		<cfreturn rObjectID>
	</cffunction>
	
	<cffunction name="dump">
		<cfargument name="var">
		<cfargument name="label" default="dump">
			<cfdump var="#arguments.var#" label="#arguments.label#">
	</cffunction>
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfargument name="cancelLocation" required="no" type="string" default="#application.url.farcry#/navajo/editContainer.cfm?containerid=#url.containerid#">
		<cfset var stObj = this.getData(arguments.objectid)>
		
        <cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
		<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
		<!--- Default Vals --->
		<cfparam name="URL.handpickaction" default="list">
		<cfparam name="URL.killplp" default="0">
		<cfparam name="URL.containerid" default="">
				
		<cfscript>
			stObjectWDDX = wddx2cfml(stObj.objectWDDX);
		</cfscript>			
		<cfwddx action="cfml2js" input="#stObjectWDDX#" output="stObj.objectJS" toplevelvariable="aWDDX">
		<cfset caller.form.ruleid = stObj.objectid>			
			<farcry:plp 
				owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
				stepDir="/farcry/farcry_core/packages/rules/_ruleHandpicked"
				cancelLocation="#arguments.cancelLocation#"
				iTimeout="15"
				stInput="#stObj#"
				bDebug="0"
				bForceNewInstance="#url.killplp#"
				r_stOutput="stOutput"
				storage="file"
				storagedir="#application.path.plpstorage#"
				redirection="server"
				r_bPLPIsComplete="bComplete">

				<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].selectObjects#" template="selectObjects.cfm">
				<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].displayMethodsArrange#" template="selectDisplayMethods.cfm">
				<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].completeUC#" template="complete.cfm">
			</farcry:plp>
		
		<cfif isDefined("bComplete") AND bComplete>
		<!--- Just doing a check here to see if user has in fact selected display methods - its possible that if they skip this step that displayMethods will get set to an empty string and break the execution of the rule --->
		<cfwddx action="wddx2cfml" input="#stoutput.objectwddx#" output="aWDDX">
		<cfif isArray(aWDDX)>
			<cfloop from="1" to="#arrayLen(aWDDX)#" index="index">
				<cfif not len(aWDDX[index].method)>
					<cfset aWDDX[index].method = 'displayTeaser'>
				</cfif>
			</cfloop>
			<cfwddx action="cfml2wddx" input="#aWDDX#" output="stOutput.objectwddx">
		</cfif>
		
		<cfscript>	
				stProperties = Duplicate(stOutput);
				this.setData(stProperties=stProperties);
		</cfscript>
			<div class="FormTitle" align="center">#application.adminBundle[session.dmProfile.locale].actionComplete#
				<form action="" method="post">
					<input type="submit" class="normalbttnstyle" value="#application.adminBundle[session.dmProfile.locale].continue#">
				</form>
			</div>
		</cfif>	

		
	</cffunction> 
	
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		<cftry>
		<cfwddx action="wddx2cfml" input="#stObj.objectWDDX#"  output="stObjectWDDX">
		<cfif isArray(stObjectWDDX)>
			<cfif arrayLen(stObjectWDDX) GT 0>
				<cfif len(trim(stObj.intro))>
					<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
				</cfif>
				<cfloop from="1" to="#arrayLen(stObjectWDDX)#" index="i">
				<cfscript>
					stInvoke = structNew();
					stInvoke.objectID = stObjectWDDX[i].objectID;
					stInvoke.typename = application.types['#stObjectWDDX[i].typename#'].typepath;
					stInvoke.method = stObjectWDDX[i].method;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
				</cfloop> 
			</cfif>
		</cfif>
		<cfcatch>
			<!-- Empty wddx packet-->
		</cfcatch>
		</cftry>
	</cffunction> 

</cfcomponent>