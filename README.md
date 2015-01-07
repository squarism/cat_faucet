Arduino Cat Faucet
==================

*Project Complete.  Ran for four years.  RIP Beaker.  She was great.*

This the software side of my Arduino Cat Faucet project.

[Screenshots and blog post on squarism.com](http://squarism.com/2011/03/09/arduino-cat-faucet-with-mongodb-and-rails/)

Super-important hourly cat drinking metrics.  :cat:

![graph_screenshot](https://raw.github.com/squarism/cat_faucet/master/cat_faucet_screenshot.png)

Components
------
* arduino/ - Arduino folder for arduino code to be uploaded onto an arduino.  You should use the cat_faucet.ino sketch.  Just upload it onto an Arduino and it will run.  The harder part is building the actual hardware.  I don't have plans at this point in time but you will see a large writeup in the link at the top.
* cat_faucet_bridge.rb - collects arduino data and uses a Fnordmetric client to log metrics/events
* fnord.rb - A Fnordmetric based webapp that collects Arduino data over XBee and graphs
* fnord_dummy_data.rb - a data generator if you just want to play with Fnordmetric

Install
------
1. Run bundle.
1. You'll want to install and run redis.  Defaults are fine.  Fnordmetric uses the fnordmetric key namespace.  The fnord.rb service expects Redis to be on localhost.
1. Run cat_faucet_bridge.rb and plug in a Xbee explorer USB.  Run in tmux, screen or set up Foreman.
1. Run fnord.rb in tmux, screen or set up Foreman.
1. Go to http://your-machine:4242 and watch the cat data come in.



TODO
----
* Include example Foreman script for fnord.rb and cat_faucet_bridge.rb
* Link to sparkfun parts.