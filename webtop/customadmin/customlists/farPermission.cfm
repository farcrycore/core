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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Permission Admin" />

<cfset aCustomColumns = arraynew(1) />
<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].webskin = "displayRelatedTypes" />
<cfset aCustomColumns[1].title = "Join on" />
<cfset aCustomColumns[1].sortable = false />

<ft:objectadmin 
	typename="farPermission"
	title="Permission Admin"
	columnList="title"
	aCustomColumns="#aCustomColumns#"
	sortableColumns="title"
	lFilterFields="title"
	sqlorderby="title asc" />

<admin:footer />

