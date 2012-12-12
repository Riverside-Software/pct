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

import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class ProgressV10 implements ProgressProcedures {
    private static final String BUNDLE_NAME = "com.phenix.pct.ProgressV10"; //$NON-NLS-1$
    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

    public String getCompileProcedure() {
        return "pct/pctCompileV10.p";
    }

    public String getIncrementalProcedure() {
        return "pct/dump_inc.p";
    }

    public String getDumpUsersProcedure() {
        return "pct/dmpUsers.p";
    }

    public String getLoadUsersProcedure() {
        return "pct/loadUsers.p";
    }

    public boolean needRedirector() {
        return false;
    }

    public String getInitString() {
        return getString("ProgressV10.0"); //$NON-NLS-1$
    }

    public String getConnectString() {
        return getString("ProgressV10.1"); //$NON-NLS-1$
    }

    public String getAliasString() {
        return getString("ProgressV10.2"); //$NON-NLS-1$
    }

    public String getPropathString() {
        return getString("ProgressV10.3"); //$NON-NLS-1$
    }

    public String getRunString() {
        return getString("ProgressV10.4"); //$NON-NLS-1$
    }

    public String getReturnProc() {
        return getString("ProgressV10.5"); //$NON-NLS-1$
    }

    public String getParameterString() {
        return getString("ProgressV10.6"); //$NON-NLS-1$
    }

    public String getString(String key) {
        try {
            return RESOURCE_BUNDLE.getString(key);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
    }

    public String getOutputParameterDeclaration() {
        return getString("ProgressV10.8"); //$NON-NLS-1$
    }

    public String getOutputParameterProc() {
        return getString("ProgressV10.9"); //$NON-NLS-1$
    }

    public String getAfterRun() {
        return getString("ProgressV10.10"); //$NON-NLS-1$
    }

    public String getOutputParameterCall() {
        return getString("ProgressV10.11"); //$NON-NLS-1$
    }

    public String getQuit() {
        return getString("ProgressV10.12"); //$NON-NLS-1$
    }
}
