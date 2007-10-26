<cfcomponent displayname="Barnacle" hint="Used to grant an item specific permissions." extends="types" output="false">
	<cfproperty name="permission" type="uuid" default="" hint="The permission this barnacle is controlling" ftSeq="1" ftFieldset="" ftLabel="Permission" ftType="uuid" ftJoin="farPermission" />
	<cfproperty name="aObjectIDs" type="array" hint="The objects this permission is being granted for" ftSeq="2" ftFieldset="" ftLabel="Objects" ftJoin="dmNavigation" />
	
	<!--- 
		Content types like navigation have rights (permissions) that can be granted item by item. That
		is, the permission is added to a role for SPECIFIC OBJECTS. A barnacle specifies a permission and a list
		of objects. Adding it to a role grants that permission for those objects.
		
		Where the permissions array only lists those simple permissions a role has, the barnacles array should
		contain a barnacle for every item-specific permission.
	 --->
	 
</cfcomponent>