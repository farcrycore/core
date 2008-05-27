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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/fixBranch.cfm,v 1.3 2005/10/28 04:10:04 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:10:04 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: fixBranch Function $
$TODO: $

|| DEVELOPER ||
$Developer: Jason Barnes (jason@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">

	<cfquery name="qChildren" datasource="#arguments.dsn#">
		select objectid, objectname, parentid from #arguments.dbowner#nested_tree_objects 
		where parentid =  '#arguments.parentid#' 
		order by nleft
	</cfquery>
	
	<!--- If no descendants then this is the leaf return left to the caller (it will become callers new right) --->
	<cfif qChildren.recordcount eq 0> 
		<cfset nReturn = arguments.nLeft>		
	<cfelse>
		<cfloop query="qChildren">
			<cfif nRight gt 0>
				<cfset nNewLeft = nRight + 1>
			<cfelse>
				<cfset nNewLeft = arguments.nLeft>
			</cfif>
			<cfset nRight = fixBranch(qChildren.objectid, nNewLeft + 1,arguments.nLevel + 1)>
			<cfif nRight gt nNewLeft>
				<cfquery name="qUpdateChild" datasource="#arguments.dsn#">
					UPDATE #arguments.dbowner#nested_tree_objects set nLeft = #nNewLeft#, nRight = #nRight#, nLevel = #arguments.nlevel#
					WHERE objectid = '#qChildren.objectid#'
				</cfquery>		
			</cfif>			
		</cfloop>
		<!--- set return variable --->
		<cfset nReturn = nRight+1>
	</cfif>

<cfsetting enablecfoutputonly="no">