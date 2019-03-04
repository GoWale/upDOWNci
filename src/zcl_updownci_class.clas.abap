class ZCL_UPDOWNCI_CLASS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_redirect,
             from TYPE seoclsname,
             to   TYPE seoclsname,
           END OF ty_redirect .

  class-data:
    mt_redirect TYPE STANDARD TABLE OF ty_redirect WITH DEFAULT KEY .

  class-methods ATTRIBUTES
    importing
      !IV_CLASS type SEOCLSNAME
    returning
      value(RT_ATTRIBUTES) type SEO_ATTRIBUTES
    raising
      CX_STATIC_CHECK .
  class-methods ADD_REDIRECT
    importing
      !IV_FROM type SEOCLSNAME
      !IV_TO type SEOCLSNAME .
  class-methods FIND_INCLUDE
    importing
      !IV_CLASS type SEOCLSNAME
    returning
      value(RV_INCLUDE) type PROGRAM
    raising
      CX_STATIC_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_UPDOWNCI_CLASS IMPLEMENTATION.


  METHOD add_redirect.

    FIELD-SYMBOLS: <ls_redirect> LIKE LINE OF mt_redirect.

    APPEND INITIAL LINE TO mt_redirect ASSIGNING <ls_redirect>.
    <ls_redirect>-from = iv_from.
    <ls_redirect>-to   = iv_to.

  ENDMETHOD.


  METHOD attributes.

    DATA: lt_attributes TYPE seo_attributes,
          lv_super      TYPE seoclsname,
          ls_redirect   LIKE LINE OF mt_redirect,
          lo_class      TYPE REF TO cl_oo_class.


    READ TABLE mt_redirect INTO ls_redirect WITH KEY from = iv_class.
    IF sy-subrc = 0.
      lo_class ?= cl_oo_class=>get_instance( ls_redirect-to ).
    ELSE.
      lo_class ?= cl_oo_class=>get_instance( iv_class ).
    ENDIF.

    rt_attributes = lo_class->get_attributes( ).

    lv_super = lo_class->get_superclass( ).
    IF NOT lv_super IS INITIAL.
      lt_attributes = attributes( lv_super ).
      APPEND LINES OF lt_attributes TO rt_attributes.
    ENDIF.

  ENDMETHOD.


  METHOD find_include.

    DATA: lo_class    TYPE REF TO cl_oo_class,
          lv_super    TYPE seoclsname,
          ls_redirect LIKE LINE OF mt_redirect,
          ls_mtdkey   TYPE seocpdkey.


    READ TABLE mt_redirect INTO ls_redirect WITH KEY from = iv_class.
    IF sy-subrc = 0.
      ls_mtdkey-clsname = ls_redirect-to.
    ELSE.
      ls_mtdkey-clsname = iv_class.
    ENDIF.
    ls_mtdkey-cpdname = 'PUT_ATTRIBUTES'.

    cl_oo_classname_service=>get_method_include(
      EXPORTING
        mtdkey              = ls_mtdkey
      RECEIVING
        result              = rv_include
      EXCEPTIONS
        class_not_existing  = 1
        method_not_existing = 2
        OTHERS              = 3 ).
    IF sy-subrc = 2.
      lo_class ?= cl_oo_class=>get_instance( iv_class ).
      lv_super = lo_class->get_superclass( ).
      rv_include = find_include( lv_super ).
    ELSEIF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_updownci_exception EXPORTING iv_text = 'error while finding method include'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
