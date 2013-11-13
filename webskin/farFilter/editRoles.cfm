

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<ft:processForm action="Save">
	<ft:processFormObjects objectid="#stobj.objectid#" />
</ft:processForm>

<ft:processForm action="Save,Cancel" bHideForms="true">
	<cfoutput>
	<script type="text/javascript">
		$fc.closeBootstrapModal();
	</script>
	</cfoutput>
</ft:processForm>

<admin:header />

<ft:form>
	<ft:object typename="#stobj.typename#" objectID="#stobj.objectid#" lFields="lRoles" legend="Select Roles" />
	
	<ft:buttonPanel>
		<ft:button value="Save" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<admin:footer />