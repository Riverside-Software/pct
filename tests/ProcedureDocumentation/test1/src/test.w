&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          symix            PROGRESS
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER i-MP AS CHAR.
DEFINE INPUT PARAMETER i-LIEU AS CHAR.
DEFINE INPUT PARAMETER i-EDIT AS CHAR.


/* Local Variable Definitions ---                                       */

&SCOPED-DEFINE HarvestID
def var HarvestID as char init "$Header$" no-undo.
DEFINE VARIABLE RcsId AS CHARACTER INITIAL "$Header$" NO-UNDO.

/* Local Variable Definitions ---                                       */
DEF SHARED VAR call-var AS CHAR .   /* login user */
DEF SHARED VAR cur-whse        LIKE symix.whse.whse.

DEF NEW SHARED VAR cur-description LIKE symix.item.description.
DEF NEW SHARED VAR v-editeur-desc  LIKE symix.whse.name NO-UNDO.
DEF NEW SHARED VAR v-lieu-desc     LIKE symix.location.description NO-UNDO.
DEF NEW SHARED VAR cur-job         LIKE symmods.zastk.job.
DEF VAR cur-habili AS CHARACTER .
DEF VAR entit-fab LIKE symix.po.whse.

def temp-table affect field Article as character format "X(13)" label "Ean13 " bgcolor 37
                      field Qualit as character format "X(5)" label "Qual." 
                      field whse like symix.whse.whse
                      field libqual as character format "X(13)" label "Lib.qualité " bgcolor 60
                      field Larg as integer format 9999 label "Larg." bgcolor 64
                      field Lg as integer format 9999 label "Long." bgcolor 62
                      field gram as integer format 999 label "Gram" bgcolor 63
                      field Datebes as date label "Date bes"
                      FIELD DATE-liv-ouvrage as date label "Liv Ouvr"
                      FIELD revision as character format "X(3)" LABEL "Ed." bgcolor 60
                      FIELD titre as character format "X(35)" LABEL "Titre"
                      FIELD qte-all as decimal format "-ZZZ,ZZZ,ZZ9" label "Qté Allouée" bgcolor 37
                      field UM like symix.item.u-m label "Um"
                      field qte-to as decimal format "-ZZZ,ZZ9.999" column-label "Qte/Ton" bgcolor 60
                      field li AS CHARACTER FORMAT "X" LABEL "Li"
                      field lieu-act as character format "X(6)" label "lieu"
                      field desi as char format "X(29)" label "Libellé Lieu"
                      field job      like symmods.zastk.job
                      field composant as character format "X(3)" label "Comp" bgcolor 64
                      FIELD oper-num as INTEGER
                      field date-liv as CHAR  FORMAT "X(8)" label "Date Liv" bgcolor 37
                      FIELD No-OT  LIKE ot-lig.no-ot bgcolor 46
                      FIELD ot-sta LIKE ot-lig.STATUt bgcolor 46
                      FIELD ot-oa LIKE symix.po.po-num  bgcolor 46
                      FIELD ot-lib AS CHAR FORMAT "x(20)" LABEL "Libellé transfert" bgcolor 46.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES affect

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 affect.qualit affect.libqual affect.larg affect.lg affect.gram affect.whse affect.article affect.revision affect.composant affect.titre affect.qte-all affect.um affect.qte-to affect.li affect.datebes affect.DATE-liv-ouvrage affect.date-liv affect.lieu-act affect.desi affect.no-ot affect.ot-sta affect.ot-oa affect.ot-lib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1   
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH affect by affect.datebes by affect.qualit by affect.larg                 by affect.lg by affect.gram.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 affect
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 affect


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS w-article Btn-lookup Btn-recherche W-lieu ~
Cde-liv w-entite t-Domaine BROWSE-1 Btn-lookup-2 Btn-lookup-3 
&Scoped-Define DISPLAYED-OBJECTS w-article W-desi W-lieu W-desi-lieu ~
Cde-liv w-entite W-desi-entite t-Domaine 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn-lookup 
     IMAGE-UP FILE "images\lookup-u":U
     IMAGE-INSENSITIVE FILE "images\lookup-i":U NO-FOCUS
     LABEL " " 
     SIZE 3.86 BY 1.04 TOOLTIP "Visualisation d'article".

DEFINE BUTTON Btn-lookup-2 
     IMAGE-UP FILE "images\lookup-u":U
     IMAGE-INSENSITIVE FILE "images\lookup-i":U NO-FOCUS
     LABEL " " 
     SIZE 3.86 BY 1.04 TOOLTIP "Visualisation d'article".

DEFINE BUTTON Btn-lookup-3 
     IMAGE-UP FILE "images\lookup-u":U
     IMAGE-INSENSITIVE FILE "images\lookup-i":U NO-FOCUS
     LABEL " " 
     SIZE 3.86 BY 1.04 TOOLTIP "Visualisation d'article".

DEFINE BUTTON Btn-recherche 
     LABEL "Recherche" 
     SIZE 11.86 BY 1.96.

DEFINE VARIABLE t-Domaine AS CHARACTER FORMAT "X(40)":U 
     LABEL "Domaine" 
     VIEW-AS FILL-IN 
     SIZE 30 BY 1
     BGCOLOR 37  NO-UNDO.

DEFINE VARIABLE w-article AS CHARACTER FORMAT "X(30)":U 
     LABEL "Article" 
     VIEW-AS FILL-IN 
     SIZE 25.43 BY 1 NO-UNDO.

DEFINE VARIABLE W-desi AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 49.72 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE W-desi-entite AS CHARACTER FORMAT "X(30)":U 
     VIEW-AS FILL-IN 
     SIZE 36.86 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE W-desi-lieu AS CHARACTER FORMAT "X(30)":U 
     VIEW-AS FILL-IN 
     SIZE 36.86 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE w-entite AS CHARACTER FORMAT "X(4)":U 
     LABEL "Entité" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE W-lieu AS CHARACTER FORMAT "X(7)":U 
     LABEL "Lieu Stock" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE Cde-liv AS LOGICAL INITIAL yes 
     LABEL "Plus commandes et Transferts à Livrer sur le lieu" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR 
      affect SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 C-Win _FREEFORM
  QUERY BROWSE-1 DISPLAY
      affect.qualit
      affect.libqual
affect.larg
affect.lg
affect.gram
affect.whse format "X(5)" label "Ent."
affect.article format "X(16)"
affect.revision
affect.composant format "x(3)" label "Cp"
affect.titre format "X(20)"
affect.qte-all 
affect.um
affect.qte-to format "-Z,ZZ9.999"
affect.li
affect.datebes
affect.DATE-liv-ouvrage
affect.date-liv
affect.lieu-act
affect.desi
affect.no-ot FORMAT "X(10)"
affect.ot-sta FORMAT "X(15)"
affect.ot-oa FORMAT "X(10)"
affect.ot-lib FORMAT "X(25)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 113.43 BY 15.46
         FONT 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     w-article AT ROW 1.27 COL 8.43 COLON-ALIGNED
     Btn-lookup AT ROW 1.27 COL 87.86
     W-desi AT ROW 1.27 COL 35 COLON-ALIGNED NO-LABEL
     Btn-recherche AT ROW 1.35 COL 99.86
     W-lieu AT ROW 2.5 COL 8.43 COLON-ALIGNED
     W-desi-lieu AT ROW 2.5 COL 16.43 COLON-ALIGNED NO-LABEL
     Cde-liv AT ROW 2.62 COL 60.72
     w-entite AT ROW 3.77 COL 8.43 COLON-ALIGNED
     W-desi-entite AT ROW 3.77 COL 17.57 COLON-ALIGNED NO-LABEL
     t-Domaine AT ROW 3.77 COL 80 COLON-ALIGNED
     BROWSE-1 AT ROW 4.81 COL 1.29
     Btn-lookup-2 AT ROW 2.5 COL 56.43
     Btn-lookup-3 AT ROW 3.77 COL 57.57
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 113.86 BY 19.92
         FONT 6.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Consultations des affectations par article MP (Gestion Appros)"
         HEIGHT             = 20.15
         WIDTH              = 113.14
         MAX-HEIGHT         = 27.73
         MAX-WIDTH          = 146.29
         VIRTUAL-HEIGHT     = 27.73
         VIRTUAL-WIDTH      = 146.29
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
                                                                        */
/* BROWSE-TAB BROWSE-1 t-Domaine DEFAULT-FRAME */
/* SETTINGS FOR FILL-IN W-desi IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN W-desi-entite IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN W-desi-lieu IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH affect by affect.datebes by affect.qualit by affect.larg
                by affect.lg by affect.gram.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Consultations des affectations par article MP (Gestion Appros) */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Consultations des affectations par article MP (Gestion Appros) */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1 IN FRAME DEFAULT-FRAME
DO:
cur-job = affect.job.
c-win:sensitive = false.
run dosfab/dosfab.w.
c-win:sensitive = true.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON ROW-DISPLAY OF BROWSE-1 IN FRAME DEFAULT-FRAME
DO:
    IF affect.lieu-act = "Cde" OR affect.no-ot <>""THEN DO:
    IF affect.datebes < DATE (affect.date-liv)  THEN DO:
    
    
        affect.Datebes:BGCOLOR IN BROWSE {&BROWSE-name} = 58.
        affect.lieu-act:BGCOLOR IN BROWSE {&BROWSE-name} = 58.
        affect.date-liv:BGCOLOR IN BROWSE {&BROWSE-name} = 58.
        affect.desi:BGCOLOR IN BROWSE {&BROWSE-name} = 58.
        affect.no-ot:BGCOLOR IN BROWSE {&BROWSE-name} = 58.
    END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON VALUE-CHANGED OF BROWSE-1 IN FRAME DEFAULT-FRAME
DO:
   assign self:tooltip = "Titre en entier : " + affect.titre. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-lookup C-Win
ON CHOOSE OF Btn-lookup IN FRAME DEFAULT-FRAME /*   */
DO:
  run browse\item-mp.p.
  ASSIGN w-article:SCREEN-VALUE = i-MP
                      w-article = i-MP.
                      
  find symix.item where item.item = i-MP NO-LOCK.
  IF AVAILABLE item then do:
    ASSIGN w-desi:SCREEN-VALUE = item.description
                        w-desi = item.description.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-lookup-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-lookup-2 C-Win
ON CHOOSE OF Btn-lookup-2 IN FRAME DEFAULT-FRAME /*   */
DO:
  run browse\loc-desc.p.
  ASSIGN w-lieu:SCREEN-VALUE = i-Lieu
                      w-lieu = i-Lieu
       w-desi-lieu:SCREEN-VALUE = v-lieu-desc
                    w-desi-lieu = v-lieu-desc.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-lookup-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-lookup-3 C-Win
ON CHOOSE OF Btn-lookup-3 IN FRAME DEFAULT-FRAME /*   */
DO:
  run browse/whse-name.p.
  ASSIGN w-entite:SCREEN-VALUE = i-edit
                      w-entite = i-edit 
    w-desi-entite:SCREEN-VALUE = v-editeur-desc
                 w-desi-entite = v-editeur-desc.
END.



&Scoped-define SELF-NAME Btn-recherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-recherche C-Win
ON CHOOSE OF Btn-recherche IN FRAME DEFAULT-FRAME /* Recherche */
DO:
    DEFINE VAR SELECT_aff AS LOGICAL.
    DEFINE VAR l-ean13 LIKE symix.job.ITEM .
    DEFINE VAR l-noedi LIKE symix.job.revision .
    DEFINE VAR l-entite LIKE symix.job.whse.


IF w-article:SCREEN-VALUE = " " AND w-entite:SCREEN-VALUE = " " and w-lieu:SCREEN-VALUE = " " 
            /* si la référence article est non renseignée, cela implique :      */
            /*    soit un code lieu renseigné                                   */
            /*    soit un code entité renseigné                                 */
        THEN DO .
           MESSAGE "Article obligatoire si lieu ou entité non renseignés" view-as alert-box.
           RETURN no-apply.
        END .
  
  FOR EACH Affect :
     DELETE Affect.
  END.
                     
 FOR EACH symmods.zastk NO-LOCK :

     IF cur-habili = '9' THEN NEXT. /* aucune habilitation by-pass systématique */

     l-ean13  = " " .
     l-noedi  = " " .
     l-entite = "***" .

     find symix.job where job.job = zastk.job no-lock no-error.
     if available job then do:
         l-ean13  = job.ITEM .
         l-noedi  = job.revision .
/*          l-entite = job.whse .  */
     end.
     ELSE do:
        find zjobean13 where zjobean13.job = zastk.job no-lock no-error.
        if available zjobean13 THEN DO :
            l-ean13  = zjobean13.ean .
            l-noedi  = zjobean13.edition .
/*             FIND first symmods.zean13 WHERE zean13.cpean = zjobean13.ean  */
/*                  AND zean13.coned = zjobean13.edition NO-LOCK NO-ERROR.   */
/*              IF AVAILABLE zean13 THEN l-entite = zean13.ented .           */
        END .
      END .

      l-entite = zastk.ented .

     SELECT_aff = YES.
      IF w-article:SCREEN-VALUE <> " " AND (w-article:SCREEN-VALUE  <> symmods.zastk.ITEM)       THEN SELECT_aff = NO.
      IF w-entite:SCREEN-VALUE  <> " " AND (w-entite:SCREEN-VALUE   <> l-entite)                 THEN SELECT_aff = NO.
      IF w-lieu:SCREEN-VALUE    <> " " THEN DO:
       IF (w-lieu:SCREEN-VALUE = symmods.zastk.lieu-act) THEN.
       ELSE DO:
       IF ((symmods.zastk.lieu-act <> symmods.zastk.lieu-dest)) AND (cde-liv:SCREEN-VALUE = "YES") AND (symmods.zastk.lieu-dest = w-lieu:SCREEN-VALUE ) THEN.
                                           ELSE SELECT_aff = NO.
       END.
      END.



      /* cas d'une recherche toutes entités (w-entite:SCREEN-VALUE = "" )       */
      /* limitation de l'affichage  (sauf habilitation Administrateur)          */
      /* utilisateurs GAP / HAchette ==> toutes entités Hachette                */
      /* autres utilisateurs         ==> limitation aux entités du même domaine */

      IF w-entite:SCREEN-VALUE = " " AND cur-habili <> '0'
           THEN DO :
              FIND FIRST s-stk WHERE s-stk.whse = l-entite NO-LOCK NO-ERROR.
              IF AVAILABLE s-stk
              THEN DO :
                  IF ( cur-habili = "1" AND t-domaine:SCREEN-VALUE <> s-stk.groupe  ) THEN SELECT_aff = NO.
                  IF ( cur-habili = "2" AND t-domaine:SCREEN-VALUE <> s-stk.branche ) THEN SELECT_aff = NO.
                  IF ( cur-habili = "3" AND t-domaine:SCREEN-VALUE <> s-stk.domaine ) THEN SELECT_aff = NO.
              END.
              ELSE DO :
                  SELECT_aff = NO.
              END.

           END.


      IF SELECT_aff = NO THEN NEXT.

      CREATE affect.
      ASSIGN affect.composant = symmods.zastk.composant
             affect.job       = symmods.zastk.job
             affect.qte-all   = symmods.zastk.qte-affect.
      IF symmods.zastk.lieu-act = "Dispo" THEN affect.lieu-act  = "Cde".
                                          ELSE affect.lieu-act  = symmods.zastk.lieu-act.
      ASSIGN affect.article   = l-ean13
             affect.revision  = l-noedi
             affect.whse      = l-entite
             .

      FIND symix.item WHERE item.item = symmods.zastk.item NO-LOCK no-error.
      if available item then do :
         ASSIGN affect.qualit = item.charfld2
                affect.gram   = item.decifld1
                affect.larg   = item.decifld3
                affect.lg     = item.decifld2
                affect.um     = item.u-m
                affect.libqual = TRIM(SUBSTRING(symix.item.description,30,11)).


         IF TRIM(item.u-m) = "ml"
         THEN ASSIGN affect.qte-to = (symmods.zastk.qte-aff * (affect.lg / 1000) * (affect.gram / 1000000)).
         ELSE ASSIGN affect.qte-to = (symmods.zastk.qte-aff * (affect.lg / 1000) * (affect.gram / 1000000) * (affect.larg / 1000)).
      end.

     FIND first symmods.zdem WHERE symmods.zdem.job = symmods.zastk.job AND symmods.zdem.oper-num = symmods.zastk.oper-num NO-LOCK NO-ERROR.
        if available zdem then  ASSIGN affect.datebes = symmods.zdem.dt-bes .


     find last zpolieu where zpolieu.job = zastk.job and zpolieu.dope = yes and zpolieu.qter
     > 0 no-lock no-error.
       IF AVAIL zpolieu THEN ASSIGN affect.li = "Y".
                        ELSE ASSIGN affect.li = "N".


     /*FIND LAST jobmatl WHERE jobmatl.job = symmods.zastk.job AND jobmatl.oper-num = symmods.zastk.oper-num NO-LOCK NO-ERROR.
 *      IF AVAIL jobmatl THEN ASSIGN affect.li = "Y".
 *                       ELSE ASSIGN affect.li = "N".
 * */

    IF affect.article <> "" THEN DO:

       FIND first zean13 WHERE symmods.zean13.cpean = affect.article
            AND symmods.zean13.coned = affect.revision NO-LOCK NO-ERROR.
       IF AVAILABLE zean13 THEN DO:
       ASSIGN affect.titre = symmods.zean13.liaco.
              affect.whse = zean13.ented.
        END.
        ELSE ASSIGN affect.titre = affect.job + "-" +  affect.revision + " non trouvé".
    END.

     IF zastk.lieu-act = "Dispo" OR  zastk.lieu-act = "Transit" THEN DO:
     FIND symix.location WHERE location.loc = zastk.lieu-dest NO-LOCK NO-ERROR.
     IF AVAILABLE location THEN affect.desi = "Dest: " + trim(zastk.lieu-dest) + "-" + location.DESCRIPTION.
     END.
     ELSE DO:
       FIND location where location.loc = affect.lieu-act NO-LOCK NO-ERROR.
       IF AVAILABLE location then affect.desi = location.DESCRIPTION.
     END.

IF zastk.lieu-act = "Dispo"  THEN DO:
find symix.poitem where symix.poitem.po-num = entry(1, zastk.lot,"-") AND symix.poitem.po-line = integer(entry(2, zastk.lot,"-")) no-lock no-error.
   if available symix.poitem then affect.date-liv = STRING(symix.poitem.due-date).
END.

if not available zean13 or affect.titre  = "" then  DO:
        IF affect.job BEGINS "t"
            THEN ASSIGN  affect.titre = "Transfert libre" .
            ELSE ASSIGN  affect.titre = affect.job  + " non trouvé".

END.

IF zastk.no-ot <> "" AND zastk.lieu-act <> zastk.lieu-dest THEN DO:
    affect.no-ot = zastk.no-ot.

    FIND FIRST ot-lig WHERE ot-lig.no-ot = zastk.no-ot NO-LOCK NO-ERROR.
    IF NOT AVAILABLE ot-lig THEN .
      ELSE DO:
      affect.ot-sta = ot-lig.STATUT.
      affect.ot-oa = ot-lig.po-num.
      affect.ot-lib = "De " + ot-lig.lieu-act + " Vers " + ot-lig.lieu-dest.
      IF ot-lig.dt-rec <> ? THEN affect.date-liv =  STRING(ot-lig.dt-rec).
                             ELSE affect.date-liv =  "Non Prévue".   
    END.
END.

END.
    
     {&open-query-browse-1}
     if available affect then apply "Value-changed" to browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-recherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-recherche C-Win
ON CHOOSE OF Btn-recherche IN FRAME DEFAULT-FRAME /* Recherche */
DO:
    DEFINE VAR SELECT_aff AS LOGICAL.
    DEFINE VAR l-ean13 LIKE symix.job.ITEM .
    DEFINE VAR l-noedi LIKE symix.job.revision .
    DEFINE VAR l-entite LIKE symix.job.whse.


IF w-article:SCREEN-VALUE = " " AND w-entite:SCREEN-VALUE = " " and w-lieu:SCREEN-VALUE = " " 
            /* si la référence article est non renseignée, cela implique :      */
            /*    soit un code lieu renseigné                                   */
            /*    soit un code entité renseigné                                 */
        THEN DO .
           MESSAGE "Article obligatoire si lieu ou entité non renseignés" view-as alert-box.
           RETURN no-apply.
        END .
  
  FOR EACH Affect :
     DELETE Affect.
  END.
                     
 FOR EACH symmods.zastk NO-LOCK :

     IF cur-habili = '9' THEN NEXT. /* aucune habilitation by-pass systématique */

     l-ean13  = " " .
     l-noedi  = " " .
     l-entite = zastk.ented.

     find symix.job where job.job = zastk.job no-lock no-error.
     if available job then do:
         l-ean13  = job.ITEM .
         l-noedi  = job.revision .
         l-entite = job.whse.
     end.
     ELSE do:
        find zjobean13 where zjobean13.job = zastk.job no-lock no-error.
        if available zjobean13 THEN DO :
            l-ean13  = zjobean13.ean .
            l-noedi  = zjobean13.edition .
            FIND first symmods.zean13 WHERE zean13.cpean = zjobean13.ean
                 AND zean13.coned = zjobean13.edition NO-LOCK NO-ERROR.
             IF AVAILABLE zean13 THEN l-entite = zean13.ented .
        END .
        
      END .

/*       l-entite = zastk.ented.  */

     SELECT_aff = YES.

      IF w-article:SCREEN-VALUE <> "" AND (w-article:SCREEN-VALUE  <> symmods.zastk.ITEM)       THEN SELECT_aff = NO.
      IF w-entite:SCREEN-VALUE  <> "" AND (w-entite:SCREEN-VALUE   <> l-entite)                 THEN SELECT_aff = NO.
      IF w-lieu:SCREEN-VALUE    <> "" THEN DO:
       IF (w-lieu:SCREEN-VALUE = symmods.zastk.lieu-act) THEN.
       ELSE DO:
       IF ((symmods.zastk.lieu-act <> symmods.zastk.lieu-dest)) AND (cde-liv:SCREEN-VALUE = "YES") AND (symmods.zastk.lieu-dest = w-lieu:SCREEN-VALUE ) THEN.
                                                                                                                                                        ELSE SELECT_aff = NO.
       END.
      END.

      /* cas d'une recherche toutes entités (w-entite:SCREEN-VALUE = "" )       */
      /* limitation de l'affichage  (sauf habilitation Administrateur)          */
      /* utilisateurs GAP / HAchette ==> toutes entités Hachette                */
      /* autres utilisateurs         ==> limitation aux entités du même domaine */

      IF w-entite:SCREEN-VALUE = " " AND cur-habili <> '0'
           THEN DO :
              FIND FIRST s-stk WHERE s-stk.whse = l-entite NO-LOCK NO-ERROR.
              IF AVAILABLE s-stk
              THEN DO :
                  IF ( cur-habili = "1" AND t-domaine:SCREEN-VALUE <> s-stk.groupe  ) THEN SELECT_aff = NO.
                  IF ( cur-habili = "2" AND t-domaine:SCREEN-VALUE <> s-stk.branche ) THEN SELECT_aff = NO.
                  IF ( cur-habili = "3" AND t-domaine:SCREEN-VALUE <> s-stk.domaine ) THEN SELECT_aff = NO.
              END.
              ELSE DO :
                  SELECT_aff = NO.
              END.

           END.

      IF SELECT_aff = NO THEN NEXT.

/*       IF SELECT_aff = YES AND zastk.ented <> w-entite:SCREEN-VALUE THEN MESSAGE zastk.job zastk.ented w-entite:SCREEN-VALUE. */

      CREATE affect.
      ASSIGN affect.composant = symmods.zastk.composant
             affect.job       = symmods.zastk.job
             affect.oper-num  = symmods.zastk.oper-num
             affect.qte-all   = symmods.zastk.qte-affect.
      IF symmods.zastk.lieu-act = "Dispo" THEN affect.lieu-act  = "Cde".
                                          ELSE affect.lieu-act  = symmods.zastk.lieu-act.
      ASSIGN affect.article   = l-ean13
             affect.revision  = l-noedi
             affect.whse      = l-entite
             .

      FIND symix.item WHERE item.item = symmods.zastk.item NO-LOCK no-error.
      if available item then do :
         ASSIGN affect.qualit = item.charfld2
                affect.gram   = item.decifld1
                affect.larg   = item.decifld3
                affect.lg     = item.decifld2
                affect.um     = item.u-m
                affect.libqual = TRIM(SUBSTRING(symix.item.description,30,11)).


         IF TRIM(item.u-m) = "ml"
         THEN ASSIGN affect.qte-to = (symmods.zastk.qte-aff * (affect.lg / 1000) * (affect.gram / 1000000)).
         ELSE ASSIGN affect.qte-to = (symmods.zastk.qte-aff * (affect.lg / 1000) * (affect.gram / 1000000) * (affect.larg / 1000)).
      end.

     FIND first symmods.zdem WHERE symmods.zdem.job = symmods.zastk.job AND symmods.zdem.oper-num = symmods.zastk.oper-num NO-LOCK NO-ERROR.
        if available zdem then  ASSIGN affect.datebes = symmods.zdem.dt-bes .


     find last zpolieu where zpolieu.job = zastk.job and zpolieu.dope = yes and zpolieu.qter
     > 0 no-lock no-error.
       IF AVAIL zpolieu THEN DO:
                        ASSIGN affect.li = "Y".
                        ASSIGN affect.date-liv-ouvrage = zpolieu.dtli.
                        END.
                        ELSE ASSIGN affect.li = "N".
    find last zpolieu where zpolieu.job = zastk.job and zpolieu.dope = yes no-lock no-error.
         IF AVAIL zpolieu THEN ASSIGN affect.date-liv-ouvrage = zpolieu.dtli.
                                            

     /*FIND LAST jobmatl WHERE jobmatl.job = symmods.zastk.job AND jobmatl.oper-num = symmods.zastk.oper-num NO-LOCK NO-ERROR.
 *      IF AVAIL jobmatl THEN ASSIGN affect.li = "Y".
 *                       ELSE ASSIGN affect.li = "N".
 * */

    IF affect.article <> "" THEN DO:

       FIND first zean13 WHERE symmods.zean13.cpean = affect.article
            AND symmods.zean13.coned = affect.revision NO-LOCK NO-ERROR.
       IF AVAILABLE zean13 THEN DO:
       ASSIGN affect.titre = symmods.zean13.liaco.
              affect.whse = zean13.ented.
       END.
    END.

     IF zastk.lieu-act = "Dispo" OR  zastk.lieu-act = "Transit" THEN DO:
     FIND symix.location WHERE location.loc = zastk.lieu-dest NO-LOCK NO-ERROR.
     IF AVAILABLE location THEN affect.desi =  location.DESCRIPTION.
     END.
     ELSE DO:
       FIND location where location.loc = affect.lieu-act NO-LOCK NO-ERROR.
       IF AVAILABLE location then affect.desi = location.DESCRIPTION.
     END.

IF zastk.lieu-act = "Dispo"  THEN DO:
find poitem where poitem.po-num = entry(1, zastk.lot,"-") AND poitem.po-line = integer(entry(2, zastk.lot,"-")) no-lock no-error.
   if available poitem then do:
    affect.date-liv = STRING(poitem.due-date).
    affect.no-ot = zastk.lot.
   END.
END.

if not available zean13 or affect.titre  = "" then  DO:
        IF affect.job BEGINS "t"
            THEN ASSIGN  affect.titre = "Transfert libre" .
            ELSE ASSIGN  affect.titre = affect.job  + " non trouvé".

END.

IF zastk.no-ot <> "" AND zastk.lieu-act <> zastk.lieu-dest THEN DO:
    affect.no-ot = zastk.no-ot.

    FIND FIRST ot-lig WHERE ot-lig.no-ot = zastk.no-ot NO-LOCK NO-ERROR.
    IF NOT AVAILABLE ot-lig THEN .
      ELSE DO:
      affect.ot-sta = ot-lig.STATUT.
      affect.ot-oa = ot-lig.po-num.
      affect.ot-lib = "De " + ot-lig.lieu-act + " Vers " + ot-lig.lieu-dest.
      IF ot-lig.dt-rec <> ? THEN affect.date-liv =  STRING(ot-lig.dt-rec).
                             ELSE affect.date-liv =  "Non Prévue".   
    END.
END.

END.
    
     {&open-query-browse-1}
     if available affect then apply "Value-changed" to browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-article
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-article C-Win
ON LEAVE OF w-article IN FRAME DEFAULT-FRAME /* Article */
DO:
  if w-article:screen-value = " " then do:
     assign w-desi:screen-value = " "
            w-desi = " ".
  end.
  else do:
  find symix.item where item.item = w-article:screen-value NO-LOCK no-error.
  IF NOT AVAILABLE item then do:
     message "Article inconnu" view-as alert-box.
     w-article:screen-value = "". 
     return no-apply.
  end.
  
  assign w-desi:screen-value = item.description
         w-desi = item.description.
  end.
     
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-entite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-entite C-Win
ON LEAVE OF w-entite IN FRAME DEFAULT-FRAME /* Entité */
DO:

IF w-entite:SCREEN-VALUE = "MAIN" THEN ASSIGN w-entite:SCREEN-VALUE = "".
if w-entite:screen-value = " " then do:
     assign w-desi-entite:screen-value = " "
            w-desi-entite = " ".
 END .
 ELSE  DO :   /* w-entite <> " "  */

  find first symix.whse where whse.whse = w-entite:screen-value NO-LOCK NO-ERROR.
  IF NOT AVAILABLE whse then do:
     message "Entité inconnue" view-as alert-box.
     return.
  end.
  
  assign w-desi-entite:screen-value = whse.name
         w-desi-entite = whse.name.
  
   IF cur-habili <> "0" 
    THEN DO.
      FIND FIRST s-stk WHERE s-stk.whse = w-entite:SCREEN-VALUE NO-LOCK NO-ERROR.
      IF AVAILABLE s-stk  
      THEN DO .
          IF  ( cur-habili = "1" AND t-domaine:SCREEN-VALUE = s-stk.groupe  )
           OR ( cur-habili = "2" AND t-domaine:SCREEN-VALUE = s-stk.branche )
           OR ( cur-habili = "3" AND t-domaine:SCREEN-VALUE = s-stk.domaine ) 
          THEN DO.
          END .
          ELSE DO.
              message "Entité " + w-entite:SCREEN-VALUE 
                  + " non autorisée (" + cur-habili + ")" view-as alert-box.
              return no-apply.
          END.
      END.
      ELSE DO.
      MESSAGE "Entité " + w-entite:SCREEN-VALUE + " - Domaine non défini" 
      SKIP "Contactez l'administrateur " view-as alert-box.
      RETURN no-apply.
      END.
    END.     /* fin cur-habili <> "0"    */
  END. /* fin  w-entite <> " "  */

END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME W-lieu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-lieu C-Win
ON LEAVE OF W-lieu IN FRAME DEFAULT-FRAME /* Lieu Stock */
DO:
   if w-lieu:screen-value = " " then do:
   assign w-desi-lieu:screen-value = " "
         w-desi-lieu = " ".
    RETURN.
  end.
  
    if w-lieu:screen-value = "dispo" then assign w-desi-lieu:screen-value = "Commandes en cours".
    else do:
         find symix.location where location.loc = w-lieu:screen-value NO-LOCK NO-ERROR.
         IF NOT AVAILABLE location then do:
          message "Lieu inconnu" view-as alert-box.
          return no-apply.
          end.
    assign w-desi-lieu:screen-value = location.description
                            w-desi-lieu = location.description.
    end.
         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  /* détermination du niveau d'habilitation du user */
  FIND FIRST zfiltm WHERE zfiltm.username = CALL-var NO-LOCK NO-ERROR .
  IF AVAILABLE zfiltm THEN DO . 
         IF SUBSTR(zfiltm.habili,1,1) = '0' THEN cur-habili = '0' .  /* administrateur    */
         IF SUBSTR(zfiltm.habili,1,1) = '1' THEN cur-habili = '1' .  /* Direction Groupe  */
         IF SUBSTR(zfiltm.habili,1,1) = '2' THEN cur-habili = '2' .  /* Branche           */
         IF SUBSTR(zfiltm.habili,1,1) > '2' THEN cur-habili = '3' .  /* Domaine Editorial */
         IF SUBSTR(zfiltm.habili,1,1) = '3'   
             AND   zfiltm.sect-fab = 'GAP'  THEN cur-habili = '1' .  /* Direction Groupe  */

         IF cur-habili > '2' 
          THEN DO .   
             FIND LAST symix.po where symix.po.charfld2 = CALL-var NO-LOCK NO-ERROR.
             IF AVAILABLE symix.po  THEN entit-fab = po.whse.
                                    ELSE entit-fab = '0000'.
           END.

        IF cur-habili = '0' THEN ASSIGN t-domaine:SCREEN-VALUE = 'Administrateur' .
        IF cur-habili = '1' THEN ASSIGN t-domaine:SCREEN-VALUE =  zfiltm.societe  .
        IF cur-habili = '2' THEN ASSIGN t-domaine:SCREEN-VALUE =  zfiltm.sect-fab .
        IF cur-habili = '3' 
            THEN DO.
               FIND FIRST s-stk WHERE s-stk.whse = entit-fab NO-LOCK NO-ERROR.
               IF AVAILABLE s-stk  
                   THEN DO .
                      ASSIGN t-domaine:SCREEN-VALUE = s-stk.domaine.
                   END.
                   ELSE DO.
                       ASSIGN t-domaine:SCREEN-VALUE = " Domaine non défini" .
                       cur-habili = '9'.
                   END.
            END.

      END.
      ELSE DO .
          ASSIGN t-domaine:SCREEN-VALUE = " Société non définie" .
          cur-habili = '9'.
      END.
IF i-MP <> "" AND i-MP BEGINS 'MP 'THEN DO:
        w-article:screen-value = i-MP.
        apply "leave" to w-article.
        end.
IF i-Lieu <> "" THEN DO:
              ASSIGN w-lieu:screen-value = SUBSTRING(string(integer(i-Lieu),"  99999"),3,7).
              apply "leave" to w-lieu.
              end.
IF i-edit <> "" THEN DO:
              w-entite:screen-value = i-edit.
              apply "leave" to w-entite.
              END.
APPLY "Choose" TO btn-recherche.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY w-article W-desi W-lieu W-desi-lieu Cde-liv w-entite W-desi-entite 
          t-Domaine 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE w-article Btn-lookup Btn-recherche W-lieu Cde-liv w-entite t-Domaine 
         BROWSE-1 Btn-lookup-2 Btn-lookup-3 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

