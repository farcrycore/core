<cfif isdefined("application.daemon_Archivetypeid")>
	<cfa_contentobjectget objectid="#attributes.objectID#" r_stobject="stobj">
	<cfa_objecttypeget dataSource="#request.cfa.objectstore.dsn#" typeID="#stobj.typeid#" bUseCache="True" r_stType="r_stType">
	<cfif listfindnocase(r_stType.metadata, "ArchiveMe")>
		<cfwddx input="#stobj#" output="stobjwddx" action="CFML2WDDX">
		<cfa_contentobjectcreate typeid="#application.daemon_Archivetypeid#" label="#attributes.objectID#" r_id="objectid">
		
		<cfa_contentobjectget objectid="#objectID#" r_stobject="starchiveobj">
		
		<cfa_contentobjectdata objectid="#starchiveobj.objectID#">
			<cfa_contentobjectproperty name="archivedObject" value="#stobjwddx#">
		</cfa_contentobjectdata>
	</cfif>
</cfif>