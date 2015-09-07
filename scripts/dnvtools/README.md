
# dnvtools
This the repository for dependency and version tracking tools for ODL project

External Libraries used :-

1. PureCss :- Licensed under Yahoo BSD License (Link : https://github.com/yahoo/pure-site/blob/master/LICENSE.md)
2. Jquery :- MIT License
3. Vis.js :- Vis.js is dual licensed under both Apache 2.0 and MIT. (Link 1 : http://www.apache.org/licenses/LICENSE-2.0, Link 2 : The MIT License http://opensource.org/licenses/MIT)

How to change the graph information?

The graph is genererated from the info in the json file :- dependencyInfo.json in tools/js. Making changes to this file will make the changes in the graph.


How to deploy using mvn?

1. Move the pom.xml file to the where you want to host the mvn site say 'root'
2. Make the following folders :- 'root/src/site/resources/'
3. Copy 'dnvtools' to the above location
4. Move site.xml from 'dnvtools' to 'root/src/site/'
5. Run the command 'mvn site:site', this will generate the target folder 'target' from the root folder
6. Finally run the command 'mvn site:run', which will start the jetty server and host the mvn site
