<cfprocessingDirective pageencoding="utf-8">
<cfobject component="#application.types.dmEmail.typePath#" name="oEmail">
<cfset oEmail.send(url.objectid)>
