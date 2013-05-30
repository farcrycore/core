<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
				</div>
			</div>
		</div>

		<script type="text/javascript">
		$j(function(){
			/* fix for https://github.com/twitter/bootstrap/pull/7211 */
			$j(document).off("click.dropdown-menu").on("click.dropdown-menu",function(e){ if (e.which===1) e.stopPropagation(); });
			
			/* testing tooltips */
			$j(".fc-tooltip").tooltip();
			
			<skin:pop>$j("##bubbles").append("<div class='alert<cfif listfindnocase(message.tags,'info')> alert-info<cfelseif listfindnocase(message.tags,'error')> alert-error<cfelseif listfindnocase(message.tags,'success')> alert-success</cfif>'><button type='button' class='close' data-dismiss='alert'>&times;</button><cfif len(trim(message.title))><strong>#message.title#</strong></cfif> <cfif len(trim(message.message))>#message.message#</cfif></div>");</skin:pop>
		});
		</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">