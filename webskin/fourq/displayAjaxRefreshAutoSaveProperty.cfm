<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Refresh Join Property --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard" prefix="wiz" />


<!--- 
<cfparam name="url.libraryType" type="string" /><!--- Can be Array or UUID. If UUID, only 1 value can be stored. --->
<cfparam name="url.PrimaryObjectID" type="UUID" />
<cfparam name="url.PrimaryTypename" type="string" />
<cfparam name="url.PrimaryFieldName" type="string" />
<cfparam name="url.PrimaryFormFieldName" type="string" />
<cfparam name="url.DataObjectID" type="string" /><!--- this could be a UUID to be added or a list of UUID's if we are re-sorting --->
<cfparam name="url.DataTypename" type="string" />
<cfparam name="url.wizardID" type="string" default="" />
<cfparam name="url.Action" type="string" default="Add" />
<cfparam name="url.ftLibrarySelectedWebskin" type="string" default="selected" />
<cfparam name="url.ftLibrarySelectedWebskinListClass" type="string" default="selected" />
<cfparam name="url.ftLibrarySelectedWebskinListStyle" type="string" default="" />
<cfparam name="url.packageType" type="string" default="types" />
 --->

<cfparam name="url.property" type="string" /><!--- The name of the property we are updating. --->
<cfparam name="url.prefix" default="" />
<cfparam name="url.format" default="display" />

<cfset request.hideAutoSaveWrapper = true />

<!--- WRAP IN CFSILENT TO AVOID EXTRANEOUS HIDDEN FIELDS DISPLAYED WHEN SIMPLY REFRESHING THE PROPERTY --->
<cfsilent>
	<cfif structKeyExists(url, "wizardID") AND len(url.wizardID)>
		<wiz:object	typename="#stobj.typename#" 
					objectID="#stobj.objectid#" 
					wizardID="#url.wizardID#" 
					lFields="#url.property#"
					format="#url.format#"
					r_stFields="stFields"
					prefix="#url.prefix#" />
	<cfelse>
		<cfset objPropValues = structNew()>
		<cfif structKeyExists(form, "propertyValue") AND len(form.propertyValue)>
			<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
			<cfif stMetadata.type EQ "array">
				<cfset objPropValues[url.property] = listToArray(form.propertyValue)>
			<cfelse>
				<cfset objPropValues[url.property] = form.propertyValue>
			</cfif>
		</cfif>
		
		<ft:object	typename="#stobj.typename#" 
					objectID="#stobj.objectid#" 
					lFields="#url.property#" 
					format="#url.format#"
					r_stFields="stFields"
					stPropValues="#objPropValues#"
					prefix="#url.prefix#" />
	</cfif>	
</cfsilent>

<cfoutput>
#stFields[url.property].HTML#
</cfoutput>
