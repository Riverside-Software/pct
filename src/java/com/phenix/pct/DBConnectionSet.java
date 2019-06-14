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

import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.types.DataType;

/**
 * Ant datatype, handling database connections, to be used in PCTRun tasks
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class DBConnectionSet extends DataType {
    private Collection<PCTConnection> connections = new ArrayList<>();

    // Variation pour antlib
    public void addDb_Connection(PCTConnection conn) {
        addDbConnection(conn);
    }

    public void addDbConnection(PCTConnection conn) {
        connections.add(conn);
    }

    public DBConnectionSet getRef() {
        return (DBConnectionSet) getCheckedRef();
    }

    /**
     * Returns a collection of PCTConnection
     * 
     * @return A non-null collection of PCTConnection
     */
    public Collection<PCTConnection> getDBConnections() {
        Collection<PCTConnection> coll = new ArrayList<>();
        coll.addAll(connections);

        if (isReference())
            coll.addAll(getRef().getDBConnections());

        return coll;
    }
}
