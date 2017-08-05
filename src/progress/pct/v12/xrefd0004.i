
DEFINE TEMP-TABLE Source
	FIELD Source-guid AS CHARACTER 
	FIELD File-num AS INTEGER 
	FIELD File-name AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	INDEX source-guid IS UNIQUE PRIMARY 
		Source-guid File-num.

DEFINE TEMP-TABLE Reference
	FIELD Source-guid AS CHARACTER 
	FIELD File-num AS INTEGER 
	FIELD Ref-seq AS INTEGER 
	FIELD Line-num AS INTEGER 
	FIELD Reference-type AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Object-identifier AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Object-context AS CHARACTER 
	FIELD Access-mode AS CHARACTER 
	FIELD Data-member-ref AS CHARACTER 
	FIELD Temp-ref AS CHARACTER 
	FIELD Detail AS CHARACTER 
	FIELD Is-static AS LOGICAL 
	FIELD Is-abstract AS LOGICAL 
	INDEX Reference_source-guid IS UNIQUE PRIMARY 
		Source-guid File-num Ref-seq.

DEFINE TEMP-TABLE Class-ref
	FIELD Source-guid AS CHARACTER 
	FIELD Ref-seq AS INTEGER 
	FIELD Inherited-list AS CHARACTER 
	FIELD Implements-list AS CHARACTER 
	FIELD Has-use-pool AS LOGICAL 
	FIELD Is-final AS LOGICAL 
	INDEX Class-ref_source-guid IS UNIQUE PRIMARY 
		Source-guid Ref-seq.

DEFINE TEMP-TABLE String-ref
	FIELD Source-guid AS CHARACTER 
	FIELD Ref-seq AS INTEGER 
	FIELD Max-length AS INTEGER 
	FIELD Justification AS CHARACTER 
	FIELD Translatable AS LOGICAL 
	INDEX String-ref_source-guid IS UNIQUE PRIMARY 
		Source-guid Ref-seq.

DEFINE TEMP-TABLE Parameter-ref
	FIELD Source-guid AS CHARACTER 
	FIELD Ref-seq AS INTEGER 
	FIELD Order AS INTEGER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Parameter-mode AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Parameter-name AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Parameter-type AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Dimension AS INTEGER 
	FIELD Is-append AS LOGICAL 
	FIELD Dataset-guid AS CHARACTER 
	INDEX Parameter-ref_source-guid IS UNIQUE PRIMARY 
		Source-guid Ref-seq Order.

DEFINE TEMP-TABLE Dataset-ref
	FIELD Source-guid AS CHARACTER 
	FIELD Dataset-guid AS CHARACTER 
	FIELD Ref-seq AS INTEGER 
	FIELD N-uri AS CHARACTER 
	FIELD N-prefix AS CHARACTER 
	FIELD Is-reference AS LOGICAL 
	FIELD Buffer-list AS CHARACTER 
	FIELD Data-links AS INTEGER 
	INDEX Dataset-ref_source-guid IS UNIQUE PRIMARY 
		Source-guid Dataset-guid Ref-seq.

DEFINE TEMP-TABLE Relation
	FIELD Source-guid AS CHARACTER 
	FIELD Dataset-guid AS CHARACTER 
	FIELD Relation-name AS CHARACTER 
		XML-NODE-TYPE "ATTRIBUTE" 
	FIELD Parent-buffer-name AS CHARACTER 
	FIELD Child-buffer-name AS CHARACTER 
	FIELD Relation-list AS CHARACTER 
	INDEX Relation-guid IS PRIMARY 
		Source-guid Dataset-guid.

DEFINE TEMP-TABLE Interface-ref
	FIELD Source-guid AS CHARACTER 
	FIELD Ref-seq AS INTEGER 
	FIELD Inherited-list AS CHARACTER 
	INDEX Interface-ref_source-guid IS UNIQUE PRIMARY 
		Source-guid Ref-seq.

DEFINE DATASET Cross-reference
	FOR Source, Reference, Class-ref, String-ref, Parameter-ref, Dataset-ref, Relation, Interface-ref
	DATA-RELATION rel-main FOR Source, Reference
		RELATION-FIELDS (Source-guid, Source-guid,File-num, File-num) NESTED
	DATA-RELATION rel-class FOR Reference, Class-ref
		RELATION-FIELDS (Source-guid, Source-guid,Ref-seq, Ref-seq) NESTED
	DATA-RELATION rel-string FOR Reference, String-ref
		RELATION-FIELDS (Source-guid, Source-guid,Ref-seq, Ref-seq) NESTED
	DATA-RELATION rel-param FOR Reference, Parameter-ref
		RELATION-FIELDS (Source-guid, Source-guid,Ref-seq, Ref-seq) NESTED
	DATA-RELATION rel-dataset FOR Reference, Dataset-ref
		RELATION-FIELDS (Source-guid, Source-guid,Ref-seq, Ref-seq) NESTED
	DATA-RELATION rel-Relation FOR Dataset-ref, Relation
		RELATION-FIELDS (Source-guid, Source-guid,Dataset-guid, Dataset-guid) NESTED
	DATA-RELATION rel-iface FOR Reference, Interface-ref
		RELATION-FIELDS (Source-guid, Source-guid,Ref-seq, Ref-seq) NESTED.
