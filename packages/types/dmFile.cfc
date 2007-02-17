<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author:  $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: dmFile type $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="types" displayname="File"  hint="File objects" bUseInTree="false">
	
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty ftSeq="1" ftFieldset="File Details" name="title" type="string" hint="Meaningful reference title for file" required="no" default="" ftLabel="Title" blabel="true" />
<cfproperty ftSeq="2" ftFieldset="File Details" name="description" type="string" hint="A description of the file to be uploaded." required="No" default="" fttype="longchar" ftLabel="Description" />
<cfproperty ftSeq="3" ftFieldset="File Details" name="filename" type="string" hint="The name of the file to be uploaded" required="no" default="" ftType="file" ftLabel="File" ftDestination="/" ftSecure="false" />
<cfproperty ftSeq="20" ftFieldset="Publishing Details" name="documentDate" type="date" hint="The date of the attached file." required="no" default="" ftLabel="Publish Date" ftDefaultType="Evaluate" ftDefault="now()" ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="false" />
<cfproperty ftSeq="21" ftFieldset="Publishing Details" name="bLibrary" type="boolean" hint="Flag to make file shared." required="no" default="1" ftLabel="Add file to library?" ftType="boolean" />
<cfproperty ftSeq="30" ftFieldset="Categorisation" name="catFile" type="string" hint="Flag to make file shared." required="no" ftLabel="Category" ftType="category" ftalias="dmfile" />

<!--- deprecated properties --->
<cfproperty name="filepath" type="string" hint="The location of the file on the webserver" required="no" default="">  
<cfproperty name="fileSize" type="numeric" hint="The size of the file on the webserver (in bytes)" required="no" default="0">  
<cfproperty name="fileType" type="string" hint="MIME content type of the saved file" required="no" default="">
<cfproperty name="fileSubType" type="string" hint="MIME content subtype of the saved file" required="no" default="">
<cfproperty name="fileExt" type="string" hint="The extension of the file on the webserver (without the period)" required="no" default="">

<!--- system property --->
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">

</cfcomponent>