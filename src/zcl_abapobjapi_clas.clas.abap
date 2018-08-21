CLASS zcl_abapobjapi_clas DEFINITION PUBLIC INHERITING FROM zcl_abapobjapi_prog_base.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        name         TYPE csequence
        package      TYPE devclass
        source_code  TYPE tt_abaptxt255
        category     TYPE vseoclass-category DEFAULT seoc_category_general
        descript     TYPE vseoclass-descript OPTIONAL
        rstat        TYPE vseoclass-rstat OPTIONAL
        msg_id       TYPE vseoclass-msg_id OPTIONAL
        locals_def   TYPE seop_source_string OPTIONAL
        locals_imp   TYPE seop_source_string OPTIONAL
        testclasses  TYPE seop_source_string OPTIONAL
        macros       TYPE seop_source_string OPTIONAL
        tpool        TYPE zif_abapgit_definitions=>ty_tpool_tt OPTIONAL
        sotr         TYPE zif_abapgit_definitions=>ty_sotr_tt OPTIONAL
        descriptions TYPE zif_abapgit_definitions=>ty_seocompotx_tt OPTIONAL
        doc          TYPE tlinetab OPTIONAL
      RAISING
        zcx_abapgit_exception.
ENDCLASS.

CLASS zcl_abapobjapi_clas IMPLEMENTATION.

  METHOD constructor.
    " build files for a class (source: method ZIF_ABAPGIT_OBJECT~SERIALIZE in ZCL_ABAPGIT_OBJECT_CLAS_OLD)

    super->constructor( obj_name = name obj_type = 'CLAS' package = package ).

    files->add_abap( it_abap = source_code ).

    IF lines( locals_def ) > 0.
      files->add_abap( iv_extra = 'locals_def'
                              it_abap  = locals_def ).      "#EC NOTEXT
    ENDIF.

    IF lines( locals_imp ) > 0.
      files->add_abap( iv_extra = 'locals_imp'
                              it_abap  = locals_imp ).      "#EC NOTEXT
    ENDIF.

    IF lines( testclasses ) > 0.
      files->add_abap( iv_extra = 'testclasses'
                              it_abap  = testclasses ).     "#EC NOTEXT
    ENDIF.

    IF lines( macros ) > 0.
      files->add_abap( iv_extra = 'macros'
                              it_abap  = macros ).          "#EC NOTEXT
    ENDIF.

    TRY.
        DATA(vseoclass) = VALUE vseoclass(
                clsname    = name
                version    = 1 " active
                langu      = sy-langu
                descript   = descript
                uuid       = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( )
                state      = '1' " always
                release    = '0' " always
                author     = sy-uname
                createdon  = sy-datum
                clsccincl  = 'X' " always
                fixpt      = 'X' " always
                unicode    = 'X' " always
                r3release  = sy-saprl
                with_unit_tests = boolc( testclasses IS NOT INITIAL ) ).
      CATCH cx_uuid_error.
        "TODO handle exception
    ENDTRY.

    DATA tokens TYPE TABLE OF string.
    DATA statement TYPE string.
    DATA lt_token TYPE TABLE OF stokes.
    DATA lt_statement TYPE TABLE OF sstmnt.

    SCAN ABAP-SOURCE source_code TOKENS INTO lt_token STATEMENTS INTO lt_statement.

    LOOP AT lt_token TRANSPORTING NO FIELDS WHERE str = 'CLASS' AND type = 'I'.
      READ TABLE lt_statement ASSIGNING FIELD-SYMBOL(<ls_statement>) WITH KEY from = sy-tabix.
      IF sy-subrc = 0.
        IF matches( val = statement regex = '(?!CREATE )PUBLIC' ).
          " TODO RAISE EXCEPTION TYPE lcx_
        ENDIF.

        CLEAR tokens.
        LOOP AT lt_token ASSIGNING FIELD-SYMBOL(<ls_token>).
          APPEND <ls_token>-str TO tokens.
        ENDLOOP.
        CONCATENATE LINES OF tokens INTO statement SEPARATED BY space.

        IF statement CS ' FOR TESTING'.
          vseoclass-category = seoc_category_test_class.
        ENDIF.
        IF statement CS ' ABSTRACT'.
          vseoclass-clsabstrct = abap_true.
        ENDIF.
        IF statement CS ' FINAL'.
          vseoclass-clsfinal = abap_true.
        ENDIF.
        IF statement CS ' CREATE PRIVATE'.
          vseoclass-exposure = seoc_exposure_private.
        ELSEIF statement CS ' CREATE PROTECTED'.
          vseoclass-exposure = seoc_exposure_protected.
        ELSEIF statement CS ' CREATE PUBLIC'.
          vseoclass-exposure = seoc_exposure_public.
        ENDIF.
        vseoclass-duration_type = SWITCH #( match( val = statement regex = ` DURATION ([^\s]+)` )
              WHEN ' DURATION SHORT' THEN 12
              WHEN ' DURATION MEDIUM' THEN 24
              WHEN ' DURATION LONG' THEN 36 ).
        vseoclass-risk_level = SWITCH #( match( val = statement regex = ` RISK LEVEL ([^\s]+)` )
              WHEN ' RISK LEVEL HARMLESS' THEN 11
              WHEN ' RISK LEVEL DANGEROUS' THEN 22
              WHEN ' RISK LEVEL CRITICAL' THEN 33 ).
        EXIT.
      ENDIF.
    ENDLOOP.


    " build the XML file (source: method SERIALIZE_XML in ZCL_ABAPGIT_OBJECT_CLAS_OLD)
    DATA(lo_xml) = NEW zcl_abapgit_xml_output( ).
    lo_xml->add( iv_name = 'VSEOCLASS'
                 ig_data = vseoclass ).

    lo_xml->add( iv_name = 'TPOOL'
                 ig_data = tpool ).

    IF vseoclass-category = seoc_category_exception.
      lo_xml->add( iv_name = 'SOTR'
                   ig_data = sotr ).
    ENDIF.

    IF lines( doc ) > 0.
      lo_xml->add( iv_name = 'LINES'
                   ig_data = doc ).
    ENDIF.

    IF lines( descriptions ) > 0.
      lo_xml->add( iv_name = 'DESCRIPTIONS'
                   ig_data = descriptions ).
    ENDIF.

    files->add_xml( io_xml = lo_xml ).

  ENDMETHOD.

ENDCLASS.

