*&---------------------------------------------------------------------*
*& Report ZR_RAFA_CADCLI
*&---------------------------------------------------------------------*
*& Exercício final - Cadastro de clientes ABAP4G
*& Abap Foundations
*& Nível easy
*&---------------------------------------------------------------------*

REPORT ZR_RAFA_CADCLI.

* ┌──────────────────────────┐
* │   I DECLARE BANKRUPTCY   │
* └──────────────────────────┘

* --- TABLES
Tables: ztclientes_rafa.

* --- USER INPUTS
* --- BLOCK 1
Selection-screen begin of block Acao with frame title text-001.
Parameters: r_cad  Radiobutton group A,
            r_edit Radiobutton group A,
            r_show Radiobutton group A Default 'X'.
Selection-screen end of block Acao.

* --- BLOCK 2
Selection-screen begin of block Sel with frame title text-002.
Select-options: s_cli FOR ztclientes_rafa-nome,
                s_cpf FOR ztclientes_rafa-cpf,
                s_rg  FOR ztclientes_rafa-rg.
Selection-screen end of block Sel.

* --- BLOCK 3
Selection-screen begin of block Cad with frame title text-003.
Parameters: p_nome    TYPE ztclientes_rafa-nome,
            p_cpf     TYPE ztclientes_rafa-cpf,
            p_rg      TYPE ztclientes_rafa-rg,
            p_dtnas   TYPE ztclientes_rafa-data_nasc,
            p_end     TYPE ztclientes_rafa-endereco.
Selection-screen end of block Cad.

* --- BLOCK 4
Selection-screen begin of block Mod with frame title text-004.
Parameters: p_nomee   TYPE ztclientes_rafa-nome,
            p_cpfe    TYPE ztclientes_rafa-cpf,
            p_rge     TYPE ztclientes_rafa-rg,
            p_dtnase  TYPE ztclientes_rafa-data_nasc,
            p_ende    TYPE ztclientes_rafa-endereco.
Selection-screen end of block Mod.

* --- DATA VARIABLES
Data: t_clirafa TYPE TABLE OF ztclientes_rafa,
      wa_cli    TYPE ztclientes_rafa.

*   ┌─┐
*   │ ᴼ  EXECUTE
* ──┴───────────────

Start-of-selection.

  If r_show = 'X'.
    Select *
      from ztclientes_rafa
      into table t_clirafa
      where nome IN s_cli
        AND cpf IN s_cpf
        AND rg IN s_rg.

      If SY-SUBRC = 0.
          Write: /3(30) 'Nome',
                  36(12) 'CPF',
                  54(10) 'RG',
                  68(10) 'Dt nasc',
                  82(35) 'Endereco'.
          Uline  /3(117).

        Loop at t_clirafa into wa_cli.
          Write: /3(30) wa_cli-nome,
                  36(12) wa_cli-cpf,
                  54(10) wa_cli-rg,
                  68(10) wa_cli-data_nasc,
                  82(35) wa_cli-endereco.
        Endloop.

      Else.
        Write / 'Nenhum registro encontrado.'.

      Endif.

  Elseif r_cad = 'X'.
    If p_nome Is initial.
      Message 'Obrigatório informar o nome do cliente.' type 'E'.

    Elseif p_cpf Is initial.
      Message 'Obrigatório informar o CPF.' type 'E'.

    Elseif p_rg Is initial.
      Message 'Obrigatório informar o RG.' type 'E'.

    Else.
        wa_cli-nome = p_nome.
        wa_cli-cpf = p_cpf.
        wa_cli-rg = p_rg.
        wa_cli-data_nasc = p_dtnas.
        wa_cli-endereco = p_end.

        Insert ztclientes_rafa FROM wa_cli.

        If Sy-Subrc = 0.
          Commit work.
          Message |Cliente { wa_cli-nome } cadastrado com sucesso.| type 'S'.

        Else.
          Message 'Erro ao cadastrar cliente (chave duplicada).' type 'E'.

        Endif.

    Endif.

  Elseif r_edit = 'X'.
    If p_nomee Is initial.
      Message 'Nome do cliente não pode ser vazio.' type 'E'.

    Elseif p_rge Is initial.
      Message 'Obrigatório informar o RG.' type 'E'.

    Elseif p_cpfe Is initial.
      Message 'Obrigatório informar o CPF.' type 'E'.

    Else.
      Select *
        from ztclientes_rafa
        into table t_clirafa
        where cpf = p_cpfe
              AND rg = p_rge.

      If Sy-Subrc = 0.
        wa_cli-nome = p_nomee.
        wa_cli-cpf = p_cpfe.
        wa_cli-rg = p_rge.
        wa_cli-data_nasc = p_dtnase.
        wa_cli-endereco = p_ende.

        Modify ztclientes_rafa FROM wa_cli.
        Commit work.
        Message |Cliente { wa_cli-nome } alterado com sucesso.| type 'S'.

      Else.
        Message 'Nenhum cliente encontrado com os dados informados.' type 'E'.

      Endif.

    Endif.

  Endif.