<!--- dmHTML Edit Handler --->
<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="url.killplp" default="0">


<!--- <cfdump var="#stObj#"> --->
   <!--- <cfset url.killplp = 1>    --->

<q4:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="#application.fourq.plppath#/dmNews"
	iTimeout="15"
	stInput="#stObj#"
	bDebug="0"
	bForceNewInstance="#url.killplp#"
	r_stOutput="stOutput"
	storage="file"
	storagedir="#application.fourq.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<q4:plpstep name="start" template="start.cfm">
	<!--- <q4:plpstep name="teaser" template="teaser.cfm"> --->
	<q4:plpstep name="files" template="files.cfm">
	<q4:plpstep name="images" template="images.cfm">
	<q4:plpstep name="body" template="body.cfm">
	<q4:plpstep name="metadata" template="metadata.cfm">
	<q4:plpstep name="complete" template="complete.cfm" bFinishPLP="true">
</q4:plp> 



<cfif isDefined("bComplete") and bComplete>
<cfoutput>
<div class="FormSubTitle">PLP Complete - Object Updated</div>
<input type="button" class="normalBttnStyle" value="close" onClick="location.href='#application.url.farcry#/navajo/genericAdmin.cfm?#CGI.QUERY_STRING#&typename=#stOutput.typename#';">  


</cfoutput>
<cfscript>
stProperties = Duplicate(stOutput);
stProperties.label = stproperties.title;
// stProperties.aObjectIDs = arrayNew(1);
// arrayAppend(stProperties.aObjectIDs, form.aObjectIDs);
stProperties.datetimelastupdated = Now();
stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
</cfscript>
<q4:contentobjectdata
 typename="#application.packagepath#.types.dmNews"
 stProperties="#stProperties#"
 objectid="#stObj.ObjectID#"
>

</cfif>
