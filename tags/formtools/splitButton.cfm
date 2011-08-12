<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: splitButton --->
<!--- @@Description: Wrapper for farcry split buttons. --->
<!--- @@Developer: Matthew Bryant (mbryant@daemon.com.au) --->


<!--- Import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam  name="attributes.class" default="">
	<cfparam  name="attributes.style" default="">
	<cfparam  name="attributes.priority" default="">
	<cfparam  name="attributes.position" default="bottom">


	<skin:onReady id="farcry-splitButton-js">
		<cfoutput>
			
			
			$j('.jquery-ui-split-button').each(function(index) {
				var t = ''; //timeout function variable
				
			
				if ( $j(this).find('button').length > 1 ) {
					$j(this).find('button:first').css('border-top-right-radius', '0');
					$j(this).find('button:first').css('border-bottom-right-radius', '0');
					$j(this).find('button:last').css('border-top-left-radius', '0');
					$j(this).find('button:last').css('border-bottom-left-radius', '0');
					$j(this).find('button:last').css('border-top-right-radius', '3px');
					$j(this).find('button:last').css('border-bottom-right-radius', '3px');
				} else {
					$j(this).find('button:last').css('border-top-right-radius', '3px');
					$j(this).find('button:last').css('border-bottom-right-radius', '3px');
				};
					
				$j(this).buttonset();
					
				$j(this).find('ul')
					.menu()
					.mouseenter(function() {
						clearTimeout(t);	
					})
					.mouseleave(function(e) {
						t=setTimeout(function() {
							$j(e.currentTarget).hide();
						}, 1000);
					});	
				
				
				
				$j(this).find( 'button:last' ).click(function(e) {		
					clearTimeout(t);
					var $wrap = $j(this).parent();
					var $first = $j($wrap).find( 'button:first' );
					var $last = $j( this );
					var $width = $first.outerWidth();
					var $list = $j(this).next('ul');
					
					if ( $j($wrap).find('button').length > 1 ) {
						$width = $width + $j($wrap).find( 'button:last' ).outerWidth();
					};
					
					if ( $width > $list.outerWidth() ) {
						$list.width($width)
					};
					
					
					$list.show();	
					
					if ($wrap.attr('ft:positionMenu') == 'top'){
					
						$maxHeight = $first.offset().top - $j(this).closest('body').scrollTop();
						if ( $list.innerHeight() > $maxHeight ) {
							$list.height($maxHeight - 20);
						};
						
						$list.position({
							of: $first,
							my: "left bottom",
							at: "left top",
							collision: "flip"				
						});
						
					} else if($wrap.attr('ft:positionMenu') == 'right') {
						
						$list.position({
							of: $first,
							my: "left top",
							at: "right top",
							collision: "flip"				
						});
						
					} else if($wrap.attr('ft:positionMenu') == 'left') {
						
						$list.position({
							of: $first,
							my: "right top",
							at: "right bottom",
							collision: "flip"				
						});
						
					} else {
						
						$list.position({
							of: $first,
							my: "left top",
							at: "left bottom",
							collision: "flip"				
						});
						
					};
					
					e.stopPropagation();
					return false;
				});	
				
				if ( $j(this).children('button').length > 1 ) {
					$j(this).find( 'button:last' ).css('border-left', 'none');
				};
				
				$j(this).find( 'button:last' )
					.mouseleave(function() {
						
						var $list = $j(this).next('ul');
						t=setTimeout(function() {
							$list.hide();
						}, 1000);
					})	
					.mouseenter(function() {
						clearTimeout(t);	
					});	
						
			});
			
			$j('body').click(function() {
			 	$j('.jquery-ui-split-button ul').hide();
			});
		</cfoutput>
	</skin:onReady>
		
	<cfif len(attributes.priority)>	
		<cfset attributes.class = listAppend(attributes.class, "ui-priority-#attributes.priority#", " ")>
	</cfif>
				
	<cfoutput>
		<div class="jquery-ui-split-button #attributes.class#" style="#attributes.style#" ft:positionMenu="#attributes.position#">
	</cfoutput>
</cfif>

<cfif thistag.ExecutionMode EQ "End">

	<cfoutput>
		<br />
		</div>
	</cfoutput>

</cfif>


<cfsetting enablecfoutputonly="false">
