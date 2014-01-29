<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Refresh Join Property --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard" prefix="wiz" />

<cfparam name="url.property" type="string" /><!--- The name of the property we are updating. --->
<cfparam name="url.prefix" default="" />

<cfset request.hideLibraryWrapper = true />

<!--- WRAP IN CFSILENT TO AVOID EXTRANEOUS HIDDEN FIELDS DISPLAYED WHEN SIMPLY REFRESHING THE PROPERTY --->
<cfsilent>
	<cfif structKeyExists(url, "wizardID") AND len(url.wizardID)>
		<wiz:object	typename="#stobj.typename#" 
					objectID="#stobj.objectid#" 
					wizardID="#url.wizardID#" 
					lFields="#url.property#"
					r_stFields="stFields"
					prefix="#url.prefix#" />
	<cfelse>
		<cfset objPropValues = structNew()>
		<cfset stMetadata = application.fapi.getPropertyMetadata(typename=stobj.typename, property=url.property) />
		<cfif structKeyExists(form, "propertyValue") AND len(form.propertyValue)>
			<cfif stMetadata.type EQ "array">
				<cfset objPropValues[url.property] = listToArray(form.propertyValue)>
			<cfelse>
				<cfset objPropValues[url.property] = form.propertyValue>
			</cfif>
		<cfelse>
			<cfif stMetadata.type EQ "array">
				<cfset objPropValues[url.property] = arrayNew(1)>
			<cfelse>
				<cfset objPropValues[url.property] = "">
			</cfif>
		</cfif>
		
		<ft:object	typename="#stobj.typename#" 
					objectID="#stobj.objectid#" 
					lFields="#url.property#" 
					r_stFields="stFields"
					stPropValues="#objPropValues#"
					prefix="#url.prefix#" />
	</cfif>	
</cfsilent>

<cfoutput>
#stFields[url.property].HTML#
</cfoutput>
