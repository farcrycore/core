<!--- @@displayname: Library list item --->
<cfset stPermission = createObject("component", application.stcoapi["farPermission"].packagePath).getData(objectid=stObj.permission) />

<cfoutput>#application.fc.lib.esapi.encodeForHTML(stPermission.title)# (#application.fc.lib.esapi.encodeForHTML(stPermission.aRelatedtypes)#)</cfoutput>