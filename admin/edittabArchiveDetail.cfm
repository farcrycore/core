<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<br>
<span class="FormTitle">Archive</span>
<p></p>

<cfinvoke 
 component="farcry.packages.farcry.versioning"
 method="getArchives"
 returnvariable="getArchivesRet">
	<cfinvokeargument name="objectID" value="#url.objectid#"/>
</cfinvoke>

<cfdump var="#getArchivesRet#" label="Archive">

<!--- setup footer --->
<admin:footer>