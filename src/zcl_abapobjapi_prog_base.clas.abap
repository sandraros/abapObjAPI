CLASS zcl_abapobjapi_prog_base DEFINITION PUBLIC INHERITING FROM zcl_abapobjapi_object.
  PUBLIC SECTION.
    TYPES: ty_spaces_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_dynpro,
             header     TYPE rpy_dyhead,
             containers TYPE dycatt_tab,
             fields     TYPE dyfatc_tab,
             flow_logic TYPE swydyflow,
             spaces     TYPE ty_spaces_tt,
           END OF ty_dynpro.

    TYPES: ty_dynpro_tt TYPE STANDARD TABLE OF ty_dynpro WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cua,
             adm TYPE rsmpe_adm,
             sta TYPE STANDARD TABLE OF rsmpe_stat WITH DEFAULT KEY,
             fun TYPE STANDARD TABLE OF rsmpe_funt WITH DEFAULT KEY,
             men TYPE STANDARD TABLE OF rsmpe_men WITH DEFAULT KEY,
             mtx TYPE STANDARD TABLE OF rsmpe_mnlt WITH DEFAULT KEY,
             act TYPE STANDARD TABLE OF rsmpe_act WITH DEFAULT KEY,
             but TYPE STANDARD TABLE OF rsmpe_but WITH DEFAULT KEY,
             pfk TYPE STANDARD TABLE OF rsmpe_pfk WITH DEFAULT KEY,
             set TYPE STANDARD TABLE OF rsmpe_staf WITH DEFAULT KEY,
             doc TYPE STANDARD TABLE OF rsmpe_atrt WITH DEFAULT KEY,
             tit TYPE STANDARD TABLE OF rsmpe_titt WITH DEFAULT KEY,
             biv TYPE STANDARD TABLE OF rsmpe_buts WITH DEFAULT KEY,
           END OF ty_cua.

    TYPES tt_abaptxt255 TYPE TABLE OF abaptxt255.

    METHODS serialize_program
      IMPORTING io_xml   TYPE REF TO zcl_abapgit_xml_output
                io_files TYPE REF TO zcl_abapgit_objects_files
                source   TYPE tt_abaptxt255
                progdir  TYPE zcl_abapgit_objects_program=>ty_progdir
                dynpros  TYPE ty_dynpro_tt OPTIONAL
                cua      TYPE ty_cua OPTIONAL
                tpool    TYPE zif_abapgit_definitions=>ty_tpool_tt OPTIONAL
      RAISING   zcx_abapgit_exception.

ENDCLASS.

CLASS zcl_abapobjapi_prog_base IMPLEMENTATION.

  METHOD serialize_program.

    " build files for any type of program (source: method SERIALIZE_PROGRAM in ZCL_ABAPGIT_OBJECTS_PROGRAM)

    io_xml->add( iv_name = 'PROGDIR'
                 ig_data = progdir ).

    IF progdir-subc = '1' OR progdir-subc = 'M'.
      io_xml->add( iv_name = 'DYNPROS'
                   ig_data = dynpros ).

      IF NOT cua IS INITIAL.
        io_xml->add( iv_name = 'CUA'
                     ig_data = cua ).
      ENDIF.
    ENDIF.

    READ TABLE tpool WITH KEY id = 'R' INTO DATA(ls_tpool).
    IF sy-subrc = 0 AND ls_tpool-key = '' AND ls_tpool-length = 0.
      " TODO exception it should not be defined
    ENDIF.

    io_xml->add( iv_name = 'TPOOL'
                 ig_data = tpool ).

    IF NOT io_xml IS BOUND.
      io_files->add_xml( io_xml = io_xml ).
    ENDIF.

    io_files->add_abap( it_abap = source ).

  ENDMETHOD.

ENDCLASS.

