#!/bin/bash

echo "Welcome to my password generator!"

# ask length of pass
echo "Please enter length of password: "

read LENGTH_OF_PASS

# validate input

if ! [[ $LENGTH_OF_PATH =~ ^[0-9]+$ ]]; then
	echo "ERROR: PLEASE ENTER A VALID NUM.."
	exit 1
fi

# create array for passing captured passes
pass = ()

for p in $(seq 1 3);
do 
	pass+=($openssl rand -base64 48 | cut -c1-$LENGTH_OF_PASS )")
done

# display pass

echo "Here are the generated passwords: "
printf "%s\n" "${passwords[@]}"

# ask to save to file
echo "Do you want to save passwords to a file? (Y/n)"
read choice

if [ "$choice" = "Yy"]; then
       for password in "${passwords[@]}"; do
		echo "$password" | ccrypt -e -K "$PASSPHRASE" > "passwords.txt.cpt"
	done

	echo "Password saved securely to passwords.txt.cpt"
elif ["$choice" = "n"]; then 
	echo "ERROR: Password could not be saved, please try again."
fi


