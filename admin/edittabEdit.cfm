<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfinvoke 
 component="fourq.fourq"
 method="findType" returnvariable="typeid">
	<cfinvokeargument name="objectid" value="#url.objectid#"/>
</cfinvoke>

<cfparam name="url.type" default="#typeid#">

<cfsetting enablecfoutputonly="No">
<cfimport taglib="/farcry/tags/navajo" prefix="nj">

<nj:edit>
<cfsetting enablecfoutputonly="No">

<!--- setup footer --->
<admin:footer>
