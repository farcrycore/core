<cfsetting enablecfoutputonly="true">
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

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:onReady id="object-admin-popup">
	<cfoutput>
	$j(document).ready(function(){
		$j(".user-stats").click(function(e){
			e.preventDefault();
			$fc.openDialog("User Activity", "#application.url.webtop#/edittabUserStats.cfm?username=" + $j(this).attr('href'));
		});
	});
	</cfoutput>
</skin:onReady>
</script>


<cfscript>	
	aCustomColumns = arrayNew(1);
	aCustomColumns[1] = structNew();
	aCustomColumns[1].webskin = "userStats"; // located in the webskin of the type the controller is listing on
	aCustomColumns[1].title = "User"; 
	aCustomColumns[1].sortable = true; //optional
	aCustomColumns[1].property = "username"; //mandatory is sortable=true
</cfscript>
	
<ft:objectadmin
	typename="dmProfile"
	title="User Activity Report"
	columnList="firstname,lastname" 
	sortableColumns="userid,userstatus"
	lFilterFields="username"
	sqlorderby="username asc" 
	lButtons=""
	bSelectCol="false"
	bShowActionList="false"
	aCustomColumns="#aCustomColumns#"
/>


<cfsetting enablecfoutputonly="false">