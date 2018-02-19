/* --- SEB TRIGGERS ---  =) */

/* TRIGGER DELETE PATIENT */
Create or Replace Trigger Delete_nbrPatient
After Delete on DossierPatient
For Each Row
Begin
	Update Docteur
	Set nbrPatients = nbrPatients - 1
	Where :old.matricule = docteur.matricule;
End;
/

/* TRIGGER INSERT PATIENT */
Create or Replace Trigger Update_nbrPatient
After Insert on DossierPatient
For Each Row
Begin
	Update Docteur
	Set nbrPatients = nbrPatients + 1
	Where :new.matricule = docteur.matricule;
End;
/

/* TRIGGER UPDATE NBR CONSULTATION PATIENT */
Create or Replace Trigger Update_nbrConsultation
After Insert on Consultation
For Each Row

Begin
	Update DossierPatient
	Set nbrConsultation = nbrConsultation + 1
	Where :new.numDos = DossierPatient.numDos;
End;
/

