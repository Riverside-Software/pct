package eu.rssw.pct.standalone;

import java.io.File;
import java.io.IOException;
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

    public static void main(String[] args) throws Throwable {
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

        if ("list".equals(jc.getParsedCommand()))
            main.executeList();
        else if ("extract".equals(jc.getParsedCommand()))
            main.executeExtract();
        else if ("compare".equals(jc.getParsedCommand()))
            main.executeCompare();
    }

    public void executeList() throws IOException {
        PLReader reader = new PLReader(list.lib);
        System.out.printf("%6s %33s %10s %s%n", "CRC", "MD5", "Size", "File");
        for (FileEntry entry : reader.getFileList()) {
            try {
                RCodeInfo info = new RCodeInfo(reader.getInputStream(entry));
                System.out.printf("%6d %33s %10d %s%n", info.getCRC(), info.getMD5(),
                        entry.getSize(), entry.getFileName());
            } catch (InvalidRCodeException caught) {
                System.out.printf("%6s %33s %10d %s%n", "-", "-", entry.getSize(),
                        entry.getFileName());
            }
        }
    }

    public void executeExtract() {
        throw new RuntimeException("Not supported for now");
    }

    public void executeCompare() throws IOException {
        PLReader lib1 = new PLReader(compare.libs.get(0));
        PLReader lib2 = new PLReader(compare.libs.get(1));

        List<FileEntry> list1 = lib1.getFileList(), list2 = lib2.getFileList();
        Collections.sort(list1);
        Collections.sort(list2);

        for (FileEntry entry1 : list1) {
            int idx = list2.indexOf(entry1);
            if (idx >= 0) {
                try {
                    RCodeInfo info1 = new RCodeInfo(lib1.getInputStream(entry1));
                    RCodeInfo info2 = new RCodeInfo(lib2.getInputStream(list2.get(idx)));
                    if ((info1.getCRC() == info2.getCRC())
                            && (info1.getMD5().equals(info2.getMD5()))) {
                        System.out.println("I " + entry1.getFileName());
                    } else {
                        System.out.println("M " + entry1.getFileName());
                    }
                } catch (InvalidRCodeException caught) {
                    System.out.println("- " + entry1.getFileName());
                }
                list2.remove(idx);
            } else {
                System.out.println("A " + entry1.getFileName());
            }
        }
        for (FileEntry entry2 : list2) {
            System.out.println("R " + entry2.getFileName());
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

        // @Parameter(description = "File patterns to list")
        // private List<String> patterns;
    }

    @Parameters(commandDescription = "Compare two PL")
    public static class CommandCompare {
        @Parameter(names = "-lib", arity = 2, description = "Source and target PL files", required = true)
        private List<File> libs;
    }
}
