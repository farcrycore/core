<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/fixBranch.cfm,v 1.3 2005/10/28 04:10:04 paul Exp $
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