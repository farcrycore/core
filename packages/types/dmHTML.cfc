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
<!--- @@Description: HTML Page Content Type --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->
<cfcomponent extends="versions" displayname="HTML Page" hint="Forms the basis of the content framework of the site.  HTML objects include containers and static information." bObjectBroker="1" bUseInTree="1" bFriendly="1" fuAlias="html">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftwizardStep="Start" ftFieldset="General Details" name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="" ftValidation="required">
<cfproperty ftSeq="2" ftwizardStep="Start" ftFieldset="General Details" name="reviewDate" type="date" hint="The date for which the object will be reviewed" required="no" default="" ftType="datetime" ftToggleOffDateTime="true" ftLabel="Review Date">
<cfproperty ftSeq="3" ftwizardStep="Start" ftFieldset="General Details" name="ownedby" displayname="Owned by" type="string" hint="Username for owner." required="No" default="" ftLabel="Owned By" ftType="list" ftRenderType="dropdown" ftListData="getOwners">
<cfproperty ftSeq="4" ftwizardStep="Start" ftFieldset="General Details" name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="displayPageStandard" ftLabel="Display Method" ftType="webskin" ftPrefix="displayPage">

<cfproperty ftSeq="5" ftwizardStep="Start" ftFieldset="Metadata" name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="" ftLabel="Meta Keywords">
<cfproperty ftSeq="6" ftwizardStep="Start" ftFieldset="Metadata" name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default="" ftlabel="Extended Metadata" ftToggle="true">


<cfproperty ftSeq="10" ftwizardStep="Body" ftFieldset="Teaser" name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty ftSeq="11" ftwizardStep="Body" ftFieldset="Teaser" name="teaserImage" type="uuid" hint="UUID of image to display in teaser" required="no" default="" ftJoin="dmImage" ftLibraryData="getTeaserImageLibraryData" ftLibraryDataTypename="dmHTML">

<cfproperty ftSeq="12" ftwizardStep="Body" ftFieldset="Body" name="Body" type="longchar" hint="Main body of content." required="no" default="" ftType="richtext" ftLabel="Body" 
	ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
	ftTemplateTypeList="dmImage,dmFile,dmFlash,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
	ftLinkListRelatedTypenames="dmFile,dmNavigation,dmHTML"
	ftTemplateSnippetWebskinPrefix="insertSnippet">

<cfproperty ftSeq="13" ftwizardStep="Body" ftFieldset="Relationships" name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="" ftLabel="Associated Media" ftJoin="dmImage,dmFile,dmFlash" bSyncStatus="true">
<cfproperty ftSeq="14" ftwizardStep="Body" ftFieldset="Relationships" name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="" ftJoin="dmNavigation,dmHTML" ftLabel="Associated Content">

<cfproperty ftSeq="20" ftwizardStep="Categorisation" name="catHTML" type="nstring" hint="Topic." required="no" default="" ftType="Category" ftAlias="root" ftLabel="Categories" />



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
		SELECT * FROM dmHTML_aRelatedIDs
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

<cffunction name="getTeaserImageLibraryData" access="public" output="false" returntype="query" hint="Return a query for all images already associated to this object.">
	<cfargument name="primaryID" type="uuid" required="true" hint="ObjectID of the object that we are attaching to" />
	<cfargument name="qFilter" type="query" required="true" hint="If a library verity search has been run, this is the qResultset of that search" />
	
	<cfset var q = queryNew("blah") />
		
	<!--- 
	Run the entire query and return in to the library. Let the library handle the pagination.
	 --->
	<cfquery datasource="#application.dsn#" name="q">
	SELECT data as objectid, dmImage.label, dmImage.thumbnailimage, dmImage.title, dmImage.alt
	FROM dmHTML_aObjectIDs 
	INNER JOIN 
		 dmImage ON dmHTML_aObjectIDs.data = dmImage.objectid
	WHERE parentid = '#arguments.primaryID#'
	<cfif qFilter.RecordCount>
		AND data IN (#ListQualify(ValueList(qFilter.key),"'")#)
	</cfif>
	ORDER BY seq
	</cfquery>
	
	<cfreturn q />
	
</cffunction>



</cfcomponent>

