CREATE TABLE CLASSIF_CONTABIL_SAP(
    ID_TIPO_CLASSIF INT NOT NULL PRIMARY KEY,
    NOME VARCHAR2(40),
    NOME_LIMPO VARCHAR2(40),
    DTCRIACAO DATE DEFAULT SYSDATE
);

INSERT INTO classif_contabil_sap VALUES (1,'Provisao','PROVISAODEMANUTENCAO',sysdate);
INSERT INTO classif_contabil_sap VALUES (2,'Intangivel','INTANGIVEL',sysdate);
INSERT INTO classif_contabil_sap VALUES (3,'Imobilizado','IMOBILIZADO',sysdate);
INSERT INTO classif_contabil_sap VALUES (4,'Sofware','SOFTWARE',sysdate);
COMMIT;