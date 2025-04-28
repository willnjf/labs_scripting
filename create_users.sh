#!/bin/bash

# Fichier de sauvegarde
BACKUP_FILE="backup_users.txt"

# Liste des utilisateurs
USERS=("willy")

# Groupe pour les utilisateurs
GROUPE="HR"

# Date 
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Vérifier si le groupe éxiste

if ! getent group "$GROUPE" &>/dev/null;
then
	echo " Groupe $GROUPE non trouvé. Création du groupe....."
	sudo groupadd "$GROUPE"
	echo " Groupe $GROUPE crée avec succès le $DATE"
else
	echo " Groupe $GROUPE existe déjà."
fi

# Vider le fichier de sauvegarde s'il existe
> "$BACKUP_FILE"

# Création des utilisateurs en bouclant sur la liste

for user in "${USERS[@]}"
do
	# Vérifier si l'utilisateur existe
	if id "$user" &>/dev/null;
	then
		echo " Utilisateur $user exite déjà"
	else
		# Créer l'utilisateur
		sudo useradd "$user"

		# Ajouter l'utilisateur  au groupe
		sudo usermod -aG "$GROUPE" "$user"

		# Génération de mot de passe aléatoire
		MOT_DE_PASSE=$(openssl rand -base64 8)
		
		# Appliquer le mot de passe aux utilisateurs
		echo "$user:$MOT_DE_PASSE" | sudo chpasswd
		
		# Forcer le mot de passe à la prémière connection
		sudo chage -d 0 "$user"

		# Sauvegarder tout dans le fichier  BACKUP_FILE
		echo "$user : $MOT_DE_PASSE" >> "BACKUP_FILE"

		echo " Uitlisateur $user créé avec mot de passe temporaire à la date du $DATE"
	fi
done
