
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset setLock(stObj=stObj,locked=true) />


<!--- Always save wizard WDDX data --->
<wiz:processwizard excludeAction="Cancel">

	<!--- Save the Primary wizard Object --->
	<wiz:processwizardObjects typename="#stobj.typename#" />	
		
</wiz:processwizard>

<wiz:processwizard action="Save" Savewizard="true" Exit="true" /><!--- Save wizard Data to Database and remove wizard --->
<wiz:processwizard action="Cancel" Removewizard="true" Exit="true" /><!--- remove wizard --->


<wiz:wizard ReferenceID="#stobj.objectid#">

		
		<!--- 
		Webtop, Section, SubSection, Menu, MenuItem
		 --->
		<skin:loadJS id="jquery" />
		<skin:loadJS id="jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
		

	<skin:onReady>
			<cfoutput>
				$j('.perm').change(function() {
					var el = $j(this);
					if (el.is(':checked')) {
						var permValue = 1;
					} else {
						var permValue = 0;
					};
					
					if(permValue == 1) {
						$j(this).closest( 'div,li' ).find( 'input:checkbox' ).each(function (i) {
							if( $j(this).attr('id') != $j(el).attr('id')) {
								$j(this).attr('checked','checked');
								$j(this).css('opacity', 1);
							}
						});
						
						$j(this).parents( 'div,li' ).children( 'input:checkbox' ).each(function (i) {
							if ( $j(this).not(':checked')) {
								$j(this).attr('checked','checked');
							};
						});
						
						$j(this).parents( 'div,li' ).children( 'input:checkbox' ).each(function (i) {
							
							
							var selectors = $j(this).closest( 'div,li' ).find( 'input:checkbox' ).length;
							var selected = 0;
							$j(this).closest( 'div,li' ).find( 'input:checkbox' ).each(function(index, el) {
								if ( $j(el).is(':checked') ) {
									selected++;
								};
								
							});
							console.log(selected + '==' + selectors);
							if (selected == selectors) {
								$j(this).css('opacity', 1)
							} else if ( selected > 0 ) {
								$j(this).css('opacity', 0.5)
							} else {
								$j(this).css('opacity', 1 )
							}
							
							
						});
						
					};
					if(permValue == 0) {
						$j(this).closest( 'div,li' ).find( 'input:checkbox' ).each(function (i) {
							if( $j(this).attr('id') != $j(el).attr('id')) {
								$j(this).removeAttr('checked');
								$j(this).css('opacity', 1);
							}
						});
						
						$j(this).parents( 'div,li' ).children( 'input:checkbox' ).each(function (i) {							
							
							var selectors = $j(this).closest( 'div,li' ).find( 'input:checkbox' ).length;
							var selected = 0;
							$j(this).closest( 'div,li' ).find( 'input:checkbox' ).each(function(index, el) {
								if ( $j(el).is(':checked') ) {
									selected++;
								};
								
							});
							
							if (selected == selectors) {
								$j(this).css('opacity', 1)
							} else if ( selected > 0 ) {
								$j(this).css('opacity', 0.5)
							} else {
								$j(this).css('opacity', 1 )
							}
							
							
						});
					};
					
				});
			</cfoutput>
			</skin:onReady>


<!--- 		
		<skin:onReady>
		<cfoutput>
			$j('.perm').change(function() {
				var el = $j(this);
				var permValue = el.val();
				if(permValue == 'none') {
					$j(this).closest( 'div,li' ).find( 'select' ).each(function (i) {
						if( $j(this).attr('id') != $j(el).attr('id')) {
							$j(this).val(permValue);
							$j(this).attr('disabled','disabled');
						}
					});
					
					$j(this).parents( 'div,li' ).children( 'select' ).each(function (i) {
						if ( $j(this).val() == 'all') {
							$j(this).val( 'selected' );	
						};
					});
				};
				if(permValue == 'all') {
					$j(this).closest( 'div,li' ).find( 'select' ).each(function (i) {
						if( $j(this).attr('id') != $j(el).attr('id')) {
							$j(this).val(permValue);	
							$j(this).attr('disabled','disabled');
						}
					});
					
					$j(this).parents( 'div,li' ).children( 'select' ).each(function (i) {
						if ( $j(this).val() == 'none') {
							$j(this).val( 'selected' );	
						};
					});
				};
				if(permValue == 'selected') {
					
					$j(this).siblings( 'div' ).children( 'select' ).each(function (i) {
						if( $j(this).attr('id') != $j(el).attr('id')) {
							$j(this).removeAttr('disabled');
						}
					});
					
					$j(this).siblings( 'ul' ).children( 'li' ).children( 'select' ).each(function (i) {
						console.log($j(this));
						if( $j(this).attr('id') != $j(el).attr('id')) {
							$j(this).removeAttr('disabled');
						}
					});
					
					$j(this).parents( 'div,li' ).children( 'select' ).each(function (i) {
						if ( $j(this).val() == 'none') {
							$j(this).val( 'selected' );	
						};
					});
				};
				
			});
		</cfoutput>
		</skin:onReady>
				 --->
				
					
		<wiz:step name="Groups">
			
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="title,isdefault,aGroups" format="edit" intable="false" />
			
		</wiz:step>

	
		<wiz:step name="Permissions">
			
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="aPermissions" format="edit" intable="false" />
			
		</wiz:step>

	
		<wiz:step name="Webskins">
			
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="webskins" format="edit" intable="false" />
			
		</wiz:step>
	
	
	
		<wiz:step name="Navigation">

			

			<cfoutput>
			<div style="background-color:red;color:white;font-size:14px;text-align:center;margin:5px 5px 10px 5px;">PROOF OF CONCEPT ONLY</div>
			</cfoutput>

			<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>
			
			<cfset qNav = o.getDescendants(objectid=application.navID['root'], bIncludeSelf="true") />
			
			
			<cfset currentlevel= 0 />
			<cfset ul= 0 />
			<cfset bHomeFirst = false /> <!--- // used to stop the first node being flagged as first if home link is inserted. --->
			<cfset bFirstNodeInLevel = true /> <!--- // used to track the first node in each level.	 --->			
			
			<cfset bHighlightFirst= true />
			<cfset bIncludeSpan= true />
			
			
			
			<cfoutput>
				
			<cfloop query="qNav">
				<cfset previousLevel= currentlevel />
				<cfset currentlevel=qNav.nLevel />
				<cfset itemclass = "">
				
				<cfif previouslevel eq 0>
					<ul>
					
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
				<cfif bHighlightFirst>
					<cfif previouslevel eq 0 AND bHomeFirst>
						<!--- //top level and home link is first --->
					<cfelse>
						<cfif bFirstNodeInLevel>
							<cfset itemclass= itemclass & 'first ' />
							<cfset bFirstNodeInLevel=false />
						</cfif>
					</cfif>
					
				</cfif>
				<!--- // open a list item --->
				<li style="margin-left:40px;">
					
				<input type="checkbox" value="1" class="perm" id="#qNav.objectid#" name="#qNav.objectid#" />
				<!--- <select class="perm" id="#qNav.objectid#" <cfif qNav.nLevel NEQ 0>disabled="disabled"</cfif>>
					<cfif qNav.nRight-qNav.nLeft GT 1>
						<option value="none">No</option>
						<option value="all">Yes</option>
						<option value="selected">Selected</option>
					<cfelse>
						<option value="none">No</option>
						<option value="all">Yes</option>
					</cfif>
				</select> --->
				
				#trim(qNav.ObjectName)#
						
			</cfloop>
			
			#repeatString("</li></ul>",ul)#
			</cfoutput>
	
		</wiz:step>
		

	
		<wiz:step name="Webtop">

			

			<cfoutput>
			<div style="background-color:red;color:white;font-size:14px;text-align:center;margin:5px 5px 10px 5px;">PROOF OF CONCEPT ONLY</div>
			</cfoutput>


			
			<!--- WEBTOP PERMISSIONS --->
			
			<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />

			
			
			
			<grid:div class="level0">
			
				<cfoutput>
				<input type="checkbox" value="1" class="perm" id="root" name="root" />
				<!--- <select class="perm" id="root">
					<cfif listLen(stWebtop.CHILDORDER)>
						<option value="none">No</option>
						<option value="all">Yes</option>
						<option value="selected">Selected</option>
					<cfelse>
						<option value="none">No</option>
						<option value="all">Yes</option>
					</cfif>
				</select> --->
				Webtop
				</cfoutput>
					
				<cfloop list="#stWebtop.CHILDORDER#" index="i">
					
					<cfset stLevel1 = stWebtop.children[i] />
					
					<grid:div class="level1" style="padding-left:40px;">
					<cfoutput>
					
						<input type="checkbox" value="1" class="perm" id="#stLevel1.rbKey#" name="#stLevel1.rbKey#" />
						<!--- <select class="perm" id="#stLevel1.rbKey#" disabled="disabled">
							<cfif listLen(stLevel1.CHILDORDER)>
								<option value="none">No</option>
								<option value="all">Yes</option>
								<option value="selected">Selected</option>
							<cfelse>
								<option value="none">No</option>
								<option value="all">Yes</option>
							</cfif>
						</select> --->
						#stLevel1.label#
					
					</cfoutput>
					
					<cfif listLen(stLevel1.CHILDORDER)>
						<cfloop list="#stLevel1.CHILDORDER#" index="j">
						
							<cfset stLevel2 = stLevel1.children[j] />
						
							<grid:div class="level2" style="padding-left:40px;">
								<cfoutput>
								<input type="checkbox" value="1" class="perm" id="#stLevel2.rbKey#" name="#stLevel2.rbKey#" />
								<!--- <select class="perm" id="#stLevel2.rbKey#" disabled="disabled">
									<cfif listLen(stLevel2.CHILDORDER)>
										<option value="none">No</option>
										<option value="all">Yes</option>
										<option value="selected">Selected</option>
									<cfelse>
										<option value="none">No</option>
										<option value="all">Yes</option>
									</cfif>
								</select> --->
								#stLevel2.label#
							
								</cfoutput>		
								
								<cfif listLen(stLevel2.CHILDORDER)>
									<cfloop list="#stLevel2.CHILDORDER#" index="k">
									
										<cfset stLevel3 = stLevel2.children[k] />
										<grid:div class="level3" style="padding-left:40px;">
										
											<cfoutput>
											<input type="checkbox" value="1" class="perm" id="#stLevel3.rbKey#" name="#stLevel3.rbKey#" />
											<!--- <select class="perm" id="#stLevel3.rbKey#" disabled="disabled">
												<cfif listLen(stLevel3.CHILDORDER)>
													<option value="none">No</option>
													<option value="all">Yes</option>
													<option value="selected">Selected</option>
												<cfelse>
													<option value="none">No</option>
													<option value="all">Yes</option>
												</cfif>
											</select> --->
											#stLevel3.label#
											</cfoutput>		
											
											<cfif listLen(stLevel3.CHILDORDER)>
												<cfloop list="#stLevel3.CHILDORDER#" index="l">
												
													<cfset stLevel4 = stLevel3.children[l] />
													
													<grid:div class="level4" style="padding-left:40px;">
														<cfoutput>
														<input type="checkbox" value="1" class="perm" id="#stLevel4.rbKey#" name="#stLevel4.rbKey#" />
														<!--- <select class="perm" id="#stLevel4.rbKey#" disabled="disabled">
															<cfif listLen(stLevel4.CHILDORDER)>
																<option value="none">No</option>
																<option value="all">Yes</option>
																<option value="selected">Selected</option>
															<cfelse>
																<option value="none">No</option>
																<option value="all">Yes</option>
															</cfif>
														</select> --->
														#stLevel4.label#
														</cfoutput>		
													</grid:div>
												
												</cfloop>						
											</cfif>
										
										</grid:div>
										
									
									</cfloop>			
								</cfif>
							
							</grid:div>
						
						</cfloop>
				
					</cfif>
					
					</grid:div>
				
				</cfloop>
			
			</grid:div>
		</wiz:step>
		

	
		<wiz:step name="Webskin">

			

			<cfoutput>
			<div style="background-color:red;color:white;font-size:14px;text-align:center;margin:5px 5px 10px 5px;">PROOF OF CONCEPT ONLY</div>
			</cfoutput>

		
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="webskins" format="edit" intable="false" r_stPrefix="prefix" />
			
			<cfset roleWebskins = stwizard.data[stobj.objectid].webskins>

<!--- 
			<cfoutput>
			<p><ft:button value="Refresh Webskin Permissions" onClick="$fc.refreshWebskinPermissions();" renderType="link" confirmText="Are you sure you want to " /></p>
			</cfoutput> --->
			<skin:onReady>
				<cfoutput>
				var accordion = $j("##webskin-permissions");
				accordion.accordion({
					autoHeight: false,
					collapsible:true,
					animated:false
				});
				</cfoutput>
			</skin:onReady>

			<grid:div id="webskin-permissions">
				<cfset lTypesAndRules = structKeyList(application.stCoapi) />
				
				<cfloop list="#lTypesAndRules#" index="i">

					<cfoutput><h3><a href="##">#i# (#application.stCoapi[i].displayName#)</a></h3></cfoutput>
					
					<grid:div id="wrap-#i#" style="">
					<cfset qWebskins = application.stCoapi[i].qWebskins>
					<cfloop query="qWebskins">
						<cfset bPermitted = false />		
						<cfloop list="#roleWebskins#" index="filter" delimiters="#chr(10)##chr(13)#,">
							<cfif (not find(".",filter) or listfirst(filter,".") eq "*" or listfirst(filter,".") eq i or reFindNoCase(replace(listFirst(filter,"."),"*",".*","ALL"),i)) 
									and reFindNoCase(replace(listlast(filter,"."),"*",".*","ALL"),application.stCoapi[i].qWebskins.name)>
								<cfset bPermitted = true />
							</cfif>
						
						</cfloop>
											
						<cfoutput>
						
							<cfif bPermitted EQ true>
								<span style="color:green;">#application.stCoapi[i].qWebskins.name#</span><br />
							<cfelse>
								<span style="color:red;">#application.stCoapi[i].qWebskins.name#</span><br />
							</cfif>
						
						</cfoutput>
					</cfloop>
					</grid:div>
				</cfloop>
			</grid:div>
		</wiz:step>



		
</wiz:wizard>	
