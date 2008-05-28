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
|| DESCRIPTION ||
$Description: Image library administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Update application" />

<ft:processform action="Update Application">
	<ft:processformobjects typename="updateapp" />
	<cfoutput>
		<p class="success">
			Selected application variables and objects have been reloaded
		</p>
	</cfoutput>
</ft:processform>

<ft:form>
	<ft:object typename="updateapp" />
	
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Update Application" />
	</ft:farcryButtonPanel>
</ft:form>

<admin:footer />