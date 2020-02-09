var szUrl = "http://www.google.com";
var width = 1600;
var height = 800;
var delay = 20000;
var szOut = "webpage.png";

var page = require('webpage').create();

var system = require('system');
var args = system.args;
if (args.length > 1) {
	var i = 1;
    while (i < args.length)
    {
        console.log(i + ': ' + args[i]);
        if (args[i] === "-u")
        {            	
        	  szUrl = args[++i];
           console.log("url: " + szUrl);
        }
        else if (args[i] == "-w")
        {
        	  width = parseInt(args[++i]);
           console.log("width: " + width);
        }
        else if (args[i] == "-h")
        {
        	  height = parseInt(args[++i]);
           console.log("height: " + height);
        }
        else if (args[i] == "-d")
        {
        	  delay = parseInt(args[++i]);
           console.log("delay: " + delay);
        }
        else if (args[i] == "-o")
        {
        	  szOut = args[++i];
           console.log("outfile: " + szOut);
        }
        i++;
    }
}
page.onConsoleMessage = function(msg, lineNum, sourceId) {
  console.log('CONSOLE: ' + msg);
};
console.log("loading webpage");
page.open(szUrl, function() {
	  page.viewportSize = { width: width, height: height };
	  page.reload();
	  
  setTimeout(function() {
	  page.render(szOut,{format: 'png', quality: '90'});
	  console.log("after render");
	  phantom.exit();
  }, delay);
});
