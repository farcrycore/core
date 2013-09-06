<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->

<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset request.fc.inwebtop = true />

<!------------------ 
START WEBSKIN
 ------------------>
<cfparam name="url.property" type="string" />
<cfparam name="lSelected" type="string" default=""/>
<!--- DETERMINE METADATA --->
<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />

<!--- DETERMINE THE SELECTED ITEMS --->
<cfif isArray(stobj[url.property])>
	<cfloop array="#stobj[url.property]#"  index="i">
		<cfif isStruct(i) and StructKeyExists(i,"data")>
			<cfset lSelected = listappend(lSelected,i.data)>
		<cfelse>
			<cfset lSelected = listappend(lSelected,i)>
		</cfif>
	</cfloop>
<cfelse>
	<cfset lSelected = stobj[url.property] />
</cfif>			

<cfif listLen(lSelected)>
	<cfoutput><div id="OKMsg">#listLen(lSelected)# items selected.</div></cfoutput>
<cfelse>
	<cfoutput><div id="errorMsg">No items have been selected.</div></cfoutput>
</cfif>



<cfsetting enablecfoutputonly="false">