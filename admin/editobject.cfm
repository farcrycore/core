<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="url.type" type="string">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfoutput>
<h3>Object Editor (#url.type#)</h3>
</cfoutput>

<cfif NOT IsDefined("url.oid")>
<!--- create object and populate with defaults --->
<cfscript>
// need to modify fourq.createData() to pick up defaults from cfproperty entries
	stObj.objectid = createUUID();
	stObj.label = "(incomplete)";
	stObj.lastupdatedby = session.dmSec.authentication.userlogin;
	stObj.datetimelastupdated = Now();
	stObj.createdby = session.dmSec.authentication.userlogin;
	stObj.datetimecreated = Now();

// dmHTML specific props
	stObj.displayMethod = "display";
	stObj.status = "draft";
</cfscript>

<q4:contentobjectcreate
 typename="#application.fourq.packagepath#.types.#url.type#"
 stProperties="#stObj#"
 r_objectid="objectid"
 >

<!--- reload page with newly created objectid --->
<cflocation url="#cgi.script_name#?#cgi.query_string#&oid=#objectid#" addtoken="No"> 
</cfif>

<!--- edit object --->
<q4:contentobject
 typename="#application.fourq.packagepath#.types.#url.type#"
 method="edit"
 objectID="#url.oid#"
 >

<!--- setup footer --->
<admin:footer>

