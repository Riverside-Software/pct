package com.phenix.pct;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Map;

import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import com.phenix.pct.BackgroundWorker.Message;

public class BackgroundWorkerTest {
    private SimpleBackgroundWorker backgroundWorker;
    
    private static class SimpleBackgroundWorker extends BackgroundWorker {

        private List<Message> returnValues;
        private String customResponse;

        public SimpleBackgroundWorker(PCTBgRun parent) {
            super(parent);
        }

        @Override
        protected boolean performCustomAction() throws IOException {
            return false;
        }

        @Override
        public void setCustomOptions(Map<String, String> options) {
            
        }

        @Override
        public void handleResponse(String command, String parameter, boolean err,
                String customResponse, List<Message> returnValues) {
            this.returnValues = returnValues;
            this.customResponse = customResponse;
        }

        public String getCustomResponse() {
            return customResponse;
        }

        public List<Message> getReturnValues() {
            return returnValues;
        }
        
    }
    
    @BeforeTest(groups = {"v10"})
    public void setUp() {
        PCTBgRun parent = mock(PCTBgRun.class);
        backgroundWorker = new SimpleBackgroundWorker(parent);
        
        Charset utf8 = Charset.forName("utf-8");
        when(parent.getCharset()).thenReturn(utf8);
    }
    
    public Socket setUpSocket(String contentsToRead) throws IOException {
        Socket socket = mock(Socket.class);
        
        InputStream bais = new ByteArrayInputStream(contentsToRead.getBytes());
        OutputStream mockOS = mock(OutputStream.class);
        when(socket.getInputStream()).thenReturn(bais);
        when(socket.getOutputStream()).thenReturn(mockOS);
        
        return socket;
    }

    @Test(groups = {"v10"})
    public void readMSGFromResponsePacket() throws IOException {
        Socket socket = setUpSocket( "\n" + "MSG:0:Message here\n" + "END");

        // get more general overview
        backgroundWorker.initialize(socket);
        backgroundWorker.listen();
        assertNotNull(backgroundWorker.getReturnValues());
        assertEquals(1, backgroundWorker.getReturnValues().size(), "Expected one message");
        Message m = backgroundWorker.getReturnValues().get(0);
        assertEquals("Message here", m.getMsg());
        assertEquals(0, m.getLevel());
    }
    
    @Test(groups = {"v10"})
    public void readOKFromResponsePacket() throws IOException {
        Socket socket = setUpSocket("\n" + "OK\n" + "END");
        
        backgroundWorker.initialize(socket);
        backgroundWorker.listen();
    }
    
    @Test(groups = {"v10"})
    public void readERRFromResponsePacket() throws IOException {
        Socket socket = setUpSocket("\n" + "ERR:Error message\n" + "END");
        
        backgroundWorker.initialize(socket);
        backgroundWorker.listen();
        
        assertEquals("Error message", backgroundWorker.getCustomResponse());
    }
    
    @Test(groups = {"v10"})
    public void testEmptyResponsePacketDoesNotThrowNPE() throws IOException {
        Socket socket = setUpSocket("\n");
        
        backgroundWorker.initialize(socket);
        backgroundWorker.listen();
    }
}
