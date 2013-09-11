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
<cfcomponent 
	extends="types" displayname="File"  
	hint="A global document library that can be referenced from other content types.  Documents can be secured or open to all depending on your settings." 
	bBulkUpload="true">
	
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
	<cfproperty name="title" type="string" required="no" default="" 
		ftSeq="1" ftFieldset="File Details" ftLabel="Title" 
		blabel="true" ftBulkUploadEdit="true"
		hint="Meaningful reference title for file">

	<cfproperty name="description" type="longchar" required="No" default="" 
		ftSeq="2" ftFieldset="File Details" ftLabel="Description" 
		ftType="longchar" 
		ftBulkUploadEdit="true"
		hint="A description of the file to be uploaded.">

	<cfproperty name="filename" type="string" required="no" default="" 
		ftSeq="3" ftFieldset="File Details" ftLabel="File" 
		ftType="file" ftDestination="/dmfile" 
		ftSecure="false" ftBulkUploadTarget="true"
		hint="The name of the file to be uploaded">

	<cfproperty name="documentDate" type="date" required="no" default="" 
		ftSeq="4" ftFieldset="Publishing Details" ftLabel="Publish Date" 
		ftType="datetime" ftDefaultType="Evaluate" ftDefault="now()" 
		ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="false"
		hint="The date of the attached file.">

	<cfproperty name="catFile" type="string" required="no" 
		ftSeq="5" ftFieldset="Categorisation" ftLabel="Category" 
		ftType="category" ftAlias="dmfile" 
		ftBulkUploadDefault="true"
		hint="Flag to make file shared.">

<!--- 
 // system property 
--------------------------------------------------------------------------------->
	<cfproperty name="status" type="string" required="yes" default="draft"
		hint="Status of the node (draft, pending, approved).">

<!------------------------------------------------------------------------
object methods
------------------------------------------------------------------------->
<cffunction name="fileInfo" output="false" returntype="query" access="private">
	<cfargument name="fileName" type="string" required="true" />
	
	<cfset var directory = "" />
	<cfset var getFile = queryNew("blah") />
	
	<cfif not fileExists(fileName)>
		<cfthrow message="fileInfo error: #fileName# does not exist." />
	</cfif>

	<cfset directory = getDirectoryFromPath(fileName)>
	<cfdirectory name="getFile" directory="#directory#" filter="#getFileFromPath(fileName)#" />

	<cfreturn getFile>
</cffunction>

<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
	<cfargument name="stProperties" required="true" type="struct">
	<cfargument name="stFields" required="true" type="struct">
	<cfargument name="stFormPost" required="false" type="struct">		
	
	<cfif not structkeyexists(arguments.stProperties,"title") or not len(arguments.stProperties.title) and structkeyexists(arguments.stProperties,"filename")>
		<cfset arguments.stProperties.title = listfirst(listlast(arguments.stProperties.filename,"/"),".") />
	</cfif>
	
	<cfif structkeyexists(arguments.stProperties,"title")>
		<cfset arguments.stProperties.label = arguments.stProperties.title />
	</cfif>
	
	<cfreturn super.beforeSave(argumentCollection=arguments) />
</cffunction>

	
</cfcomponent>