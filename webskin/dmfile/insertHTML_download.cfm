<cfsetting enablecfoutputonly="yes">
<!--- 

|| DESCRIPTION || 
$Description: Creates a link to a file. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->

<!--- @@displayname: Download File --->
<!--- @@author: Matthew Bryant --->

<!--- TODO: download.cfm needs to updated so that it handles the new way file locations are stored with only the location starting from the package path portion of the file being stored --->

<cfoutput><a href="#stobj.filepath#">#stobj.title#</a></cfoutput>

<cfsetting enablecfoutputonly="yes">