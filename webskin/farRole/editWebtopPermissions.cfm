
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!--- 
ENVIRONMENT VARIABLES
 --->
<cfset form.selectPermission = application.security.factory.permission.getID(name="viewWebtopItem") />

<cfparam name="request.stWebtopPermissions['#form.selectPermission#']" default="#structNew()#" />


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />

<skin:htmlHead><cfoutput>
	<style type="text/css">
		##webtopTree a.permission-explicit:hover, ##webtopTree a.permission-inherit:hover { text-decoration:none; }
		##webtopTree a.permission-explicit .fa-check-circle { color:##006600; }
		##webtopTree a.permission-inherit .fa-check-circle { color:##8bd68b; }
		##webtopTree a.permission-explicit .fa-times-circle { color:##FF0000; }
		##webtopTree a.permission-inherit .fa-times-circle { color:##FF8080; }
		##webtopTree a.permButton, ##webtopTree a.permButton:hover, ##bAllowAccess, ##bAllowAccess:hover { cursor:pointer; text-decoration:none;font-size:14px;}
		##bAllowAccess .fa-check-circle { color:##006600; }
		##bAllowAccess .fa-times-circle { color:##FF0000; }
		##bAllowAccess .fa { font-size: 16px; margin-top: 5px;}
		##webtopTree .fa { position:relative; font-size: 16px; line-height: 14px; top: -2px; }
		##webtopTree .nodelabel { font-size: 13px; line-height: 14px; color: inherit; }
	</style>
</cfoutput></skin:htmlHead>

		
<!--- WEBTOP PERMISSIONS --->
<cfset stCurrentPermissionSet = request.stWebtopPermissions['#form.selectPermission#']>

<!--- individual mode: the role sees only items with an explicit allow; any other stored value is inherit --->
<cfset visibilityMode = "inherit">
<cfif structKeyExists(stobj, "webtopVisibilityMode") AND stobj.webtopVisibilityMode EQ "individual">
	<cfset visibilityMode = "individual">
</cfif>
<cfset bIndividualMode = (visibilityMode EQ "individual")>



<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />
<cfset barnacleID = hash(stWebtop.rbKey)>

<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT 	farBarnacle.referenceID, farBarnacle.barnacleValue, farBarnacle.roleid, farBarnacle.permissionID
	FROM 	farBarnacle
	WHERE 	objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
			AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
			AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
</cfquery>

<cfoutput>
<div style="float:left; width:100%">
</cfoutput>

<ft:field label="Webtop Access">
	<cfset accessPermissionID = application.fapi.getContentType("farPermission").getID('admin')>
	<cfif application.fapi.arrayFind(stobj.aPermissions, accessPermissionID)>
		<cfset allowAccess = 1>
	<cfelse>
		<cfset allowAccess = -1>
	</cfif>
	
	<cfif allowAccess EQ 1>
		<cfset icon = "fa-check-circle">
	<cfelse>
		<cfset icon = "fa-times-circle">
	</cfif>
	
	<cfoutput><a id="bAllowAccess" class="permButton" value="#allowAccess#" ftpermissionid="#accessPermissionID#" ftbarnaclevalue="#numberformat(allowAccess)#"><i class="fa #icon# fa-fw"></i></a></cfoutput>
	
	<ft:fieldHint><cfoutput>Should this role be allowed to access the webtop?</cfoutput></ft:fieldHint>
</ft:field>

<ft:field label="Visibility inheritance">
	<cfoutput>
	<label class="radio inline"><input type="radio" name="webtopVisibilityMode" value="inherit"<cfif visibilityMode EQ "inherit"> checked="checked"</cfif> /> Inherit from parent</label>
	<label class="radio inline"><input type="radio" name="webtopVisibilityMode" value="individual"<cfif visibilityMode EQ "individual"> checked="checked"</cfif> /> Allow each page individually</label>
	</cfoutput>
	<ft:fieldHint><cfoutput>Inherit from parent: a page is shown unless it, or a menu above it, is denied. Allow each page individually: a page is shown only if it is allowed, and pages added later stay hidden until you allow them.</cfoutput></ft:fieldHint>
</ft:field>

<ft:field label="Access Permissions" bMultiField="true">
	<cfoutput>
	<div id="webtopTreeWrap" <cfif allowAccess EQ -1>style="display:none;"</cfif>>
		<input type="hidden" name="permissionID" value="#encodeForHTMLAttribute(form.selectPermission)#" />
		<p id="webtopVisibilityLegend" class="webtop-visibility-legend<cfif visibilityMode NEQ "individual"> is-hidden</cfif>">This role sees only the pages you allow.</p>
		<ul id="webtopTree" data-mode="#visibilityMode#">
			<li>
	</cfoutput>
	
	<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
		<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
	<cfelse>
		<cfquery dbtype="query" name="qNodeBarnacle">
		SELECT *
		FROM qBarnacles
		WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
		</cfquery>
		
		<cfif qNodeBarnacle.recordCount>
			<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
		<cfelse>
			<cfset currentBarnacleValue = -1 />
		</cfif>
	</cfif>
	
	<cfset currentWebtopValue = currentBarnacleValue />
	
	<!--- individual mode: nothing inherits, so sections see a denied parent; the root icon stays explicitly allowed --->
	<cfif bIndividualMode>
		<cfset currentWebtopValue = -1 />
	</cfif>

	<!--- We always have webtop permission as checked --->
	<cfoutput>
		<a id="webtopRoot" class="permButton permission-explicit" onClick="alert('Use the webtop access permission above to turn off access to the webtop.');return false;"><i class="fa fa-check-circle fa-fw"></i></a>
		<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="1">
		<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="1">
		<span class="nodelabel">Webtop</span>
	</cfoutput>
	
	
	<cfif listLen(stWebtop.CHILDORDER)>
		<cfoutput><ul></cfoutput>
	</cfif>
	
	<cfloop list="#stWebtop.CHILDORDER#" index="i">
		
		<cfset stLevel1 = stWebtop.children[i] />
		<cfset barnacleID = hash(stLevel1.rbKey)>
		
		<cfoutput><li class="closed"></cfoutput>
		
		<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
			<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
		<cfelse>
			<cfquery dbtype="query" name="qNodeBarnacle">
			SELECT *
			FROM qBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
			</cfquery>
			
			<cfif qNodeBarnacle.recordCount>
				<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
			<cfelse>
				<cfset currentBarnacleValue = 0 />
			</cfif>
		</cfif>
		
		<cfif bIndividualMode>
			<!--- icon from this item's own record; children never inherit --->
			<cfset priority = (currentBarnacleValue EQ 1) ? "permission-explicit" : "permission-inherit" />
			<cfset currentSectionValue = -1 />
		<cfelseif currentBarnacleValue eq 0>
			<cfset priority = "permission-inherit">
			<cfset currentSectionValue = currentWebtopValue />
		<cfelse>
			<cfset priority = "permission-explicit">
			<cfset currentSectionValue = currentBarnacleValue />
		</cfif>
		
		<cfif bIndividualMode>
			<cfset icon = (currentBarnacleValue EQ 1) ? "fa-check-circle" : "fa-times-circle" />
		<cfelseif currentSectionValue EQ 1>
			<cfset icon = "fa-check-circle">
		<cfelseif currentSectionValue EQ -1>
			<cfset icon = "fa-times-circle">
		</cfif>
		
		<cfoutput>
			<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
			<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
			<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentWebtopValue#">
			<span class="nodelabel">#stLevel1.label#</span>
		</cfoutput>
		
		
		<cfif listLen(stLevel1.CHILDORDER)>
			<cfoutput><ul></cfoutput>
			
			<cfloop list="#stLevel1.CHILDORDER#" index="j">
			
				<cfset stLevel2 = stLevel1.children[j] />
				<cfset barnacleID = hash(stLevel2.rbKey)>
			
				<cfoutput><li></cfoutput>
					
				<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
					<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
				<cfelse>
					<cfquery dbtype="query" name="qNodeBarnacle">
					SELECT *
					FROM qBarnacles
					WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
					</cfquery>
					
					<cfif qNodeBarnacle.recordCount>
						<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
					<cfelse>
						<cfset currentBarnacleValue = 0 />
					</cfif>
				</cfif>
				
				<cfif bIndividualMode>
					<cfset priority = (currentBarnacleValue EQ 1) ? "permission-explicit" : "permission-inherit" />
					<cfset currentSubsectionValue = -1 />
				<cfelseif currentBarnacleValue eq 0>
					<cfset priority = "permission-inherit">
					<cfset currentSubsectionValue = currentSectionValue />
				<cfelse>
					<cfset priority = "permission-explicit">
					<cfset currentSubsectionValue = currentBarnacleValue />
				</cfif>
				
				<cfif bIndividualMode>
					<cfset icon = (currentBarnacleValue EQ 1) ? "fa-check-circle" : "fa-times-circle" />
				<cfelseif currentSubsectionValue EQ 1>
					<cfset icon = "fa-check-circle">
				<cfelseif currentSubsectionValue EQ -1>
					<cfset icon = "fa-times-circle">
				</cfif>
				
				<cfoutput>
					<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
					<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
					<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentSectionValue#">
					<span class="nodelabel">#stLevel2.label#</span>
				</cfoutput>
				
				
				<cfif listLen(stLevel2.CHILDORDER)>
					<cfoutput><ul></cfoutput>
					
					<cfloop list="#stLevel2.CHILDORDER#" index="k">
					
						<cfset stLevel3 = stLevel2.children[k] />
						<cfset barnacleID = hash(stLevel3.rbKey)>
						
						<cfoutput><li></cfoutput>
						
						<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
							<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
						<cfelse>
							<cfquery dbtype="query" name="qNodeBarnacle">
							SELECT *
							FROM qBarnacles
							WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
							</cfquery>
							
							<cfif qNodeBarnacle.recordCount>
								<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
							<cfelse>
								<cfset currentBarnacleValue = 0 />
							</cfif>
						</cfif>
						
						<cfif bIndividualMode>
							<cfset priority = (currentBarnacleValue EQ 1) ? "permission-explicit" : "permission-inherit" />
							<cfset currentMenuValue = -1 />
						<cfelseif currentBarnacleValue eq 0>
							<cfset priority = "permission-inherit">
							<cfset currentMenuValue = currentSubsectionValue />
						<cfelse>
							<cfset priority = "permission-explicit">
							<cfset currentMenuValue = currentBarnacleValue />
						</cfif>
						
						<cfif bIndividualMode>
							<cfset icon = (currentBarnacleValue EQ 1) ? "fa-check-circle" : "fa-times-circle" />
						<cfelseif currentMenuValue EQ 1>
							<cfset icon = "fa-check-circle">
						<cfelseif currentMenuValue EQ -1>
							<cfset icon = "fa-times-circle">
						</cfif>
						
						<cfoutput>
							<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
							<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
							<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentSubsectionValue#" />
							<span class="nodelabel">#stLevel3.label#</span>
						</cfoutput>
						
						<cfif listLen(stLevel3.CHILDORDER)>
							<cfoutput><ul></cfoutput>
							
							<cfloop list="#stLevel3.CHILDORDER#" index="l">
							
								<cfset stLevel4 = stLevel3.children[l] />
								<cfset barnacleID = hash(stLevel4.rbKey)>
								
								
								<cfoutput><li></cfoutput>
									

								<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
									<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
								<cfelse>
									<cfquery dbtype="query" name="qNodeBarnacle">
									SELECT *
									FROM qBarnacles
									WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
									</cfquery>
									
									<cfif qNodeBarnacle.recordCount>
										<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
									<cfelse>
										<cfset currentBarnacleValue = 0 />
									</cfif>
								</cfif>
								
								<cfif bIndividualMode>
									<cfset priority = (currentBarnacleValue EQ 1) ? "permission-explicit" : "permission-inherit" />
									<cfset currentMenuItemValue = -1 />
								<cfelseif currentBarnacleValue eq 0>
									<cfset priority = "permission-inherit">
									<cfset currentMenuItemValue = currentMenuValue />
								<cfelse>
									<cfset priority = "permission-explicit">
									<cfset currentMenuItemValue = currentBarnacleValue />
								</cfif>
								
								<cfif bIndividualMode>
									<cfset icon = (currentBarnacleValue EQ 1) ? "fa-check-circle" : "fa-times-circle" />
								<cfelseif currentMenuItemValue EQ 1>
									<cfset icon = "fa-check-circle">
								<cfelseif currentMenuItemValue EQ -1>
									<cfset icon = "fa-times-circle">
								</cfif>
								
								<cfoutput>
										<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
										<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
										<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentMenuValue#">
										<span class="nodelabel">#stLevel4.label#</span>
									</li>
								</cfoutput>
								
							</cfloop>
							
							<cfoutput></ul></cfoutput>
						</cfif>
						
						<cfoutput></li></cfoutput>
						
					</cfloop>
					
					<cfoutput></ul></cfoutput>
				</cfif>
				
				<cfoutput></li></cfoutput>
			
			</cfloop>
			
			<cfoutput></ul></cfoutput>
		</cfif>
		
		<cfoutput></li></cfoutput>
	
	</cfloop>
	
	<cfif listLen(stWebtop.CHILDORDER)>
		<cfoutput></ul></cfoutput>
	</cfif>
	
	<cfoutput>
			</li>
		</ul>
		<input type="hidden" name="webtopPermissionsSubmitted" value="true">
	</div>
	</cfoutput>
</ft:field>

<cfoutput>
</div>
</cfoutput>


<skin:onReady><cfoutput>
	$j('##webtopTree .permButton').click(function() {
		var el = $j(this);
		var barnacleValue = parseInt(el.siblings( '.barnacleValue' ).val());
		var inheritBarnacleValue = parseInt(el.siblings( '.inheritBarnacleValue' ).val());
		var newValue = 0;
		
		if (el.attr('id') == 'webtopRoot'){
			return false;
		}

		if (webtopCurrentMode() === 'individual') {
			webtopIndividualClick(el);
			return false;
		}
		
		if (barnacleValue===0)
			newValue = inheritBarnacleValue===1 ? -1 : 1;
		else
			newValue = 0;
		
		$j(this).siblings(".barnacleValue").val(newValue);
		
		switch( newValue ) {
			case -1:
				el.removeClass("permission-inherit").addClass("permission-explicit")
					.find(".fa-check-circle").removeClass("fa-check-circle").addClass("fa-times-circle");
				break;
			case 0:
				el.removeClass("permission-explicit").addClass("permission-inherit");
				
				if (inheritBarnacleValue===1)
					el.find(".fa-times-circle").removeClass("fa-times-circle").addClass("fa-check-circle");
				else
					el.find(".fa-check-circle").removeClass("fa-check-circle").addClass("fa-times-circle");
				
				break;
			case 1:
				el.removeClass("permission-inherit").addClass("permission-explicit")
					.find(".fa-times-circle").removeClass("fa-times-circle").addClass("fa-check-circle");
				break;
		}
		
		$fc.fixDescendants(el,false);
	});
	
		
	// --- visibility mode helpers (individual vs inherit); function declarations hoist, so the click handler above can call them ---
	function webtopCurrentMode() { return $j('##webtopTree').attr('data-mode'); }
	function webtopIsRoot(li) { return $j(li).children('a.permButton').attr('id') === 'webtopRoot'; }

	// switching mode rewrites each node so its effective visibility (shown or hidden) is preserved in the new mode, and renders it.
	// individual is an allow-list (shown iff own value 1); inherit is a deny-list (shown unless own or an ancestor is -1). walk top down so each node knows if its parent is shown.
	function webtopConvertMode(li, parentShown, fromMode, toMode) {
		$j(li).children('ul').children('li').each(function() {
			var node = $j(this), bv = parseInt(node.children('.barnacleValue').val());
			var shown = parentShown && (fromMode === 'individual' ? (bv === 1) : (bv !== -1));
			var newVal = (toMode === 'individual') ? (shown ? 1 : (bv === -1 ? -1 : 0)) : (shown ? 0 : (parentShown ? -1 : 0));
			node.children('.barnacleValue').val(newVal);
			node.children('.inheritBarnacleValue').val(parentShown ? 1 : -1);
			var a = node.children('a.permButton');
			a.removeClass('permission-inherit permission-explicit');
			a.find('.fa').removeClass('fa-check-circle fa-times-circle');
			if (toMode === 'individual') {
				a.addClass(newVal === 1 ? 'permission-explicit' : 'permission-inherit').find('.fa').addClass(newVal === 1 ? 'fa-check-circle' : 'fa-times-circle');
			} else {
				a.addClass(newVal === -1 ? 'permission-explicit' : 'permission-inherit').find('.fa').addClass(shown ? 'fa-check-circle' : 'fa-times-circle');
			}
			webtopConvertMode(this, shown, fromMode, toMode);
		});
	}

	// set one node's icon from its own stored value: solid green allow when 1, faded red otherwise
	function webtopIndividualIcon(li) {
		var v = parseInt($j(li).children('.barnacleValue').val());
		var a = $j(li).children('a.permButton');
		a.removeClass('permission-inherit permission-explicit').addClass(v === 1 ? 'permission-explicit' : 'permission-inherit');
		a.find('.fa').removeClass('fa-check-circle fa-times-circle').addClass(v === 1 ? 'fa-check-circle' : 'fa-times-circle');
	}

	function webtopRenderIndividual() {
		$j('##webtopTree li').each(function() { if (!webtopIsRoot(this)) webtopIndividualIcon(this); });
	}

	function webtopIndividualClick(el) {
		var li = el.closest('li');
		var v = parseInt(el.siblings('.barnacleValue').val());
		if (v === 1) {
			// removing an allow also removes it from any allowed pages inside, after confirmation
			var allowedDesc = li.find('ul li').filter(function() { return parseInt($j(this).children('.barnacleValue').val()) === 1; });
			if (allowedDesc.length && !confirm('The pages inside this menu will be hidden too. Continue?')) return;
			allowedDesc.each(function() { $j(this).children('.barnacleValue').val(0); webtopIndividualIcon(this); });
			el.siblings('.barnacleValue').val(0);
		} else {
			// allowing a page allows every menu above it, so it can be reached
			el.siblings('.barnacleValue').val(1);
			li.parents('li').each(function() { if (!webtopIsRoot(this)) { $j(this).children('.barnacleValue').val(1); webtopIndividualIcon(this); } });
		}
		webtopIndividualIcon(li);
	}

	// switching the mode radio re-renders the tree in place and records the choice
	$j('input[name=webtopVisibilityMode]').change(function() {
		var mode = $j(this).val();
		var fromMode = webtopCurrentMode();
		$j('##webtopTree').attr('data-mode', mode);

		// rewrite each page's record so its effective visibility is preserved in the new mode; any toggle, including a round-trip, is then non-destructive
		webtopConvertMode($j('##webtopRoot').closest('li'), true, fromMode, mode);

		if (mode === 'individual') {
			$j('##webtopVisibilityLegend').removeClass('is-hidden');
		} else {
			$j('##webtopVisibilityLegend').addClass('is-hidden');
		}

		$j.ajax({
			type: 'POST',
			url: '/index.cfm?ajaxmode=1&type=farRole&objectid=#stobj.objectid#&view=editAjaxSaveVisibilityMode',
			dataType: 'html',
			cache: false,
			timeout: 15000,
			data: { webtopVisibilityMode: mode },
			error: function() { alert('change unsuccessful. The page will be refreshed.'); location = location; }
		});
	});

	// initial tree render depends on the mode: individual renders from each node's own record, inherit cascades as before
	if (webtopCurrentMode() === 'individual') {
		webtopRenderIndividual();
	} else {
		$fc.fixDescendants ( $j('##webtopRoot'), true );
	}
		
	$j("##webtopTree input.barnacleValue[value='1'],##webtopTree input.barnacleValue[value='-1']").each(function (i) {
		$j(this).parent('li').parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##webtopTree").treeview({
		animated: "fast",
		collapsed: true
	});
	
	
	
	$j('##bAllowAccess').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var barnacleValue = $j(this).attr('ftbarnaclevalue');
		
		if(barnacleValue == 1) {
			
			$j(this).attr('ftbarnaclevalue', '-1');
			$j(this).find('i').removeClass('fa-check-circle').addClass('fa-times-circle');
			
			$j('##webtopTreeWrap').hide('fast');
		
		} else {
			
			$j(this).attr('ftbarnaclevalue', '1');
			$j(this).find('i').removeClass('fa-times-circle').addClass('fa-check-circle');
			
			$j('##webtopTreeWrap').show('fast');
		};
		
		$j.ajax({
		   type: "POST",
		   url: '/index.cfm?ajaxmode=1&type=farRole&objectid=#stobj.objectid#&view=editAjaxSaveGenericPermission',
		   dataType: "html",
		   cache: false,
		   context: $j(this),
		   timeout: 15000,
		   data: {
				permissionid: $j(this).attr('ftpermissionid'),
				barnaclevalue: $j(this).attr('ftbarnaclevalue')
			},
		   success: function(msg){
		   		$j(this).find('i').removeClass('icon-caret-right');
		   },
		   error: function(data){	
				alert('change unsuccessful. The page will be refreshed.');
				location=location;
			},
			complete: function(){
				
			}
		 });
		
	});
</cfoutput></skin:onReady>
