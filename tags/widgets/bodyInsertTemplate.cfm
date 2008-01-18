<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.typename" default="">
<cfset typename = attributes.typename>
<cfif typename NEQ ""> <!--- typename check --->
	<cfdirectory action="LIST" directory="#application.path.project#/webskin/#typename#/" name="qListTemplates" filter="template*.htm" sort="name ASC">
	<cfset aTemplates = ArrayNew(1)>
	<cfset iCounter = 0>
	<cfloop query="qListTemplates">
		<cfset iCounter = iCounter + 1>
		<cffile action="READ" file="#qListTemplates.directory#\#qListTemplates.name#" variable="tTemplateContent">
		<cfset aTemplates[iCounter] = StructNew()>		
		<cfset aTemplates[iCounter].text = qListTemplates.name>
		<cfset aTemplates[iCounter].value = htmlEditFormat(tTemplateContent)>
	</cfloop>

	<cfif ArrayLen(aTemplates) GT 0>
<cfoutput>
<h2>Templates</h2>
<select id="l#typeName#Template" name="l#typeName#Template" size="3"><cfloop index="j" from="1" to="#Arraylen(aTemplates)#">
	<option value="#aTemplates[j].value#">#aTemplates[j].text#</option>
</cfloop></select>

<div class="f-submit-wrap">
<input type="button" name="buttonInsertInBody" value="Insert in body" class="f-submit" onclick="fInsertTemplate();" />
</div>

<script type="text/javascript">
function fInsertTemplate(){
	objSelect = document.getElementById("l#typeName#Template");
	if(objSelect.selectedIndex >= 0){
		strVal = objSelect.options[objSelect.selectedIndex].value;
		insertHTML(strVal);
	}else
		alert("Please select a Template to Insert.");
}
</script>
</cfoutput>
	</cfif>
</cfif> <!--- // typename check --->
<cfsetting enablecfoutputonly="false">