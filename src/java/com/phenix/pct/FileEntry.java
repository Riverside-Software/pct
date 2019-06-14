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

import java.text.MessageFormat;
import java.util.Date;

/**
 * Class representing a file entry in a PL file
 */
public class FileEntry implements Comparable<FileEntry> {
    private final boolean valid;
    private final String fileName;
    private final long modDate, addDate;
    private final int offset, size, tocSize;

    /**
     * Invalid file entry - Will be skipped in entries list
     */
    public FileEntry(int tocSize) {
        this.tocSize = tocSize;
        valid = false;
        fileName = "";
        modDate = addDate = offset = 0;
        size = 0;
    }

    public FileEntry(String fileName, long modDate, long addDate, int offSet, int size, int tocSize) {
        this.valid = true;
        this.fileName = fileName;
        this.modDate = modDate;
        this.addDate = addDate;
        this.offset = offSet;
        this.size = size;
        this.tocSize = tocSize;
    }

    public String getFileName() {
        return fileName;
    }

    public int getSize() {
        return size;
    }

    public long getModDate() {
        return modDate;
    }

    public long getAddDate() {
        return addDate;
    }

    public int getOffset() {
        return offset;
    }

    public int getTocSize() {
        return tocSize;
    }

    public boolean isValid() {
        return valid;
    }

    @Override
    public String toString() {
        return MessageFormat
                .format(Messages.getString("PLReader.6"), this.fileName, Integer.valueOf(size), new Date(addDate), new Date(modDate), Long.valueOf(offset)); //$NON-NLS-1$
    }

    @Override
    public int compareTo(FileEntry o) {
        return fileName.compareTo(o.getFileName());
    }

    @Override
    public int hashCode() {
        return fileName.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof FileEntry)
            return fileName.equals(((FileEntry) obj).getFileName());
        return false;
    }
}
