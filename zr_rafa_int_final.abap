*&---------------------------------------------------------------------*
*& Report ZR_RAFA_INT_FINAL
*&---------------------------------------------------------------------*
*& Exercício final - Listagem de Materiais ABAP4G
*& Abap Intermediário
*& Nível médio
*& WIP
*&---------------------------------------------------------------------*

REPORT zr_rafa_int_final.

* ┌──────────────────────────┐
* │   I DECLARE BANKRUPTCY   │
* └──────────────────────────┘

TABLES: mara.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_mara,
         matnr TYPE zvi_mara_makt-matnr,    "Número do material
         ersda TYPE zvi_mara_makt-ersda,    "Data de criação
         ernam TYPE zvi_mara_makt-ernam,    "Nome do responsável
         lvorm TYPE zvi_mara_makt-lvorm,    "Marcar material para eliminação a nível de mandante
         mtart TYPE zvi_mara_makt-mtart,    "Tipo de material
         matkl TYPE zvi_mara_makt-matkl,    "Grupo de mercadorias
         maktx TYPE zvi_mara_makt-maktx,    "Descrição do material
       END OF ty_mara.

DATA: gt_mara     TYPE TABLE OF ty_mara,
      gs_mara     TYPE ty_mara,
      gs_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv,
      gv_button   TYPE char1.


* --- USER INPUTS

* --- BLOCK 1
SELECTION-SCREEN:
  BEGIN OF BLOCK Rad WITH FRAME TITLE text-001,
    BEGIN OF LINE,
      PUSHBUTTON  5(25) button1 USER-COMMAND com1,
      PUSHBUTTON 35(25) button2 USER-COMMAND com2,
    END OF LINE,
  END OF BLOCK Rad.

* --- BLOCK 2
SELECTION-SCREEN BEGIN OF BLOCK Sel WITH FRAME TITLE text-002.
  SELECT-OPTIONS: s_ersda FOR mara-ersda.
SELECTION-SCREEN END OF BLOCK Sel.

INITIALIZATION.
  button1 = 'Materiais criados'.
  button2 = 'Materiais eliminados'.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'COM1'.
      gv_button = 1.
      PERFORM f_report.

    WHEN 'COM2'.
      gv_button = 2.
      PERFORM f_report.
  ENDCASE.


*   ┌─┐
*   │ ᴼ  EXECUTE
* ──┴───────────────

START-OF-SELECTION.
  IF gv_button IS INITIAL.
    MESSAGE 'Escolha uma opção válida para continuar.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

* ┌─────────────────────────┐
* │   SUBROUTINES (FORMS)   │
* └─────────────────────────┘

FORM f_report.

  REFRESH: gt_mara, gt_fieldcat.

  IF gv_button = '1'.
    SELECT matnr, ersda, ernam, lvorm, mtart, matkl, maktx
      FROM zvi_mara_makt
      INTO TABLE @gt_mara
      WHERE ersda IN @s_ersda
            AND lvorm = @space.

  ELSEIF gv_button = '2'.
    SELECT matnr, ersda, ernam, lvorm, mtart, matkl, maktx
      FROM zvi_mara_makt
      INTO TABLE @gt_mara
      WHERE ersda IN @s_ersda
            AND lvorm = 'X'.
  ENDIF.

  IF gt_mara IS INITIAL.
    MESSAGE 'Não existem materiais para os filtros informados.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM f_build_fieldcat.
  PERFORM f_display_alv.

  CLEAR gv_button.

ENDFORM.

* ---

FORM f_build_fieldcat.
 
  PERFORM f_fieldcat USING:
    'MATNR'  'Número do material'     1,
    'ERSDA'  'Data da criação'        2,
    'ERNAM'  'Nome do responsável'    3,
    'LVORM'  'Marcado para exclusão'  4,
    'MTART'  'Tipo de material'       5,
    'MATKL'  'Grupo de material'      6,
    'MAKTX'  'Descrição do material'  7.

ENDFORM.

* ---

FORM f_fieldcat USING   lv_campo
                        lv_descr
                        lv_pos.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = lv_campo.
  gs_fieldcat-seltext_l = lv_descr.
  gs_fieldcat-col_pos   = lv_pos.

  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.

* ---

FORM f_display_alv.

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-window_titlebar = 'Teste ALV - Lista de materiais'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout        = gs_layout
      it_fieldcat      = gt_fieldcat
    TABLES
      t_outtab         = gt_mara
    EXCEPTIONS
      program_error    = 1
      OTHERS           = 2.

ENDFORM.