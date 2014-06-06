<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
				</div>
			</div>
		</div>

		<div class="farcry-footer container-fluid">
			<div class="row-fluid">
				<div class="span12">
					Copyright &copy; <a href="http://www.daemon.com.au" target="_blank">Daemon</a> 1997-#year(now())#. #application.sysInfo.farcryVersionTagLine#
				</div>
			</div>
		</div>

		<script type="text/javascript">
		$j(function(){
			/* fix for https://github.com/twitter/bootstrap/pull/7211 */
			$j(document).off("click.dropdown-menu").on("click.dropdown-menu",function(e){ if (e.which===1) e.stopPropagation(); });
			
			/* enable bootstrap menus to work on hover */
			$j(".farcry-secondary-nav .nav:first > li.dropdown").hover(function(){
				clearTimeout($j.data(this, "timer"));
				$j(document).off("mousemove.menu");
				$j("li.open").removeClass("open");
				$j(this).addClass("open");
			}, function(){
				var dropdown = this, self = $j(this), megamenu = self.find(".dropdown-mega-menu"), menupos = megamenu.offset(), buffer = 60;
				
				$j.data(this, "timer", setTimeout(function() {
					self.removeClass("open");
					$j(document).off("mousemove.menu");
				}, 1000));
				
				/* timer only applies while the mouse is a certain distance from the menu */
				menupos = {
					right : menupos.left + megamenu.width() + buffer,
					bottom : menupos.top + megamenu.height() + buffer,
					top : menupos.top,
					left : menupos.left - buffer
				};
				$j(document).on("mousemove.menu",function(e){
					if (e.pageX < menupos.left || e.pageX > menupos.right || e.pageY < menupos.top || e.pageY > menupos.bottom){
						clearTimeout(self.data("timer"));
						$j(document).off("mousemove.menu");
						$j("li.open").removeClass("open");
					}
				});
			});

			/* allow a clicked dropdown link in the secondary nav to stay open */
			$j(".farcry-secondary-nav").on("click", ".nav:first > li.open > a", function(evt){
				return false;
			});

			/* live pretty dates */
			if (typeof moment != "undefined") {
				moment.lang(['#session.dmProfile.locale#', 'en']);
				moment.langData("en")._relativeTime.s = "moments";
				moment.langData("en_AU")._relativeTime.s = "moments";
				moment.langData("en_US")._relativeTime.s = "moments";
				function livePrettyDate(){
					$j(".fc-prettydate").each(function(){
						var el = $j(this);
						var d = el.data("datetime");
						if (d) {
							el.html(moment(d + " #numberFormat((getTimeZoneInfo().utcHourOffset*-1*100)+(getTimeZoneInfo().utcMinuteOffset*-1), "+0000")#", "YYYY-MM-DD HH:mm Z").fromNow());
						}
					})
				};
				livePrettyDate();
				setInterval(livePrettyDate, 30000);
			}

			/* remove updateapp from URL */
			var newURL = window.location.href.replace(/(updateapp=.*?([&]+|$))/gi, "").replace(/&$/gi, "");
			if (window.history.replaceState && newURL != window.location.href) {
				window.history.replaceState("", window.document.title, newURL);
			}

			/* navigation tabs overflow */
			var headerContainer = $j(".farcry-header-top");
			var brandContainer = $j(".farcry-header-brand");
			var utilityContainer = $j(".farcry-header-utility");
			var tabContainer = $j(".farcry-header-tabs ul");
			var tabItems = tabContainer.find("> li");
			var tabOverflowTimer = null;

			function renderTabOverflow() {

				var tabContainerWidth = headerContainer.width() - brandContainer.width() - utilityContainer.width() - 52;
				var tabTotalWidth = 0;
				var aHiddenTabs = [];
				var previousTab = null;
				var previousWidth = 0;
				var overflowActive = false;

				// set width again
				tabContainer.width(tabContainerWidth);

				// calculate widths and position of overflow dropdown
				tabItems.each(function(){
					var currentTab = this;
					var $el = $j(this);

					tabTotalWidth += $el.width();
					if ($el.hasClass("last")) {
						tabTotalWidth -= 50;
					}

					if (tabTotalWidth > (tabContainerWidth-previousWidth+50)) {
						if ($el.hasClass("nav-more")) {
							aHiddenTabs.push(previousTab);
							$el.remove();
						}
						else {
							aHiddenTabs.push(currentTab);
							$el.css("display", "none");
							if ($el.hasClass("active")) {
								overflowActive = true;
							}
						} 
					}
					else {
						if ($el.hasClass("nav-more")) {
							aHiddenTabs.push(previousTab);
							$el.remove();
						}
						else {
							$el.css("display", "block");
						}
					}

					previousTab = currentTab;
					previousWidth = $el.width();

				});

				// render overflow dropdown
				if (aHiddenTabs.length) {
					var dropdownHTML = "";
					tabContainer.find(".nav-more").remove();
					for (var i=0; i<aHiddenTabs.length;i++) {
						var $el = $j(aHiddenTabs[i]);
						dropdownHTML += "<li id='"+$el.attr("id")+"' class='"+$el.attr("class")+"'>" + $el.html() + "</li>";
					}
					$j("<li class='dropdown dropdown-toggle nav-more "+ ((overflowActive)?"active":"") +"'><a href='##'><i class='fa fa-caret-down'></i></a><ul class='dropdown-menu pull-right'>" + dropdownHTML + "</ul></li>").insertBefore(aHiddenTabs[0]);
				}
				else {
					tabContainer.find(".nav-more").remove();
				}

				$j(".farcry-header-tabs").css("overflow", "visible");
				$j(".farcry-header-tabs ul").css("overflow", "visible");

			}
			$j(window).resize(function(){
				clearTimeout(tabOverflowTimer);
				$j(".farcry-header-tabs").css("overflow", "hidden");
				$j(".farcry-header-tabs ul").css("overflow", "hidden");
				tabOverflowTimer = setTimeout(function(){
					renderTabOverflow();
				}, 150);
			});
			setTimeout(function(){
				renderTabOverflow();
			}, 300);


			
			<skin:pop>$j("##bubbles").append("<div class='alert<cfif listfindnocase(message.tags,'info')> alert-info<cfelseif listfindnocase(message.tags,'error')> alert-error<cfelseif listfindnocase(message.tags,'success')> alert-success</cfif>'><button type='button' class='close' data-dismiss='alert'>&times;</button><cfif len(trim(message.title))><strong>#application.fc.lib.esapi.encodeForJavascript(message.title)#</strong></cfif> <cfif len(trim(message.message))>#application.fc.lib.esapi.encodeForJavascript(message.message)#</cfif></div>");</skin:pop>
		});
		</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">