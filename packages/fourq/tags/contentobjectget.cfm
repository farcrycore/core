<!------------------------------------------------------------------------
contentObjectGet (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectget.cfm,v 1.15 2005/10/24 03:49:16 guy Exp $
$Author: guy $
$Date: 2005/10/24 03:49:16 $
$Name:  $
$Revision: 1.15 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)
Paul Harrison (harrisonp@cbc.curtin.edu.au)

Description:
A wrapper to get a content object instance and return its structure.
------------------------------------------------------------------------->
<!--- ContentObjectGet --->

<cfif thisTag.executionmode eq "start">

	<cfif not isDefined("attributes.objectid")>
		<cfabort showerror="objectid must be passed to contentobjectget" />
	</cfif>
	<cfparam name="attributes.typename" default="" />
	<cfparam name="attributes.r_stObject" default="stObject" />
	<cfparam name="attributes.dsn" default="#application.dsn#" /> 
	
	<cfif not len(attributes.typename)>
		<cfset variables.oFourQ = createObject("component", "farcry.core.packages.fourq.fourq") />
		<cfset attributes.typename = variables.oFourQ.findType(objectid=attributes.objectid,dsn=attributes.dsn) />
	</cfif>
	
	<cfif len(attributes.typename)>
		<!--- Just in case the whole package path has been passed in, we only need the actual typename --->
		<cfset attributes.typename = listLast(attributes.typename,".") />
	
		<cfset oType  = createObject("component", application.stcoapi[attributes.typename].packagePath) />
		<cfset caller[attributes.r_stObject] = oType.getData(objectid=attributes.objectid,dsn=attributes.dsn) />
	<cfelse>
		<cfset caller[attributes.r_stObject] = structNew() />
	</cfif>

</cfif>