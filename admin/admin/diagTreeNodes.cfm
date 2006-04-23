<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Diagnostics :: Tree Nodes</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<span class="formtitle">Diagnostics :: Tree Nodes</span><p></p>

<h3>Attach Orphans</h3>

<form action="" method="post">
	<select name="navalias" size="1">
		<cfloop collection="#application.navid#" item="key">
			<cfoutput><option value="#application.navid[key]#"> #key#</cfoutput>
		</cfloop>
	</select>
	<input type="submit" name="action" value="Attach Orphans">
</form>

<cfscript>
// get navigation elements
	oTree = createObject("component", "fourq.utils.tree.tree");
	// getChildren for application.navid.home
	qDescendants = oTree.getDescendants(objectid=application.navid.root);
</cfscript>

<!--- 
<cfdump var="#application.navid#" label="NavAliases">
<cfdump var="#qDescendants#" label="qDescendants">
 --->

<cfquery datasource="#application.dsn#" name="qOrphans">
	SELECT * FROM dmNavigation
	WHERE 
	objectID NOT IN (#quotedValueList(qDescendants.objectid)#)
	AND objectID NOT IN ('#application.navid.root#')
</cfquery>

<!--- if requested, attach orphans to navnode in tree --->
<cfif isDefined("form.navalias")>
	<cfloop query="qOrphans">
		<cfscript>
			oTree.setOldest(parentid=form.navalias, objectid=qOrphans.objectID, objectname=qOrphans.label, typename="dmNavigation");
		</cfscript>
	</cfloop>
	<cfoutput>#qOrphans.recordCount# nav node orphans attached to #form.navalias#.</cfoutput>
<cfelse>
	<p></p>
	<cfdump var="#qOrphans#" label="qOrphans">
</cfif>

</body>
</html>
