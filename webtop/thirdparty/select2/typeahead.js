;(function($){
	var stringtruthyness = {
		"" : false,
		"0" : false,
		"NO" : false,
		"false" : false,

		"1" : true,
		"YES" : true,
		"true" : true
	}

	$.fn.typeahead = function setupTypeahead(config){
		this.each(function(){
			var self = $(this);
			var fieldname = this.id;
			var single = self.hasClass("typeahead-single");

			var thisconfig = jQuery.extend({
				typename : self.data("typename"),
				prefix : self.data("prefix"),
				objectid : self.data("objectid"),
				ajaxurl : self.data("ajaxurl"),
				multiple : self.prop("multiple"),
				watch : self.data("watch") || "",
				placeholder : self.data("placeholder"),
				data : self.data("inlinedata") || undefined,
				createoptions : self.data("createoptions") || undefined,
				minimumInputLength : self.data("minimuminputlength")===undefined ? (self.data("inlinedata") ? 0 : 3) : self.data("minimuminputlength"),
				pagesize : 15
			},config);
			thisconfig.multiple = stringtruthyness[thisconfig.multiple];
			thisconfig.watch = thisconfig.watch.split ? thisconfig.watch.split(",") : [];
			self.data("typeahead-config",thisconfig);

			var propertyname = fieldname.slice(thisconfig.prefix.length);

			// Select2 4.x escapes string returns from templateResult. The library row
			// (librarySelected) is server-side-encoded HTML, so render it via a jQuery
			// object; the plain label falls through as a string and stays auto-escaped.
			function templateResult(item){
				var ls = item.librarySelected || (item.element ? $(item.element).data("librarySelected") : null);
				if (ls) return $("<span>").html(ls);
				return item.text;
			};

			// Builds the query sent to the ajax endpoint. 4.x calls this with a params
			// object (params.term / params.page). The current value is sent so the
			// server can exclude already-selected items; watched fields are scraped live.
			function getData(params){
				var result = {
					search: params.term || "", // search term
					page: params.page || 1
				};

				result[propertyname] = self.val();
				if (result[propertyname] && result[propertyname].constructor == Array) result[propertyname] = result[propertyname].join();

				for (var i=0; i<thisconfig.watch.length; i++){
					result[thisconfig.watch[i]] = [];
					$j("select[name="+thisconfig.prefix+thisconfig.watch[i]+"], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=text], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=password], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=checkbox]:checked, input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=radio]:checked").each(function(){
						result[thisconfig.watch[i]].push($(this).val());
					});
					result[thisconfig.watch[i]] = result[thisconfig.watch[i]].join();
				}

				return result;
			};

			if (thisconfig.data) {
				// Inline-data mode: append the pool as real <option>s (4.x's `data:` array
				// won't merge into a <select> that already has <option>s). librarySelected
				// rides on each option for templateResult; create options are appended too.
				var pool = thisconfig.data.slice();
				if (thisconfig.createoptions) pool = pool.concat(thisconfig.createoptions);
				for (var pi=0; pi<pool.length; pi++){
					if (!self.find("option[value='"+pool[pi].id+"']").length){
						var opt = new Option(pool[pi].text, pool[pi].id, false, false);
						if (pool[pi].librarySelected) $(opt).data("librarySelected", pool[pi].librarySelected);
						self.append(opt);
					}
				}
				self.select2({
					minimumInputLength: thisconfig.minimumInputLength,
					allowClear: !thisconfig.multiple,
					placeholder: thisconfig.placeholder,
					templateResult: templateResult
				});
			}
			else {
				self.select2({
					minimumInputLength: thisconfig.minimumInputLength,
					allowClear: !thisconfig.multiple,
					placeholder: thisconfig.placeholder,
					templateResult: templateResult,
					ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
						url: thisconfig.ajaxurl,
						dataType: 'json',
						data: getData,
						processResults: function(data){
							// The server returns a bare array. No `pagination.more` is sent, so
							// Select2 treats it as a single page (matches the 3.x behaviour).
							return {
								results: data
							};
						}
					}
				});
			}

			self.on("change",function(){
				var val = $j(this).val();
				if (!thisconfig.multiple){
					if (typeof(val)=="string" && val.length && val.slice(0,1) == "_"){
						$j(this).val("").trigger("change");
						$j("#"+fieldname+"-add-type").val(val.slice(1));

						fcForm.openLibraryAdd(thisconfig.typename,thisconfig.objectid,propertyname,fieldname);
					}
				}
				else if (val && val.constructor==Array && val.length && val[val.length-1].slice(0,1) == "_"){
					var addtype = val[val.length-1].slice(1);
					val = val.slice(0,-1);
					$j(this).val(val).trigger("change");
					$j("#"+fieldname+"-add-type").val(addtype);

					fcForm.openLibraryAdd(thisconfig.typename,thisconfig.objectid,propertyname,fieldname);
				}
			});

			if (single) {
				self.next(".select2-container").addClass("typeahead-single");
				// Single (uuid) fields use the multiple widget for a consistent inline-search look
				// but only ever hold one value: replace the previous pick instead of stacking.
				self.on("select2:select",function(e){
					var id = e.params && e.params.data ? e.params.data.id : null;
					if (typeof(id)=="string" && id.slice(0,1)=="_") return;
					if (self.val() && self.val().length > 1) self.val([id]).trigger("change");
				});
			}

			if (!fcForm.typeaheadOldRefreshProperty){
				fcForm.typeaheadOldRefreshProperty = fcForm.refreshProperty
				fcForm.refreshProperty = function(typename,objectid,property,id){
					var el = $j("#"+id), cfg = el.data("typeahead-config");
					// Ajax-mode typeahead: after a library add/create the new id is attached
					// server-side, so re-sync from the object's current value (the modal's
					// select.val() write cannot select an option that does not exist yet).
					if (el.siblings(".select2-container").length && cfg && cfg.ajaxurl){
						$j.getJSON(cfg.ajaxurl,{ resolvecurrent:1 },function(data){
							$j.each(data,function(i,item){
								if (!el.find("option[value='"+item.id+"']").length)
									el.append(new Option(item.text,item.id,true,true));
							});
							el.val(cfg.multiple ? $j.map(data,function(item){ return item.id; }) : (data.length ? data[0].id : "")).trigger("change");
						});
					}
					else{
						fcForm.typeaheadOldRefreshProperty(typename,objectid,property,id);
					}
				}
			}
		});
	};

	$(function(){
		$("input.typeahead,select.typeahead").typeahead();
	})
})(jQuery);
