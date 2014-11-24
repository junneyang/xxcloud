Q(document)
		.ready(
				function() {

					var concurrentBuild = Q("input:checkbox[name='_.concurrentBuild']");
					
					checkConcurrentExecutionValuesNode();
					checkConcurrentExecutionValuesLabel();

					concurrentBuild.bind('change', function() {
						checkConcurrentExecutionValuesNode();
						checkConcurrentExecutionValuesLabel();
					});
					
					
					Q('input:radio[name$=triggerIfResult]').change( function() {
						checkConcurrentExecutionValuesNode();
						checkConcurrentExecutionValuesLabel();
					});
					
					
					function checkConcurrentExecutionValuesNode() {
						if ( concurrentBuild.is(":checked") && (Q('input:radio[name$=triggerIfResult]:checked').val() != "allowMultiSelectionForConcurrentBuilds" ) ) {
							Q("#allowmultinodeselection").show();
						} else if ( !concurrentBuild.is(":checked") && (Q('input:radio[name$=triggerIfResult]:checked').val() == "allowMultiSelectionForConcurrentBuilds" ) ) {
							Q("#allowmultinodeselection").show();
						} else {
							Q("#allowmultinodeselection").hide();
						}
					}
					
					function checkConcurrentExecutionValuesLabel() {
						if ( concurrentBuild.is(":checked") && (Q('input:radio[name$=triggerIfResult]:checked').val() != "allCases" ) ) {
							Q("#allowmultinodeselection_label").show();
						} else {
							Q("#allowmultinodeselection_label").hide();
						}
					}

				});