CLASS zcl_abapobjapi_fugr DEFINITION PUBLIC INHERITING FROM zcl_abapobjapi_prog_base.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_include,
        progdir     TYPE zcl_abapgit_objects_program=>ty_progdir,
        descript    TYPE string,
        source_code TYPE string_table,
      END OF ty_include,
      ty_includes TYPE STANDARD TABLE OF ty_include WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_function,
        funcname          TYPE rs38l_fnam,
        global_flag       TYPE rs38l-global,
        remote_call       TYPE rs38l-remote,
        update_task       TYPE rs38l-utask,
        short_text        TYPE tftit-stext,
        remote_basxml     TYPE rs38l-basxml_enabled,
        import            TYPE STANDARD TABLE OF rsimp WITH DEFAULT KEY,
        changing          TYPE STANDARD TABLE OF rscha WITH DEFAULT KEY,
        export            TYPE STANDARD TABLE OF rsexp WITH DEFAULT KEY,
        tables            TYPE STANDARD TABLE OF rstbl WITH DEFAULT KEY,
        exception         TYPE STANDARD TABLE OF rsexc WITH DEFAULT KEY,
        documentation     TYPE STANDARD TABLE OF rsfdo WITH DEFAULT KEY,
        exception_classes TYPE abap_bool,
      END OF ty_function .
    TYPES:
      ty_function_tt TYPE STANDARD TABLE OF ty_function WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
        progdir      TYPE zcl_abapgit_objects_program=>ty_progdir
        package      TYPE devclass
        source_code  TYPE seop_source_string
        areat        TYPE tlibt-areat
        functions    TYPE ty_function_tt
        includes     TYPE ty_includes
        dynpros      TYPE ty_dynpro_tt OPTIONAL
        cua          TYPE ty_cua OPTIONAL
        tpool        TYPE zif_abapgit_definitions=>ty_tpool_tt OPTIONAL
        descriptions TYPE zif_abapgit_definitions=>ty_seocompotx_tt OPTIONAL
        doc          TYPE tlinetab OPTIONAL
      RAISING
        zcx_abapgit_exception.
ENDCLASS.

CLASS zcl_abapobjapi_fugr IMPLEMENTATION.

  METHOD constructor.
    " build files for a program (source: method ZIF_ABAPGIT_OBJECT~SERIALIZE in ZCL_ABAPGIT_OBJECT_FUGR)
    super->constructor( obj_name = progdir-name obj_type = 'FUGR' package = package ).

    DATA(lo_xml) = NEW zcl_abapgit_xml_output( ).

    lo_xml->add( iv_name = 'AREAT'
                 ig_data = areat ).

    " list of includes
    DATA(include_names) = VALUE rso_t_objnm( FOR <ls_include> IN includes ( <ls_include>-progdir-name ) ).
    lo_xml->add( iv_name = 'INCLUDES'
                 ig_data = include_names ).

    lo_xml->add( iv_name = 'FUNCTIONS'
                 ig_data = functions ).

    " source code of includes
    LOOP AT includes ASSIGNING FIELD-SYMBOL(<ls_include2>).
      lo_xml->add( iv_name = 'PROGDIR'
                   ig_data = <ls_include2>-progdir ).

      lo_xml->add( iv_name = 'TPOOL'
                   ig_data = VALUE zif_abapgit_definitions=>ty_tpool_tt( ( id = 'R' entry = <ls_include2>-descript length = strlen( <ls_include2>-descript ) ) ) ).

    ENDLOOP.

    lo_xml->add( iv_name = 'DYNPROS'
                 ig_data = dynpros ).

    lo_xml->add( iv_name = 'CUA'
                 ig_data = cua ).

    files->add_xml( io_xml = lo_xml ).

  ENDMETHOD.

ENDCLASS.

