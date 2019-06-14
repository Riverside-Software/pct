/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.phenix.pct;

import java.io.File;

import org.apache.tools.ant.types.Path;

public interface IRunAttributes {

    /**
     * Adds a database connection
     */
    void addDBConnection(PCTConnection dbConn);

    /**
     * Adds a database connection set
     */
    void addDBConnectionSet(DBConnectionSet set);

    /**
     * Adds a new command line option
     */
    void addOption(PCTRunOption option);

    /**
    /**
     * Adds a new parameter which can be read by the called Progress procedure
     */
    void addParameter(RunParameter param);

    /**
     * Add a new output param which will be passed to progress procedure
     */
    void addOutputParameter(OutputParameter param);

    /**
     * Set the propath to be used when running the procedure
     */
    void addPropath(Path propath);

    /**
     * Parameter file (-pf attribute)
     */
    void setParamFile(File pf);

    /**
     * Thousands separator (-numsep attribute)
     */
    void setNumSep(String numsep);

    /**
     * Decimal separator (-numdec attribute)
     */
    void setNumDec(String numdec);

    /**
     * Parameter (-param attribute)
     */
    void setParameter(String param);

    /**
     * Turns on/off debugging mode (keeps Progress temp files on disk)
     */
    void setDebugPCT(boolean debugPCT);

    /**
     * If files beginning with an underscore should be compiled (-zn option) See POSSE documentation
     * for more details
     */
    void setCompileUnderscore(boolean compUnderscore);

    /**
     * The number of compiled procedure directory entries (-D attribute)
     */
    void setDirSize(int dirSize);

    /**
     * Graphical mode on/off (call to _progres or prowin32)
     */
    void setGraphicalMode(boolean graphMode);

    /**
     * Sets .ini file to use (-basekey INI -ininame xxx)
     */
    void setIniFile(File iniFile);

    /**
     * Stream code page (-cpstream attribute)
     */
    void setCpStream(String cpStream);

    /**
     * Internal code page (-cpinternal attribute)
     */
    void setCpInternal(String cpInternal);

    /**
     * Collation table (-cpcoll attribute)
     */
    void setCpColl(String cpColl);

    /**
     * Case table (-cpcase attribute)
     */
    void setCpCase(String cpCase);
    
    /**
     * The number of characters allowed in a single statement (-inp attribute)
     */
    void setInputChars(int inputChars);

    /**
     * Century year offset (-yy attribute)
     */
    void setCenturyYearOffset(int centuryYearOffset);

    /**
     * Date format (-d attribute)
     */
    void setDateFormat(String dateFormat);

    /**
     * The number of tokens allowed in a 4GL statement (-tok attribute)
     */
    void setToken(int token);

    /**
     * The amount of memory allocated for r-code segments
     */
    void setMaximumMemory(int maximumMemory);

    /**
     * The size of the stack in 1KB units.
     */
    void setStackSize(int stackSize);

    /**
     * Buffer Size for Temporary Tables (-Bt attribute)
     */
    void setTTBufferSize(int ttBufferSize);

    /**
     * Message buffer size (-Mm attribute)
     */
    void setMsgBufferSize(int msgBufSize);

    /**
     * Port number on which debugger should connect (-debugReady parameter)
     */
    void setDebugReady(int debugReady);

    /**
     * Temporary directory for Progress runtime (-T parameter)
     */
    void setTempDir(File tempDir);

    /**
     * The directory in which the Progress runtime should be executed.
     */
    void setBaseDir(File baseDir);

    /**
     * Sets the name of a property in which the return valeur of the Progress procedure should be
     * stored. Only of interest if failonerror=false.
     */
    void setResultProperty(String resultProperty);

    /**
     * Profiler support
     */
    void addProfiler(Profiler profiler);

    /**
     * If task should throw a BuildException when error occurs, or continue to next task
     */
    void setFailOnError(boolean failOnError);

    /**
     * Quick request (-q parameter)
     */
    void setQuickRequest(boolean quickRequest);

    /**
     * assemblies.xml file reference (-assemblies parameter) 
     */
    void setAssemblies(String assemblies);

    /**
     * Main procedure to be executed
     */
    void setProcedure(String procedure);

    /**
     * XCode session key
     */
    void setXCodeSessionKey(String xCodeSessionKey);

    /**
     * Add a database alias
     */
    void addDBAlias(DBAlias alias);

    /**
     * Use relative paths in COMPILE statements, and when defining PROPATH
     */
    void setRelativePaths(boolean rel);

    /**
     * Class name used for PCT callback mechanism
     */
    void setMainCallback(String callback);

    /**
     * Prevents QUIT statement to throw a BuildException
     */
    void setNoErrorOnQuit(boolean noErrorOnQuit);

    /**
     * Add init procedure to the super procedures stack
     */
    void setSuperInit(boolean superInit);

    /**
     * Name of a file to which to write the output. If the error stream is not also redirected to a file or property, it will appear in this output.
     */
    void setOutput(File output);
}