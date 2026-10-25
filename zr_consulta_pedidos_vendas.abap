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

DATA: gt_vbak TYPE TABLE OF ty_vbak,
      gt_vbap TYPE TABLE OF ty_vbap,
      gt_kna1 TYPE TABLE OF ty_kna1,
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


* ┌─────────────────────────┐
* │   SUBROUTINES (FORMS)   │
* └─────────────────────────┘

FORM f_seleciona_dados.

  SELECT vbeln, erdat, ernam, kunnr, netwr, waerk
  FROM vbak
  INTO TABLE @gt_vbak
  WHERE vbeln IN @s_vbeln
    AND erdat IN @s_erdat
    AND kunnr = @p_kunnr.

  IF gt_vbak IS NOT INITIAL.
    SELECT vbeln, posnr, matnr, arktx, kwmeng, vrkme, netwr
    FROM vbap
    INTO TABLE @gt_vbap
    FOR ALL ENTRIES IN @gt_vbak
    WHERE vbeln = @gt_vbak-vbeln.

    IF gt_vbap IS NOT INITIAL.

    ENDIF.

  ELSE.
    MESSAGE |Nenhum pedido encontrado para os filtros informados.| TYPE 'E'.
    STOP.
  ENDIF.

ENDFORM.