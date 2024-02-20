class ZCL_SERIE definition
  public
  final
  create public .

public section.

  methods GET_NOME
    returning
      value(RD_NOME) type CHAR20 .
  methods GET_ANO
    returning
      value(RD_ANO) type INT2 .
  methods GET_TEMPORADAS
    returning
      value(RD_TEMPORADAS) type INT1 .
  methods GET_ANDAMENTO
    returning
      value(RD_ANDAMENTO) type CHAR1 .
  methods GET_NOTA
    returning
      value(RD_NOTA) type CHAR4 .
  methods SET_NOME
    importing
      !ID_NOME type CHAR20 .
  methods SET_ANO
    importing
      !ID_ANO type INT2 .
  methods SET_TEMPORADAS
    importing
      !ID_TEMPORADAS type INT1 .
  methods SET_ANDAMENTO
    importing
      !ID_ANDAMENTO type CHAR1 .
  methods SET_NOTA
    importing
      !ID_NOTA type CHAR4 .
  methods SET_ID
    importing
      !ID_ID type CHAR3 .
  methods GET_ID
    returning
      value(RD_ID) type CHAR3 .
protected section.
private section.

  data MD_NOME type CHAR20 .
  data MD_ANO type INT2 .
  data MD_ANDAMENTO type CHAR1 .
  data MD_NOTA type CHAR4 .
  data MD_TEMPORADAS type INT1 .
  data MD_ID type CHAR3 .
ENDCLASS.



CLASS ZCL_SERIE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_ANDAMENTO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_ANDAMENTO                   TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_andamento.
    rd_andamento = md_andamento.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_ANO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_ANO                         TYPE        INT2
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_ano.
    rd_ano = md_ano.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_ID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_ID                          TYPE        CHAR3
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_id.
    rd_id = md_id.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_NOME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_NOME                        TYPE        CHAR20
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_nome.
    rd_nome = md_nome.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_NOTA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_NOTA                        TYPE        CHAR4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_nota.
    rd_nota = md_nota.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->GET_TEMPORADAS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_TEMPORADAS                  TYPE        INT1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_temporadas.
    rd_temporadas = md_temporadas.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_ANDAMENTO
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ANDAMENTO                   TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_ANDAMENTO.
    me->md_andamento = id_andamento.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_ANO
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ANO                         TYPE        INT2
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_ANO.
    me->md_ano = id_ano.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_ID
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ID                          TYPE        CHAR3
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_id.
    me->md_id = id_id.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_NOME
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_NOME                        TYPE        CHAR20
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_nome.
    me->md_nome = id_nome.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_NOTA
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_NOTA                        TYPE        CHAR4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_NOTA.
    me->md_nota = id_nota.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SERIE->SET_TEMPORADAS
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TEMPORADAS                  TYPE        INT1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_TEMPORADAS.
    me->md_temporadas = id_temporadas.
  endmethod.
ENDCLASS.