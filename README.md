[![Velma Dinkley said "Jinkies"][1]][2]

> Her catchphrases are: "**Jinkies!**", "My glasses! I can't see without my glasses!", and "You wouldn't hit someone wearing glasses, would you?".

--------------------------------------------------------------------------

Jinkies is a [coffee-script](http://jashkenas.github.com/coffee-script/) interface to the [Jenkins](http://jenkins-ci.org) ([Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html)) server's JSON API.

I'd written half of this before I realized I was cloning a lot of [hudson.rb](https://github.com/cowboyd/hudson.rb).

--------------------------------------------------------------------------

You need a current [node.js](http://nodejs.org) development environment.

[Setting up your environment](https://github.com/atmos/jinkies/wiki/Development)
---------------------------------------------------------------------------------------------------

Jinkies is [available](https://github.com/atmos/jinkies) under an [MIT license](https://github.com/atmos/jinkies/blob/master/LICENSE).

[If you care about testing your hacks](https://github.com/atmos/jinkies/wiki/Testing)
-------------------------------------------------------------------------------------

Jinkies has tests that you can run too.

[If you're interested with GitHub integration](https://github.com/atmos/jinkies/wiki/The-Web-API)
-------------------------------------------------------------------------------------

Jinkies works as a post-receive endpoint for GitHub webhooks.

[If you're interested in the command line](https://github.com/atmos/jinkies/wiki/Command-Line)
-----------------------------------------------------------------------------------------------

Jinkies gives you a simple executable that uses the library.

    $ bin/jinkies -h
    Usage jinkies [options]

    Available options:
      -h, --help                Display the help information
      -j, --job JOB             Specify the jenkins job
      -t, --trigger-build       Trigger a build for the jenkins jobs
      -b, --branch BRANCH       Specify the jenkins build should locate
      -s, --sha1 SHA1           Specify the SHA1 the jenkins build should locate
      -p, --express-port PORT   Specify the express port, defaults to 45678
      -e, --express-app         Start the express webhook endpoint
      -r, --robot               Start the robot!!!!1
      -d, --server SERVER       Specify jinkies server to use
      -a, --all                 List all the jobs on the jenkins server

[1]: http://f.cl.ly/items/370L3N2X363C2S38110W/img-rn_jinkies.jpeg
[2]: http://en.wikipedia.org/wiki/Velma_Dinkley
