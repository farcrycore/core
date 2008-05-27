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
$Header: /cvs/farcry/core/packages/types/_dmImage/delete.cfm,v 1.4 2005/05/30 02:37:43 guy Exp $
$Author: guy $
$Date: 2005/05/30 02:37:43 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmImage delete method. Deletes physical files from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfif NOT StructIsEmpty(stObj)>

	<!--- delete --->
	<cfset super.delete(stObj.objectId)>

	<!--- delete Source Image --->
	<cfif len(stObj.SourceImage)>
		<cftry>
      <cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.SourceImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	
	<!--- delete Standard Image --->
	<cfif len(stObj.StandardImage)>
		<cftry>
			<cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.StandardImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	
	<!--- delete Thumbnail Image --->
	<cfif len(stObj.ThumbnailImage)>
		<cftry>
			<cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.ThumbnailImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>	
</cfif>