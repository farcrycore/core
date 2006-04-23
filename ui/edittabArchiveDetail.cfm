<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<br>
<span class="FormTitle">Archive</span>
<p></p>

<cfinvoke 
 component="#application.packagepath#.farcry.versioning"
 method="getArchiveDetail"
 returnvariable="getArchiveDetailRet">
	<cfinvokeargument name="objectID" value="#url.archiveid#"/>
</cfinvoke>

<cfdump var="#getArchiveDetailRet#" label="Archive">

<!--- setup footer --->
<admin:footer>