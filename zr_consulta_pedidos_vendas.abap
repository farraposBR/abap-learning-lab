*&---------------------------------------------------------------------*
*& Report ZR_CONSULTA_PEDIDOS_VENDAS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT zr_consulta_pedidos_vendas.

* ┌──────────────────────────┐
* │   I DECLARE BANKRUPTCY   │
* └──────────────────────────┘

* --- TABLES
TABLES: vbak,
        vbap,
        kna1.

" Estrutura da tabela de saída do ALV
TYPES: BEGIN OF ty_output,
         vbeln  TYPE vbak-vbeln,
         posnr  TYPE vbap-posnr,
         erdat  TYPE vbak-erdat,
         ernam  TYPE vbak-ernam,
         kunnr  TYPE vbak-kunnr,
         name1  TYPE kna1-name1,
         matnr  TYPE vbap-matnr,
         arktx  TYPE vbap-arktx,
         kwmeng TYPE vbap-kwmeng,
         vrkme  TYPE vbap-vrkme,
         netwr  TYPE vbak-netwr,
         waerk  TYPE vbak-waerk,
       END OF ty_output.

DATA: gt_output TYPE TABLE OF ty_output,
      gw_output TYPE ty_output.


" Tipos e tabelas internas auxiliares
TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         erdat TYPE vbak-erdat,
         ernam TYPE vbak-ernam,
         kunnr TYPE vbak-kunnr,
         netwr TYPE vbak-netwr,
         waerk TYPE vbak-waerk,
       END OF ty_vbak,

       BEGIN OF ty_vbap,
         vbeln  TYPE vbap-vbeln,
         posnr  TYPE vbap-posnr,
         matnr  TYPE vbap-matnr,
         arktx  TYPE vbap-arktx,
         kwmeng TYPE vbap-kwmeng,
         vrkme  TYPE vbap-vrkme,
         netwr  TYPE vbap-netwr,
       END OF ty_vbap,

       BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
       END OF ty_kna1.

DATA: gt_vbak  TYPE TABLE OF ty_vbak,
      gw_vbak  TYPE ty_vbak,
      gt_vbap  TYPE TABLE OF ty_vbap,
      gw_vbap  TYPE ty_vbap,
      gt_kna1  TYPE TABLE OF ty_kna1,
      gw_kna1  TYPE ty_kna1,
      lv_kunnr TYPE kna1-kunnr,
      lv_name1 TYPE kna1-name1.

* --- USER INPUTS
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-001.
  SELECT-OPTIONS: s_vbeln for vbak-vbeln,
                  s_erdat for vbak-erdat OBLIGATORY.

  PARAMETERS: p_kunnr TYPE vbak-kunnr.
SELECTION-SCREEN END OF BLOCK sel.

INITIALIZATION.
  s_erdat-low    = sy-datum(6) && '01'.
  s_erdat-high   = sy-datum.
  s_erdat-sign   = 'I'.
  s_erdat-option = 'BT'.
  APPEND s_erdat TO s_erdat.


AT SELECTION-SCREEN.

  IF p_kunnr IS NOT INITIAL.
    SELECT SINGLE kunnr, name1
    FROM kna1
    INTO (@lv_kunnr, @lv_name1)
    WHERE kunnr = @p_kunnr.

    IF sy-subrc = 0.
      MESSAGE |Cliente { lv_kunnr } - { lv_name1 } preenchido.| TYPE 'S'.
    ELSE.
      MESSAGE |Cliente informado não cadastrado.| TYPE 'E'.
    ENDIF.

  ENDIF.


START-OF-SELECTION.

  PERFORM f_seleciona_dados.
  PERFORM f_processa_dados.


* ┌─────────────────────────┐
* │   SUBROUTINES (FORMS)   │
* └─────────────────────────┘

FORM f_seleciona_dados.

  SELECT vbeln, erdat, ernam, kunnr, netwr, waerk
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE @gt_vbak
  WHERE vbeln IN @s_vbeln
    AND erdat IN @s_erdat.

  IF p_kunnr IS NOT INITIAL.
    DELETE gt_vbak WHERE kunnr <> p_kunnr.
  ENDIF.

  IF gt_vbak IS INITIAL.
    MESSAGE |Nenhum pedido encontrado para os filtros informados.| TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 1000.
  ENDIF.

  SELECT vbeln, posnr, matnr, arktx, kwmeng, vrkme
    FROM vbap
    INTO CORRESPONDING FIELDS OF TABLE @gt_vbap
    FOR ALL ENTRIES IN @gt_vbak
    WHERE vbeln = @gt_vbak-vbeln.

  IF gt_vbap IS INITIAL.
    MESSAGE |Nenhum pedido encontrado para os filtros informados.| TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 1000.
  ENDIF.

  SELECT kunnr, name1
  FROM kna1
  INTO CORRESPONDING FIELDS OF TABLE @gt_kna1
  FOR ALL ENTRIES IN @gt_vbak
  WHERE kunnr = @gt_vbak-kunnr.

ENDFORM.

FORM f_processa_dados.

  SORT gt_vbak BY vbeln.
  SORT gt_kna1 BY kunnr.

  CLEAR gt_output.

  LOOP AT gt_vbap INTO gw_vbap.

    CLEAR: gw_output, gw_vbak, gw_kna1.

    gw_output-vbeln  = gw_vbap-vbeln.
    gw_output-posnr  = gw_vbap-posnr.
    gw_output-matnr  = gw_vbap-matnr.
    gw_output-arktx  = gw_vbap-arktx.
    gw_output-kwmeng = gw_vbap-kwmeng.
    gw_output-vrkme  = gw_vbap-vrkme.

    READ TABLE gt_vbak INTO gw_vbak
      WITH KEY vbeln = gw_vbap-vbeln
      BINARY SEARCH.

    IF sy-subrc = 0.
      gw_output-erdat = gw_vbak-erdat.
      gw_output-ernam = gw_vbak-ernam.
      gw_output-kunnr = gw_vbak-kunnr.
      gw_output-netwr = gw_vbak-netwr.
      gw_output-waerk = gw_vbak-waerk.

      READ TABLE gt_kna1 INTO gw_kna1
        WITH KEY kunnr = gw_vbak-kunnr
        BINARY SEARCH.

      IF sy-subrc = 0.
        gw_output-name1 = gw_kna1-name1.
      ENDIF.

    ENDIF.

    APPEND gw_output TO gt_output.

  ENDLOOP.

ENDFORM.