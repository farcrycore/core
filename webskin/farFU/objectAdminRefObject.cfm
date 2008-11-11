<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Display Summary Info of Ref Object --->
<!--- @@description: Attempts to use library Selected otherwise the label of the related object  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#stobj.refObjectID#") />

<cfif not structIsEmpty(stRefObject)>
	<skin:view typename="#stRefObject.typename#" objectid="#stRefObject.objectid#" template="librarySelected" alternateHTML="#stRefObject.label#" />
</cfif>
<cfsetting enablecfoutputonly="false">