package com.phenix.pct;

import com.progress.common.property.MergeProperties;
import com.progress.common.property.MergePropertyFilter;
import com.progress.common.property.MergeUtility;
import com.progress.common.property.PropertyManager;
import com.progress.juniper.admin.JATools;
import com.progress.juniper.admin.JuniperProperties;
import com.progress.ubroker.util.PropMgrUtils;

public class TestMerge {

    /**
     * @param args
     */
    public static void main(String[] args) throws Throwable {
        System.setProperty("Install.Dir", "/opt/dlc-10.1a");
        String propFile = "/home/gillesq/ubroker.v9";
        
//        Pour database
//        JATools.setIsServer();
//        PropertyManager pm = new JuniperProperties(propFile);
        
//        Pour Appserver
//        PropMgrUtils.setUpdateUtility(true);
//        System.out.println("1");
//        PropMgrUtils propmgrutils = new PropMgrUtils(propFile, false, false);
//        System.out.println("2");
//        // PropertyManager pm = propmgrutils.m_propMgr; // PropMgrUtils.m_propMgr;
//        System.out.println("3");
//        MergeUtility mu = new MergeUtility(PropMgrUtils.m_propMgr);
//        System.out.println("4");
//        PropMgrUtils.m_propMgr.setPutPropertyFilter(new MergePropertyFilter(PropMgrUtils.m_propMgr));
//        mu.listAll("ubroker.AS");
//        System.out.println("5");
        
        Thread t = new Thread() {
            public void run() {
                try {
                    MergeProperties mp = new MergeProperties();
                    mp.setTargetFile("/home/gillesq/ubroker.v9");
                    mp.setType(MergeProperties.TYPE_UBROKER);
                    mp.setAction(MergeProperties.ACTION_LISTALL);
                    mp.setDeltaFile("UBroker.AS.Truc");
                    mp.mergeprop();
                    System.out.println(mp.toString());
                } catch (Throwable t) { System.out.println(t); }
            }
        };
        t.start();
        System.out.println("1");
        t.join();
        System.out.println("2");
    }

}
