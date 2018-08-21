CLASS zcl_abapobjapi_prog DEFINITION PUBLIC INHERITING FROM zcl_abapobjapi_prog_base.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_tpool_i18n,
             language TYPE langu,
             textpool TYPE zif_abapgit_definitions=>ty_tpool_tt,
           END OF ty_tpool_i18n,
           tt_tpool_i18n TYPE STANDARD TABLE OF ty_tpool_i18n.

    METHODS constructor
      IMPORTING
        name         TYPE trdir-name
        type         TYPE trdir-subc
        package      TYPE devclass
        source_code  TYPE tt_abaptxt255
        category     TYPE vseoclass-category DEFAULT seoc_category_general
        descript     TYPE vseoclass-descript OPTIONAL
        rstat        TYPE vseoclass-rstat OPTIONAL
        msg_id       TYPE vseoclass-msg_id OPTIONAL
        tpool        TYPE zif_abapgit_definitions=>ty_tpool_tt OPTIONAL
        tpool_i18n   TYPE tt_tpool_i18n OPTIONAL
        dynpros      type zcl_abapobjapi_prog_base=>ty_dynpro_tt OPTIONAL
        cua          type zcl_abapobjapi_prog_base=>ty_cua optional
      RAISING
        zcx_abapgit_exception.
ENDCLASS.

CLASS zcl_abapobjapi_prog IMPLEMENTATION.

  METHOD constructor.
    " build files for a program (source: method ZIF_ABAPGIT_OBJECT~SERIALIZE in ZCL_ABAPGIT_OBJECT_PROG)
    super->constructor( obj_name = name obj_type = 'PROG' package = package ).

    DATA(lo_xml) = NEW zcl_abapgit_xml_output( ).

    serialize_program( io_xml   = lo_xml
                       io_files = files
                       progdir  = VALUE #(
                            name    = name
                            subc    = type
                            uccheck = 'X'
                            )
                       source  = source_code
                       tpool   = VALUE #( base tpool ( id = 'R' entry = descript length = strlen( descript ) ) )
                       dynpros = dynpros
                       cua     = cua ).

    IF lines( tpool_i18n ) > 0.
      lo_xml->add( iv_name = 'I18N_TPOOL'
                   ig_data = tpool_i18n ).
    ENDIF.

    files->add_xml( io_xml = lo_xml ).

  ENDMETHOD.

ENDCLASS.

