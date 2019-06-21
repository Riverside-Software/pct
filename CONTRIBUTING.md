## How to report bugs ?

* Please use the Issues page on GitHub.
* Use the provided templates to report issue
* Always include the version number of PCT and OpenEdge ; you can easily get this information by including the following statements in your build.xml :
```xml
 <PCTVersion />
 <ProgressVersion dlcHome="${DLC}" fullVersion="dlc.version.full" />
 <echo message="${dlc.version.full}" />
```
Which will give you something like:
```
[PCTVersion] PCT Version : jenkins-Dev1-PCT-376
     [echo] OpenEdge Release 11.5 as of Fri Dec  5 19:02:15 EST 2014
```
* Upgrade to the latest version of PCT if possible
* Include a verbose log of your problem, by using `ant -v`
* For old versions of PCT, include a verbose log by adding verbose="true" in your PCTRun or PCTCompile statement
* If you have a problem with [[PCTCompileExt]], first verify that [[PCTCompile]] works correctly.
* If you want a problem to be fixed in a short amount of time, include a test case to reproduce the problem. The easier it will be for me to reproduce the problem, the faster the fix will come
* If you know how to fix a problem, please open a pull request

## How to build PCT ?

* Fork and clone project on GitHub
* Modify `pct.build.properties` to match your OpenEdge installation dir
* Make sure you don’t have PCT.jar in `$ANT_HOME/lib`
* Execute `ant clean jar` to build everything (PCT.jar is created in dist/ directory)
* Execute `ant prepare-test` to (re)generate the testbox dir, where tests are executed
* Execute `ant -DDLC=/path/to/dlc -Dprofiler=true -lib dist/PCT.jar -file tests.xml test` to execute unit tests
