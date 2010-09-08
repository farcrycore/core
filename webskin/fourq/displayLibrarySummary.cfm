<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfparam name="url.property" type="string" />

<!--- DETERMINE METADATA --->
<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />

<!--- DETERMINE THE SELECTED ITEMS --->

<cfif isArray(stobj[url.property])>
	<cfset lSelected = arrayToList(stobj[url.property]) />
<cfelse>
	<cfset lSelected = stobj[url.property] />
</cfif>			

<cfif listLen(lSelected)>
	<cfoutput><div id="OKMsg">#listLen(lSelected)# items selected.</div></cfoutput>
<cfelse>
	<cfoutput><div id="errorMsg">No items have been selected.</div></cfoutput>
</cfif>



<cfsetting enablecfoutputonly="false">