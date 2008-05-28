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
$Header: /cvs/farcry/core/webtop/navajo/keywords/overview.cfm,v 1.10 2005/09/13 06:34:27 guy Exp $
$Author: guy $
$Date: 2005/09/13 06:34:27 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Displays edit form for category tree $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfparam name="url.objectid" default="#application.catid.root#" />

<cfset html = createObject("component", application.stcoapi["dmCategory"].packagePath).getView(objectid="#url.objectid#", template="edit", alternateHTML="") /> 


<cfif len(html)>
    <cfoutput>#html#</cfoutput>
<cfelse>
	<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
    <!--- <cfset evaluate("oType.#method#(objectid='#objectid#',OnExit=#stOnExit#)")> --->
    <cfinvoke component="#application.stcoapi['dmCategory'].packagePath#" method="edit">
        <cfinvokeargument name="objectId" value="#objectId#" />
    </cfinvoke>
</cfif>
