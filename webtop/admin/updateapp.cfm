<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
	
	<ft:farcrybuttonpanel>
		<ft:farcrybutton value="Update Application" />
	</ft:farcrybuttonpanel>
</ft:form>

<admin:footer />