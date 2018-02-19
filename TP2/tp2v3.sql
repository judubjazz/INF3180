--SET ECHO ON
---- Script Oracle SQL*plus de creation du schema Entreprise de cnsultation

CREATE TABLE SPECIALITE
(code INTEGER,
titre VARCHAR2(20) NOT NULL,
description VARCHAR2(20),
CONSTRAINT SPECIALITE_PK PRIMARY KEY (code)
)
/

CREATE TABLE SALLE
(idSalle INTEGER,
nom VARCHAR2(20) NOT NULL,
CONSTRAINT SALLE_PK PRIMARY KEY (idSalle)
)
/

CREATE TABLE CATEGORIES
(IdCategorie INTEGER,
nom VARCHAR2(20) NOT NULL,
Description VARCHAR2(20),
CONSTRAINT CATEGORIES_PK PRIMARY KEY (IdCategorie)
)
/

CREATE TABLE TYPECHIRURGIE
(IdType INTEGER,
nom VARCHAR2(20) NOT NULL,
Description VARCHAR2(200),
CONSTRAINT TYPECHIRURGIE_PK PRIMARY KEY (IdType)
)
/

CREATE TABLE ORDONNANCE
(numOrd INTEGER,
recommandations VARCHAR2(20),
type VARCHAR2(20),
dateC DATE,
nbrMedicaments INTEGER DEFAULT 0,
CONSTRAINT ORDONNANCE_PK PRIMARY KEY (numOrd),
CONSTRAINT ORDONNANCE_CHK CHECK (type IN ('Chirurgie','Médicaments')),
CONSTRAINT ORDONNANCE_CHK2 CHECK (nbrMedicaments >= 0)
)
/

CREATE TABLE DOCTEUR
(matricule INTEGER,
nomM VARCHAR2(20) NOT NULL,
prenomM VARCHAR2(20) NOT NULL,
specialite INTEGER,
ville VARCHAR2(20),
adresse VARCHAR2(100),
niveau VARCHAR2(20),
nbrPatients INTEGER DEFAULT 0,
nbrMoyenMedicaments NUMBER DEFAULT 0,
CONSTRAINT DOCTEUR_PK PRIMARY KEY (matricule),
CONSTRAINT DOCTEUR_FK FOREIGN KEY (specialite) REFERENCES SPECIALITE(code), 
CONSTRAINT DOCTEUR_CHK CHECK (nbrPatients >=0),
CONSTRAINT DOCTEUR_CHK2 CHECK (nbrMoyenMedicaments >=0),
CONSTRAINT DOCTEUR_CHK3 CHECK (niveau IN ('Étudiant','Interne','Docteur'))
)
/

CREATE TABLE DOSSIERPATIENT
(numDos INTEGER,
nomP VARCHAR2(20) NOT NULL,
prenomP VARCHAR2 (20) NOT NULL,
sexe VARCHAR2 (1),
numAS INTEGER,
dateNaiss DATE,
dateC DATE,
matricule INTEGER,
nbrConsultation INTEGER DEFAULT 0,
CONSTRAINT DOSSIERPATIENT_PK PRIMARY KEY (numDos),
CONSTRAINT DOSSIERPATIENT_FK FOREIGN KEY (matricule) REFERENCES DOCTEUR(matricule) ON DELETE SET NULL,
CONSTRAINT DOSSIERPATIENT_CHK CHECK (sexe IN ('M','F')),
CONSTRAINT DOSSIERPATIENT_CHK2 CHECK (nbrConsultation >=0),
CONSTRAINT DOSSIERPATIENT_UN UNIQUE(numAS)
)
/

CREATE TABLE CONSULTATION
(CodeDocteur INTEGER,
numDos INTEGER,
dateC DATE,
diagnostic VARCHAR2(200) NOT NULL,
numOrd INTEGER,
CONSTRAINT CONSULTATION_PK PRIMARY KEY (CodeDocteur,numDos,dateC),
CONSTRAINT CONSULTATION_FK FOREIGN KEY (CodeDocteur) REFERENCES DOCTEUR(matricule) ON DELETE CASCADE,
CONSTRAINT CONSULTATION_FK2 FOREIGN KEY (numOrd) REFERENCES ORDONNANCE(numOrd) NOT DEFERRABLE, 
CONSTRAINT CONSULTATION_FK3 FOREIGN KEY (numDos) REFERENCES DOSSIERPATIENT(numDos) ON DELETE CASCADE
)
/

CREATE TABLE CHIRURGIE
(idChir INTEGER,
idType INTEGER,
idSalle INTEGER,
dateChirurgie DATE,
HeureDebut INTEGER,
HeureFin INTEGER,
CONSTRAINT CHIRURGIE_PK PRIMARY KEY (idChir),
CONSTRAINT CHIRURGIE_FK FOREIGN KEY (IdType) REFERENCES TYPECHIRURGIE(IdType),
CONSTRAINT CHIRURGIE_FK2 FOREIGN KEY (idSalle) REFERENCES SALLE(idSalle),
CONSTRAINT CHIRURGIE_CHK CHECK (HeureDebut >=0),
CONSTRAINT CHIRURGIE_CHK2 CHECK (HeureFin >=0)
)
/

CREATE TABLE ORDONNANCECHIRURGIE
(numOrd INTEGER,
idChir INTEGER,
rang INTEGER,
CONSTRAINT ORDONNANCECHIRURGIE_PK PRIMARY KEY (numOrd,idChir),
CONSTRAINT ORDONNANCECHIRURGIE_FK FOREIGN KEY (idChir) REFERENCES CHIRURGIE(idChir),
CONSTRAINT ORDONNANCECHIRURGIE_FK2 FOREIGN KEY (numOrd) REFERENCES ORDONNANCE(numOrd),
CONSTRAINT ORDONNANCECHIRURGIE_UNI UNIQUE (numOrd,idChir,rang)
)
/

CREATE TABLE SPECIALISATIONSALLE
(IdType INTEGER,
idSalle INTEGER, 
dateC DATE,
CONSTRAINT SPECIALISATIONSALLE_PK PRIMARY KEY(IdType,idSalle),
CONSTRAINT SPECIALISATIONSALLE_FK FOREIGN KEY (IdType) REFERENCES TYPECHIRURGIE(IdType),
CONSTRAINT SPECIALISATIONSALLE_FK2 FOREIGN KEY (idSalle) REFERENCES SALLE(idSalle)
)
/

CREATE TABLE MEDICAMENT
(idMed INTEGER,
nomMed VARCHAR2(20) NOT NULL,
prix NUMBER (6,2) DEFAULT 0,
categorie INTEGER,
CONSTRAINT MEDICAMENT_PK PRIMARY KEY(idMed),
CONSTRAINT MEDICAMENT_FK FOREIGN KEY(categorie) REFERENCES CATEGORIES(IdCategorie),
CONSTRAINT MEDICAMENT_CHK CHECK (prix >=0),
CONSTRAINT MEDICAMENT_UNI UNIQUE (idMed, categorie)
)
/

CREATE TABLE ORDONNANCEMEDICAMENTS
(numOrd INTEGER,
idMed INTEGER,
nbBoites INTEGER DEFAULT 0,
CONSTRAINT ORDONNANCEMEDICAMENTS_PK PRIMARY KEY(numOrd,idMed),
CONSTRAINT ORDONNANCEMEDICAMENTS_FK FOREIGN KEY(numOrd) REFERENCES ORDONNANCE(numOrd),
CONSTRAINT ORDONNANCEMEDICAMENTS_FK2 FOREIGN KEY(idMed) REFERENCES MEDICAMENT(idMed),
CONSTRAINT ORDONNANCEMEDICAMENTS_CHK CHECK (nbBoites >=0)
)
/
--2 Il ne peut pas y avoir deux chirurgies pour une même salle qui se chevauche dans la plage horaire.
CREATE OR REPLACE TRIGGER trigger_chirurgie_update_salle
BEFORE UPDATE OF HeureDebut,HeureFin ON CHIRURGIE 
FOR EACH ROW
WHEN (OLD.IdSalle =NEW.IdSalle AND New.HeureDebut NOT BETWEEN OLD.HeureDebut AND OLD.HeureFin OR NEW.HeureFin NOT BETWEEN OLD.HeureFin And OLD.HeureDebut  )
BEGIN
    raise_application_error(-20100, 'Il ne peut pas y avoir deux chirurgies pour une même salle qui se chevauche dans la plage horaire.');
END;
/

CREATE OR REPLACE TRIGGER trigger_chirurgie_insert_salle
BEFORE INSERT ON CHIRURGIE 
FOR EACH ROW
Declare nbr INTEGER;
BEGIN
    Select count(*) 
    into nbr
    From CHIRURGIE c
    WHERE NEW.idSalle = c.idSalle AND NEW.dateChirurgie = c.dateChirurgie AND New.HeureDebut BETWEEN OLD.HeureDebut AND OLD.HeureFin OR NEW.HeureFin NOT BETWEEN OLD.HeureFin And OLD.HeureDebut;
    
    If :nbr > 0 THEN
         raise_application_error(-20100, 'Il ne peut pas y avoir deux chirurgies pour une même salle qui se chevauche dans la plage horaire.');
    END IF;     
END;
/

--3a Les nbrPatients (nombre de patients d’un docteur à titre de médecin traitant)
--   doivent être toujours mis à jour automatiquement.

CREATE OR REPLACE TRIGGER trigger_docteur_insert
AFTER INSERT ON DOSSIERPATIENT dp
FOR EACH ROW
DECLARE lematricule NUMBER;
BEGIN
    Select matricule into lematricule
    From DOCTEUR d
    WHERE matricule = NEW matricule
    UPDATE DOCTEUR
    SET nbrPatient = nbrPatient + 1
    Where matricule = lematricule;
END;
/

CREATE OR REPLACE TRIGGER trigger_docteur_delete
AFTER Delete ON DOSSIERPATIENT dp
FOR EACH ROW
DECLARE lematricule NUMBER;
BEGIN
    Select matricule into lematricule
    From DOCTEUR d
    WHERE matricule = OLD matricule
    UPDATE DOCTEUR
    SET nbrPatient = nbrPatient - 1
    Where matricule = lematricule;
END;
/

--3b Les nbrMoyenMedicaments (nombre moyen de médicaments prescrits par un docteur par prescription)
--   doivent être toujours mis à jour automatiquement.
CREATE OR REPLACE TRIGGER trigger_ordon_med
AFTER UPDATE OR INSERT of nbrMedicament ON ORDONNANCE 
FOR EACH ROW
BEGIN
    Select count(*)AS nbr 
    From CONSULTATION c JOIN DOCTEUR d ON c.CodeDocteur = d.matricule AND NEW.numOrd = c.numOrd
    Update DOCTEUR 
    SET nbrMoyenMedicament = nbrMoyenMedicament + (NEW.nbrMedicament -nbrMoyenMedicament)/ nbr
END; 
/

CREATE OR REPLACE TRIGGER trigger_ordon_med2
AFTER Delete of nbrMedicament ON ORDONNANCE 
FOR EACH ROW
BEGIN
    Select count(*)AS nbr 
    From CONSULTATION c JOIN DOCTEUR d ON c.CodeDocteur = d.matricule AND OLD.numOrd = c.numOrd
    Update DOCTEUR 
    SET nbrMoyenMedicament = ((nbrMoyenMedicament * nbrPatient) - OLD.nbrMedicament )/ nbr -1
END; 
/

--3c Les nbrConsultation (nombre total de consultations pour un patient)
--   doivent être toujours mis à jour automatiquement.
CREATE OR REPLACE TRIGGER trigger_dossierpatient
AFTER INSERT of numDos ON DOSSIERPATIENT
FOR EACH ROW
BEGIN
    UPDATE DOSSIERPATIENT
    SET nbrConsultation = nbrConsulation +1
    WHERE numDos = NEW.numDos;
END; 
/


--3d les nbrMedicaments (nombre de médicaments différents – pas les boîtes - pour une unique ordonnance)
--   doivent être toujours mis à jour automatiquement.
CREATE OR REPLACE TRIGGER trigger_ordonnance_nbrmed
AFTER UPDATE ON ORDONNANCE 
FOR EACH ROW
BEGIN
    UPDATE ORDONNANCE
    SET nbrMedicament = nbrMedicament + NEW.nbrMedicament
    WHERE numOrd = NEW.numOrd;
END; 
/


--2 Le détail de l’ordonnance (ORDONNANCECHIRURGIE ou ORDONNANCEMEDICAMENTS) doit correspondre au type d’ordonnance.

--DROP TABLE DOSSIERPATIENT CASCADE CONSTRAINTS PURGE;
--DROP TABLE DOCTEUR CASCADE CONSTRAINTS PURGE;
--DROP TABLE CONSULTATION CASCADE CONSTRAINTS PURGE;
--DROP TABLE ORDONNANCE CASCADE CONSTRAINTS PURGE;
--DROP TABLE ORDONNANCECHIRURGIE CASCADE CONSTRAINTS PURGE;
--DROP TABLE CHIRURGIE CASCADE CONSTRAINTS PURGE;
--DROP TABLE SALLE CASCADE CONSTRAINTS PURGE;
--DROP TABLE SPECIALISATIONSALLE CASCADE CONSTRAINTS PURGE;
--DROP TABLE TYPECHIRURGIE CASCADE CONSTRAINTS PURGE;
--DROP TABLE ORDONNANCEMEDICAMENTS CASCADE CONSTRAINTS PURGE;
--DROP TABLE MEDICAMENT CASCADE CONSTRAINTS PURGE;
--DROP TABLE SPECIALITE CASCADE CONSTRAINTS PURGE;
--DROP TABLE CATEGORIES CASCADE CONSTRAINTS PURGE;
DROP TRIGGER trigger_ordonnance_nbrmed
DROP TRIGGER trigger_dossierpatient
DROP TRIGGER trigger_ordon_med2
DROP TRIGGER trigger_ordon_med
DROP TRIGGER trigger_docteur_delete
DROP TRIGGER trigger_docteur_insert
DROP TRIGGER trigger_chirurgie_insert_salle
DROP TRIGGER trigger_chirurgie_update_salle


