<cfsetting requesttimeout="999">
<!--- 
 // export table data 
 - called via AJAX from ./webskin/farCOAPI/webtopBodyExportSkeleton.cfm
--------------------------------------------------------------------------------->

<cfset stResult = exportTable(stObj, url.position)>

<cfcontent reset="true" type="application/json" variable="#toBinary(toBase64(serializeJSON(stResult)))#">
