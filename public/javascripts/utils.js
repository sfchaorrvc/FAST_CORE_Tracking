// String trim functions
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function() {
	return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function() {
	return this.replace(/\s+$/,"");
}

var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// Function to display localized date/time
function displayLocalDT(dt) {
	return getLongDateTime(dt);
}

// Function to display localized date
function displayLocalDate(dt) {
	return (new Date(dt).toDateString());
}

// Display 12 hour clock time
function getLongDateTime(millis) {
	var dt    = new Date(millis);
	var hour   = dt.getHours();
	var minute = dt.getMinutes();
	var second = dt.getSeconds();
	var day = dt.getDay();
	var month = dt.getMonth();
	var year = dt.getFullYear();
	var ap = "AM";
	if (hour   > 11) { ap = "PM";             }
	if (hour   > 12) { hour = hour - 12;      }
	if (hour   == 0) { hour = 12;             }
	if (minute < 10) { minute = "0" + minute; }
	if (second < 10) { second = "0" + second; }
	return days[day] + " " + months[month] + " " + (dt.getDate()) + " " + year + " " + hour + ':' + minute + ':' + second + " " + ap;
}

// Popup dynamically sized window
function popIt(url, name, props) {
	window.open(url, name, props);
}

function $(id) {
	return document.getElementById(id);
}

// Retrieves MSISDN based on device IMEI from deploymanager
function getMSISDN(e, key) {
	var url = "/admin/devices/get_msisdn?key=" + key;
	
	new Ajax.Request(url,
	  {
	    method:'get',
	    onSuccess: function(transport){
				var response = eval(transport.responseText);
				if(response.length && response[0].gsm_device.msisdn != null && response[0].gsm_device.msisdn != "" ) {
					e.innerHTML = response[0].gsm_device.msisdn;
				} else {
					e.innerHTML = "Unavailable";
				}
    },
	    onFailure: function(){
				e.innerHTML = "Error";
			}
	  });
}