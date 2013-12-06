

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!--- 
ENVIRONMENT VARIABLES
 --->
<cfset permissions = application.security.factory.permission.getAllPermissions('dmNavigation') />


<cfparam name="form.selectPermission" default="#application.security.factory.permission.getID(name='view')#">
<cfparam name="request.stSitePermissions['#form.selectPermission#']" default="#structNew()#" />




<!--- 
Webtop, Section, SubSection, Menu, MenuItem
 --->
<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />
<skin:loadCSS id="fc-fontawesome" />

<skin:onReady><cfoutput>
	$j('##siteTree .permButton').click(function() {
		var el = $j(this);
		var barnacleValue = $j(this).siblings( '.barnacleValue' ).val();
		var inheritBarnacleValue = $j(this).siblings( '.inheritBarnacleValue' ).val();
		
		// Different rules for first item in tree. Can Not Inherit.
		if (  $j(this).parents( 'div,li' ).children( '.permButton' ).length == 1 ) {
			if(barnacleValue == 1) {
				$j(this).siblings( '.barnacleValue' ).val(-1);
				$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				$j(this).removeClass('inherit');
			} else {
				$j(this).siblings( '.barnacleValue' ).val(1);
				$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				$j(this).removeClass('inherit');
			}
			
		} else {
			if(barnacleValue == 1 || barnacleValue == -1) {
				$j(this).siblings( '.barnacleValue' ).val(0);
				$j(this).removeClass('permission-explicit').addClass('permission-inherit');
				
				if(inheritBarnacleValue == -1) {
					$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				} else {
					$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				};
			}
			else{
				$j(this).removeClass('permission-inherit').addClass('permission-explicit');
				
				if(inheritBarnacleValue == 1) {
					$j(this).siblings( '.barnacleValue' ).val(-1);
					$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				} else {
					$j(this).siblings( '.barnacleValue' ).val(1);
					$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
					
				};
			};
		}
		
		$fc.fixDescendants(el,true);
	});
			
		
	$j("##siteTree input.barnacleValue[value='1'],##siteTree input.barnacleValue[value='-1']").each(function (i) {
		$j(this).parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##siteTree").treeview({
		animated: "fast",
		collapsed: true
	});
	
</cfoutput></skin:onReady>

<skin:htmlHead><cfoutput>
	<style type="text/css">
		##siteTree a.permission-explicit:hover, ##siteTree a.permission-inherit:hover { text-decoration:none; }
		##siteTree a.permission-explicit .fa-check-circle { color:##006600; }
		##siteTree a.permission-inherit .fa-check-circle { color:##8bd68b; }
		##siteTree a.permission-explicit .fa-times-circle { color:##FF0000; }
		##siteTree a.permission-inherit .fa-times-circle { color:##FF8080; }
		##siteTree a.permButton, ##siteTree a.permButton:hover, ##bAllowAccess, ##bAllowAccess:hover { cursor:pointer; text-decoration:none;font-size:14px;}
		##bAllowAccess .fa-check-circle { color:##006600; }
		##bAllowAccess .fa-times-circle { color:##FF0000; }
		##siteTree .fa { position:relative; font-size: 16px; line-height: 14px; top: -2px; }
		##siteTree .nodelabel { font-size: 13px; line-height: 14px; color: inherit; }
	</style>
</cfoutput></skin:htmlHead>


<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>

<cfset qNode = o.getNode(objectid="#application.navID['root']#")>


<cfoutput>
<div style="float:left; width:100%;">
</cfoutput>

<ft:field label="Permission to Manage">
	<cfoutput>
		<select id="selectPermission" name="selectPermission">
			<cfloop list="#permissions#" index="iPermission">
				<option value="#iPermission#" <cfif iPermission EQ form.selectPermission>selected="selected"</cfif>>#application.security.factory.permission.getLabel(iPermission)#</option>
			</cfloop>
		</select>
		<input type="hidden" name="permissionID" value="#form.selectPermission#">
	</cfoutput>
</ft:field>

<skin:onReady><cfoutput>
	$j('##selectPermission').change(function() {
		btnSubmit( $j(this).closest('form').attr('id') ,'Change Site Permission');
	});
</cfoutput></skin:onReady>

<cfquery datasource="#application.dsn#" name="qNav">
	SELECT 		ntm.objectID, ntm.objectname, ntm.nleft, ntm.nright, ntm.nLevel, barnacle.barnacleValue, barnacle.roleid, barnacle.permissionID
	FROM 		nested_tree_objects as ntm
				LEFT OUTER JOIN (
					SELECT 	farBarnacle.referenceID, farBarnacle.barnacleValue, farBarnacle.roleid, farBarnacle.permissionID
					FROM 	farBarnacle
					WHERE 	objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="dmNavigation">
							AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
							AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
				) barnacle ON ntm.objectid = barnacle.referenceid
	WHERE 		ntm.nleft	>= <cfqueryparam cfsqltype="cf_sql_integer" value="#qNode.nLeft#">
				AND ntm.nleft < <cfqueryparam cfsqltype="cf_sql_integer" value="#qNode.nRight#">
				AND ntm.typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="dmNavigation">
	ORDER BY 	ntm.nleft
</cfquery>


<cfset currentlevel= 0 />
<cfset ul= 0 />
<cfset bHomeFirst = false /> <!--- // used to stop the first node being flagged as first if home link is inserted. --->
<cfset bFirstNodeInLevel = true /> <!--- // used to track the first node in each level.	 --->			

<cfset bHighlightFirst= true />
<cfset bIncludeSpan= true />

<cfset stParentPermissions = structNew() />

<cfset stCurrentPermissionSet = request.stSitePermissions['#form.selectPermission#']>


<ft:field label="Site Tree" bMultiField="true">
	<cfloop query="qNav">
		<cfset previousLevel= currentlevel />
		<cfset currentlevel=qNav.nLevel />
		<cfset itemclass = "">
		
		<cfif structKeyExists(stCurrentPermissionSet, qNav.objectid)>
			<cfset currentBarnacleValue = stCurrentPermissionSet[qNav.objectid] >
		<cfelse>
			<cfset currentBarnacleValue = numberFormat(qNav.barnacleValue) />
		</cfif>
		
		<cfif previouslevel eq 0>
			<cfoutput><ul id="siteTree"></cfoutput>
			
			<cfset ul = ul + 1 >
			
		<cfelseif currentlevel gt previouslevel>
			<!--- // if new level, open new list --->
			<cfoutput><ul></cfoutput>
				
			<cfset ul = ul + 1 >
			<cfset bFirstNodeInLevel = true />
		<cfelseif currentlevel lt previouslevel>
			<!--- // if end of level, close current item --->
			<cfoutput></li></cfoutput>
			<!--- // close lists until at correct level --->
			<cfoutput>#repeatString("</ul></li>",previousLevel-currentLevel)#</cfoutput>
			<cfset ul = ul - ( previousLevel - currentLevel ) />
		<cfelse>
			<!--- // close item --->
			<cfoutput></li></cfoutput>
		</cfif>
		 
		<cfif currentBarnacleValue NEQ "">
			<cfset stParentPermissions[ul] = currentBarnacleValue >
		</cfif>
		
		<cfloop from="#ul+1#" to="20" index="i">
			<cfset structDelete( stParentPermissions , i )>
		</cfloop>
		
		<cfset inheritBarnacleValue = -1 /><!--- default permission --->
		<cfloop from="#ul-1#" to="0" step="-1" index="i">
			<cfif structKeyExists(stParentPermissions, i) AND stParentPermissions[i] NEQ 0>
				<cfset inheritBarnacleValue = stParentPermissions[i]>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- The First Node in the tree will always be DISALLOW if nothing explicitly set --->
		<cfif qNav.currentRow EQ 1 AND currentBarnacleValue EQ 0>
			<cfset currentBarnacleValue = -1>
		</cfif>
		
		<!--- // open a list item --->
		
		
		<cfset value = 0>
		<cfset priority = "permission-inherit">
		<cfset icon = "fa-times-circle">
		<cfset bChecked = false>
		
	
		<cfif currentBarnacleValue EQ 1>
			<cfset bChecked = true>
			<cfset value = 1>
			<cfset priority = "permission-explicit">
			<cfset icon = "fa-check-circle">
		<cfelseif currentBarnacleValue EQ -1>
			<cfset bChecked = false>
			<cfset value = -1>
			<cfset priority = "permission-explicit">
			<cfset icon = "fa-times-circle">
		<cfelse>
			<cfif inheritBarnacleValue EQ 1>
				<cfset bChecked = true>
				<cfset priority = "permission-inherit">
				<cfset icon = "fa-check-circle">
			<cfelse>
				<cfset priority = "permission-inherit">
				<cfset icon = "fa-times-circle">
			</cfif>
			
			<cfset value = 0>
		</cfif>
		
		<cfoutput>
			<li <cfif value EQ 0>class="closed"</cfif>>	
				<a id="node-#qNav.objectid#" class="permButton barnacleBox #priority#"><i class="fa #icon# fa-fw"></i></a>
				<input type="hidden" class="barnacleValue" id="barnacleValue-#qNav.objectid#" name="barnacleValue-#qNav.objectid#" value="#value#" style="width:10px;">
				<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#qNav.objectid#" value="#inheritBarnacleValue#" style="width:10px;">
				<span class="nodelabel">#trim(qNav.ObjectName)#</span>
		</cfoutput>
	</cfloop>
	
	<cfoutput>
		#repeatString("</li></ul>",ul)#
		<input type="hidden" name="sitePermissionsSubmitted" value="true">
	</cfoutput>
</ft:field>

<cfoutput>
</div>
</cfoutput>
