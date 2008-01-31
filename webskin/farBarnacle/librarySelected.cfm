<!--- @@displayname: Library list item --->
<cfset stPermission = createObject("component", application.stcoapi["farPermission"].packagePath).getData(objectid=stObj.permission) />

<cfoutput>#stPermission.title# (#stPermission.aRelatedtypes#)</cfoutput>