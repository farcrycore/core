<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/versions.cfc,v 1.4.2.2 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name: milestone_3-0-1 $
$Revision: 1.4.2.2 $

|| DESCRIPTION || 
$Description: Component Versions Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
--->
<cfcomponent extends="farcry.farcry_core.packages.types.types" bAbstract="true" displayname="Versions Abstract Class" hint="Provides default properties and handlers for content object types using farcry versioning.  This component should never be instantiated directly -- it should only be inherited.">
<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="" />

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	

	<!--- // STATUS: versions status changing methods --->
	<cffunction name="statustodraft" access="public" returntype="struct" hint="Sends object to draft state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- delete underlying draft if it exists
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustodraft()>
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustopending" access="public" returntype="struct" hint="Sends object to pending state." output="false">
	<!--- 	
	// TODO: 
		probably nothing to do here but super
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustopending()>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustoapproved" access="public" returntype="struct" hint="Sends object to approved state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- archive current live
			- set appropriate friendly url as required
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustoapproved()>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to approved.">
 		<cfreturn stResult>
	</cffunction>


</cfcomponent>

