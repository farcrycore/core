<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<q4:contentobjectget typename="#application.types.dmArchive.typePath#" objectid="#attributes.objectID#" r_stobject="stObject">

<cfdump var="#stObject#">