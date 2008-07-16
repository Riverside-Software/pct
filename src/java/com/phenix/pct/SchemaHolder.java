/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import java.io.File;
import java.util.Collection;

/**
 * Schema holders class. Used as a nested element of PCTCreateBase.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
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
    public abstract Collection getParameters();
}