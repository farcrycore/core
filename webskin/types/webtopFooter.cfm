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

		<script src="js/jquery.js"></script>
		<script src="js/bootstrap.min.js"></script>

		<script type="text/javascript">
		$(function(){

			/* enable bootstrap menus to work on hover */
			$(".farcry-secondary-nav .nav > li.dropdown").hover(function(){
				clearTimeout($.data(this, "timer"));
				$("li.open").removeClass("open");
				$(this).addClass("open");
			}, function(){
				var dropdown = this;
				$.data(this, "timer", setTimeout(function() {
					$(dropdown).removeClass("open");
				}, 1000));
			});

			/* allow a clicked dropdown link in the secondary nav to stay open */
			$(".farcry-secondary-nav").on("click", ".nav > li.open > a", function(evt){
				return false;
			});

			/* testing tooltips */
			$(".fc-tooltip").tooltip();

		});
		</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">