<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Highcharts Example</title>

		<script type="text/javascript" src="http://cdn.hcharts.cn/jquery/jquery-1.8.3.min.js"></script>
		<style type="text/css">
.chart {
    min-width: 320px;
    max-width: 800px;
    height: 220px;
    margin: 0 auto;
}
</style>
<!-- http://doc.jsfiddle.net/use/hacks.html#css-panel-hack -->
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
		</style>
		<script type="text/javascript">
/*
The purpose of this demo is to demonstrate how multiple charts on the same page can be linked
through DOM and Highcharts events and API methods. It takes a standard Highcharts config with a
small variation for each data set, and a mouse/touch event handler to bind the charts together.
*/

$(function () {

    /**
     * In order to synchronize tooltips and crosshairs, override the
     * built-in events with handlers defined on the parent element.
     */
    $('#container').bind('mousemove touchmove touchstart', function (e) {
        var chart,
            point,
            i,
            event;

        for (i = 0; i < Highcharts.charts.length; i = i + 1) {
            chart = Highcharts.charts[i];
            event = chart.pointer.normalize(e.originalEvent); // Find coordinates within the chart
            point = chart.series[0].searchPoint(event, true); // Get the hovered point

            if (point) {
                point.onMouseOver(); // Show the hover marker
                chart.tooltip.refresh(point); // Show the tooltip
                chart.xAxis[0].drawCrosshair(event, point); // Show the crosshair
            }
        }
    });
    /**
     * Override the reset function, we don't need to hide the tooltips and crosshairs.
     */
    Highcharts.Pointer.prototype.reset = function () {
        return undefined;
    };

    /**
     * Synchronize zooming through the setExtremes event handler.
     */
    function syncExtremes(e) {
        var thisChart = this.chart;

        if (e.trigger !== 'syncExtremes') { // Prevent feedback loop
            Highcharts.each(Highcharts.charts, function (chart) {
                if (chart !== thisChart) {
                    if (chart.xAxis[0].setExtremes) { // It is null while updating
                        chart.xAxis[0].setExtremes(e.min, e.max, undefined, false, { trigger: 'syncExtremes' });
                    }
                }
            });
        }
    }

    // Get the data. The contents of the data file can be viewed at
    // https://github.com/highcharts/highcharts/blob/master/samples/data/activity.json
    $.getJSON('MapAction_returnCaseTimeData', function (data) {
        //console.log(activity);
        var datasets = [{"name":"案件发生次数/(次)",data:data[0],unit:"次(该时间段发生次数/平均值)",type:"line",valueDecimals:1},{"name":"出警延迟时间/(分)",data:data[1],unit:"分钟(案件发生多少时间出警/平均值)",type:"line",valueDecimals:1},{"name":"结案延迟时间(天)",data:data[2],unit:"天(案件发生多久结案/平均值)",type:"line",valueDecimals:1}]
        var activity = {xData:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23],datasets:datasets};
        console.log(activity);
        $.each(activity.datasets, function (i, dataset) {
			
            // Add X values
            dataset.data = Highcharts.map(dataset.data, function (val, j) {
                return [activity.xData[j], val];
            });

            $('<div class="chart">')
                .appendTo('#container')
                .highcharts({
                    chart: {
                        marginLeft: 40, // Keep all charts left aligned
                        spacingTop: 20,
                        spacingBottom: 20
                    },
                    title: {
                        text: dataset.name,
                        align: 'left',
                        margin: 0,
                        x: 30
                    },
                    credits: {
                        enabled: false
                    },
                    legend: {
                        enabled: false
                    },
                    xAxis: {
                        crosshair: true,
                        events: {
                            setExtremes: syncExtremes
                        },
                        categories:[0],
                        labels: {
                            format: '{value} h'
                        },
                        min:0,
                        max:23,
                        title:{
							text:"案发时间（一天内）"
                            }
                    },
                    yAxis: {
                        title: {
                            text: null
                        }
                    },
                    tooltip: {
                        positioner: function () {
                            return {
                                x: this.chart.chartWidth - this.label.width, // right aligned
                                y: -1 // align to title
                            };
                        },
                        borderWidth: 0,
                        backgroundColor: 'none',
                        pointFormat: '{point.y}',
                        headerFormat: '',
                        shadow: false,
                        style: {
                            fontSize: '18px'
                        },
                        valueDecimals: dataset.valueDecimals,

                    },
                    series: [{
                        data: dataset.data,
                        name: dataset.name,
                        type: dataset.type,
                        color: Highcharts.getOptions().colors[i],
                        fillOpacity: 0.3,
                        tooltip: {
                            valueSuffix: ' ' + dataset.unit
                        }
                    }]
                });
        });
    });
});
		</script>
	</head>
	<body>
<script src="http://cdn.hcharts.cn/highcharts/highcharts.js"></script>

<div id="container"></div>
	</body>
</html>
