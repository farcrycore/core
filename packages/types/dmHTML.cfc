<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<!--- @@Description: Web Page Content Type --->
<cfcomponent extends="versions" displayname="Web Page" 
	hint="A simple web page. Web pages can include a variety of publishing rules." 
	bUseInTree="1" bFriendly="1" fuAlias="html"
	bObjectBroker="1"
	icon="fa-file-o">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty 
	name="Title" type="string" hint="Title of content item." required="no" default="" ftType="string" ftLabel="Title"
	ftSeq="1" ftwizardStep="Web Page" ftFieldset="General Details" ftValidation="required" 
	ftHint="This title will appear as the major title on the page. It should not be confused with the title that appears in the navigation.">

<cfproperty 
	name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="displayPageStandard" 
	ftSeq="5" ftwizardStep="Web Page" ftFieldset="General Details" ftLabel="Page Layout" 
	ftHint="This selection will determine the overall layout of the page."
	ftType="webskin" ftPrefix="displayPage" >

<cfproperty 
	name="Teaser" type="longchar" ftLabel="Teaser" ftType="longchar" hint="Teaser text." required="no" default=""
	ftSeq="10" ftwizardStep="Web Page" ftFieldset="Teaser"
	ftAutoResize="true">
	
<cfproperty 
	name="teaserImage" type="uuid" ftType="uuid" hint="UUID of image to display in teaser" required="no" default=""
	ftSeq="11" ftwizardStep="Web Page" ftFieldset="Teaser" ftLabel="Teaser Image"
	ftJoin="dmImage" ftAllowEdit="true">

<cfproperty 
	name="Body" type="longchar" hint="Main body of content." required="no" default="" 
	ftSeq="20" ftwizardStep="Web Page" ftFieldset="Body" ftLabel="Body" ftLabelAlignment="block"
	ftType="richtext" 
	ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
	ftTemplateTypeList="dmImage,dmFile,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
	ftLinkListFilterTypenames="dmFile,dmNavigation,dmHTML"
	ftTemplateSnippetWebskinPrefix="insertSnippet">

<cfproperty 
	name="aObjectIDs" type="array" hint="Related media items for this content item." required="no" default=""
	ftSeq="21" ftwizardStep="Web Page" ftFieldset="Body" ftLabel="Attached Images/Files" 
	ftType="array" ftJoin="dmImage,dmFile" 
	ftShowLibraryLink="false" ftAllowAttach="true" ftAllowAdd="true" ftAllowEdit="true" ftRemoveType="detach"
	ftallowbulkupload="true"
	bSyncStatus="true">

<cfproperty 
	name="aRelatedIDs" type="array" ftType="array" hint="Holds object pointers to related objects. Can be of mixed types." required="no" default="" 
	ftSeq="25" ftwizardStep="Web Page" ftFieldset="Relationships" ftLabel="Related Content"
	ftJoin="dmNavigation,dmHTML" ftAllowCreate="false">

<!--- 
 // seo
--------------------------------------------------------------------------------------------------->
<cfproperty 
	name="seoTitle" type="string" hint="SEO title of content item." required="no" default="" 
	ftSeq="32" ftWizardStep="SEO" ftFieldset="SEO" ftLabel="SEO Title"
	ftLimit="69" ftLimitOverage="warn" ftAutoResize="true"
	ftHint="Optional: The title in the search result defaults to the page title"
	ftType="longchar"
	ftRenderWebskinBefore="editSEOPreview"
	ftHelpTitle="Search Engine Optimization" 
	ftHelpSection="Search Engines will automatically detect the page title and show a description snippet in the context of a user's search terms. You can use the fields below to suggest a title or description that might better match what a user is searching for." />
	
<cfproperty 
	name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default=""
	ftSeq="35" ftwizardStep="SEO" ftFieldset="SEO" ftlabel="SEO Description"
	ftHint="Optional: The description in the search result defaults to the teaser or body content"
	ftType="longchar" ftLimit="170" ftLimitOverage="warn"
	ftAutoResize="true" />

<cfproperty 
	name="metaKeywords" type="longchar" hint="HTML head section metakeywords." required="no" default="" 
	ftSeq="38" ftwizardStep="SEO" ftFieldset="SEO" ftLabel="SEO Keywords"
	ftHint="Optional: 10-20 keywords per page at most, limited to 900 characters"
	ftType="longchar" ftLimit="900"
	ftAutoResize="true" ftLimitOverage="warn" />


<cfproperty 
	name="ownedby" displayname="Owned by" type="string" hint="Username for owner." required="No" default=""
	ftSeq="50" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Owned By"
	ftHint="This should be set to the person responsible for this page. Any questions... ask this person."
	ftType="list" ftRenderType="dropdown" ftListData="getOwners" >
	
<cfproperty 
	name="reviewDate" type="date" hint="The date for which the object will be reviewed." required="no" default=""
	ftSeq="52" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Review Date" 
	ftHint="Optionally enter a date to remind you when this content should be reviewed."
	ftType="datetime" ftToggleOffDateTime="true" ftShowTime="false">
	
<cfproperty 
	name="catHTML" type="string" hint="Topic." required="no" default="" 
	ftSeq="54" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Categories"
	ftType="Category" ftAlias="root" />


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="deleteRelatedIds" hint="Deletes references to a given uuid in the dmHTML_relatedIds table">
	<cfargument name="objectid" required="yes" type="uuid">
	<cfargument name="dsn" required="no" default="#application.dsn#">
	<cfargument name="dbowner" required="no" default="#application.dbowner#">
	
	<cfset var q = ''>
	<cfquery name="q" datasource="#arguments.dsn#">
		DELETE FROM #application.dbowner#dmHTML_aRelatedIDs
		WHERE parentid = '#arguments.objectid#'
	</cfquery>
	
</cffunction>


<cffunction name="delete" access="public" hint="Specific delete method for dmHTML. Removes all descendants">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	
	<cfset var oHTML = createObject("component", application.stcoapi.dmHTML.packagePath) />
	<cfset var stHTML = structNew() />
	<cfset var qRelated = queryNew("blah") />
	<cfset var qDeleteRelated = queryNew("blah") />
	
	<cfset var stReturn = structNew() />
	
	<cfif NOT structIsEmpty(stObj)>
		
		<cfset stReturn = super.delete(stObj.objectId) />
		
		<!--- Find any dmHTML pages that reference this html page. --->
		<cfquery datasource="#application.dsn#" name="qRelated">
		SELECT parentid FROM dmHTML_aRelatedIDs
		WHERE data = '#stobj.objectid#'
		</cfquery>
		
		<cfif qRelated.recordCount>

			<!--- Delete any of these relationships --->
			<cfquery datasource="#application.dsn#" name="qDeleteRelated">
			DELETE FROM dmHTML_aRelatedIDs
			WHERE data = '#stobj.objectid#'
			</cfquery>
						
			<!--- Remove deleted objects from object broker if required --->
			<cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs="#valueList(qRelated.parentID)#", typename="dmHTML") />
			
			
			
			<cfloop query="qRelated">
				<cfset stHTML = oHTML.getData(objectid=qRelated.parentid, bUseInstanceCache=false) />				
			</cfloop>		
						
		</cfif>

		
		<cfreturn stReturn>
	<cfelse>
		
		<cfset stReturn.bSuccess = false>
		<cfset stReturn.message = "#arguments.objectid# (dmHTML) not found.">
		<cfreturn stReturn>
		
	</cfif>
</cffunction>


</cfcomponent>