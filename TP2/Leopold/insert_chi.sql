-- INSERT CHIRURGIE 

Insert into Chirurgie
Values (1, 1, 1, '2001-01-01', -1, 1);

Insert into Chirurgie
Values (2, 2, 2, '2002-02-02', 0, -1);

Insert into Chirurgie
Values (10, 10, 10, '2010-10-10', 10, 11);

Insert into Chirurgie
Values (11, 11, 11, '2011-11-11', 12, 13);

Insert into Chirurgie
Values (12, 12, 12, '2012-12-12', 14, 15);

Insert into Chirurgie
Values (20, 20, 20, '2020-10-20', 10, 15);

Insert into Chirurgie
Values (21, 20, 20, '2020-10-20', 9, 11);

Insert into Chirurgie
Values (22, 20, 20, '2020-10-20', 14, 16);

Insert into Chirurgie
Values (23, 20, 20, '2020-10-20', 11, 14);

-- INSERT SPECIALITE

Insert into SPECIALITE
Values (1, NULL, 'Facial');

Insert into SPECIALITE
Values (10, 'Esthetique', 'Facial');

Insert into SPECIALITE
Values (11, 'Urgentiste', 'Accident');

Insert into SPECIALITE
Values (12, 'Opthamologiste', 'Chirurgie');

--INSERT ORDONNANCECHIRURGIE

Insert into ORDONNANCECHIRURGIE
Values (1, 1, 1);

Insert into ORDONNANCECHIRURGIE
Values (1, 1, 1);

Insert into ORDONNANCECHIRURGIE
Values (10, 10, 10);

Insert into ORDONNANCECHIRURGIE
Values (11, 11, 11);

Insert into ORDONNANCECHIRURGIE
Values (12, 12, 12);

--INSERT CATEGORIES

Insert into CATEGORIES
Values (1, NULL, 'comprime');

Insert into CATEGORIES
Values (10, 'comprime', 'comprime');

Insert into CATEGORIES
Values (11, 'gelule', 'gelule');

Insert into CATEGORIES
Values (12, 'sirop', 'sirop');

--INSERT TYPECHIRURGIE

Insert into TYPECHIRURGIE
Values (1, NULL, 'Facial');

Insert into TYPECHIRURGIE
Values (10,'chirurgie dentaire', 'bouche');

Insert into TYPECHIRURGIE
Values (11, 'chirurgie plastique', 'esthetique');

Insert into TYPECHIRURGIE
Values (12, 'occulaire', 'yeux');

--INSERT CONSULTATION

Insert into CONSULTATION
Values (1, 1, '2001-01-01', NULL, 1);

Insert into CONSULTATION
Values (10, 10, '2010-10-10', 'inflamation', 10);

Insert into CONSULTATION
Values (11, 11, '2011-11-11', 'cancer', 11);

Insert into CONSULTATION
Values (12, 12, '2012-12-12', 'fracture', 12);

--INSERT DOSSIERPATIENT

Insert into DOSSIERPATIENT
Values (1, NULL, 'inette', 'M', 1, '2001-01-01', '2001-01-01', 1, 1);

Insert into DOSSIERPATIENT
Values (2, 'bob', NULL, 'M', 2, '2002-02-02', '2002-02-02', 2, 2);

Insert into DOSSIERPATIENT
Values (3, 'bob', 'inette', 'M', 3, '2003-03-03', '2003-03-03', 3, -1);

Insert into DOSSIERPATIENT
Values (4, 'bob', 'inette', 'T', 4, '2004-04-04', '2004-04-04', 4, 4);

Insert into DOSSIERPATIENT
Values (10, 'bob', 'inette', 'M', 10, '2010-10-10', '2010-10-10', 10, 10);

Insert into DOSSIERPATIENT
Values (5, 'bob', 'inette', 'M', 10, '2010-10-10', '2010-10-10', 10, 10);

Insert into DOSSIERPATIENT
Values (11, 'guy', 'lafleur', 'M', 11, '2011-11-11', '2011-11-11', 11, 11);

Insert into DOSSIERPATIENT
Values (12, 'jojo', 'savard', 'F', 12, '2012-12-12', '2012-12-12', 12, 12);

--INSERT DOCTEUR

Insert into DOCTEUR
Values (1, NULL, 'Phil', 1, 'NY', 'ici', 'Docteur', 1, 1);

Insert into DOCTEUR
Values (2, 'McGraw', NULL, 2, 'NY', 'ici', 'Docteur', 2, 2);

Insert into DOCTEUR
Values (3, 'McGraw', 'Phil', 3, 'NY', 'ici', 'Docteur', -1, 3);

Insert into DOCTEUR
Values (4, 'McGraw', 'Phil', 4, 'NY', 'ici', 'Docteur', 4, -1);

Insert into DOCTEUR
Values (5, 'McGraw', 'Phil', 4, 'NY', 'ici', 'tv', 4, -1);

Insert into DOCTEUR
Values (10, 'Dr', 'House', 10, 'NY', '10 dix', 'Étudiant', default , 10);

Insert into DOCTEUR
Values (11, 'Dr', 'Evil', 11, 'NY', '11 onze', 'Interne', 11 , default);

Insert into DOCTEUR
Values (12, 'Dr', 'Green Thumb', 12, 'NY', '12 douze', 'Docteur', 12, 12);

--INSERT SALLE
Insert into SALLE
Values (1, NULL);

Insert into SALLE
Values (10, 'wilfred');

Insert into SALLE
Values (11, 'calixa');

Insert into SALLE
Values (12, 'abraham');

--INSERT SPECIALISATIONSALLE

Insert into SPECIALISATIONSALLE
Values (10, 10, '2010-10-10');

Insert into SPECIALISATIONSALLE
Values (11, 11, '2011-11-11');

Insert into SPECIALISATIONSALLE
Values (12, 12, '2012-12-12');

--INSERT ORDONNANCEMEDICAMENTS

Insert into ORDONNANCEMEDICAMENTS
Values (1, 1, -1);

Insert into ORDONNANCEMEDICAMENTS
Values (10, 10, 10);

Insert into ORDONNANCEMEDICAMENTS
Values (11, 11, 11);

Insert into ORDONNANCEMEDICAMENTS
Values (12, 12, 12);

--INSERT ORDONNANCE

Insert into ORDONNANCE
Values (1, 'test', 'erreur', 2001-01-01, 1);

Insert into ORDONNANCE
Values (2, 'boire de l eau', 'Chirurgie', 2002-02-02, -1);

Insert into ORDONNANCE
Values (10, 'ne pas manger', 'Médicaments', 2010-10-10, 10);

Insert into ORDONNANCE
Values (11, 'ne pas boire', 'Chirurgie', 2011-11-11, 11);

Insert into ORDONNANCE
Values (10, 'ne rien faire', 'Chirurgie', 2012-12-12, default);


--INSERT MEDICAMENT

Insert into MEDICAMENT
Values (1, NULL, 1.11, 1);

Insert into MEDICAMENT
Values (2, 'vortex', -2.22, 2);

Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);

Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);

Insert into MEDICAMENT
Values (10, 'chilax', 10.10, 10);

Insert into MEDICAMENT
Values (11, 'silex', 11.11, 11);

Insert into MEDICAMENT
Values (12, 'cutex', default, 12);
