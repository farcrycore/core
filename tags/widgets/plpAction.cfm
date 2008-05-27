<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

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
$Header: /cvs/farcry/core/tags/widgets/plpAction.cfm,v 1.5 2005/09/15 02:14:44 guy Exp $
$Author: guy $
$Date: 2005/09/15 02:14:44 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
Works out where to go next during plp

|| DEVELOPER ||
Ben Bishop (ben@daemon.com.au)
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">

<cfparam name="form.plpAction" default="none">
<!--- if the click enter  move to next step --->
<cfif form.plpAction EQ "">
	<cfset form.plpAction = "Next">
</cfif>

<cfswitch expression="#listGetAt(form.plpAction,1,":")#">
	
	<cfcase value="next">
		<cfset caller.thisstep.isComplete = 1>
		<cfset caller.thisstep.advance = 1>
	</cfcase>
	
	<cfcase value="prev">
		<cfscript>
			// TODO: is there a better way to find the array position of the current step? BB
			for (i=1; i lte arrayLen(caller.stPLP.Steps); i=i+1) {
				if (caller.thisstep.name eq caller.stPLP.Steps[i].name) {
					caller.thisstep.nextStep = caller.stPLP.Steps[i-1].name;
				}
				caller.thisstep.isComplete = 1;
				caller.thisstep.advance = 1;
			}
		</cfscript>
	</cfcase>
	
	<cfcase value="complete">
		<!--- TODO: this is currently as save did, saving to PLP but not moving on, verify required action --->
		<!--- save plp and return to current step --->
		<cfset caller.thisstep.isComplete = 1>
		<cfset caller.thisstep.nextStep = caller.thisstep.name>
		<cfset caller.thisstep.advance = 1>
	</cfcase>
	
	<cfcase value="cancel">
		<cftry>
			<!--- cancel content item lock (note a bit dodge but we're trying to lose the dedicated locking component GB --->
			<cfset oCancel=createobject("component", "#application.types[caller.output.typename].name#")>
			<cfset oCancel.getdata(objectid=caller.output.objectid)>
			<cfset oCancel.setlock(locked="false")>
			<cfcatch>
				<cftrace type="error" category="types" text="Attempt to unlock content item on PLP cancel failed.">
			</cfcatch>
		</cftry>  

		<!--- delete the current plp file this will ensure that when user goes back into plp, it will be regarded as 'new'--->
		<!--- currently only storage type is 'file' --->
		<cfswitch expression="#caller.attributes.storage#">
			<cfcase value="file">
				<cftry>
					<cflock name="plpfile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE">
						<cffile action="delete" file="#caller.attributes.storagedir#/#caller.attributes.owner#.plp">
					</cflock>
					<cfcatch type="Any">
					</cfcatch>
				</cftry>
			</cfcase>
			<cfcase value="db">
				<!--- TODO: storage = db? --->
			</cfcase>
		</cfswitch>
		<!--- relocate to cancel location or close window --->
		<cfif isdefined("url.ref") AND url.ref eq "closewin">
			<cfoutput>
			<script type="text/javascript">
				// close browser
				window.close();
			</script>
			</cfoutput>
			<cfabort>
		</cfif>
	
		<cftry>
			<cflocation url="#caller.attributes.cancelLocation#" addtoken="no">
			<cfcatch>
				<!--- if no cancel location specified go to the farcry admin home --->
				<cflocation url="#application.url.farcry#" addtoken="no">
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="step">
		<cfset caller.thisstep.nextStep = caller.stPLP.Steps[listGetAt(form.plpAction,2,":")].name>
		<cfset caller.thisstep.isComplete = 1>
		<cfset caller.thisstep.advance = 1>
	</cfcase>
	
</cfswitch>
<cfsetting enablecfoutputonly="no">