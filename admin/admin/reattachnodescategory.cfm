<!--- 
// ACTION: update nested tree model //
--->
<cfif NOT structIsEmpty(form)>

	<cfif isDefined("attachntmorphans")>
		<cfquery datasource="#application.dsn#" name="updateNTM">
		UPDATE nested_tree_objects
		SET
			parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.parentid_orphan#">
		WHERE
		objectid IN
			(	SELECT objectid
				FROM nested_tree_objects
				WHERE parentid not in (select objectid from nested_tree_objects)
				AND typename = 'categories'
				AND NOT (parentid is NULL OR parentid = '') -- ie. not ROOT
			)
		</cfquery>
		<cfoutput>
		<h3>Attaching NTM Orphans</h3>
		You <strong>MUST</strong> now <a href="/farcry/admin/rebuildTree.cfm">Rebuild Tree</a> for the dmNavigation content types.
		</cfoutput>
		
	<cfelseif isDefined("attachlostcontent")>
		<cfquery datasource="#application.dsn#" name="updateNTM">
		INSERT INTO nested_tree_objects
			(ParentID, ObjectID, ObjectName, TypeName, nLevel, nRight, nLeft)
			SELECT 
				'#form.parentid_lost#' AS ParentID, 
				categoryID AS ObjectID, 
				categoryLabel AS ObjectName, 
				'categories' AS TypeName, 
				0 AS nLevel, 
				2 AS nRight,
				1 AS nLeft
			FROM categories
			WHERE 
			categoryid IN 
				(	SELECT categoryid
					FROM categories 
					WHERE categoryid NOT IN
					(	SELECT objectid 
						FROM nested_tree_objects
					)
				)
		</cfquery>
		<cfoutput>
		<h3>Attaching Lost Category Content Items</h3>
		You <strong>MUST</strong> now <a href="/farcry/admin/rebuildTree.cfm">Rebuild Tree</a> for the <strong>categories</strong> content types.
		</cfoutput>
	</cfif>
<cfabort />
</cfif>

<!--- 
// FORM: report on orphans and build form //
--->
<!--- get nav aliases --->
<cfquery datasource="#application.dsn#" name="qCatAlias">
SELECT categoryid, categoryLabel + ' (' + alias + ')' AS display
FROM categories
WHERE alias <> ''
ORDER BY categoryLabel
</cfquery>

<!--- orphan nodes and exist in categories --->
<cfquery datasource="#application.dsn#" name="ntmorphans">
SELECT ntm.parentid, c.categoryid, c.categoryLabel, c.alias
FROM nested_tree_objects ntm, categories c
WHERE ntm.objectid = c.categoryid
	AND ntm.parentid not in
		(select objectid from nested_tree_objects)
	AND NOT (ntm.parentid is NULL OR ntm.parentid = '') -- ie. not ROOT
</cfquery>

<!--- show parent of all orphans; information only --->
<cfquery datasource="#application.dsn#" name="ntmparents">
SELECT categoryid, categoryLabel, alias
FROM categories
where categoryid IN
	(	SELECT ntm.parentid
		FROM nested_tree_objects ntm, categories c
		WHERE ntm.objectid = c.categoryid
			AND parentid not in
				(select objectid from nested_tree_objects)
	)
</cfquery>

<!--- objects not in ntm that should be there --->
<cfquery datasource="#application.dsn#" name="lostcontent">
select categoryid, categoryLabel, alias from categories 
where categoryid not in 
	(select objectid from nested_tree_objects)
</cfquery>

<cfform format="flash" height="800">
	<cfformgroup type="panel" label="Orphan Utility (Categories Only)">
		<!--- nested tree model orphans --->
		<cfformitem type="html"><b>Nested Tree Orphans</b></cfformitem>
		<cfgrid query="ntmorphans" name="ntmorphans"  />
		<cfformgroup type="horizontal">
			<cfselect name="parentid_orphan" query="qCatAlias" value="categoryid" display="display" label="Select Parent: " />
			<cfinput type="submit" name="attachntmorphans" value="Re-attach Content">
		</cfformgroup>
		
		<cfformitem type="html"><b>Orphans Parents</b></cfformitem>
		<cfformitem type="html">(Nothing to do here... orphan parent information just provides a bit of insight.)</cfformitem>
		<cfgrid query="ntmparents" name="ntmparents"  />
	
		<!--- lost categories content items --->
		<cfformitem type="html"><b>Lost Category Content</b></cfformitem>
		<cfgrid query="lostcontent" name="lostcontent"  />
		<cfformgroup type="horizontal">
			<cfselect name="parentid_lost" query="qCatAlias" value="categoryid" display="display" label="Select Parent: " />
			<cfinput type="submit" name="attachlostcontent" value="Re-attach Content">
		</cfformgroup>
	</cfformgroup>
</cfform>

