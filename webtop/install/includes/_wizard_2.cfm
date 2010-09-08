<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 2 --->
<!--- @@description: Database details --->

<cfset qDBTypes = session.oUI.getDBTypes() />
<cfset lUsesDBOwner = "" />

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
		        <cfloop query="qDBTypes">
					<option value="#qDBTypes.key#" <cfif session.oUI.stConfig.dbType EQ qDBTypes.key> selected="selected"</cfif>>#qDBTypes.label#</option>
					<cfif qDBTypes.usesDBOwner>
						<cfset lUsesDBOwner = listappend(lUsesDBOwner,qDBTypes.key," ") />
					</cfif>
				</cfloop>
			</select>
			<div class="fieldHint">Funnily enough, your choice of database type must reflect the database your datasource is pointing to.</div>
		</div>
		<div class="clear"></div>
		<input type="hidden" name="DBType" value="" />
	</div>
	
	<cfif refindnocase("(^|,)#session.oUI.stConfig.dbType#($|,)",lUsesDBOwner)>
		<cfset ownerDisplay = 'block' />
	<cfelse>
		<cfset ownerDisplay = 'none' />
	</cfif>
    <div class="item #lUsesDBOwner#" id="divDBOwner" style="display:#ownerDisplay#;">
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
		$j(function(){
			$j("##DBType").bind("change",function() {
				if (this.value=="") 
					$j("##divDBOwner").filter(":not(:hidden)").slideUp();
				else {
					$j("##divDBOwner").filter("."+this.value+":hidden").slideDown();
					$j("##divDBOwner").filter(":not(."+this.value+"):not(:hidden)").slideUp();
				}
			});
		});
	</script>	
</cfoutput>

<cfsetting enablecfoutputonly="false" />