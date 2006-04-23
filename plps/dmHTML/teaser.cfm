<!--- 
dmHTML PLP
 - teaser (teaser.cfm)
--->
<cfimport taglib="/farcry/tags" prefix="tags">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">

<!--- huh? --->
<cfset refObj="Teaser Image">

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">

	<cfoutput>
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">Teaser</div>	
	<div class="FormTable">
<!--- 	
TODO
get tree working
get images working

<table class="BorderTable" rules="rows">
	<tr><td><b>Teaser Image</b></td></tr>
	<tr>
	  <td>
	  <div id="specobjs"><h3>#refObj#</h3>Loading Data...</div>
	  </td>
	</tr>
	</table>
	<input type="hidden" name="aIds" value="#arrayToList(output.aTeaserImageIds)#">
	
	<!--- on insert getobjectdata, insert --->
	<script>
	drawNode( '#arrayToList(output.aTeaserImageIds)#' );
	</script>
	
	<Br><br>
 --->
<table width="400" border="0" cellspacing="0" cellpadding="5" align="center">
	<tr>
		<td><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="256"></td>
	</tr>										
</table>
</div>
</cfoutput>
	
	<cfoutput>
	<div class="FormTableClear">
	<cftrace inline="true" text="Form complete">
		<tags:PLPNavigationButtons>
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</div>
	</cfoutput>
	
</cfform>
	
<cfelse>
	<cfparam name="form.aIds" default="">
	<cfset output.aTeaserImageIds = ListToArray(form.aIds)>

	<!--- <cf_ektron_scrub in="form.teaser"> --->

	<tags:plpUpdateOutput>
</cfif>