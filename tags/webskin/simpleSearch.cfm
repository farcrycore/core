<!--- simpleSearch custom tag --->
<cfsetting enablecfoutputonly="Yes">
<cfoutput>
<form action="#application.url.conjurer#?objectid=#application.navid.search#" method="post">
<input type="text" name="criteria" value="">
<input type="submit" name="action" value="Search">
</form>
</cfoutput>
<cfsetting enablecfoutputonly="No">
