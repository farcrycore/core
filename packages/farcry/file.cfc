<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/file.cfc,v 1.1 2004/04/27 22:41:09 tom Exp $
$Author: tom $
$Date: 2004/04/27 22:41:09 $
$Name: milestone_2-2-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: file handling cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="File" hint="Farcry File Operations">
	<cffunction name="getMimeTypes" returntype="struct" hint="Returns a structure of known Mime Types" output="No">
		<cfinclude template="_file/getMimeTypes.cfm">
		<cfreturn stMimeTypes>
	</cffunction>
	<cffunction name="getMimeType" returntype="string" hint="Return Mime Type based on lookup of file extension" output="No">
		<cfargument required="Yes" name="filename" type="string">
		<cfscript>
			//@author Kenneth Rainey (kip.rainey@incapital.com) @version 1, April 21, 2004 
			var mimeStruct = this.getMimeTypes();
			var fileExtension = "";
			//extract file extension from file name
			fileExtension = Reverse(SpanExcluding(Reverse(fileName),"."));
			if(structKeyExists(mimeStruct,fileExtension))
				return mimeStruct[fileExtension];
			else
				return "unknown/unknown";
		</cfscript>
	</cffunction>

</cfcomponent>