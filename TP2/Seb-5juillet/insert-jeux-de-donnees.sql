/* INSERT SPECIALITE */
Insert into Specialite
Values (100, 'Esthetique', 'Faciale');

/* INSERT DOCTEUR */
Insert into Docteur 
values (1, 'Jean', 'Robert', 100, 'Montreal', '200 rue Roger', 'Interne', 0, 0);

Insert into Docteur 
values (2, 'Favreau', 'Lyne', 100, 'Montreal', '3800 rue Desrosiers', 'Interne', 0, 0);

/* INSERT PATIENT */
Insert into DossierPatient 
values (1, 'Boivin', 'Albert', 'M', 210300400, '80-01-01', '17-06-01', 1, 0);

Insert into DossierPatient 
values (2, 'Charest', 'Michelle', 'F', 200300400, '88-01-01', '17-07-02', 1, 0);

Insert into DossierPatient 
values (3, 'Rivet', 'Yves', 'M', 300300400, '75-01-01', '17-07-03', 2, 0);

/* INSERT ORDONNANCE */
Insert into Ordonnance 
values (10, 'Boire eau','Chirugie', '17-06-01', 2);

Insert into Ordonnance 
values (20, 'Manger avant','Chirugie', '17-07-05', 3);

/* INSERT CONSULTATION */
Insert into Consultation 
values (1, 1,'17-07-05', 'Appendicite', 20);

Insert into Consultation 
values (1, 2,'17-07-04', 'Infection urinaire', 10);

Insert into Consultation 
values (2, 3,'17-07-06', 'Infection urinaire', 10);