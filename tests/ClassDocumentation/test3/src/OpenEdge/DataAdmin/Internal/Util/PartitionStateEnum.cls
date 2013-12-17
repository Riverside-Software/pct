/*------------------------------------------------------------------------
    File        : PartitionStateEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri May 15 15:41:08 EDT 2009
    Notes       : Storage object Object-state is an enumerator, so we 
                  must use the bit-map  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.*.

class OpenEdge.DataAdmin.Internal.Util.PartitionStateEnum : 
    define variable mValue as int no-undo.
    /* the value of the internal var represents the position in the enum, not the value */ 
    define var mInActive         as int init 1  no-undo. /* 1 */ 
    define var mNone             as int init 2  no-undo. /* 2 */
    define var mDelayed          as int init 3  no-undo. /* 4 */
/*    define var mValue8           as int init 4  no-undo. /* 8   */*/
/*    define var mValue16          as int init 5  no-undo. /* 16  */*/
/*    define var mValue32          as int init 6  no-undo. /* 32  */*/
/*    define var mValue64          as int init 7  no-undo. /* 64  */*/
/*    define var mValue128         as int init 8  no-undo. /* 128 */*/
/*    define var mValue256         as int init 9  no-undo. /* 256 */*/
/*    define var mValue512         as int init 10 no-undo. /* 512 */*/
        
    define public property InActive as logical no-undo 
        get:
            return get-bits(mValue,mInActive,1) = 1.
        end.
        
    define public property None as logical no-undo 
        get:
            return get-bits(mValue,mNone,1) = 1.
        end.
        set(l as log):
            put-bits(mValue,mNone,1) = if l then 1 else 0. 
        end.
       
    define public property Delayed as logical no-undo 
        get:
            return get-bits(mValue,mDelayed,1) = 1.
        end.
        set(l as log):
            put-bits(mValue,mDelayed,1) = if l then 1 else 0. 
        end.
    
    define public property Value as int no-undo 
       get:
           return mValue.
       end.    
       set(i as int):
           mValue = i .
       end.  
     
     constructor public PartitionStateEnum ( ):
         super().
     end.    
     
     constructor public PartitionStateEnum (ival as int):
         super().
         mValue = ival.
     end.    
     
     
     
     
end class.