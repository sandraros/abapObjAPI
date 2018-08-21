CLASS zcl_abapobjapi_repo DEFINITION PUBLIC INHERITING FROM zcl_abapgit_repo.
  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        name    TYPE csequence DEFAULT 'virtual repository'
        package TYPE devclass
      RAISING
        zcx_abapgit_exception.

    METHODS add_object
      IMPORTING
        io_object TYPE REF TO zcl_abapobjapi_object
      RAISING
        zcx_abapgit_exception.

    METHODS get_overwrite_all
      RETURNING
        VALUE(overwrites) TYPE zif_abapgit_definitions=>ty_overwrite_tt
      RAISING
        zcx_abapgit_exception.

    METHODS get_files
      IMPORTING
        io_repo         TYPE REF TO zcl_abapgit_repo
      RETURNING
        VALUE(rt_files) TYPE zif_abapgit_definitions=>ty_files_tt
      RAISING
        zcx_abapgit_exception.

    METHODS delete REDEFINITION.
    METHODS delete_checks REDEFINITION.
    METHODS deserialize REDEFINITION.
    METHODS deserialize_checks REDEFINITION.
    METHODS find_remote_dot_abapgit REDEFINITION.
    METHODS get_dot_abapgit REDEFINITION.
    METHODS get_files_local REDEFINITION.
    METHODS get_files_remote REDEFINITION.
    METHODS get_key REDEFINITION.
    METHODS get_local_checksums REDEFINITION.
    METHODS get_local_checksums_per_file REDEFINITION.
    METHODS get_local_settings REDEFINITION.
    METHODS get_name REDEFINITION.
    METHODS get_package REDEFINITION.
    METHODS is_offline REDEFINITION.
    METHODS rebuild_local_checksums REDEFINITION.
    METHODS refresh REDEFINITION.
    METHODS run_code_inspector REDEFINITION.
    METHODS set_dot_abapgit REDEFINITION.
    METHODS set_files_remote REDEFINITION.
    METHODS set_local_settings REDEFINITION.
    METHODS update_local_checksums REDEFINITION.

  PRIVATE SECTION.
    DATA: repo           TYPE REF TO zcl_abapgit_repo_offline,
          name           TYPE string,
          mo_dot_abapgit TYPE REF TO zcl_abapgit_dot_abapgit.
ENDCLASS.

CLASS zcl_abapobjapi_repo IMPLEMENTATION.

  METHOD constructor.
    super->constructor( is_data = VALUE #( key = 'virtual repository' package = package ) ).
    me->name = name.
    set_dot_abapgit( zcl_abapgit_dot_abapgit=>build_default( ) ).
  ENDMETHOD.

  METHOD add_object.
    LOOP AT io_object->files->get_files( ) ASSIGNING FIELD-SYMBOL(<file>).
      <file>-path = zcl_abapgit_folder_logic=>get_instance( )->package_to_path(
                                                        iv_top     = get_package( )
                                                        io_dot     = get_dot_abapgit( )
                                                        iv_package = io_object->package ).
      <file>-sha1 = zcl_abapgit_hash=>sha1( iv_type = zif_abapgit_definitions=>c_type-blob
                                               iv_data = <file>-data ).
      APPEND <file> TO mt_remote.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_files.
  ENDMETHOD.

  METHOD get_files_remote.
    rt_files = mt_remote.
  ENDMETHOD.

  METHOD deserialize.
    DATA: lt_updated_files TYPE zif_abapgit_definitions=>ty_file_signatures_tt,
          lx_error         TYPE REF TO zcx_abapgit_exception.


    TRY.
        lt_updated_files = zcl_abapgit_objects=>deserialize(
            io_repo   = me
            is_checks = is_checks ).
      CATCH zcx_abapgit_exception INTO lx_error.
        " ensure to reset default transport request task
        zcl_abapgit_default_transport=>get_instance( )->reset( ).
        RAISE EXCEPTION lx_error.
    ENDTRY.


  ENDMETHOD.

  METHOD get_files_local.
    " always return empty (virtual is only via remote)
  ENDMETHOD.

  METHOD delete.
    repo->delete( ).
  ENDMETHOD.

  METHOD delete_checks.
    rs_checks = repo->delete_checks( ).
  ENDMETHOD.

  METHOD deserialize_checks.
*    rs_checks = repo->deserialize_checks( ).
  ENDMETHOD.

  METHOD find_remote_dot_abapgit.
    ro_dot = repo->find_remote_dot_abapgit( ).
  ENDMETHOD.

  METHOD get_dot_abapgit.
    ro_dot_abapgit = mo_dot_abapgit.
  ENDMETHOD.

  METHOD get_key.
    rv_key = repo->get_key( ).
  ENDMETHOD.

  METHOD get_local_checksums.
    rt_checksums = ms_data-local_checksums.
  ENDMETHOD.

  METHOD get_local_checksums_per_file.
    FIELD-SYMBOLS <ls_object> LIKE LINE OF ms_data-local_checksums.

    LOOP AT ms_data-local_checksums ASSIGNING <ls_object>.
      APPEND LINES OF <ls_object>-files TO rt_checksums.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_local_settings.
*    rs_settings = repo->get_local_settings( ).
  ENDMETHOD.

  METHOD get_name.
    rv_name = me->name.
  ENDMETHOD.

  METHOD get_package.
    rv_package = ms_data-package.
  ENDMETHOD.

  METHOD is_offline.
    rv_offline = abap_true.
  ENDMETHOD.

  METHOD rebuild_local_checksums.
    repo->rebuild_local_checksums( ).
  ENDMETHOD.

  METHOD refresh.
    repo->refresh( iv_drop_cache = iv_drop_cache ).
  ENDMETHOD.

  METHOD run_code_inspector.
    rt_list = repo->run_code_inspector( ).
  ENDMETHOD.

  METHOD set_dot_abapgit.
    me->mo_dot_abapgit = io_dot_abapgit.
    ms_data-dot_abapgit = io_dot_abapgit->get_data( ).
  ENDMETHOD.

  METHOD set_files_remote.
    zcx_abapgit_exception=>raise( 'SET_FILES_REMOTE forbidden - Use ADD_OBJECT' ).
  ENDMETHOD.

  METHOD set_local_settings.
    repo->set_local_settings( is_settings = is_settings ).
  ENDMETHOD.

  METHOD update_local_checksums.
    repo->update_local_checksums( it_files = it_files ).
  ENDMETHOD.

  METHOD get_overwrite_all.

    DATA(results) = zcl_abapgit_file_status=>status( me ).

    overwrites = VALUE #( FOR <result> IN results (
                          obj_name = <result>-obj_name
                          obj_type = <result>-obj_type
                          devclass = <result>-package ) ).
    SORT overwrites BY table_line.
    DELETE ADJACENT DUPLICATES FROM overwrites.
  ENDMETHOD.

ENDCLASS.

