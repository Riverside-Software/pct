/*********************************************************************
* Copyright (C) 2006,2009 by Progress Software Corporation. All rights    *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/* admnhlp.i */

/*
   This file contains
   Help Context Identifiers for PROGRESS GUI ADMIN TOOL
   embedded in PROGRESS pre-processor statements.

   The form used in this file is:

	   <Name of the Help Topic>
	   &Global-Define <context-string> <context-number>

   Please contact Documentation to make changes to this file. 
   Thanks. 
   
   History:
     kmcintos June 7, 2005  Added context help ids for auditing options.
     fernando     09/12/06  Added context help id for Adjust Schema
     fernando     06/30/09  Added context help id for Encryption/AltBufPool options
     
*/

/* Admin Help Contents screen */
&Global-define Adjust_Schema_dialog_box 37

/* Oracle Dataservers - Server Attributes - Create Foreign Constraints */ 
&Global-define ORACLE_DatatServer_Create_Constraints_Dialog 53
/* Oracle Dataservers - Server Attributes - Delete Foreign Constraints */ 
&Global-define ORACLE_DataServer_Delete_Constraints_Dialog_Box 54
/* Dataservers - Server Attributes - Activate/Deactivaye Constraints */ 
&Global-define DataServer_Activate_Deactivate_Constraint_Definitions_Dialog_Box 55

/* MSS Dataservers - Server Attributes - Create Foreign Constraints */ 
&Global-define MS_SQL_Server_Data_Server_Create_Constraints_Dialog 61
/* MSS Dataservers - Server Attributes - Delete Foreign Constraints */ 
&Global-define MS_SQL_Server_DataServer_Delete_Constraints_Dialog_Box 62

/*  */
&Global-define MS_SQL_Server_DataServer_View_Maintains_Foreign_Constraints 63
/* MSS Dataservers - Server Attributes - Constraint Properties */
&Global-define MS_SQL_Server_DataServer_View_Modify_Contraint_Properties_Dialog_Box 64

/* Create MSS DataServer Schema - migration "Advanced" button */
&Global-define OpenEdge_DB_to_MS_SQL_Advanced_Dialog_Box 65
/* Create Oracle DataServer Schema - migration "Advanced" button */
&Global-define OpenEdge_DB_to_ORACLE_Advanced_Dialog_Box 66

/*  */
&Global-define ORACLE_DataServer_View_Maintains_Foreign_Constraints 67
/* Oracle Dataservers - Server Attributes - Constraint Properties */
&Global-define ORACLE_DataServer_View_Modify_Contraint_Properties_Dialog_Box 68

/* Admin Help Contents screen */
&Global-define Main_Contents 49153

/* Admin Window  */
&Global-define Admin_Window 49154

/* Admin Menu Commands  */
&Global-define Menu_Commands 49155

/* List of Views Dialog Box */
&Global-define List_Views_Dlg_Box 49156

/* Edit User List Dialog Box */
&Global-define Edit_User_List_Dlg_Box 49157

/* Add User Dialog Box */
&Global-define Add_User_Dlg_Box 49158

/* Modify User Dialog Box */
&Global-define Modify_User_Dlg_Box 49159

/* List Tables (select 1 or All) Dialog Box */
&Global-define List_Tables_1orAll_Dlg_Box 49160

/* List Tables (select some) Dialog Box */
&Global-define List_Tables_Some_Dlg_Box 49161

/* List Tables (select one) Dialog Box */
&Global-define List_Tables_1_Dlg_Box 49162

/* Select Table by Pattern Match Dialog Box */
&Global-define Select_by_Pattern_Dlg_Box 49163

/* Select Database Dialog Box */
&Global-define Select_Database_Dlg_Box 49164

/* Edit Data Security Dialog Box */
&Global-define Edit_Data_Security_Dlg_Box 49165

/* Edit Parameter File Dialog Box */
&Global-define Edit_Parameter_File_Dlg_Box 49166

/* Edit Auto Connect List Dialog Box */
&Global-define Edit_Auto_Connect_List_Dlg_Box 49167

/* Add Auto Connect Record Dialog Box */
&Global-define Add_Auto_Connect_Dlg_Box 49168

/* Modify Auto Connect Record Dialog Box */
&Global-define Modify_Auto_Connect_Dlg_Box 49169

/* Fixed Length Field Columns Dialog Box */
&Global-define Fixed_Length_Field_Columns_Dlg_Box 49170

/* Pick a Database for Incremental Dump Dialog Box */
&Global-define Pick_DB_For_Incr_Dump_Dlg_Box 49171

/* Ordered Pick Dialog Box */
&Global-define Ordered_Pick_Dlg_Box 49172

/* Generate Workfile Dialog Box */
&Global-define Generate_Workfile_Dlg_Box 49173

/* Dump Create View Dialog Box */
&Global-define Dump_Create_View_Dlg_Box 49174

/* Dump Create Table Dialog Box */
&Global-define Dump_Create_Table_Dlg_Box 49175

/* Change Password Dialog Box */
&Global-define Change_Your_Password_Dlg_Box 49176

/* Import dBase Definitions Dialog Box */
&Global-define Import_dBase_Definitions_Dlg_Box 49177

/* Connect Database Dialog Box */
&Global-define Connect_Database_Dlg_Box 49178

/* Quote Entire Lines Dialog Box */
&Global-define Quote_Entire_Lines_Dlg_Box 49179

/* Quote By Delimiter Dialog Box */
&Global-define Quote_By_Delimiter_Dlg_Box 49180

/* Quote By Column Ranges Dialog Box */
&Global-define Quote_By_Column_Ranges_Dlg_Box 49181

/* Quoter Include File Dialog Box */
&Global-define Quoter_Include_File_Dlg_Box 49182

/* Quoter Conversion Completed Dialog Box */
&Global-define Quoter_Conversion_Completed_Dlg_Box 49183

/* Include File Created Dialog Box */
&Global-define Include_File_Created_Dlg_Box 49184

/* Password Verification Dialog Box */
&Global-define Password_Verification_Dlg_Box 49185

/* Parameter File Name Dialog Box */
&Global-define Parameter_File_Name_Dlg_Box 49186


/* Reconstruct Bad Load Records Dialog Box */
&Global-define Reconstruct_Bad_Load_Records_Dlg_Box 49187

/* Load Stuff Dialog Box (used for sequences, views and user records) */
&Global-define Load_Stuff_Dlg_Box 49188

/* Load Database Options Dialog Box */
&GLOBAL-DEFINE Load_Database_Options_Dialog_Box 123

/* Load Database Identification Properties Dialog Box */
&GLOBAL-DEFINE Load_Database_Identification_Properties_Dialog_Box 122

/* Load Application Audit Events Dialog Box */
&GLOBAL-DEFINE Load_Application_Audit_Events_Dialog_Box 121

/* Dump Database Options Dialog Box */
&GLOBAL-DEFINE Dump_Database_Options_Dialog_Box 120

/* Dump Audit Data -- Filter Dialog Box */
&GLOBAL-DEFINE Dump_Audit_Data_Filter_Dialog_Box 119

/* Database Identification Maintenance Dialog Box */
&GLOBAL-DEFINE Database_Identification_Maintenance_Dialog_Box 116

/* New Database Passkey/Identifier Dialog Box */
&GLOBAL-DEFINE Database_Passkey_Identifier_Dialog_Box 117

/* Database Identification History Dialog Box */
&GLOBAL-DEFINE Database_Identification_History_Dialog_Box 115

/* Database Options Dialog Box */
&GLOBAL-DEFINE Database_Options_Dialog_Box 109

/* Authentication Systems Dialog Box */
&GLOBAL-DEFINE Authentication_Systems_Dialog_Box 101

/* Edit Audit Permissions Dialog Box */
&GLOBAL-DEFINE Edit_Audit_Permissions_Dialog_Box 5

/* Cascade Revoke Dialog Box*/
&GLOBAL-DEFINE Cascade_Revoke_Permissions_Dialog_Box 6

/* Authentication System Domains Dialog Box */
/* &GLOBAL-DEFINE Authentication_System_Domains_Dialog_Box 80 */
/* &GLOBAL-DEFINE Authentication_System_Domains_Dialog_Box 80 */

/* Select Audit Policies for Dump Dialog Box */
&GLOBAL-DEFINE Select_Audit_Policies_for_Dump_Dialog_Box 118

/* Load Definitions Dialog Box */
&Global-define Load_Data_Definitions_Dlg_Box 49189

/* Load Data Contents Dialog Box */
&Global-define Load_Data_Contents_Dlg_Box 49190

/* Video Attribute Settings Dialog Box */
&Global-define Video_Attribute_Settings_Dlg_Box 49191

/* Dump Incremental Definitions Dialog Box */
&Global-define Dump_Incremental_Definitions_Dlg_Box 49192

/* Import Stuff Dialog Box (used for DIF and SYLK files) */
&Global-define Import_Stuff_Dlg_Box 49193

/* Import dBase File Contents Dialog Box */
&Global-define Import_dBase_File_Contents_Dlg_Box 49194

/* Import Delimited ASCII Dialog Box */
&Global-define Import_Delimited_ASCII_Dlg_Box 49195

/* Import Fixed Length Dialog Box */
&Global-define Import_Fixed_Length_Dlg_Box 49196

/* Index Deactivation Dialog Box */
&Global-define Index_Deactivation_Dlg_Box 49197

/* Generate Form Dialog Box */
&Global-define Generate_Form_Dlg_Box 49198

/* Export Stuff Dialog Box (used for export of everything but ASCII */
&Global-define Export_Stuff_Dlg_Box 49199

/* Export ASCII Dialog Box */
&Global-define Export_ASCII_Dlg_Box 49200

/* Dump Stuff Dialog Box 
   (used for dump of everything except table (data) contents */
&Global-define Dump_Stuff_Dlg_Box 49201

/* Dump Data Contents Dialog Box */
&Global-define Dump_Data_Contents_Dlg_Box 49202

/* Freeze/Unfreeze Table Dialog Box */
&Global-define Freeze_Unfreeze_Table_Dlg_Box 49203

/* Generate Assign Dialog Box */
&Global-define Generate_Assign_Dlg_Box 49204

/* Security Administrators Dialog Box */
&Global-define Security_Administrators_Dlg_Box 49205

/* Convert df File Format Dialog Box */
&Global-define Convert_df_File_Format_Dlg_Box 49206

/* Import Dbase Definition Results Dialog Box */
&Global-define Import_dBase_Definition_Results_Dlg_Box 49207

/* Resolve Mismatched Table Dialog Box (used in incremental dump) */
&Global-define Resolve_Mismatched_Table_Dlg_Box 49208

/* Resolve Mismatched Field Dialog Box (used in incremental dump)*/
&Global-define Resolve_Mismatched_Field_Dlg_Box 49209

/* Resolve Mismatched Sequence Dialog Box (used in incremental dump)*/
&Global-define Resolve_Mismatched_Sequence_Dlg_Box 49210

/* Fields for Export Dialog Box */
&Global-define Fields_For_Export_Dlg_Box 49211

/* Fields for Import Dialog Box */
&Global-define Fields_For_Import_Dlg_Box 49212

/* Indexes for Deactivation Dialog Box */
&Global-define Indexes_For_Deactivation_Dlg_Box 49213

/* Make Bulk Load Description File Dialog Box */
&Global-define Make_Bulk_Load_Dlg_Box 49214

/* Output Record Dialog Box */
&Global-define Output_Record_Dlg_Box 49215

/* Dump Data Contents Some Dialog Box */
&Global-define Dump_Data_Contents_Some_Dlg_Box 49216

/* Load Data Contents Some Dialog Box */
&Global-define Load_Data_Contents_Some_Dlg_Box 49217

/* Dump CREATE VIEW All Dialog Box */
&Global-define Dump_Create_View_All_Dlg_Box 49218

/* Dump CREATE TABLE All Dialog Box */
&Global-define Dump_Create_Table_All_Dlg_Box 49219

/* Edit Variable Length Settings Dialog Box */
&Global-define Edit_Var_AS400 49220

/* Create/Modify Database Record for DataServer Schema Dialog Box */
&Global-define Create_DataServer_Schema_Dlg_Box 49221

/* User ID and Password Dialog Box */
&Global-define User_ID_Dlg_Box 49222

/* Select DataServer Tables Dialog Box */
&Global-define Select_DataServer_Tables_Dlg_Box 49223

/* Verify DataServer Dialog Box */
&Global-define Verify_DataServer_Dlg_Box 49224

/* Adding ISAM Table Definitions Dialog Box */
&Global-define Add_Table_Defs_Dlg_Box 49225

/* Codepage Dialog Box */
&Global-define Code_Page_Dlg_Box 49226

/* Deselect Tables by Pattern Match Dialog Box */
&Global-define Deselect_by_Pattern_Dlg_Box 49

/* Select Tables by Pattern Match Dialog Box (DataServer context) */
&Global-define Select_by_Pattern_DataServer_Dlg_Box 49228

/* Deselect Tables by Pattern Match Dialog Box  (DataServer context) */
&Global-define Deselect_by_Pattern_DataServer_Dlg_Box 49229

/* Change Code Page Dialog Box */
&Global-define Change_Code_Page_Dlg_Box 49230

/* Pre-selection Criteria for Schema Pull Dialog Box */
&Global-define Presel_Schema_Pull_Dlg_Box 49231

/* Pre-selection Criteria for Schema Pull Dialog Box (Qualifier version) */
&Global-define Presel_Schema_Pull_Qual_Dlg_Box 49232

/* User-defined Data Types Selection Dialog Box */
&Global-define User_Def_Datatype_Dlg_Box 49233

/* User-defined Data Types Add/Update Dialog Box */
&Global-define User_Def_Datatype_Dlg_Box_Prop 49234

/* Links to Distributed Databases Dialog Box (ORACLE DataServer) */
&Global-define Link_Distrib_DB_Dlg_Box 49235

/* Help Menu How To Help screen. */
&Global-define How_To 49236

/* Redefining RMS Idexes - Index selection */
&Global-define Redef_Index_IdxSel_Dlg_Box 49237

/* Redefining RMS Idexes - Index-fields selection */
&Global-define Redef_Index_IdxFldSel_Dlg_Box 49238

/* Adding RMS Table Definitions Dialog Box */
&Global-define Add_RMS_Table_Defs_Dlg_Box 49239

/* Folling 2 help # moved to dictghlp.i */
/* ROWID-Index Dialog Box */
/*  &Global-define RowID_Idx_Dlg_Box 49240 */
/* ROWID-Index Detail Dialog Box */
/* &Global-define RowID_Idx_Dtl_Dlg_Box 49241 */

/* Schema Verify Dialog Box */
&Global-define Schema_Verify_Dlg_Box 49242

/* Schema Verify Reports Detail Dialog Box */
&Global-define Verify_Report_Dlg_Box 49243

/* Migration from Progress DB to an ODBC Data Source */
&Global-define PROGRESS_DB_to_ODBC_Dlg_Box	650

/* Create a SQL script and a df for the schema holder from a Progress delta.df */
&Global-define Incremental_Schema_Migration_Dlg_Box	651

/* Migration from Progress DB to an Oracle Database */
&Global-define PROGRESS_DB_to_ORACLE_Dlg_Box	652

/* Migration from Progress DB to a SQL Server Database */
&Global-define Progress_DB_To_SQL_Dlg_Box  2511111

/* ROWID-Index Dialog Box */
&Global-define RowID_Idx_Dlg_Box 49240

/* ROWID-Index Detail Dialog Box */
&Global-define RowID_Idx_Dtl_Dlg_Box 49241

/* Alternate Buffer Pool Maintenance dialog box */
&Global-define Alternate_Buffer_Pool_Maintenance_Dialog_Box 40

/* Alternate Buffer Pool Object Selector dialog box */
&Global-define Alternate_Buffer_Pool_Object_Selector_Dialog_Box 41

/* Encryption Policies Object Selector dialog box */
&Global-define Encryption_Policies_Object_Selector_Dialog_Box1 44

/* Edit Encryption Policies dialog box */
&Global-define Edit_Encryption_Policy_Dialog_Box1 45

/* Encryption Policy History dialog box */
&Global-define Encryption_Policy_History_Dialog_Box 46

/* Encryption Policy Generate Encryption Keys dialog box */
&Global-define Generate_Encryption_Keys_Dialog_Box 47

/* Copy Current Setting To dialog box */
&Global-define Copy_Current_Setting_To            48

&Global-define Deselect_Objects_by_Pattern_Match   51

&Global-define Select_Objects_by_Pattern_Match       52

/* Confirm Domain dialog box */
&Global-define Domains_Dialog_Box 56 

/* Confirm dump data Multi-tenancy dialog box */
&Global-define Dump_Data_Contents_for_Some_Tables_Multi_tenant_enabled_Dialog_Box 57

/* Confirm Select tenant dialog box */
&Global-define Select_Tenant_Dialog_Box 60
