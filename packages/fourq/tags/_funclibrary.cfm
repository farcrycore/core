<!------------------------------------------------------------------------
Custom Tag Function Library (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/_funclibrary.cfm,v 1.4 2002/10/15 08:48:09 geoff Exp $
$Author: geoff $
$Date: 2002/10/15 08:48:09 $
$Name:  $
$Revision: 1.4 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Just some functions to short cut scripting. Probably should remove at 
some point so the general public don't get confused.
------------------------------------------------------------------------->
<!--- building cfparam for cfscript --->
<cffunction name="reqParam">
	<cfargument name="name" required="true">
	<cfparam name="attributes.#arguments[1]#">
</cffunction>
<cffunction name="optParam">
	<cfargument name="name" required="true">
	<cfargument name="default" required="true">
	<cfparam name="attributes.#arguments[1]#" default="#arguments[2]#">
</cffunction>
<cffunction name="dump">
	<cfargument name="var" required="true">
	<cfargument name="label" required="false" default="#arguments[1]#">
	<cfargument name="expand" required="false" default="yes">
	<cfdump var="#arguments[1]#" label="#arguments[2]#" expand="#arguments[3]#">
</cffunction>

