<cfsetting enablecfoutputonly="yes">
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
<!---
|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  $
$TODO: $

|| DEVELOPER ||
$Developer: $

@@displayname: Array and UUID popup object editor
@@author: Mat Bryant (mat@daemon.com.au)
 --->


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" >


<!--- PREPARE OBJECTS --->
<cfset oPrimary = createObject("component", application.stcoapi[url.primaryTypename].packagepath)>
<cfset stPrimary = oPrimary.getdata(objectid="#url.primaryID#") />
<cfset dataTypename = application.coapi.coapiUtilities.findType(objectid="#listFirst(url.dataID, ':')#") />
<cfset oData = createObject("component", application.stcoapi[dataTypename].packagepath)>
<cfset stData = oData.getdata(objectid="#listFirst(url.dataID, ':')#") />


<!--- SETUP THE ONEXIT DETAILS OF THE EDIT HANDLER --->
<cfset onExitProcess = structNew() />
<cfset onExitProcess.Type = "HTML" />
<cfsavecontent variable="onExitProcess.Content">
	<!--- REFRESH THE CALLING UUID OR ARRAY FIELD --->
	<cfoutput>
	<script type="text/javascript">
		<cfif URL.LibraryType EQ "array">					
			opener.libraryCallbackArray('#url.primaryFormFieldname#', 'sort','#arrayToList(stPrimary[url.primaryFieldName])#','#application.url.webroot#',window);			
		<cfelse>
			<cfif len(stPrimary[url.primaryFieldName]) >
				opener.libraryCallbackUUID('#url.primaryFormFieldname#', 'add','#stPrimary[url.primaryFieldName]#','#application.url.webroot#',window);
			</cfif>
		</cfif>
	 </script>
	</cfoutput>
	
</cfsavecontent>

<!--- RENDER LIBRARY EDIT FORM --->
<admin:Header Title="Library">
	

	<cfset HTML = oData.getView(objectid="#stData.objectid#", template="#url.ftLibraryEditWebskin#", alternateHTML="", onExitProcess="#onExitProcess#") />	
		
	<cfif len(HTML)>
		<cfoutput>#HTML#</cfoutput>
	<cfelse>
		<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
	    <!--- <cfset evaluate("oType.#method#(objectid='#objectid#',onExitProcess=#onExitProcess#)")> --->
	    <cfinvoke component="#oData#" method="edit">
	        <cfinvokeargument name="objectId" value="#stData.objectid#" />
	        <cfinvokeargument name="onExitProcess" value="#onExitProcess#" />
	    </cfinvoke>
	</cfif>

	


<admin:footer>



	
	


	



<cfsetting enablecfoutputonly="no">