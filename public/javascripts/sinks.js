// Javascript specific for Sink views.  Draws statistic graphs etc.

function log(s) {
	$('#debug').append('<p>' + s + '<p>');
}

// return an array of sink IDs we found from the divs
function find_placeholders() {
	var a = new Array();
	$(".overview-graph").each(function() {
		a.push($(this).attr('id'));
	});
	
	return a;
}

$(document).ready(function() {
	var placeholders = find_placeholders();	
	var data = [];
	
	var options = {
			colors: ["#5f7395", "#afd8f8", "#cb4b4b", "#4da74d", "#9440ed"],
	        bars: { barWidth: 0.75, show: true, align:"center" },
	        points: { show: false },
	        xaxis: { ticks: 12, tickDecimals: 0, tickSize: 1, min: 0, max: 24 },
			yaxis: { min: 0 },
			grid: {
				hoverable: true,
				backgroundColor: { colors: ["#fff", "#ddd"] },
				clickable: false
			}
	    };	
	
	function onDataReceived(series) {
		// hardcoded test
		//data = [ { label: 'JS Hardcoded', data: [ [1999, 3.0], [2000, 3.9], [2001,2.5] ] } ];
		
		// data from AJAX call
		data = [ series ];

		// plot data
		$.plot(placeholder, data, options);
	}
	
	// for each graph div, ajax call to json rails URL and get data
	for (var i in placeholders) {
		var placeholder = $('#' + placeholders[i]);
		
		// get flot data and plot on success
		$.ajax({
			url: '/sinks/json/' + placeholders[i],
			method: 'GET',
			dataType: 'json',
			success: onDataReceived
		});		
	}	
		
	// flot tooltip function
	function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #bbb',
            padding: '1px',
            'background-color': '#eee',
            opacity: 0.80
        }).appendTo("body").fadeIn(0);
    };
	
	// bind mouse hover event to tooltip function
	var previousPoint = null;
    placeholder.bind("plothover", function (event, pos, item) {
        $("#x").text(pos.x.toFixed(2));
        $("#y").text(pos.y.toFixed(2));

        if (true) {
            if (item) {
                if (previousPoint != item.datapoint) {
                    previousPoint = item.datapoint;

                    $("#tooltip").remove();
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(2);

                    showTooltip(item.pageX, item.pageY,
                                "Drinks at " + x + ":00 " + y + "% of the time.");
                }
            } else {
                $("#tooltip").remove();
                previousPoint = null;            
            }
        }
    });
	
});