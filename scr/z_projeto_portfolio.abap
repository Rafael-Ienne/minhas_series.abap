*&---------------------------------------------------------------------*
*& Report Z_PROJETO_PORTFOLIO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_projeto_portfolio.

"Interface que armazena os números de cada tela
INTERFACE lif_telas.
  CONSTANTS: tela_100 TYPE sy-dynnr VALUE 100,
             tela_200 TYPE sy-dynnr VALUE 200,
             tela_300 TYPE sy-dynnr VALUE 300.
ENDINTERFACE.

CLASS lcl_tela DEFINITION .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !id_numero_tela TYPE sy-dynnr .
    METHODS get_numero_tela
      RETURNING
        VALUE(rd_numero_tela) TYPE sy-dynnr .
    METHODS set_numero_tela
      IMPORTING
        !id_numero_tela TYPE sy-dynnr .
    METHODS mostrar_tela .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA md_numero_tela TYPE sy-dynnr .
ENDCLASS.

CLASS lcl_tela IMPLEMENTATION.
  METHOD constructor.
    me->md_numero_tela = id_numero_tela.
  ENDMETHOD.

  METHOD get_numero_tela.
    rd_numero_tela = me->md_numero_tela.
  ENDMETHOD.

  METHOD mostrar_tela.
    CALL SCREEN me->md_numero_tela.
  ENDMETHOD.

  METHOD set_numero_tela.
    me->md_numero_tela = id_numero_tela.
  ENDMETHOD.
ENDCLASS.

INCLUDE <icon>.

"Tabela interna de séries e workarea
DATA: lt_ztbseries    TYPE zcl_crud=>ty_tztbseries,
      lt_ztbandamento TYPE STANDARD TABLE OF ztbandamento,
      wa_ztbandamento LIKE LINE OF lt_ztbandamento.


CLASS lcl_event_grid DEFINITION.
  PUBLIC SECTION.
    METHODS:
    data_changed
    FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed
                                                        e_onf4
                                                        e_onf4_before
                                                        e_onf4_after
                                                        e_ucomm,
    hotspot_click
    FOR EVENT hotspot_click OF cl_gui_alv_grid IMPORTING e_row_id
                                                         e_column_id
                                                         es_row_no.
ENDCLASS.

CLASS lcl_event_grid IMPLEMENTATION.
  "Método que salva as alterações feitas nos campos modificaveis do ALV na tabela interna
  METHOD data_changed.
    LOOP AT er_data_changed->mt_good_cells[] ASSIGNING FIELD-SYMBOL(<fs_mt_good_cells>).
      READ TABLE lt_ztbseries ASSIGNING FIELD-SYMBOL(<fs_ztbseries>) INDEX <fs_mt_good_cells>-row_id.

      CASE <fs_mt_good_cells>-fieldname.
        WHEN 'NOME_SERIE'.
          <fs_ztbseries>-nome_serie = <fs_mt_good_cells>-value.
        WHEN 'ANO_LANCAMENTO'.
          <fs_ztbseries>-ano_lancamento = <fs_mt_good_cells>-value.
        WHEN 'ANDAMENTO'.
          <fs_ztbseries>-andamento = <fs_mt_good_cells>-value.
        WHEN 'TEMPORADAS'.
          <fs_ztbseries>-temporadas = <fs_mt_good_cells>-value.
        WHEN 'NOTA_IMDB'.
          <fs_ztbseries>-nota_imdb = <fs_mt_good_cells>-value.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.
  "Método que gera um popup ao se clicar em uma célula do campo "Andamento"
  METHOD hotspot_click.

    READ TABLE lt_ztbseries ASSIGNING FIELD-SYMBOL(<fs_ztbseries>) INDEX e_row_id-index.

    SELECT * FROM ztbandamento INTO TABLE lt_ztbandamento WHERE sigla EQ <fs_ztbseries>-andamento.

    IF sy-subrc IS INITIAL.
      "Geração de um pop-up
      CALL SCREEN lif_telas=>tela_200 STARTING AT 50 5 ENDING AT 100 10.

    ENDIF.

  ENDMETHOD.
ENDCLASS.


"Variáveis básicas para geração de ALV
DATA: lo_grid_100     TYPE REF TO cl_gui_alv_grid,
      lo_serie        TYPE REF TO zcl_serie,
      lo_grid_200     TYPE REF TO cl_gui_alv_grid,
      lt_fieldcat     TYPE lvc_t_fcat,
      lt_fieldcat_200 TYPE lvc_t_fcat,
      ls_layout       TYPE lvc_s_layo,
      ls_layout_200   TYPE lvc_s_layo,
      ls_variant      TYPE disvariant,
      lv_okcode_100   TYPE sy-ucomm,
      lv_okcode_200   TYPE sy-ucomm,
      lv_okcode_300   TYPE sy-ucomm,
      lo_event_grid   TYPE REF TO lcl_event_grid,
      lo_tela         TYPE REF TO lcl_tela.

"Parameters para inserir registro, carregar todos, carregar um registro, atualizar ou deletar
"registro
PARAMETERS: p_insert RADIOBUTTON GROUP g1,
            p_load_a RADIOBUTTON GROUP g1,
            p_load_o RADIOBUTTON GROUP g1,
            p_update RADIOBUTTON GROUP g1,
            p_del    RADIOBUTTON GROUP g1.

START-OF-SELECTION.

  CASE 'X'.

    WHEN p_insert.

      CASE zcl_crud=>inserir(  ).
        WHEN 'S'.
          MESSAGE 'Dados inseridos com sucesso' TYPE 'S'.
          PERFORM f_mostrar_alv.
        WHEN 'E'.
          MESSAGE 'Id já registrado' TYPE 'I' DISPLAY LIKE 'E'.
      ENDCASE.

    WHEN p_load_a.
      PERFORM f_mostrar_alv.

    WHEN p_load_o OR p_update.

      FREE: lt_ztbseries[].

      CASE zcl_crud=>mostrar_um(
        CHANGING
          ct_tabela = lt_ztbseries[]
      ).
        WHEN 'S'.
          PERFORM f_mostrar_alv.
        WHEN 'E'.
          MESSAGE 'Série não encontrada' TYPE 'I' DISPLAY LIKE 'E'.
      ENDCASE.

    WHEN p_del.

      CASE zcl_crud=>deletar(  ).
        WHEN 'S'.
          MESSAGE 'Série excluída com sucesso' TYPE 'I' DISPLAY LIKE 'S'.
        WHEN 'E'.
          MESSAGE 'Id não encontrado' TYPE 'I' DISPLAY LIKE 'E'.
      ENDCASE.

  ENDCASE.

FORM f_obter_dados.

  FREE lt_ztbseries[].

  lt_ztbseries = zcl_crud=>mostrar_tudo( ).

ENDFORM.

FORM f_mostrar_alv .
  IF p_insert EQ 'X' OR p_load_a EQ 'X'.
    PERFORM f_obter_dados.
  ENDIF.
  PERFORM f_visao_completa_alv.

ENDFORM.

FORM f_visao_completa_alv.

  IF lt_ztbseries[] IS NOT INITIAL.
    IF p_insert EQ 'X' OR p_load_a EQ 'X' OR p_load_o EQ 'X'.
      lo_tela = NEW lcl_tela( id_numero_tela = lif_telas=>tela_100 ).
      lo_tela->mostrar_tela( ).
    ELSEIF p_update EQ 'X'.
      lo_tela = NEW lcl_tela( id_numero_tela = lif_telas=>tela_300 ).
      lo_tela->mostrar_tela( ).
    ELSE.
      MESSAGE 'Dados não localizados' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.
  ENDIF.

ENDFORM.

FORM f_visao_completa_alv_update.

  IF lt_ztbseries[] IS NOT INITIAL.
    lo_tela = NEW lcl_tela( id_numero_tela =  lif_telas=>tela_300  ).
    lo_tela->mostrar_tela( ).
  ELSE.
    MESSAGE 'Dados não localizados' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

MODULE user_command_0100 INPUT.
  lv_okcode_100 = sy-ucomm.
  CASE lv_okcode_100.
    WHEN 'VOLTAR'.
      LEAVE TO SCREEN 0.
    WHEN 'SAIR'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

*----------------------------------------------------------------------*
***INCLUDE Z_PROJETO_PORTFOLIO_STATUS_O03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITULO100'.
ENDMODULE.

*----------------------------------------------------------------------*
***INCLUDE Z_PROJETO_PORTFOLIO_M_SHOW_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module M_SHOW_GRID_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_show_grid_100 OUTPUT.

  FREE: lt_fieldcat[].

  "Tamanho do ALV automático
  ls_layout-cwidth_opt = 'X'.
  "ALV zebrado ou não
  ls_layout-zebra = 'X'.

  PERFORM build_grid .

ENDMODULE.

FORM build_grid.
  IF p_update EQ 'X'.
    PERFORM f_build_fieldcat USING:
    'ID' 'ID' 'ZTBSERIES' 'Id' '' '' '' '' '' '' CHANGING lt_fieldcat[],
    'NOME_SERIE' 'NOME_SERIE' 'ZTBSERIES' 'Nome série' '' '' '' 'X' '' '' CHANGING lt_fieldcat[],
    'ANO_LANCAMENTO' 'ANO_LANCAMENTO' 'ZTBSERIES' 'Ano lançamento' '' '' '' 'X' '' '' CHANGING lt_fieldcat[],
    'TEMPORADAS' 'TEMPORADAS' 'ZTBSERIES' 'Temporadas' '' '' '' 'X' '' '' CHANGING lt_fieldcat[],
    'ANDAMENTO' 'ANDAMENTO' 'ZTBSERIES' 'Andamento' '' '' '' 'X' '' '' CHANGING lt_fieldcat[],
    'NOTA_IMDB' 'NOTA_IMDB' 'ZTBSERIES' 'Nota' '' '' '' 'X' '' '' CHANGING lt_fieldcat[],
    'IC' 'IC' 'ICON' 'Status' '' 'X' '' '' '' '' CHANGING lt_fieldcat[].
  ELSE.
    PERFORM f_build_fieldcat USING:
  'ID' 'ID' 'ZTBSERIES' 'Id' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'NOME_SERIE' 'NOME_SERIE' 'ZTBSERIES' 'Nome série' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'ANO_LANCAMENTO' 'ANO_LANCAMENTO' 'ZTBSERIES' 'Ano lançamento' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'TEMPORADAS' 'TEMPORADAS' 'ZTBSERIES' 'Temporadas' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'ANDAMENTO' 'ANDAMENTO' 'ZTBSERIES' 'Andamento' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'NOTA_IMDB' 'NOTA_IMDB' 'ZTBSERIES' 'Nota' '' '' '' '' '' '' CHANGING lt_fieldcat[],
  'IC' 'IC' 'ICON' 'Status' '' 'X' '' '' '' '' CHANGING lt_fieldcat[].
  ENDIF.


  IF lo_grid_100 IS INITIAL.

    lo_event_grid = NEW lcl_event_grid( ).

    lo_grid_100   = NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).

    "Permite que mais de uma linha seja selecionada(para fins visuais)
    lo_grid_100->set_ready_for_input( 1 ).

    IF p_update EQ 'X'.
      lo_grid_100->register_edit_event(
      EXPORTING
        i_event_id =    cl_gui_alv_grid=>mc_evt_modified
    ).
    ENDIF.

    lo_grid_100->set_table_for_first_display(

      EXPORTING

        is_variant                    =    ls_variant
        i_save                        =       'A'
        is_layout                     =    ls_layout

      CHANGING
        it_fieldcatalog               =     lt_fieldcat[]
        it_outtab                     =     lt_ztbseries[]
      ) .

    "Titulo do ALV
    lo_grid_100->set_gridtitle( 'Lista de séries preferidas' ).
    SET HANDLER lo_event_grid->hotspot_click FOR lo_grid_100.
    IF p_update EQ 'X'.
      SET HANDLER lo_event_grid->data_changed FOR lo_grid_100.
    ENDIF.

  ELSE.
    "Refresh dos dados para não construir o objeto novamente
    lo_grid_100->refresh_table_display( ).
  ENDIF.

ENDFORM.

FORM f_build_fieldcat USING VALUE(p_fieldname)  TYPE c
                            VALUE(p_field)      TYPE c
                            VALUE(p_table)      TYPE c
                            VALUE(p_coltext)    TYPE c
                            VALUE(p_checkbox)   TYPE c
                            VALUE(p_icon)       TYPE c
                            VALUE(p_emphasize)  TYPE c
                            VALUE(p_edit)       TYPE c
                            VALUE(p_hotspot)    TYPE c
                            VALUE(p_do_sum)     TYPE c
                            CHANGING t_fieldcat TYPE lvc_t_fcat.
  DATA: ls_fieldcat LIKE LINE OF t_fieldcat[].

  "Nome do campo dado na tabela interna
  ls_fieldcat-fieldname = p_fieldname.
  "Nome do campo na tabela transparente
  ls_fieldcat-ref_field = p_field.
  "Tabela transparente
  ls_fieldcat-ref_table = p_table.
  "Descrição que daremos para o campo no ALV.
  ls_fieldcat-coltext   = p_coltext.
  "Existe ou nao checkbox
  ls_fieldcat-checkbox  = p_checkbox.
  "Existe ou nao icone
  ls_fieldcat-icon  = p_icon.
  "Estabelece a cor a ser colocada na coluna
  ls_fieldcat-emphasize  = p_emphasize.
  "Estabelece se coluna pode ser editada ou não
  ls_fieldcat-edit       = p_edit.
  "Permite criar o hotspot, ou seja, quando se clicar no campo, aprece um pop up com info. adicionais
  ls_fieldcat-hotspot    = p_hotspot.
  "Permite realizar a sumarização de uma coluna(somente se a coluna for numérica)
  ls_fieldcat-do_sum     = p_do_sum.

  APPEND ls_fieldcat TO t_fieldcat[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS200'.
  SET TITLEBAR 'TITULO200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module M_SHOW_GRID_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_show_grid_200 OUTPUT.
  FREE: lt_fieldcat_200[].
  ls_layout_200-cwidth_opt = 'X'.

  PERFORM f_build_fieldcat USING:
          'DESCRICAO' 'DESCRICAO' 'ZTBANDAMENTO' 'Descrição' '' '' '' '' '' '' CHANGING lt_fieldcat_200[].

  IF lo_grid_200 IS INITIAL.

    lo_event_grid = NEW lcl_event_grid( ).
    lo_grid_200   = NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).

    "Permite que mais de uma linha seja selecionada(para fins visuais)
    lo_grid_200->set_ready_for_input( 1 ).

    lo_grid_200->set_table_for_first_display(
      EXPORTING

        is_variant                    =    ls_variant
        i_save                        =       'A'
        is_layout                     =    ls_layout_200

      CHANGING
        it_fieldcatalog               =     lt_fieldcat_200[]
        it_outtab                     =     lt_ztbandamento[]
      ) .


    " Dá autorização para que o grid use o método criado
    SET HANDLER lo_event_grid->hotspot_click FOR lo_grid_200.
  ELSE.
    lo_grid_100->refresh_table_display( ).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'STATUS300'.
  SET TITLEBAR 'TITULO300'.
ENDMODULE.

FORM f_salvar .
  MODIFY ztbseries FROM TABLE lt_ztbseries .
  IF sy-subrc IS INITIAL.
    COMMIT WORK.
    PERFORM f_obter_dados.
    MESSAGE 'Dados atualizados com sucesso' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Erro ao atualizar dados' TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  lv_okcode_300 = sy-ucomm.
  CASE lv_okcode_300.
    WHEN 'SALVAR'.
      PERFORM f_salvar.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      PERFORM f_salvar.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.