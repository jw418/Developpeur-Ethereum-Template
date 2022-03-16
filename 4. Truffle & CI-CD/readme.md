// le SC Voting.sol à été modifiée par rapport à la version rendu projet #1
Rendu projet 2:

Fichier de test Voting.js du smart contract Voting.sol


expect revert pour tester les require
 
	par ex: soit bien le owner ? ne soit pas deja WLed ? est WLed ? le workflow status est le bon? a déja voté? la propostionn exsiste?


expect event pour tester les event:
 	_ event VoterRegistered(address voterAddress); 
	si une addresse est ajouté a la wl un evenemment est-il bien émis ernvoyant l'address qui vient d'etre wled?

  	_ event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
	quand le workstauts change est-il bien émis renvoie du nouveau et du précédent status	

  	_ event ProposalRegistered(uint proposalId);
	avons nous bien un event a chaque fois qu'une propostiosions est déposée?
  	
	_event Voted(address voter, uint proposalId);
	a chaque vote on a bien un event qui renvoi l'adresse du votant et l'uint de l'id proposal pour laqulle il a voté

expect pour tester les variable/struct du smart contract:
	_ est-ce que tout est bien initaialisée ? bool sur false? uint == 0 ? string ==""?
	_ est-ce que le smart contarct modifie bien les variables/struct comme attendu?
		la description de la proposal est bien push dans le array?
		les votant sont correctement ajouté a la whitelist?
		les votes sont bien comptés?
		etc...