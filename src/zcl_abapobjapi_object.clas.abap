CLASS zcl_abapobjapi_object DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA: package TYPE devclass,
          files   TYPE REF TO zcl_abapgit_objects_files.
    METHODS constructor
      IMPORTING
        obj_name TYPE csequence
        obj_type TYPE csequence
        package  TYPE devclass.
ENDCLASS.

CLASS zcl_abapobjapi_object IMPLEMENTATION.

  METHOD constructor.
    files = NEW zcl_abapgit_objects_files( is_item = VALUE #( obj_name = to_upper( obj_name ) obj_type = obj_type ) ).
    me->package = package.
  ENDMETHOD.

ENDCLASS.

