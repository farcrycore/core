<!--- first need to generate feed --->
<cfset generate(stargs.objectid)>

<!--- display --->
<CFHEADER NAME="content-disposition" VALUE="inline; filename=#stObj.xmlFile#">
<cfcontent type="text/xml" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#" deletefile="No" reset="Yes">


