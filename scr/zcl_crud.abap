class ZCL_CRUD definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_ztbseries.
        INCLUDE TYPE  ztbseries.
        TYPES: ic TYPE icon-id.
    TYPES END OF ty_ztbseries .
  types:
    ty_tztbseries TYPE STANDARD TABLE OF ty_ztbseries WITH KEY id .
  types:
    ty_tval TYPE TABLE OF sval .

  class-methods INSERIR
    returning
      value(RD_LVCODE) type CHAR1 .
  class-methods DELETAR
    returning
      value(RD_RESULT) type CHAR1 .
  class-methods MOSTRAR_TUDO
    returning
      value(RT_TABELA) type TY_TZTBSERIES .
  class-methods MOSTRAR_UM
    changing
      value(CT_TABELA) type TY_TZTBSERIES
    returning
      value(RD_RESULT) type CHAR1 .
  class-methods INSERIR_CAMPO
    importing
      !ID_TABELA type STRING
      !ID_FIELDNAME type STRING
      !ID_OBL type STRING
      !ID_FIELDTEXT type STRING
    changing
      !IT_SVAL type TY_TVAL .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_CRUD IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRUD=>DELETAR
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_RESULT                      TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deletar.
    "Variáveis para percorrer os dados pegos na tela gerada por POPUP_GET_VALUES
    DATA: lt_sval  TYPE TABLE OF sval,
          ls_sval  LIKE LINE OF lt_sval,
          lv_code  TYPE c,
          lt_dfies TYPE TABLE OF dfies.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = 'ZTBSERIES'
      TABLES
        dfies_tab = lt_dfies.

    LOOP AT lt_dfies ASSIGNING FIELD-SYMBOL(<fs_campos>).
      IF <fs_campos>-lfieldname EQ 'ID'.
        zcl_crud=>inserir_campo(
       EXPORTING
         id_tabela    = 'ZTBSERIES'
         id_fieldname = CONV #( <fs_campos>-fieldname )
         id_obl       = 'X'
         id_fieldtext = CONV #( <fs_campos>-scrtext_m )
       CHANGING
         it_sval      = lt_sval
     ).
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        no_value_check  = 'X'
        popup_title     = 'Deletar uma série'
        start_column    = '10'
        start_row       = '10'
      IMPORTING
        returncode      = lv_code
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    IF lv_code EQ ''.
      LOOP AT lt_sval INTO ls_sval.
        DELETE FROM ztbseries WHERE id EQ ls_sval-value.
        IF sy-subrc IS INITIAL.
          "Sucesso ao se deletar a série
          rd_result = 'S'.
          COMMIT WORK.
        ELSE.
          "Erro ao se deletar série
          rd_result = 'E'.
          ROLLBACK WORK.
        ENDIF.
      ENDLOOP.
    ELSE.
      "Fechar popup
      rd_result = 'B'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRUD=>INSERIR
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_LVCODE                      TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD inserir.
    "Variáveis para percorrer os dados pegos na tela gerada por POPUP_GET_VALUES
    DATA: lt_sval  TYPE TABLE OF sval,
          ls_sval  LIKE LINE OF lt_sval,
          lv_code  TYPE c,
          lo_serie TYPE REF TO zcl_serie,
          lt_dfies TYPE TABLE OF dfies.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = 'ZTBSERIES'
      TABLES
        dfies_tab = lt_dfies.

    LOOP AT lt_dfies ASSIGNING FIELD-SYMBOL(<fs_campos>).
      IF <fs_campos>-lfieldname NE 'MANDT'.
        zcl_crud=>inserir_campo(
       EXPORTING
         id_tabela    = 'ZTBSERIES'
         id_fieldname = CONV #( <fs_campos>-fieldname )
         id_obl       = 'X'
         id_fieldtext = CONV #( <fs_campos>-scrtext_m )
       CHANGING
         it_sval      = lt_sval
     ).
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        no_value_check  = 'X'
        popup_title     = 'Inserir dados na tabela de séries'
        start_column    = '10'
        start_row       = '10'
      IMPORTING
        returncode      = lv_code
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    IF lv_code EQ ''.
      lo_serie = NEW zcl_serie( ).
      LOOP AT lt_sval INTO ls_sval.
        CASE ls_sval-fieldname.
          WHEN 'ID'.
            lo_serie->set_id( id_id = CONV #( ls_sval-value ) ).
          WHEN 'NOME_SERIE'.
            lo_serie->set_nome( id_nome = CONV #( ls_sval-value ) ).
          WHEN 'ANO_LANCAMENTO'.
            lo_serie->set_ano( id_ano = CONV #( ls_sval-value ) ).
          WHEN 'TEMPORADAS'.
            lo_serie->set_temporadas( id_temporadas = CONV #( ls_sval-value ) ).
          WHEN 'ANDAMENTO'.
            lo_serie->set_andamento( id_andamento = CONV #( ls_sval-value ) ).
          WHEN 'NOTA_IMDB'.
            lo_serie->set_nota( id_nota = CONV #( ls_sval-value ) ).
        ENDCASE.
      ENDLOOP.

      DATA: ls_serie TYPE ztbseries.

      ls_serie-nome_serie = lo_serie->get_nome( ).
      ls_serie-ano_lancamento = lo_serie->get_ano( ).
      ls_serie-temporadas = lo_serie->get_temporadas( ).
      ls_serie-andamento = lo_serie->get_andamento( ).
      ls_serie-nota_imdb = lo_serie->get_nota( ).
      ls_serie-id = lo_serie->get_id( ).

      INSERT ztbseries FROM ls_serie.

      IF sy-subrc IS INITIAL.
        COMMIT WORK.
        "Sucesso no insert
        rd_lvcode = 'S'.
      ELSE.
        ROLLBACK WORK.
        "Erro no insert
        rd_lvcode = 'E'.
      ENDIF.

    ELSE.
      "Voltar para a tela inicial
      rd_lvcode = 'A'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRUD=>INSERIR_CAMPO
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TABELA                      TYPE        STRING
* | [--->] ID_FIELDNAME                   TYPE        STRING
* | [--->] ID_OBL                         TYPE        STRING
* | [--->] ID_FIELDTEXT                   TYPE        STRING
* | [<-->] IT_SVAL                        TYPE        TY_TVAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD inserir_campo.
    DATA: ls_sval LIKE LINE OF it_sval.

    CLEAR: ls_sval.

    ls_sval-tabname = id_tabela.
    ls_sval-fieldname = id_fieldname.
    ls_sval-field_obl = id_obl.
    ls_sval-fieldtext = id_fieldtext.

    APPEND ls_sval TO it_sval.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRUD=>MOSTRAR_TUDO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_TABELA                      TYPE        TY_TZTBSERIES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD mostrar_tudo.

    SELECT * FROM ztbseries INTO TABLE rt_tabela WHERE id NE ''.

    LOOP AT rt_tabela ASSIGNING FIELD-SYMBOL(<fs_ztbseries>).
      IF <fs_ztbseries> IS ASSIGNED.
        CASE <fs_ztbseries>-andamento.
          WHEN 'E'.
            <fs_ztbseries>-ic = icon_led_yellow.
          WHEN 'F'.
            <fs_ztbseries>-ic = icon_led_green.
          WHEN 'C'.
            <fs_ztbseries>-ic = icon_led_red.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      MESSAGE 'Erro ao procurar as séries' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRUD=>MOSTRAR_UM
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_TABELA                      TYPE        TY_TZTBSERIES
* | [<-()] RD_RESULT                      TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD mostrar_um.

    "Variáveis para percorrer os dados pegos na tela gerada por POPUP_GET_VALUES
    DATA: lt_sval  TYPE TABLE OF sval,
          ls_sval  LIKE LINE OF lt_sval,
          lv_code  TYPE c,
          lo_serie TYPE REF TO zcl_serie,
          lt_dfies TYPE TABLE OF dfies.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = 'ZTBSERIES'
      TABLES
        dfies_tab = lt_dfies.

    LOOP AT lt_dfies ASSIGNING FIELD-SYMBOL(<fs_campos>).
      IF <fs_campos>-lfieldname EQ 'ID'.
        zcl_crud=>inserir_campo(
       EXPORTING
         id_tabela    = 'ZTBSERIES'
         id_fieldname = CONV #( <fs_campos>-fieldname )
         id_obl       = 'X'
         id_fieldtext = CONV #( <fs_campos>-scrtext_m )
       CHANGING
         it_sval      = lt_sval
     ).
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        no_value_check  = 'X'
        popup_title     = 'Localizar uma série'
        start_column    = '10'
        start_row       = '10'
      IMPORTING
        returncode      = lv_code
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    IF lv_code EQ ''.
      DATA(lt_series) = zcl_crud=>mostrar_tudo( ).
      SORT lt_series BY id ASCENDING.
      LOOP AT lt_sval INTO ls_sval.
        READ TABLE lt_series ASSIGNING FIELD-SYMBOL(<fs_serie>) WITH KEY id = CONV #( ls_sval-value ) BINARY SEARCH.
        IF <fs_serie> IS ASSIGNED.
          APPEND <fs_serie> TO ct_tabela.
          "Sucesso ao se procurar o registro
          rd_result = 'S'.
        ELSE.
          "Erro ao se procurar o registro
          rd_result = 'E'.
        ENDIF.
      ENDLOOP.
    ELSE.
      "Voltar para tela inicial
      rd_result = 'B'.
      EXIT.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
