<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<br>
<span class="FormTitle">Object Dump</span>
<p></p>

<!--- get object details and dump results --->
<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
<cfdump var="#stobj#" label="#stobj.title# Dump">

<!--- setup footer --->
<admin:footer>
