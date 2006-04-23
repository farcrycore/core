<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="url.type" type="string">
<cfparam name="url.oid" type="string">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfoutput>
<h3>Object Delete (#url.type#)</h3>
</cfoutput>

<cfif IsDefined("form.deleteme")>
<Cfdump var="#form#">
<Cfdump var="#url#">

<!--- delete object --->
<q4:contentobjectdelete
 typename="#application.fourq.packagepath#.types.#url.type#"
 objectID="#url.oid#"
 >

<!--- relocate to object browser --->
<cflocation url="objectbrowser.cfm?type=#url.type#">

<cfelse>
<!--- display object with delete warning --->
<cfform action="">
Are you sure you want to delete this object?<br>
<input type="submit" name="deleteme" value="Make it so!">
<p>
<q4:contentobject
 typename="#application.fourq.packagepath#.types.#url.type#"
 method="display"
 objectID="#url.oid#"
 >
</cfform>
</cfif>

<!--- setup footer --->
<admin:footer>

