
CREATE TABLE LANC_CLASSIF_CONTABIL  (
    ID_LANCAMENTO INT NOT NULL PRIMARY KEY,
    ID_IMPORTACAO VARCHAR2(17) NOT NULL,
    ID_TIPO_CLASSIF VARCHAR2(50) NOT NULL,
    EMPCOD INT NOT NULL,
    DT_LANCAMENTO_SAP DATE,    
    PRJCOD INT NOT NULL,    
    PEP VARCHAR2(40) NOT NULL,    
    DESCRICAO_PEP VARCHAR2(200),
    CONTA_CONTABIL VARCHAR2(15),    
    VALOR NUMBER(18,2),
    CLASSE_IMOBILIZADO VARCHAR2(10),
    CHAVE_DEPRECIACAO VARCHAR2(4),
    ANO_EXERCICIO VARCHAR2(4),
    IMOBILIZADO VARCHAR2(12),
    SUB_NUMERO_IMOB VARCHAR2(4),
    NOMENCLATURA VARCHAR2(40)
);
 
CREATE SEQUENCE  SERVDESK.LANC_CONTABIL  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE;
 
CREATE OR REPLACE TRIGGER SERVDESK.TGR_LANC_CONTABIL_INS 
BEFORE INSERT ON SERVDESK.LANC_CLASSIF_CONTABIL
FOR EACH ROW
  WHEN (NEW.ID_LANCAMENTO IS NULL) BEGIN
  SELECT SERVDESK.LANC_CONTABIL.NEXTVAL
  INTO   :NEW.ID_LANCAMENTO
  FROM   DUAL;
END;
/


  CREATE OR REPLACE FORCE VIEW "SERVDESK"."V_LANC_CLASSIF_ESG" ("IDEMPRESA", "NOMEEMPRESA", "IDGRUPOPROGRAMA", "GRUPODEPROGRAMA", "IDPROGRAMA", "PROGRAMA", "IDPROJETO", "NOMEPROJETO", "VALORORCADO", "VALORTENDENCIA", "VALORREALIZADO", "VALORREPLAN", "VALORCICLO", "VALORPREVISTO", "TIPOLANCAMENTO","IDTIPOCLASSIFICACAO", "VALORREALIZADOSAP", "IDCLASSIFICACAOESG", "IDGESTOR", "NOMEGESTOR", "DTLANCAMENTOSAP", "PEP", "NOMENCLATURA", "NOMEFASE", "DTLANCAMENTOPROJETO", "SEQFASE") AS 
  select e.empcod as IdEmpresa
      ,e.empnom as NomeEmpresa
      ,gru.pgmgrucod as IdGrupoPrograma
      , nvl(gru.pgmgrunom,'Não Possui') as GrupoDePrograma
      , pro.pgmcod as IdPrograma
      , nvl(pro.pgmnom,'Não Possui') as Programa
      , p.prjcod as IdProjeto
      , p.prjnom as NomeProjeto
      , decode(orc.prjorctip,'O',nvl(orc.prjorcval,0),0) as ValorOrcado
      , decode(orc.prjorctip,'J',nvl(orc.prjorcval,0),0) as ValorTendencia
      , decode(orc.prjorctip,'R',nvl(orc.prjorcval,0),0) as ValorRealizado
      , decode(orc.prjorctip,'2',nvl(orc.prjorcval,0),0) as ValorReplan
      , decode(orc.prjorctip,'1',nvl(orc.prjorcval,0),0) as ValorCiclo
      , decode(orc.prjorctip,'P',nvl(orc.prjorcval,0),0) as ValorPrevisto
      , orc.prjorctip as TipoLancamento
      , lcc.id_tipo_classif as IdTipoClassificacao
      , nvl(lcc.valor,0) as ValorRealizadoSap
      , 0 as IdClassificacaoEsg
      , p.prjges as IdGestor
      ,(SELECT TRIM(USUNOM) 
          FROM CORPORA.USUARI 
         WHERE TRIM(USULOG) = TRIM(P.PRJGES))                          as NomeGestor
      , lcc.dt_lancamento_sap as DtLancamentoSap
      ,lcc.pep
      ,lcc.nomenclatura
      ,fse.prjfsenom as NomeFase
      , to_date('01' || '/' || decode(nvl(orc.prjorcmes,0),0,1,orc.prjorcmes) || '/' || decode(nvl(orc.prjorcano,0),0,1999,orc.prjorcano)) as DtLancamentoProjeto
      , fse.prjfseseq as SeqFase
  from projeto p         
        inner join corpora.empres e on (e.empcod = p.prjempcus)
        left join lanc_classif_contabil lcc on (lcc.prjcod = p.prjcod  and lcc.ano_exercicio > 2016 and lcc.empcod = e.empcod)
        left join pgmgru gru on (gru.pgmgrucod = p.prjpgmgru)
        left join pgmpro pro on (pro.pgmcod = p.prjpgmcod)
        left join pgmass m on (m.pgmasscod = p.pgmasscod and m.pgmassver = gru.pgmgruver and m.pgmgrucod = gru.pgmgrucod and m.pgmassver = 0 and m.pgmcod = pro.pgmcod)
        inner join prjorc orc on (orc.prjcod = p.prjcod 
                                and orc.prjorcver = 0 
                                and orc.prjorcmes > 0
                                and orc.prjorcmes = nvl(extract(month from lcc.dt_lancamento_sap),orc.prjorcmes) 
                                and orc.prjorctip in ('O','J','R','1','2','P') 
                                and orc.prjorcfse > 0
                                and orc.prjorcano = nvl(extract(year from lcc.dt_lancamento_sap),orc.prjorcano) 

                                )
        left join prjfse fse on (orc.prjcod = fse.prjcod and orc.prjorcfse = fse.prjfseseq)
  where p.prjsit = 'A';
/
