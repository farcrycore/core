<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
<cfset stOnExit = structNew() />
<cfset stOnExit.Type = "HTML" />
<cfsavecontent variable="stOnExit.Content">
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
<admin:Header Title="Library" bodyclass="popup imagebrowse library" bCacheControl="false">


	<cfset HTML = oData.getView(objectid="#stData.objectid#", template="#url.ftLibraryEditWebskin#", alternateHTML="", onExit="#stOnExit#") />	
		
	<cfif len(HTML)>
		<cfoutput>#HTML#</cfoutput>
	<cfelse>
		<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
	    <!--- <cfset evaluate("oType.#method#(objectid='#objectid#',OnExit=#stOnExit#)")> --->
	    <cfinvoke component="#oData#" method="edit">
	        <cfinvokeargument name="objectId" value="#stData.objectid#" />
	        <cfinvokeargument name="onExit" value="#stOnExit#" />
	    </cfinvoke>
	</cfif>

	


<admin:footer>



	
	


	



<cfsetting enablecfoutputonly="no">