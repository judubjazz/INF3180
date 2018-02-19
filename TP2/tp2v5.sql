--SET ECHO ON
---- Script Oracle SQL*plus de creation du schema Entreprise de cnsultation

                ----CREATION------

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

                               -----TRIGGER--------
                               
                               
                               
--2 Il ne peut pas y avoir deux chirurgies pour une même salle qui se chevauche dans la plage horaire.
CREATE OR REPLACE TRIGGER trg_chirurgie_update_salle
BEFORE UPDATE OF HeureDebut,HeureFin ON CHIRURGIE 
FOR EACH ROW
WHEN (OLD.IdSalle = NEW.IdSalle AND New.HeureDebut NOT BETWEEN OLD.HeureDebut AND OLD.HeureFin OR NEW.HeureFin NOT BETWEEN OLD.HeureFin And OLD.HeureDebut  )
BEGIN
    raise_application_error(-20100, 'Il ne peut pas y avoir deux chirurgies pour une même salle qui se chevauche dans la plage horaire.');
END;
/

Create Or Replace Trigger trg_chirurgie_heure
	Before Insert Or Update On Chirurgie
	For each row
	Declare 
		nbrEnreg Integer;
	Begin
		Select count(*) Into nbrEnreg 
		From Chirurgie 
		Where idSalle = :New.idSalle And dateChirurgie = :New.dateChirurgie 
			And ((HeureDebut < :New.HeureFin And :New.HeureFin <= HeureDebut)
			Or (HeureDebut <= :New.HeureDebut And :New.HeureDebut < HeureDebut)
			Or (:New.HeureDebut < HeureDebut  And :New.HeureFin > HeureDebut));
		If nbrEnreg > 0 
		Then Raise_Application_Error(-20001, 'Cette chirurgie n epeut être insérée ou mise à jour ! Il y a chevauchement d horaire dans cette salle à cette date');
		End If;
	End;
/

--3a Les nbrPatients (nombre de patients d’un docteur à titre de médecin traitant)
--   doivent être toujours mis à jour automatiquement.

Create or Replace Trigger trg_patient_insert
After Insert on DossierPatient
For Each Row
Begin
	Update Docteur
	Set nbrPatients = nbrPatients + 1
	Where :new.matricule = docteur.matricule;
End;
/

Create or Replace Trigger trg_patient_delete
After Delete on DossierPatient
For Each Row
Begin
	Update Docteur
	Set nbrPatients = nbrPatients - 1
	Where :old.matricule = docteur.matricule;
End;
/

--3b Les nbrMoyenMedicaments (nombre moyen de médicaments prescrits par un docteur par prescription)
--   doivent être toujours mis à jour automatiquement.

CREATE OR REPLACE TRIGGER trg_ordon_med
AFTER INSERT ON ORDONNANCE 
FOR EACH ROW
DECLARE nbr INTEGER;
BEGIN
    Select count(*)
    into nbr
    From CONSULTATION c, DOCTEUR d
    WHERE c.CodeDocteur = d.matricule AND :NEW.numOrd = c.numOrd;
    IF nbr = 0 then nbr:= 1;
    END IF;
    Update DOCTEUR 
    SET nbrMoyenMedicaments = nbrMoyenMedicaments + (:NEW.nbrMedicaments -nbrMoyenMedicaments)/ nbr;
END; 
/

CREATE OR REPLACE TRIGGER trg_ordon_med2
AFTER Delete ON ORDONNANCE 
FOR EACH ROW
DECLARE nbr INTEGER;
BEGIN
    Select count(*) into nbr 
    From CONSULTATION c ,DOCTEUR d 
    WHERE c.CodeDocteur = d.matricule AND :OLD.numOrd = c.numOrd;
    IF nbr = 1 then nbr:= 2;
    END IF;
    Update DOCTEUR 
    SET nbrMoyenMedicaments = ((nbrMoyenMedicaments * nbrPatients) - :OLD.nbrMedicaments )/ nbr -1;
END; 
/


--3c Les nbrConsultation (nombre total de consultations pour un patient)
--   doivent être toujours mis à jour automatiquement.

CREATE OR REPLACE TRIGGER trg_dossierpatient
AFTER INSERT ON CONSULTATION
FOR EACH ROW
BEGIN
    UPDATE DOSSIERPATIENT d
    SET d.nbrConsultation = d.NBRCONSULTATION + 1
    WHERE d.numDos = :NEW.numDos;
END; 
/


--3d les nbrMedicaments (nombre de médicaments différents – pas les boîtes - pour une unique ordonnance)
--   doivent être toujours mis à jour automatiquement.

CREATE OR REPLACE TRIGGER trg_ordonnance_nbrmed
AFTER UPDATE ON ORDONNANCE 
FOR EACH ROW
BEGIN
    UPDATE ORDONNANCE
    SET nbrMedicaments = nbrMedicaments + :NEW.nbrMedicaments
    WHERE numOrd = :NEW.numOrd;
END; 
/

--4 le detail de l ordonnance ( ORDONNANCE CHIRURGIE OU ORDONANCE MEDICAMMENT) doit corresponde au type d ordonnce
-- manquant


                                ----JEU DE MOT/INSERTION----
 
 
 -- INSERT SPECIALITE

Insert into SPECIALITE
Values (1, NULL, 'Facial');
/
Insert into SPECIALITE
Values (10, 'Esthetique', 'Facial');
/
Insert into SPECIALITE
Values (11, 'Urgentiste', 'Accident');
/
Insert into SPECIALITE
Values (12, 'Opthamologiste', 'Chirurgie');
/

--INSERT SALLE
Insert into SALLE
Values (1, NULL);
/
Insert into SALLE
Values (10, 'wilfred');
/
Insert into SALLE
Values (11, 'calixa');
/
Insert into SALLE
Values (12, 'abraham');
/


--INSERT CATEGORIES

Insert into CATEGORIES
Values (1, NULL, 'comprime');
/
Insert into CATEGORIES
Values (10, 'comprime', 'comprime');
/
Insert into CATEGORIES
Values (11, 'gelule', 'gelule');
/
Insert into CATEGORIES
Values (12, 'sirop', 'sirop');
/


--INSERT TYPECHIRURGIE

Insert into TYPECHIRURGIE
Values (1, NULL, 'Facial');
/
Insert into TYPECHIRURGIE
Values (10,'chirurgie dentaire', 'bouche');
/
Insert into TYPECHIRURGIE
Values (11, 'chirurgie plastique', 'esthetique');
/
Insert into TYPECHIRURGIE
Values (12, 'occulaire', 'yeux');
/

--INSERT ORDONNANCE

Insert into ORDONNANCE
Values (1, 'test', 'erreur', '2001-01-01', 1);
/
Insert into ORDONNANCE
Values (2, 'boire de l eau', 'Chirurgie', '2002-02-02', -1);
/
Insert into ORDONNANCE
Values (10, 'ne pas manger', 'Médicaments', '2010-10-10', 10);
/
Insert into ORDONNANCE
Values (11, 'ne pas boire', 'Chirurgie', '2011-11-11', 11);
/
Insert into ORDONNANCE
Values (12, 'ne rien faire', 'Chirurgie', '2012-12-12', default);
/

--INSERT DOCTEUR

Insert into DOCTEUR
Values (1, NULL, 'Phil', 1, 'NY', 'ici', 'Docteur', 1, 1);
/
Insert into DOCTEUR
Values (2, 'McGraw', NULL, 2, 'NY', 'ici', 'Docteur', 2, 2);
/
Insert into DOCTEUR
Values (3, 'McGraw', 'Phil', 3, 'NY', 'ici', 'Docteur', -1, 3);
/
Insert into DOCTEUR
Values (4, 'McGraw', 'Phil', 4, 'NY', 'ici', 'Docteur', 4, -1);
/
Insert into DOCTEUR
Values (5, 'McGraw', 'Phil', 4, 'NY', 'ici', 'tv', 4, -1);
/
Insert into DOCTEUR
Values (10, 'Dr', 'House', 10, 'NY', '10 dix', 'Étudiant', default , 10);
/
Insert into DOCTEUR
Values (11, 'Dr', 'Evil', 11, 'NY', '11 onze', 'Interne', 11 , default);
/
Insert into DOCTEUR
Values (12, 'Dr', 'Green Thumb', 12, 'NY', '12 douze', 'Docteur', 12, 12);
/

--INSERT DOSSIERPATIENT

Insert into DOSSIERPATIENT
Values (1, NULL, 'inette', 'M', 1, '2001-01-01', '2001-01-01', 1, 1);
/
Insert into DOSSIERPATIENT
Values (2, 'bob', NULL, 'M', 2, '2002-02-02', '2002-02-02', 2, 2);
/
Insert into DOSSIERPATIENT
Values (3, 'bob', 'inette', 'M', 3, '2003-03-03', '2003-03-03', 3, -1);
/
Insert into DOSSIERPATIENT
Values (4, 'bob', 'inette', 'T', 4, '2004-04-04', '2004-04-04', 4, 4);
/
Insert into DOSSIERPATIENT
Values (10, 'bob', 'inette', 'M', 10, '2010-10-10', '2010-10-10', 10, 10);
/
Insert into DOSSIERPATIENT
Values (5, 'bob', 'inette', 'M', 10, '2010-10-10', '2010-10-10', 10, 10);
/
Insert into DOSSIERPATIENT
Values (11, 'guy', 'lafleur', 'M', 11, '2011-11-11', '2011-11-11', 11, 11);
/
Insert into DOSSIERPATIENT
Values (12, 'jojo', 'savard', 'F', 12, '2012-12-12', '2012-12-12', 12, 12);
/




--INSERT CONSULTATION

Insert into CONSULTATION
Values (1, 1, '2001-01-01', NULL, 1);
/
Insert into CONSULTATION
Values (10, 10, '2010-10-10', 'inflamation', 10);
/
Insert into CONSULTATION
Values (11, 11, '2011-11-11', 'cancer', 11);
/
Insert into CONSULTATION
Values (12, 12, '2012-12-12', 'fracture', 12);
/

--INSERT CHIRURGIE

Insert into Chirurgie
Values (1, 1, 1, '2001-01-01', -1, 1);
/
Insert into Chirurgie
Values (2, 2, 2, '2002-02-02', 0, -1);
/
Insert into Chirurgie
Values (10, 10, 10, '2010-10-10', 10, 11);
/
Insert into Chirurgie
Values (11, 11, 11, '2011-11-11', 12, 13);
/
Insert into Chirurgie
Values (12, 12, 12, '2012-12-12', 14, 15);
/
Insert into Chirurgie
Values (20, 20, 20, '2020-10-20', 10, 15);
/
Insert into Chirurgie
Values (21, 20, 20, '2020-10-20', 9, 11);
/
Insert into Chirurgie
Values (22, 20, 20, '2020-10-20', 14, 16);
/
Insert into Chirurgie
Values (23, 20, 20, '2020-10-20', 11, 14);


--INSERT ORDONNANCECHIRURGIE

Insert into ORDONNANCECHIRURGIE
Values (1, 1, 1);
/
Insert into ORDONNANCECHIRURGIE
Values (1, 1, 1);
/
Insert into ORDONNANCECHIRURGIE
Values (10, 10, 10);
/
Insert into ORDONNANCECHIRURGIE
Values (11, 11, 11);
/
Insert into ORDONNANCECHIRURGIE
Values (12, 12, 12);
/






--INSERT SPECIALISATIONSALLE

Insert into SPECIALISATIONSALLE
Values (10, 10, '2010-10-10');
/
Insert into SPECIALISATIONSALLE
Values (11, 11, '2011-11-11');
/
Insert into SPECIALISATIONSALLE
Values (12, 12, '2012-12-12');
/


--INSERT MEDICAMENT

Insert into MEDICAMENT
Values (1, NULL, 1.11, 1);
/
Insert into MEDICAMENT
Values (2, 'vortex', -2.22, 2);
/
Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);
/
Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);
/
Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);
/
Insert into MEDICAMENT
Values (11, 'silex', 11.11, 11);
/
Insert into MEDICAMENT
Values (12, 'cutex', default, 12);
/

--INSERT ORDONNANCEMEDICAMENTS

Insert into ORDONNANCEMEDICAMENTS
Values (1, 1, -1);
/
Insert into ORDONNANCEMEDICAMENTS
Values (10, 10, 10);
/
Insert into ORDONNANCEMEDICAMENTS
Values (11, 11, 11);
/
Insert into ORDONNANCEMEDICAMENTS
Values (12, 12, 12);
/

            ---SELECTION ----
            
SELECT *
FROM DOSSIERPATIENT
/

SELECT *
FROM MEDICAMENT
/

SELECT *
FROM ORDONNANCE
/

SELECT *
FROM DOCTEUR
/

SELECT *
FROM ORDONNANCEMEDICAMENTS
/

SELECT *
FROM TYPECHIRURGIE
/

SELECT *
FROM CATEGORIES
/

SELECT *
FROM ORDONNANCECHIRURGIE
/

SELECT *
FROM SPECIALITE
/

SELECT *
FROM CHIRURGIE
/

SELECT *
FROM CONSULTATION
/

SELECT *
FROM SALLE
/

SELECT *
FROM SPECIALISATIONSALLE
/
        ----DROP -------
        
DROP TRIGGER trg_ordonnance_nbrmed;
DROP TRIGGER trg_dossierpatient;
DROP TRIGGER trg_ordon_med2;
DROP TRIGGER trg_ordon_med;
DROP TRIGGER trg_patient_delete;
DROP TRIGGER trg_patient_insert;
DROP TRIGGER trg_chirurgie_update_salle;
DROP TRIGGER trg_chirurgie_heure;        
DROP TABLE ORDONNANCEMEDICAMENTS;
DROP TABLE MEDICAMENT;
DROP TABLE SPECIALISATIONSALLE;
DROP TABLE ORDONNANCECHIRURGIE;
DROP TABLE CHIRURGIE;
DROP TABLE CONSULTATION;
DROP TABLE DOSSIERPATIENT;
DROP TABLE DOCTEUR;
DROP TABLE ORDONNANCE;
DROP TABLE TYPECHIRURGIE;
DROP TABLE CATEGORIES;
DROP TABLE SALLE;
DROP TABLE SPECIALITE;



