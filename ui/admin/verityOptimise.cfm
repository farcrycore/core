<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/verityOptimise.cfm,v 1.3 2003/05/04 13:11:15 spike Exp $
$Author: spike $
$Date: 2003/05/04 13:11:15 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Optimise all Verity collections for the active application. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header title="Verity: Build Indices">

<!--------------------------------------------------------------------
Optimisation Routine For CFMX 
--------------------------------------------------------------------->
<cfoutput><h3>Optimising Collections</h3></cfoutput>

<!--- get system Verity information --->		
<cffile action="READ" variable="wVerityMX" file="#server.coldfusion.rootdir#\lib\neo-verity.xml">
<cfwddx action="WDDX2CFML" input="#wVerityMX#" output="verityMX">

<!--- get system Verity information ---> 
<cfcollection action="LIST" name="qcollections">

<!--- optimising collections --->
<h3>Optimising Collections</h3>
<cfloop query="qCollections">
	<cfif findNoCase(application.applicationname, qCollections.name)>
		<CFCOLLECTION ACTION="optimize" COLLECTION="#qCollections.name#">
		<cfoutput>
		#qCollections.name#: optimised...<br>
		</cfoutput>
		<cfflush>
	</cfif>
</cfloop>

<cfoutput><p>All done.</p></cfoutput>

<admin:footer>
<cfsetting enablecfoutputonly="No">

