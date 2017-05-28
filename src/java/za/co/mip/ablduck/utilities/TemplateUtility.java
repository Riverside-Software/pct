/**
 * Copyright 2017 MIP Holdings
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
package za.co.mip.ablduck;

import java.nio.file.Path;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.tools.ant.BuildException;

public class TemplateUtility {

    private static final int BUFFER_SIZE = 4096;

    static public void extractTemplate(String resourceName, File dest) throws IOException {

        try {
            File template = TemplateUtility.exportResource(resourceName, dest);
    
            TemplateUtility.unzip(template.getAbsolutePath(), dest.getAbsolutePath());
    
            template.delete();
        } catch (Exception ex) {
            throw ex;
        }
    }

    static public File exportResource(String resourceName, File dest) throws IOException {
        InputStream stream = null;
        OutputStream resStreamOut = null;
        File resource;

        try {
            stream = ABLDuck.class.getResourceAsStream("resources/" + resourceName); 
            if(stream == null) {
                throw new IOException("Cannot get resource \"" + resourceName + "\" from Jar file.");
            }
    
            int readBytes;
            byte[] buffer = new byte[BUFFER_SIZE];
            
            resource = new File(dest, resourceName); 
            resStreamOut = new FileOutputStream(resource.getAbsolutePath());
            while ((readBytes = stream.read(buffer)) > 0) {
                resStreamOut.write(buffer, 0, readBytes);
            }
        } catch (IOException ex) {
            throw ex;
        } finally {
            if(stream != null)
                stream.close();

            if(resStreamOut != null)
                resStreamOut.close();
        }
    
        return resource;
    }

    public static void unzip(String zipFilePath, String destDirectory) throws IOException {
        File destDir = new File(destDirectory);
        if (!destDir.exists()) {
            destDir.mkdir();
        }
        ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zipFilePath));
        ZipEntry entry = zipIn.getNextEntry();
        // iterates over entries in the zip file
        while (entry != null) {
            String filePath = destDirectory + File.separator + entry.getName();
            if (!entry.isDirectory()) {
                // if the entry is a file, extracts it
                extractFile(zipIn, filePath);
            } else {
                // if the entry is a directory, make the directory
                File dir = new File(filePath);
                dir.mkdir();
            }
            zipIn.closeEntry();
            entry = zipIn.getNextEntry();
        }
        zipIn.close();
    }
    
    private static void extractFile(ZipInputStream zipIn, String filePath) throws IOException {
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath));
        byte[] bytesIn = new byte[BUFFER_SIZE];
        int read = 0;
        while ((read = zipIn.read(bytesIn)) != -1) {
            bos.write(bytesIn, 0, read);
        }
        bos.close();
    }

    public static void replaceTemplateTags(String tag, String value, Path file) throws IOException {
        Charset charset = StandardCharsets.UTF_8;

        String content = new String(Files.readAllBytes(file), charset);
        content = content.replaceAll(Pattern.quote(tag), Matcher.quoteReplacement(value));
        Files.write(file, content.getBytes(charset));
    }
}