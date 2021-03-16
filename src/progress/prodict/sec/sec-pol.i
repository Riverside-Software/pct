/*********************************************************************
* Copyright (C) 2008-2009 by Progress Software Corporation. All rights    *
* reserved.                                                          *
*                                                                    *
*********************************************************************/

/*--------------------------------------------------------------------

File: prodict/sec/sec-pol.i

Description:
    Defines temp-table for object attributes such as encryption
    policy settings and alternate buffer pool.
        
History:
    07/01/08  fernando   created
    04/08/09  fernando   adding fields for buffer pool

--------------------------------------------------------------------*/

DEFINE TEMP-TABLE ttObjAttrs NO-UNDO BEFORE-TABLE bfttObjAttrs
    FIELD seq-num      AS INT
    FIELD obj-num      AS INT
    FIELD obj-type     AS CHAR
    FIELD obj-name     AS CHAR
    FIELD obj-area     AS INT
    FIELD disp-name    AS CHAR
    FIELD obj-cipher   AS CHAR
    FIELD has-prev-pol AS LOGICAL
    FIELD obj-genkey   AS LOGICAL
    FIELD obj-buf-pool AS CHARACTER  /* for buffer pool */
    FIELD area-buf-pool AS CHARACTER /* for buffer pool*/
    FIELD obj-selected  AS LOGICAL
    INDEX idx-seq  IS UNIQUE PRIMARY seq-num
    INDEX idx-name IS UNIQUE obj-name obj-type
    INDEX idx-num  obj-num obj-type.

DEFINE TEMP-TABLE ttObjEncPolicyVersions NO-UNDO
    FIELD obj-name    AS CHAR
    FIELD seq-num     AS INT
    FIELD pol-version AS INTEGER
    FIELD pol-state   AS CHAR
    FIELD pol-cipher  AS CHAR
    INDEX idx-name IS UNIQUE seq-num pol-version DESC.

DEFINE DATASET dsObjAttrs FOR ttObjAttrs, ttObjEncPolicyVersions.


