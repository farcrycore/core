

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
<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />



<skin:htmlHead>
<cfoutput>
<style type="text/css">
.inherit {opacity:0.4;}

.ui-button.small.barnacleBox {
	width: 16px;
	height: 16px;
	float:left;
	margin:0px;
}

.ui-button.small.barnacleBox .ui-icon {
	margin-top: -8px;
	margin-left: -8px;
}
</style>
</cfoutput>
</skin:htmlHead>




<!--- 
FORM
 --->

<ft:form>
	


			<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>
			
			<cfset qNode = o.getNode(objectid="#application.navID['root']#")>
			<!--- <cfset qNav = o.getDescendants(objectid=application.navID['root'], bIncludeSelf="true") /> --->
			
			
				<cfoutput>
				
				<select id="selectPermission" name="selectPermission">
					<cfloop list="#permissions#" index="iPermission">
						<option value="#iPermission#" <cfif iPermission EQ form.selectPermission>selected="selected"</cfif>>#application.security.factory.permission.getLabel(iPermission)#</option>
					</cfloop>
				</select>
				Select Permission to Manage: 
				</cfoutput>
			
			
			<cfoutput>
			
			<input type="hidden" name="permissionID" value="#form.selectPermission#">
			</cfoutput>
			<skin:onReady>
				<cfoutput>
				$j('##selectPermission').change(function() {
					btnSubmit( $j(this).closest('form').attr('id') ,'Change Site Permission');
				});
				</cfoutput>
			</skin:onReady>
			<cfquery datasource="#application.dsn#" name="qNav">
			SELECT ntm.objectID, ntm.objectname, ntm.nleft, ntm.nright, ntm.nLevel, barnacle.barnacleValue, barnacle.roleid, barnacle.permissionID
			FROM nested_tree_objects as ntm
			LEFT OUTER JOIN (
				SELECT farBarnacle.referenceID, farBarnacle.barnacleValue, farBarnacle.roleid, farBarnacle.permissionID
				FROM farBarnacle
				WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="dmNavigation">
				AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
				AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
			) barnacle ON ntm.objectid = barnacle.referenceid
			WHERE ntm.nleft	>= <cfqueryparam cfsqltype="cf_sql_integer" value="#qNode.nLeft#">
			AND ntm.nleft < <cfqueryparam cfsqltype="cf_sql_integer" value="#qNode.nRight#">
			AND ntm.typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="dmNavigation">
			ORDER BY ntm.nleft
			</cfquery>


			<cfset currentlevel= 0 />
			<cfset ul= 0 />
			<cfset bHomeFirst = false /> <!--- // used to stop the first node being flagged as first if home link is inserted. --->
			<cfset bFirstNodeInLevel = true /> <!--- // used to track the first node in each level.	 --->			
			
			<cfset bHighlightFirst= true />
			<cfset bIncludeSpan= true />
			
			<cfset stParentPermissions = structNew() />
			
			<cfset stCurrentPermissionSet = request.stSitePermissions['#form.selectPermission#']>
			
			<cfoutput>
				
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
					<ul id="siteTree">
					
					<cfset ul = ul + 1 >
					
				<cfelseif currentlevel gt previouslevel>
					<!--- // if new level, open new list --->
					<ul>
						
					<cfset ul = ul + 1 >
					<cfset bFirstNodeInLevel = true />
				<cfelseif currentlevel lt previouslevel>
					<!--- // if end of level, close current item --->
					</li>
					<!--- // close lists until at correct level --->
					#repeatString("</ul></li>",previousLevel-currentLevel)#
					<cfset ul = ul - ( previousLevel - currentLevel ) />
				<cfelse>
					<!--- // close item --->
					</li>
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
				
					
				<cfset class = "">
				<cfset value = 0>
				<cfset priority = "secondary">
				<cfset icon = "ui-icon-close">
				<cfset bChecked = false>
				
			
				<cfif currentBarnacleValue EQ 1>
					<cfset bChecked = true>
					<cfset value = 1>
					<cfset priority = "primary">
					<cfset icon = "ui-icon-check">
				<cfelseif currentBarnacleValue EQ -1>
					<cfset bChecked = false>
					<cfset value = -1>
					<cfset priority = "secondary">
					<cfset icon = "ui-icon-close">
				<cfelse>
					<cfif inheritBarnacleValue EQ 1>
						<cfset bChecked = true>
						<cfset priority = "primary">
						<cfset icon = "ui-icon-check">
					<cfelse>
						<cfset priority = "secondary">
						<cfset icon = "ui-icon-close">
					</cfif>
					
					<cfset value = 0>
					<cfset class="inherit" />
				</cfif>
				
				<li <cfif value EQ 0>class="closed"</cfif>>	
				
					<ft:button 
						value="perm" 
						text="" 
						priority="#priority#" 
						icon="#icon#" 
						type="button" 
						class="permButton small barnacleBox #class#"
						onclick="" />
					
					<input type="hidden" class="barnacleValue" id="barnacleValue-#qNav.objectid#" name="barnacleValue-#qNav.objectid#" value="#value#" style="width:10px;">
					<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#qNav.objectid#" value="#inheritBarnacleValue#" style="width:10px;">
				
					<span style="font-size:10px;">
						&nbsp;#trim(qNav.ObjectName)#
					</span>
				
				<!--- <br style="clear:both;" />	 --->
			</cfloop>
			
			#repeatString("</li></ul>",ul)#
			</cfoutput>
	
			<cfoutput>
			<input type="hidden" name="sitePermissionsSubmitted" value="true">
			</cfoutput>
	
</ft:form>	



<skin:onReady>
<cfoutput>
	
	$fc.fixDescendants = function(elParent) {
		
		// loop over all descendants of clicked item and if they are inheriting, adjust inherited value if required
		$j(elParent).closest( 'div,li' ).find( '.permButton' ).each(function (i) {
			
			elDescendant = $j(this);
			var descendantValue = $j(elDescendant).siblings( '.barnacleValue' ).val();
			
			if( $j(elDescendant).attr('id') != $j(elParent).attr('id')) {
				
				$j(this).parents( 'div,li' ).children( '.permButton' ).each(function (i) {
				
					var elDescendantParent = $j(this);
					
					if( $j(elDescendantParent).attr('id') != $j(elDescendant).attr('id')) {
						
						var descendantParentValue = $j(elDescendantParent).siblings( '.barnacleValue' ).val();
						
						
						if (descendantParentValue == 1) {
							$j(elDescendant).siblings( '.inheritBarnacleValue' ).val(1);
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
								$j(elDescendant).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
								
							}
							return false;
						};
						if (descendantParentValue == -1) {
							
							$j(elDescendant).siblings( '.inheritBarnacleValue' ).val(-1);
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
								$j(elDescendant).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
								
							}
							return false;
						};
					};
				});
			};
		});				
	};
	
	$j('.permButton').click(function() {
		var el = $j(this);
		var barnacleValue = $j(this).siblings( '.barnacleValue' ).val();
		var inheritBarnacleValue = $j(this).siblings( '.inheritBarnacleValue' ).val();
		
		// Different rules for first item in tree. Can Not Inherit.
		if (  $j(this).parents( 'div,li' ).children( '.permButton' ).length == 1 ) {
			if(barnacleValue == 1) {
				$j(this).siblings( '.barnacleValue' ).val(-1);
				$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
				$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
				$j(this).removeClass('inherit');
			} else {
				$j(this).siblings( '.barnacleValue' ).val(1);
				$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
				$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
				$j(this).removeClass('inherit');
			}
			
		} else {
		
			if(barnacleValue == 1) {
				if(inheritBarnacleValue == -1) {
					$j(this).siblings( '.barnacleValue' ).val(0);
					$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
					$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
					$j(this).addClass('inherit');
				} else {
					$j(this).siblings( '.barnacleValue' ).val(0);
					$j(this).removeClass('ui-priority-primarysecondary').addClass('ui-priority-primary');
					$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
					$j(this).addClass('inherit');
				};
			};
			
			if(barnacleValue == -1) {
				if(inheritBarnacleValue == 1) {
					$j(this).siblings( '.barnacleValue' ).val(0);
					$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
					$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
					$j(this).addClass('inherit');
				} else {
					$j(this).siblings( '.barnacleValue' ).val(1);
					$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
					$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');

					
												
				};
			};
			
			if(barnacleValue == 0) {
				if(inheritBarnacleValue == 1) {
					
					$j(this).siblings( '.barnacleValue' ).val(-1);
					$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
					$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
				} else {
					$j(this).siblings( '.barnacleValue' ).val(1);
					$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
					$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
					
				};
				$j(this).removeClass('inherit');
			};
		}
		
		$fc.fixDescendants(el);
	});
			
		
	$j("##siteTree input.barnacleValue[value='1'],##siteTree input.barnacleValue[value='-1']").each(function (i) {
		$j(this).parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##siteTree").treeview({
		animated: "fast",
		collapsed: true
	});
	
</cfoutput>
</skin:onReady>

				