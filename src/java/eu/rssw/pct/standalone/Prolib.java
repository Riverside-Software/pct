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
package eu.rssw.pct.standalone;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.nio.file.Files;
import java.util.Collections;
import java.util.List;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import com.beust.jcommander.Parameters;
import com.phenix.pct.FileEntry;
import com.phenix.pct.PLReader;
import com.phenix.pct.RCodeInfo;
import com.phenix.pct.RCodeInfo.InvalidRCodeException;

public class Prolib {
    private static CommandExtract extract = new CommandExtract();
    private static CommandList list = new CommandList();
    private static CommandCompare compare = new CommandCompare();

    private PrintStream out;

    public Prolib() {
        this(System.out);
    }

    public Prolib(PrintStream out) {
        this.out = out;
    }

    public static void main(String[] args) {
        Prolib main = new Prolib();
        JCommander jc = new JCommander(main);
        jc.addCommand("extract", extract);
        jc.addCommand("list", list);
        jc.addCommand("compare", compare);

        try {
            jc.parse(args);
        } catch (ParameterException caught) {
            jc.usage();
            System.exit(1);
        }
        try {
            if ("list".equals(jc.getParsedCommand()))
                main.executeList();
            else if ("extract".equals(jc.getParsedCommand()))
                main.executeExtract();
            else if ("compare".equals(jc.getParsedCommand()))
                main.executeCompare();
        } catch (IOException caught) {
            main.out.println("I/O problem: " + caught.getMessage());
            System.exit(1);
        }
    }

    public void executeList() throws IOException {
        PLReader reader = new PLReader(list.lib);
        out.printf("%6s %44s %10s %s%n", "CRC", "Digest", "Size", "File");
        for (FileEntry entry : reader.getFileList()) {
            try {
                RCodeInfo info = new RCodeInfo(reader.getInputStream(entry));
                out.printf("%6d %44s %10d %s%n", info.getCRC(), info.getRcodeDigest(),
                        entry.getSize(), entry.getFileName());
            } catch (InvalidRCodeException caught) {
                out.printf("%6s %44s %10d %s%n", "-", "-", entry.getSize(),
                        entry.getFileName());
            }
        }
    }

    public void executeExtract() {
        PLReader reader = new PLReader(extract.lib);
        List<FileEntry> entries = reader.getFileList();
        if (reader.isMemoryMapped()) {
            out.println("Unable to extract files from memory-mapped library");
            return;
        }
        for (FileEntry entry : entries) {
            File file = new File(entry.getFileName().replace('\\', '/'));
            try (InputStream input = reader.getInputStream(entry)) {
                if (file.getParentFile() != null)
                    file.getParentFile().mkdirs();
                Files.copy(input, file.toPath());
            } catch (IOException e) {
                out.printf("Unable to extract file %s%n", entry.getFileName());
            }
        }
    }

    public void executeCompare() throws IOException {
        PLReader lib1 = new PLReader(compare.libs.get(0));
        PLReader lib2 = new PLReader(compare.libs.get(1));

        List<FileEntry> list1 = lib1.getFileList();
        List<FileEntry> list2 = lib2.getFileList();
        Collections.sort(list1);
        Collections.sort(list2);

        for (FileEntry entry1 : list1) {
            int idx = list2.indexOf(entry1);
            if (idx >= 0) {
                try {
                    RCodeInfo info1 = new RCodeInfo(lib1.getInputStream(entry1));
                    RCodeInfo info2 = new RCodeInfo(lib2.getInputStream(list2.get(idx)));
                    if ((info1.getCRC() == info2.getCRC())
                            && (info1.getRcodeDigest().equals(info2.getRcodeDigest()))) {
                        if (compare.showIdenticals)
                            out.println("I " + entry1.getFileName());
                    } else {
                        out.println("M " + entry1.getFileName());
                    }
                } catch (InvalidRCodeException caught) {
                    out.println("- " + entry1.getFileName());
                }
                list2.remove(idx);
            } else {
                out.println("A " + entry1.getFileName());
            }
        }
        for (FileEntry entry2 : list2) {
            out.println("R " + entry2.getFileName());
        }
    }

    @Parameters(commandDescription = "Extract files from PL")
    public static class CommandExtract {
        @Parameter(names = "-lib", description = "PL file", required = true)
        private File lib;

        @Parameter(description = "File patterns to extract")
        private List<String> patterns;
    }

    @Parameters(commandDescription = "List PL content")
    public static class CommandList {
        @Parameter(names = "-lib", description = "PL file", required = true)
        private File lib;

    }

    @Parameters(commandDescription = "Compare two PL")
    public static class CommandCompare {
        @Parameter(names = "-lib", arity = 2, description = "Source and target PL files", required = true)
        private List<File> libs;

        @Parameter(names = "-showIdenticals", description = "Also display identical files")
        private Boolean showIdenticals = false;
    }
}
