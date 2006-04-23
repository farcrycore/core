<!--- dmHTML Edit Handler --->
<cfimport taglib="/fourq/tags" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

<cfparam name="url.killplp" default="0">


<q4:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="#application.fourq.plppath#/dmHTML"
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
	<q4:plpstep name="related" template="related.cfm">
	<q4:plpstep name="complete" template="complete.cfm" bFinishPLP="true">
</q4:plp>


<cfif isDefined("bComplete") and bComplete>
	<nj:TreeGetRelations 
			typename="#stOutput.typename#"
			objectId="#stOutput.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<nj:updateTree objectId="#parentID#" complete="1">
	
<div class="FormSubTitle">PLP Complete - Object Updated</div>
<input type="button" class="normalBttnStyle" value="close" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
<cfscript>
stProperties = Duplicate(stOutput);
stProperties.label = stproperties.title;
// stProperties.aObjectIDs = arrayNew(1);
// arrayAppend(stProperties.aObjectIDs, form.aObjectIDs);
stProperties.datetimelastupdated = Now();
stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
</cfscript>


<q4:contentobjectdata
 typename="#application.packagepath#.types.dmHTML"
 stProperties="#stProperties#"
 objectid="#stObj.ObjectID#"
>
	

</cfif>
