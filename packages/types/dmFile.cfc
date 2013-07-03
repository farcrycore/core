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
<cfcomponent extends="types" displayname="File"  hint="A global document library that can be referenced from other content types.  Documents can be secured or open to all depending on your settings.">
	
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty ftSeq="1" ftFieldset="File Details" name="title" type="string" hint="Meaningful reference title for file" required="no" default="" ftLabel="Title" blabel="true" />
<cfproperty ftSeq="2" ftFieldset="File Details" name="description" type="longchar" hint="A description of the file to be uploaded." required="No" default="" fttype="longchar" ftLabel="Description" />
<cfproperty ftSeq="3" ftFieldset="File Details" name="filename" type="string" hint="The name of the file to be uploaded" required="no" default="" ftType="file" ftLabel="File" ftDestination="/dmfile" ftSecure="false" />

<cfproperty ftSeq="20" ftFieldset="Publishing Details" name="documentDate" type="date" hint="The date of the attached file." required="no" default="" ftLabel="Publish Date" ftDefaultType="Evaluate" ftDefault="now()" ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="false" />
<cfproperty ftSeq="30" ftFieldset="Categorisation" name="catFile" type="string" hint="Flag to make file shared." required="no" ftLabel="Category" ftType="category" ftalias="dmfile" />

<!--- system property --->
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">


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