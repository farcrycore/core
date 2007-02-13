<cfinclude template="/farcry/core/admin/Application.cfm">
<cfimport taglib="/farcry/core/tags/security/ui/" prefix="dmsec">
<!---- ******** CHECK THE USER IS LOGGED IN AND HAS ADMIN PERMISSIONS *********** --->
<dmsec:dmSecUI_Application>