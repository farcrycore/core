<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 2 --->
<!--- @@description: Database details --->

<cfoutput>
	<h1>Database Configuration</h1>
	<div class="item">
      	<label for="DSN">Project Datasource (DSN) <em>*</em></label>
		<div class="field">
			<input type="text" id="DSN" name="DSN" value="#session.oUI.stConfig.DSN#" />
			<div class="fieldHint">You must type in the name of a valid datasource, preconfigured in the ColdFusion Administrator.  The database must be empty otherwise the installer will not proceed.</div>
		</div>
		<div class="clear"></div>
	</div>
	
  	<div class="item">
      	<label for="DBType">Database Type <em>*</em></label>
		<div class="field">
			<!--- TODO: should the database name/key be in a conifg file or something? --->
	      	<select name="DBType" id="DBType" class="selectOne">
		        <option value="">-- Select --</option>
		        <option value="mssql" <cfif session.oUI.stConfig.dbType EQ "mssql"> selected="selected"</cfif>>Microsoft SQL Server</option>
		        <option value="ora" <cfif session.oUI.stConfig.dbType EQ "ora"> selected="selected"</cfif>>Oracle</option>
		        <option value="mysql" <cfif session.oUI.stConfig.dbType EQ "mysql"> selected="selected"</cfif>>MySQL</option>
		        <option value="postgresql" <cfif session.oUI.stConfig.dbType EQ "postgresql"> selected="selected"</cfif>>PostgreSQL</option>
				<!--- <option value="HSQLDB" <cfif session.oUI.stConfig.dbType EQ "HSQLDB"> selected="selected"</cfif>>HSQLDB</option> --->
			</select>
			<div class="fieldHint">Funnily enough, your choice of database type must reflect the database your datasource is pointing to.</div>
		</div>
		<div class="clear"></div>
		<input type="hidden" name="DBType" value="" />
	</div>
	
	<cfif session.oUI.stConfig.dbType EQ "mssql" OR session.oUI.stConfig.dbType EQ "ora">
		<cfset ownerDisplay = 'block' />
	<cfelse>
		<cfset ownerDisplay = 'none' />
	</cfif>
    <div class="item" id="divDBOwner" style="display:#ownerDisplay#;">
      	<label for="DBOwner">Database Owner</label>
		<div class="field">
			<input type="text" id="DBOwner" name="DBOwner" value="#session.oUI.stConfig.DBOwner#" />
		</div>
		<div class="clear"></div>
	</div>
	<input type="hidden" name="DBOwner" value="" /><!--- Think makes sure that at the very least, an empty string is set for dbowner --->
	</cfoutput>
	
	<cfoutput>
	<script type="text/javascript">
		Ext.onReady(function(){	
			var field = Ext.get('DBType');
			field.on('change', checkDBType);
			
		});
		<cfif session.oUI.stConfig.dbType EQ "mssql" OR session.oUI.stConfig.dbType EQ "ora">
			var showingOwner = true;
		<cfelse>
			var showingOwner = false;
		</cfif>
				
		
		
		function checkDBType() {
			
			
			//if(this.dom.value == "postgresql" || this.dom.value == "mysql" || this.dom.value == "")
			if(this.dom.value != "ora" && this.dom.value != "mssql")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = '';		
				
				if (showingOwner) {	
					var el = Ext.get('divDBOwner');	
				
					el.ghost('b', {
					    easing: 'easeOut',
					    duration: .5,
					    remove: false,
					    useDisplay: true
					});
					
					showingOwner = false;
				}
					
			}
			else if (this.dom.value == "ora")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = 'username.';		
				
				
				var el = Ext.get('divDBOwner');	
			
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
				
				showingOwner = true;
				
			}
			else 
			{		
				
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = 'dbo.';		
				
			
				var el = Ext.get('divDBOwner');	
			
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
				
				showingOwner = true;
				
			}
		}
	</script>	
</cfoutput>

<cfsetting enablecfoutputonly="false" />