<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">



<!-------------------------------------------------
DEPRECATED:  this code should no longer be used.
-------------------------------------------------->
<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="./tags/navajo/displayPrinterFriendly.cfm should be replaced with a regular view." />




<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<!--- method for dealing with the missing url param... redirect to home page --->
<cfif not isDefined("url.objectId")>
	<cfif isDefined("application.navid.home")>
		<cfset url.objectid = application.navid.home>
		<cftrace var="application.navid.home" text="home UUID set">
	<cfelse>
		<cflocation url="#application.url.farcry#/" addtoken="No">
	</cfif>
</cfif>

<!--- grab the object we are displaying --->
<cftry>	  
	<q4:contentobjectget objectid="#url.ObjectID#" r_stobject="stObj">
	<cfcatch type="Any">
		<cfthrow detail="Print Friendly: cannot find content item." />
		<cfabort>
	</cfcatch>
</cftry>

<!--- if we are displaying a navigation point, get the first approved object to display --->
<cfif 
	stObj.typename eq "dmNavigation"
	AND structKeyExists(stObj,"aObjectIds")
	AND arrayLen(stObj.aObjectIds)>
	
	<cfloop index="idIndex" from="1" to="#arrayLen(stObj.aObjectIds)#">
		<q4:contentobjectget objectid="#stObj.aObjectIds[idIndex]#" r_stobject="stObjTemp">
		
		<!--- request.lValidStatus is approved, or draft, pending, approved in SHOWDRAFT mode --->
		<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status)>
			<!--- set the navigation point for the child obj --->
			<cfset request.navid = stObj.objectID>
			<!--- reset stObj to appropriate object to be displayed --->
			<cfset stObj = stObjTemp>
			
			<!--- end loop now --->
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- if request.navid is not set, then no valid objects available for 
	this node. --->
	<cfif NOT isDefined("request.navid")>
		<cfabort showerror="#application.adminBundle[session.dmProfile.locale].errorNavNodeNoContent#">
	</cfif>

<!--- else get the navigation point from the URL --->
<cfelseif isDefined("url.navid")>
	<!--- ie. this is a dynamic object looking for context --->
	<cfset request.navid = url.navid>

<!--- otherwise get the navigation point for this object --->
<cfelse>
	<nj:GetNavigation objectId="#stObj.objectId#" r_stobject="stNav">
	<!--- if the object is in the tree this will give us the node --->
	<cfif isDefined("stNav.objectid") AND len(stNav.objectid)>
		<cfset request.navid = stNav.objectID>
	
	<!--- otherwise, use the home node as a last resort --->
	<cfelse>
		<cfset request.navid = application.navid.home>
	</cfif>
</cfif>

<!--- 
check security,... 
remember security is applied through the tree navigation point *not*
the individual object being rendered.
lpolicyGroupIds="#application.dmsec.ldefaultpolicygroups#"
the latter is the policy group for anonymous...
--->

<cfif isDefined("request.navid")>
	<cfscript>
		iHasViewPermission = application.security.checkPermission(permission="view",object=request.navid);
	</cfscript>
	
	<cfif iHasViewPermission neq 1>
	<!--- log out the user --->
		<cfscript>
			application.factory.oAuthentication.logout();
		</cfscript>
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
		<cfabort>
	</cfif>

<cfelse>
	<cfdump var="#stObj#" label="Object Structure for stObj">
	<cfdump var="#request#" label="Request Scope">
	<cfabort showerror="Error: no navigational context could be established for this object.">
	<!--- <cfset request.navid = application.navid["home"]> --->
</cfif>

<!--- <cfdump var="#stObj#" label="Object Structure for stObj"> --->

<cfif IsStruct(stObj) and not StructIsEmpty(stObj)>
	
	<!---------------------------
	Build floatMenu, as required 
	TODO:
	This should respond to request.mode settings and not require a
	a whole new set of permission checks
	---------------------------->
	<!--- begin: logged in user? --->
	<cfscript>
		stLoggedInUser = application.factory.oAuthentication.getUserAuthenticationData();
		bLoggedIn = stLoggedInUser.bLoggedIn;
	</cfscript>
	
	<cfif bLoggedIn>
	<!--- check they are admin --->
	<cfscript>
		iAdmin = application.security.checkPermission(permission="Admin");
		iCanCommentOnContent = application.security.checkPermission(permission="CanCommentOnContent",object=request.navid);
	</cfscript>
	
	<cfif iAdmin eq 1 or iCanCommentOnContent eq 1>
		<cfset request.floaterIsOnPage = true>
		<cfinclude template="floatMenu.cfm">
	</cfif>
	</cfif>
	<!--- end: logged in user? --->
		
	<!--- Setup page caching (cached on objectID of page) --->
	<cfparam name="stObj.PageType" default="">
	<cfif isDefined("url.displayMethod")>
		<cfset stObj.displayMethod=url.displayMethod>
	</cfif>
	
	<!--- output printerfriendly display --->
	<nj:importCSS>
	<cfoutput>
	<div class="title">#stObj.Title#</div>
	<p></p>
	<div class="contentbody" style="width:600px">
		#stObj.Body#
		<p></p>
		<b>http://#cgi.http_host##application.url.conjurer#?objectid=#url.objectid#</b>
	</div>
	</cfoutput>
	
		
<cfelse>
	<cfabort showerror="#application.adminBundle[session.dmProfile.locale].badCOAPI#">
</cfif> 
<!--- end: of if object exists... --->

<cfsetting enablecfoutputonly="No">

