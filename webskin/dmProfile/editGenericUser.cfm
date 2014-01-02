<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Generic User --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />


<!--- 
 // process form 
--------------------------------------------------------------------------------->
<ft:serverSideValidation />

<ft:processform action="Save" exit="true">
	<ft:processformobjects typename="dmProfile" />
</ft:processform>

<ft:processform action="Cancel" exit="true" />


<!--- 
 // view: profile form 
--------------------------------------------------------------------------------->
<cfoutput>
	<h2>EDIT: #listdeleteat(stObj.username,listlen(stObj.username,"_"),"_")# - #stObj.userdirectory#</h2>
</cfoutput>

<ft:form>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="firstname,lastname,breceiveemail,emailaddress,avatar,phone,fax,position,department" 
		lhiddenFields="username,userdirectory" 
		legend="Profile Details" />
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="locale,overviewHome" 
		legend="Webtop Settings" />
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />