<cfinclude template="/farcry/farcry_core/admin/Application.cfm">
<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<!---- ******** CHECK THE USER IS LOGGED IN AND HAS ADMIN PERMISSIONS *********** --->
<dmsec:dmSecUI_Application>