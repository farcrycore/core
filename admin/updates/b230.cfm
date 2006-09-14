<!--- @@description:
Updates general config with locale attribute<br />
Adds the locale property to dmProfile<br />
Adds mirrorId field to the container table<br />
Adds bShared field to the container table<br />
Expands HTMLArea config<br />
Updates permission sequence for PostgeSQL installs<br />
Sets category alias for root node<br />
Adds mediaType field to dmCSS table<br />
Adds bThisNodeOnly field to dmCSS table<br />
Removes orphaned containers from refContainers table
--->

<html>
<head>
<title>Farcry Core b230 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
		
	<!--- Add locale entry to general config --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating General config...</cfoutput><cfflush>
	<cfset application.config.general.locale = "en_AU">

	<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'general'
	</cfquery>

	<cfoutput><strong>done</strong></p></cfoutput><cfflush>
		
	<!--- Update HTML Area Config --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating HTML Area config...</cfoutput><cfflush>
	
	<cfset application.config.htmlArea.useContextMenu = "No">
	<cfset application.config.htmlArea.useTableOperations = "No">
	<cfset application.config.htmlArea.pageStyle  = "">
	<cfset application.config.htmlArea.width  = "595px">
	<cfset application.config.htmlArea.height  = "400px">

	<cfwddx action="CFML2WDDX" input="#application.config.htmlArea#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'htmlArea'
	</cfquery>

	<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	

	<cfset error = 0>
	<!--- Add locale entry to dmProfile table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmProfile table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					locale VARCHAR2(10) default 'en_AU' NOT NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					locale VARCHAR(10) NOT NULL default 'en_AU'
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					locale VARCHAR(10)
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile 
					ALTER COLUMN locale SET DEFAULT 'en_AU'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner#dmProfile 
					SET locale = 'en_AU'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile 
					ALTER COLUMN locale SET NOT NULL
				</cfquery>
			</cfcase>			
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					locale VARCHAR(10) NOT NULL default('en_AU')
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	
	
	<cfset error = 0>
	<!--- Add mirrorid entry to container table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating container table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
			
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR2(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
			
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
			
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
			
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	
	
	
	
	<cfset error = 0>
	<!--- Add mirrorid entry to container table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating container table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					mirrorID VARCHAR2(50) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR2(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					mirrorID VARCHAR(50) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					mirrorID VARCHAR(50) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					mirrorID VARCHAR(50) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					displayMethod VARCHAR(50) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	
	
	<cfset error = 0>
	<!--- Add bShared entry to container table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating container table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					bShared NUMBER(1) DEFAULT '0' NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					bShared INT NULL DEFAULT '0'
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					bShared INT NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container 
					ALTER COLUMN bShared SET DEFAULT '0'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#container ADD
					bShared int NULL DEFAULT '0'
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	
	
	<cfif application.dbtype eq "postgresql">
		<!--- update permission sequence for postgresql installs --->
		<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating permission sequence...</cfoutput><cfflush>
		<cfquery name="update" datasource="#application.dsn#">
			SELECT setval('#application.dbowner#dmPermission_PermissionId_seq', 500);
		</cfquery>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>
	
	<!--- sets root category alias --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Setting root category alias...</cfoutput><cfflush>
	
	<!--- get root category node --->
	<cfquery name="qRoot" datasource="#application.dsn#">
			SELECT objectID
			FROM nested_tree_objects
			WHERE nlevel = 0 AND lower(typename) = 'categories'
		</cfquery>
		
	<cfquery datasource="#application.dsn#" name="qUpdate">
		insert into #application.dbowner#categories
		(categoryid,alias,categorylabel)
		values 
		('#qRoot.objectid#','root' ,'root')
	</cfquery>

	<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	
	<cfset error = 0>
	<!--- Add new 'mediaType' column to dmCSS --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding new 'mediaType' column to dmCSS...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					mediaType VARCHAR2(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					mediaType VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					mediaType VARCHAR(50) NULL
				</cfquery>
			</cfcase>			
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					mediaType VARCHAR(50) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	

	<cfset error = 0>
	<!--- Add new 'bThisNodeOnly' column to dmCSS --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding new 'bThisNodeOnly' column to dmCSS...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					bThisNodeOnly NUMBER(1) DEFAULT '0' NOT NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					bThisNodeOnly INT NOT NULL default 0
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					bThisNodeOnly INT
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS 
					ALTER COLUMN bThisNodeOnly SET DEFAULT '0'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner#dmCSS 
					SET bThisNodeOnly = '0'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS 
					ALTER COLUMN bThisNodeOnly SET NOT NULL
				</cfquery>
			</cfcase>			
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmCSS ADD
					bThisNodeOnly INT NOT NULL default(0)
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	

	<cfset error = 0>
	<!--- Removes orphaned container ids form refContainers table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Removing orphaned containers from refContainers table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mysql,mysql5">
				<cfquery name="qGet" datasource="#application.dsn#">
					select * 
					from #application.dbowner#refContainers
				</cfquery>
				<cfloop query="qGet">
					<cfquery name="qCheck" datasource="#application.dsn#">
						SELECT objectID 
						FROM #application.dbowner#container
						where objectID = '#qGet.containerid#'
					</cfquery>
					<cfif qCheck.recordCount eq 0>
						<cfquery name="update_refContainers" datasource="#application.dsn#">
							DELETE from #application.dbowner#refContainers
							WHERE containerid = '#qGet.containerId#'
						</cfquery>
					</cfif>
				</cfloop>				
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update_refContainers" datasource="#application.dsn#">
					DELETE from #application.dbowner#refContainers
					WHERE containerid NOT IN (SELECT objectID FROM #application.dbowner#container)
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	
	
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Updates general config with locale attribute</li>
		<li type="square">Adds the locale property to dmProfile object</li>
		<li type="square">Adds mirrorId field to the container table</li>
		<li type="square">Adds bShared field to the container table</li>
		<li type="square">Expands HTMLArea config</li>
		<li type="square">Updates permission sequence for PostgeSQL installs</li>
		<li type="square">Sets category alias for root node</li>
		<li type="square">Adds mediaType field to dmCSS table</li>
		<li type="square">Adds bThisNodeOnly field to dmCSS table</li>
		<li type="square">Removes orphaned containers from refContainers table</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b230 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
