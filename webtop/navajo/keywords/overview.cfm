<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
