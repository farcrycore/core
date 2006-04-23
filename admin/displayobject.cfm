<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="url.oid" type="UUID">
<cfparam name="url.type" type="string">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<h3>Display Object</h3>

<q4:contentobject 
 typename="#application.fourq.packagepath#.types.#url.type#"
 objectid="#url.oid#"
 method="display">

<!--- setup footer --->
<admin:footer>