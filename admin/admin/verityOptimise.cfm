<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/admin/" prefix="admin">

<admin:header title="Verity: Build Indices">

<!--------------------------------------------------------------------
Optimisation Routine For CFMX 
--------------------------------------------------------------------->
<cfoutput><h3>Optimising Collections</h3></cfoutput>

<!--- get system Verity information --->		
<cffile action="READ" variable="wVerityMX" file="C:\CFusionMX\lib\neo-verity.xml">
<cfwddx action="WDDX2CFML" input="#wVerityMX#" output="verityMX">

<!--- optimising collections --->
<h3>Optimising Collections</h3>
<cfloop collection="#veritymx[3]#" item="key">
	<CFCOLLECTION ACTION="optimize" COLLECTION="#key#">
	<cfoutput>
	#key#: optimised...<br>
	</cfoutput>
	<cfflush>
</cfloop>

<cfoutput><p>All done.</p></cfoutput>

<admin:footer>
<cfsetting enablecfoutputonly="No">

