<cfsetting enablecfoutputonly="Yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfinvoke 
 component="farcry.fourq.fourq"
 method="findType" returnvariable="typeid">
	<cfinvokeargument name="objectid" value="#url.objectid#"/>
</cfinvoke>

<cfparam name="url.type" default="#typeid#">

<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<nj:edit>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="No">