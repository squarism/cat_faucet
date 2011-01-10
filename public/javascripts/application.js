// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log(s) {
	$('#debug').append('<p>' + s + '<p>');
}


$(document).ready(function() {
	var placeholder = $('#sink-time-of-day');
	var dataurl = '/sinks/json.js'
	var data = [];
	
	/*
	var options = {
		series: {
            lines: { show: false },
            points: { show: false }
        },
		xaxis: {
			ticks: 12,
			min: 0,
			max: 24
		},
		yaxis: {
			
		},
		grid: {
			hoverable: true,
			backgroundColor: { colors: ["#fff", "#eee"] }
		}
    };
	*/
	
	
	var options = {
	        bars: { show: true },
	        points: { show: false },
	        xaxis: { tickDecimals: 0, tickSize: 2 },
			yaxis: { min: 0, max: 100 },
	    };
	
	

	$.plot(placeholder, data, options);
	
	
	/*
	$.plot(placeholder, [
		{
			label: "Beaker",
			data: [[0,3], [4,8], [8.5], [23,43]],
			bars: {show:true},
		}], {
			series: {
	            lines: { show: false },
	            points: { show: false }
	        },
			xaxis: {
				ticks: 12,
				min: 0,
				max: 24
			},
			yaxis: {
				
			},
			grid: {
				hoverable: true,
				backgroundColor: { colors: ["#fff", "#eee"] }
			}
	});
	*/
	
	
	function onDataReceived(series) {
		// hardcoded test
		//data = [ { label: 'JS Hardcoded', data: [ [1999, 3.0], [2000, 3.9], [2001,2.5] ] } ];
		
		// data from AJAX call
		data = [ series ];

		// plot data
		$.plot(placeholder, data, options);
	}
	
	// get flot data
	$.ajax({
		url: dataurl,
		method: 'GET',
		dataType: 'json',
		success: onDataReceived
	});
	
	
	// flot tooltip
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
	    }
	
	var previousPoint = null;
	    placeholder.bind("plothover", function (event, pos, item) {
	        $("#x").text(pos.x.toFixed(0));
	        $("#y").text(pos.y.toFixed(0));

	        if (true) {
	            if (item) {
	                if (previousPoint != item.datapoint) {
	                    previousPoint = item.datapoint;

	                    $("#tooltip").remove();
	                    var x = item.datapoint[0].toFixed(0),
	                        y = item.datapoint[1].toFixed(0);

	                    showTooltip(item.pageX, item.pageY,
	                                item.series.label + " drinks at " + x + ":00 " + y + "% of the time.");
	                }
	            }
	            else {
	                $("#tooltip").remove();
	                previousPoint = null;            
	            }
	        }
	    });


	
	// test DOM append and jquery
	if ($('img').length > 0) {
		log('jquery test: we found more than zero images');
	} else {
		log('not enough imgs');
	}
	

	
});