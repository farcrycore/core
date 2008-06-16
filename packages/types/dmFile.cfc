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
<cfproperty ftSeq="2" ftFieldset="File Details" name="description" type="string" hint="A description of the file to be uploaded." required="No" default="" fttype="longchar" ftLabel="Description" />
<cfproperty ftSeq="3" ftFieldset="File Details" name="filename" type="string" hint="The name of the file to be uploaded" required="no" default="" ftType="file" ftLabel="File" ftDestination="/dmfile" ftSecure="false" />

<cfproperty ftSeq="20" ftFieldset="Publishing Details" name="documentDate" type="date" hint="The date of the attached file." required="no" default="" ftLabel="Publish Date" ftDefaultType="Evaluate" ftDefault="now()" ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="false" />
<cfproperty ftSeq="21" ftFieldset="Publishing Details" name="bLibrary" type="boolean" hint="Flag to make file shared." required="no" default="1" ftLabel="Add file to library?" ftType="boolean" />
<cfproperty ftSeq="30" ftFieldset="Categorisation" name="catFile" type="string" hint="Flag to make file shared." required="no" ftLabel="Category" ftType="category" ftalias="dmfile" />

<!--- system property --->
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">

<!--- deprecated properties: these properties should not be referenced and are here for backward compatability only --->
<cfproperty name="filepath" type="string" hint="The location of the file on the webserver" required="no" default="">  
<cfproperty name="fileSize" type="numeric" hint="The size of the file on the webserver (in bytes)" required="no" default="0">  
<cfproperty name="fileType" type="string" hint="MIME content type of the saved file" required="no" default="">
<cfproperty name="fileSubType" type="string" hint="MIME content subtype of the saved file" required="no" default="">
<cfproperty name="fileExt" type="string" hint="The extension of the file on the webserver (without the period)" required="no" default="">


<!------------------------------------------------------------------------
object methods
------------------------------------------------------------------------->
<cffunction name="BeforeSave" access="public" output="true" returntype="struct">
	<cfargument name="stProperties" required="true" type="struct">
	<cfargument name="stFields" required="true" type="struct">
	<cfargument name="stFormPost" required="false" type="struct">
	
	<!--- 
		This will set the default Label value. It first looks form the bLabel associated metadata.
		Otherwise it will look for title, then name and then anything with the substring Name.
	 --->
	<cfset var NewLabel = "" />
	<cfset var filepath = "" />
	<cfset var fileContents = "" />
	
	<cfparam name="arguments.stProperties.label" default="">
	
	<cfif structKeyExists(arguments.stProperties,"Title")>
		<cfset arguments.stProperties.label = "#arguments.stProperties.title#">
	</cfif>
	
	<cfset arguments.stProperties.datetimelastupdated = now() />
	
	<cfif structKeyExists(arguments.stProperties,"filename") AND len(trim(arguments.stProperties.filename))>
	
		<cfif structKeyExists(arguments.stFields.filename.Metadata,"ftSecure") AND arguments.stFields.filename.Metadata.ftSecure>
			<cfset filepath = application.path.secureFilePath />
		<cfelse>
			<cfset filepath = application.path.defaultFilePath />
		</cfif>
		
		<cftry>
			<cfset fullFilePath = "#filepath##arguments.stProperties.filename#" />
			<cfset fileRead = createObject("java","java.io.FileInputStream").init(fullFilePath) />
					
			<cfset arguments.stProperties.fileSize = fileRead.available() />
			<cfset arguments.stProperties.fileExt = "#listLast(arguments.stProperties.filename,".")#" />
					
			<cfset fileRead.close() />
						
			<cfcatch type="any"><!--- File may not exist i.e. development environments ---></cfcatch>
		</cftry>
	</cfif>
	
	<cfreturn stProperties>
</cffunction>

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



	
</cfcomponent>