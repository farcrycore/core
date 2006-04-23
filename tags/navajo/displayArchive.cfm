<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<q4:contentobjectget typename="#application.packagepath#.types.dmArchive" objectid="#attributes.objectID#" r_stobject="stObject">

<cfdump var="#stObject#">