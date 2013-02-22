<cfsetting enablecfoutputonly="true">

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

		});
		</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">