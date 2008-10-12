<!--- 
// ACTION: update nested tree model //
--->
<cfdump var="#form#" expand="false" label="form" />
<cfabort showerror="debugging" />
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
				AND typename = 'dmNavigation'
				AND NOT (parentid is NULL OR parentid = '') -- ie. not ROOT
			)
		</cfquery>
		<cfoutput>
		<h3>Attaching NTM Orphans</h3>
		You <strong>MUST</strong> now <a href="#application.url.farcry#/admin/rebuildTree.cfm">Rebuild Tree</a> for the dmNavigation content types.
		</cfoutput>
		
	<cfelseif isDefined("attachlostcontent")>
		<cfquery datasource="#application.dsn#" name="updateNTM">
		INSERT INTO nested_tree_objects
			(ParentID, ObjectID, ObjectName, TypeName, nLevel, nRight, nLeft)
			SELECT 
				'#form.parentid_lost#' AS ParentID, 
				ObjectID, 
				label AS ObjectName, 
				'dmNavigation' AS TypeName, 
				0 AS nLevel, 
				2 AS nRight,
				1 AS nLeft
			FROM dmNavigation
			WHERE 
			objectid IN 
				(	SELECT objectid
					FROM dmNavigation 
					WHERE objectid NOT IN
					(	SELECT objectid 
						FROM nested_tree_objects
					)
				)
		</cfquery>
		<cfoutput>
		<h3>Attaching Lost dmNavigation Content Items</h3>
		You <strong>MUST</strong> now <a href="#application.url.farcry#/admin/rebuildTree.cfm">Rebuild Tree</a> for the dmNavigation content types.
		</cfoutput>
	</cfif>
<cfabort />
</cfif>

<!--- 
// FORM: report on orphans and build form //
--->
<!--- get nav aliases --->
<cfquery datasource="#application.dsn#" name="qNavAlias">
SELECT objectid, label + ' (' + lnavidalias + ')' AS display
FROM dmNavigation
WHERE lnavidalias <> ''
ORDER BY label
</cfquery>

<!--- orphan nodes and exist in dmNavigation --->
<cfquery datasource="#application.dsn#" name="ntmorphans">
SELECT ntm.parentid, n.objectid, n.label, n.status, n.lnavidalias, n.datetimelastupdated
FROM nested_tree_objects ntm, dmNavigation n
WHERE ntm.objectid = n.objectid
	AND ntm.parentid not in
		(select objectid from nested_tree_objects)
	AND NOT (ntm.parentid is NULL OR ntm.parentid = '') -- ie. not ROOT
</cfquery>

<!--- show parent of all orphans; information only --->
<cfquery datasource="#application.dsn#" name="ntmparents">
SELECT objectid, label, status, lnavidalias, datetimelastupdated
FROM dmNavigation
where objectid IN
	(	SELECT ntm.parentid
		FROM nested_tree_objects ntm, dmNavigation n
		WHERE ntm.objectid = n.objectid
			AND parentid not in
				(select objectid from nested_tree_objects)
	)
</cfquery>

<!--- objects not in ntm that should be there --->
<cfquery datasource="#application.dsn#" name="lostcontent">
select objectid, label, status, lnavidalias, datetimelastupdated from dmNavigation 
where objectid not in 
	(select objectid from nested_tree_objects)
</cfquery>

<cfform format="flash" height="800">
	<cfformgroup type="panel" label="Orphan Utility (Navigation Folders Only)">
		<!--- nested tree model orphans --->
		<cfformitem type="html"><b>Nested Tree Orphans</b></cfformitem>
		<cfgrid query="ntmorphans" name="ntmorphans"  />
		<cfformgroup type="horizontal">
			<cfselect name="parentid_orphan" query="qNavAlias" value="objectid" display="display" label="Select Parent: " />
			<cfinput type="submit" name="attachntmorphans" value="Re-attach Content">
		</cfformgroup>
		
		<cfformitem type="html"><b>Orphans Parents</b></cfformitem>
		<cfformitem type="html">(Nothing to do here... orphan parent information just provides a bit of insight.)</cfformitem>
		<cfgrid query="ntmparents" name="ntmparents"  />
	
		<!--- lost dmNavigation content items --->
		<cfformitem type="html"><b>Lost Navigation Content</b></cfformitem>
		<cfgrid query="lostcontent" name="lostcontent"  />
		<cfformgroup type="horizontal">
			<cfselect name="parentid_lost" query="qNavAlias" value="objectid" display="display" label="Select Parent: " />
			<cfinput type="submit" name="attachlostcontent" value="Re-attach Content">
		</cfformgroup>
	</cfformgroup>
</cfform>

