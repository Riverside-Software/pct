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

```text
[PCTVersion] PCT Version : pct-226-main-e52f4a4
     [echo] OpenEdge Release 12.2.8 as of Fri Mar 25 19:01:43 EDT 2022
```

* Upgrade to the latest version of PCT if possible
* Include a verbose log of your problem, by using `ant -v`
* For old versions of PCT, include a verbose log by adding verbose="true" in your PCTRun or PCTCompile statement
* If you have a problem with [[PCTCompileExt]], first verify that [[PCTCompile]] works correctly.
* If you want a problem to be fixed in a short amount of time, include a test case to reproduce the problem. The easier it will be for me to reproduce the problem, the faster the fix will come
* If you know how to fix a problem, please open a pull request

## How to build PCT ?

* JDK 11 is required
* Modify `pct.build.properties` to match your OpenEdge installation dir
  * If you don't want to modify the properties you can create a symbolic link using `mklink /j /d C:\\Progress\\OpenEdge-12.6 your-oe126-path` in an administrator command prompt
* Make sure you **don’t** have PCT.jar in `$ANT_HOME/lib`
* Execute `ant clean jar` (or `ant clean classDoc jar` if you want to test ClassDocumentation on Windows) to build everything (PCT.jar is created in dist/ directory)
* Execute `ant prepare-test` to (re)generate the testbox dir, where tests are executed
* Execute `ant -DDLC=%DLC% -Dprofiler=true -lib dist/PCT.jar -file tests.xml test` to execute unit tests

## Individual unit tests in Docker containers

_ The docker images are only available internally_

```
docker run -it --rm -v %CD%:/pct docker.rssw.eu/progress/dlc:12.8
cd /pct/testbox/PCTRun/test1
# Standard unit tests
ant -DDLC=$DLC -lib ../../../dist/PCT.jar test
# Class documentation unit tests
ant -DDLC=$DLC -lib ../../../dist/PCT.jar -lib ../../../lib/xmltask.jar -lib ../../../lib/ast.jar -lib ../../../lib/ast-dependencies.jar -lib ../../../lib/activation-1.1.1.jar test
```
