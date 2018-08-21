# abapObjAPI
ABAP API to easily create ABAP repository objects on the fly ; the API uses abapGit classes

Object types currently handled :
* PROG
* CLAS

# Installation

Get and install ZABAPGIT program -> https://github.com/larshp/abapGit

Install abapObjAPI :
* Start ZABAPGIT
* Click +Online and enter GIT repository https://github.com/sandraros/abapObjAPI and package $abapObjAPI (or any package you want)
* Click Pull

# Usage

In your program :

    data(repo) = new zcl_abapobjapi_repo( package = 'ZPROJECT' ).
    repo->add_object( new zcl_abapobjapi_prog( name = 'ZREPORT' type = '1' package = 'ZPROJECT_REPORTS'
        source = value #( ( |REPORT zreport.| )
                          ( |WRITE 'hello world'.| ) ) ) ).
    repo->deserialize( is_checks = VALUE #( transport       = VALUE #( transport = 'DEVK900048' required = abap_true )
                                            warning_package = repo->get_overwrite_all( ) ) ).
