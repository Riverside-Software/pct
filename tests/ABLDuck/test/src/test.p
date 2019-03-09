/**
 * # Purpose
 * The application factorys main purpose is to manage the life-cycle of
 *
 * @author              Robert Edwards
 * @param ipcMainInput1 Are we at the start of the request.
 *                      Multiline parameter comment... cool
 * @deprecated 1.0.0 Please use something else.
 * @internal
 */

DEFINE INPUT PARAMETER ipcMainInput1 AS CHARACTER 	NO-UNDO.


/**
 * testProcedure comment
 * This is two paragraphs. _markdown_ is also supported here. Lorem ipsum dolor sit amet,
 * consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
 * Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
 *
 *     /* This is a comment */
 *     DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.
 *     RUN testProcedure IN TARGET-PROCEDURE (INPUT "test", OUTPUT cResult).
 *
 * @param ipcInput1 salkdjsaklds.
 *                  Multiline parameter comment... cool
 * @param opcOutput1 someOutput.
 *                   Multiline parameter comment... cool
 */
PROCEDURE testProcedure:
	DEFINE INPUT  PARAMETER ipcInput1  AS CHARACTER 	NO-UNDO.
	DEFINE OUTPUT PARAMETER opcOutput1 AS CHARACTER 	NO-UNDO.

END PROCEDURE.


/**
 * testFunction comment
 * This is two paragraphs. _markdown_ is also supported here. Lorem ipsum dolor sit amet,
 * consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
 * Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
 *
 *     /* This is a comment */
 *     DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.
 *     cResult = testFunction (INPUT "test").
 *
 * @param ipcInput1 Are we at the start of the request.
 *                  Multiline parameter comment... cool
 * @return         Returns something if successful and something else if not
 */
FUNCTION testFunction RETURNS CHARACTER
  (INPUT ipcInput1  AS CHARACTER):

END PROCEDURE.