<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
				</div>
			</div>
		</div>

		<div class="farcry-footer container-fluid">
			<div class="row-fluid">
				<div class="span12">
					Copyright &copy; <a href="http://www.daemon.com.au" target="_blank">Daemon</a> 1997-#year(now())#, #application.sysInfo.farcryVersionTagLine#
				</div>
			</div>
		</div>

		<script src="js/bootstrap.min.js"></script>

		<script type="text/javascript">
		$j(function(){

			/* enable bootstrap menus to work on hover */
			$j(".farcry-secondary-nav .nav > li.dropdown").hover(function(){
				clearTimeout($j.data(this, "timer"));
				$j("li.open").removeClass("open");
				$j(this).addClass("open");
			}, function(){
				var dropdown = this;
				$j.data(this, "timer", setTimeout(function() {
					$j(dropdown).removeClass("open");
				}, 1000));
			});

			/* allow a clicked dropdown link in the secondary nav to stay open */
			$j(".farcry-secondary-nav").on("click", ".nav > li.open > a", function(evt){
				return false;
			});

			/* testing tooltips */
			$j(".fc-tooltip").tooltip();
			
			<skin:pop>$j("##bubbles").append("<div class='alert<cfif listfindnocase(message.tags,'info')> alert-info<cfelseif listfindnocase(message.tags,'error')> alert-error<cfelseif listfindnocase(message.tags,'success')> alert-success</cfif>'><button type='button' class='close' data-dismiss='alert'>&times;</button><cfif len(trim(message.title))><strong>#message.title#</strong></cfif> <cfif len(trim(message.message))>#message.message#</cfif></div>");</skin:pop>
		});
		</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">