<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
Custom Tag Function Library (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/_funclibrary.cfm,v 1.4 2002/10/15 08:48:09 geoff Exp $
$Author: geoff $
$Date: 2002/10/15 08:48:09 $
$Name:  $
$Revision: 1.4 $

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

