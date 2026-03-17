#!/bin/bash

shopt -s nocasematch

TODO_FILE="my_todos.txt"

todos=()

if [ -f "$TODO_FILE" ]; then
	mapfile -t todos < "$TODO_FILE"
fi

echo "Please enter your name to get started."
read -r name

echo "Hey $name! Would you like me to see what you have to do today? (Y/n)"
read -r choice

if [ "$choice" = "Y" ]; then

    while true; do
        if (( ${#todos[@]} == 0 )); then
		echo "Looks like your todo list is empty..."
        else
		echo "--- YOUR CURRENT TODOS ---"
		for item in "${todos[@]}"; do
			echo " - $item"
            	done
        fi

        echo "Would you like to add to your todo list? (Y/n) or type 'exit' to quit"
        read c

        if [ "$c" = "Y" ]; then
		echo "Please enter what you have to do, separated by commas"
		read -r raw_inp

            	IFS=',' read -ra inp_items <<< "$raw_inp"

		for task in "${inp_items[@]}"; do
			task=$(echo "$task" | xargs)
			if [[ -n "$task" ]]; then
				todos+=("$task")
				echo " - $task" >> "$TODO_FILE"
			fi
		done
		
		echo "Tasks updated!"

        elif [ "$c" = "n" ] || [ "$c" = "exit" ]; then
            	echo " Leaving TODO app .... "
            	sleep 2
            	exit 1
        else
		echo "Invalid input, please try again."
        fi
    done

elif [ "$choice" = "n" ]; then
    	echo " Leaving TODO app .... "
    	sleep 1
    	exit 1
fi

echo " Here are the TODOS you need to accomplish: "
echo "${todos[@]}"
