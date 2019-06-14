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
import java.util.Collection;

/**
 * Schema holders class. Used as a nested element of PCTCreateBase.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 */
public abstract class SchemaHolder {
    private String dbName = null;
    private File schemaFile = null;
    private String codepage = null;
    private String collation = null;
    private String username = null;
    private String password = null;

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * Returns schema holder name
     * 
     * @return String - Schema holder name
     */
    public String getDbName() {
        return dbName;
    }

    /**
     * Sets schema holder name
     * 
     * @param dbName String - Schema holder name
     */
    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * Returns holder's codepage
     * 
     * @return String - Codepage
     */
    public String getCodepage() {
        return codepage;
    }

    /**
     * Sets holder's codepage
     * 
     * @param codepage String - Codepage
     */
    public void setCodepage(String codepage) {
        this.codepage = codepage;
    }

    /**
     * Returns schema file to load
     * 
     * @return String - Schema file
     */
    public File getSchemaFile() {
        return schemaFile;
    }

    /**
     * Sets schema file to load
     * 
     * @param schemaFile String - Schema file
     */
    public void setSchemaFile(File schemaFile) {
        this.schemaFile = schemaFile;
    }

    /**
     * Returns holder's collation table
     * 
     * @return String - Collation table
     */
    public String getCollation() {
        return collation;
    }

    /**
     * Sets holder's collation table
     * 
     * @param collation String - Collation table
     */
    public void setCollation(String collation) {
        this.collation = collation;
    }

    /**
     * Validation of schema holder parameters. Use with care for now. Oh no, not really care, but
     * it isn't validating many things for now. In fact, this should be subclassed for every
     * database type.
     * 
     * @return True if parameters are correct
     */
    public abstract boolean validate();
    public abstract String getProcedure();
    public abstract Collection<RunParameter> getParameters();
}