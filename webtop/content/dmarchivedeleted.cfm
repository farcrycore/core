<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header$
$Author$
$Date$
$Name$
$Revision$

|| DESCRIPTION ||
$Description: Generic type administration. $
$TODO: i18n resource bundle update$
$TODO: requires specific permission set for access$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfquery datasource="#application.dsn#" name="qArchives" blockfactor="50">
SELECT 
	(SELECT count(*) FROM refObjects o WHERE o.objectid = a.archiveid) AS bNotDeleted, 
	objectid, 
	label, 
	archiveid, 
	datetimecreated, 
	createdby, 
	datetimelastupdated
FROM dmArchive a
WHERE archiveid not in (SELECT objectid FROM refObjects)
ORDER BY bNotDeleted ASC
</cfquery>

<!--- set up page header --->
<admin:header title="Archive Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmArchive"
	permissionset="news"
	title="Deleted Archived Content Items"
	orderby="datetimecreated"
	query="#qArchives#"
	bFilterCategories="false"
	bdebug="0">
	<widgets:typeadmincolumn title="View" columntype="expression" value="<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&flushcache=1"" target=""_self""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" alt=""#application.rb.getResource("view")#"" title=""#application.rb.getResource("view")#"" /></a>" style="text-align: center;" />
	<widgets:typeadmincolumn title="Label" columntype="value" value="label" orderby="label" />
	<widgets:typeadmincolumn title="Created" columntype="value" value="datetimecreated" orderby="datetimecreated" />
	<widgets:typeadmincolumn title="By" columntype="value" value="createdby" orderby="createdby" />
	<widgets:typeadmincolumn title="Deleted" columntype="evaluate" value="##YesNoFormat(recordset.bNotDeleted*-1+1)##" style="text-align: center;" orderby="bNotDeleted" />
	<widgets:typeadminbutton buttontype="unlock" />
</widgets:typeadmin>

<admin:footer>

