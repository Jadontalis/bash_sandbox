#!/bin/bash

shopt -s nocasematch

TODO_FILE="my_todos.txt"
NAME="my_todo_name.txt"
user_name=""
todos=()

load_todos() {
	if [ -f "$TODO_FILE" ]; then
        	mapfile -t todos < "$TODO_FILE"
    	fi
}

save_todos() {
	printf "%s\n" "${todos[@]}" > "$TODO_FILE"
}

load_animation() {
	echo ""
	for c in '█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████████▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████████▒▒▒▒▒▒▒▒▒▒▒' '██████████████████████▒▒▒▒▒▒▒▒▒▒' '███████████████████████▒▒▒▒▒▒▒▒▒' '████████████████████████▒▒▒▒▒▒▒▒' '█████████████████████████▒▒▒▒▒▒▒' '██████████████████████████▒▒▒▒▒▒' '███████████████████████████▒▒▒▒▒' '████████████████████████████▒▒▒▒' '█████████████████████████████▒▒▒' '██████████████████████████████▒▒' '███████████████████████████████▒' '████████████████████████████████' '  '; do
		printf '\r%s' "$c"
			sleep .01
		done
	echo ""
}

load_save_animation() {
	for c in '/' '|' '\' '-' '/' '|' '\' '-' ' '; do
		printf '\r%s' "$c"
		sleep .025
		done
	echo ""
}

load_name() {
	if [ -f "$NAME" ]; then
		user_name=$(cat "$NAME")
	fi

	if [ -f "$user_name" ]; then
		echo "Please enter your name to get started: "
		read -r user_name
		echo "$user_name" > "$NAME"
	fi
}

display_todos() {
	if (( ${#todos[@]} == 0 )); then
        	echo "   Looks like your todo list is empty..."
    	else
		echo "----------------------- YOUR CURRENT TODOS -----------------------"
		echo ""
        	for i in "${!todos[@]}"; do
            		echo "     $((i + 1)). ${todos[$i]}"
        	done
	fi
}

load_todos
load_name

echo ""
echo "========================================================================"
echo ""
echo "  Hey $user_name! Loading your todos now ...."
load_animation
echo ""
echo "========================================================================"

while true; do
    	echo ""
    	display_todos
   	echo "" 
	echo "     +-----------------------------+"
    	echo "     | What would you like to do?  |"
    	echo "     | 1) Add task(s)              |"
    	echo "     | 2) Complete/Remove a task   |"
    	echo "     | 3) Exit                     |"
	echo "     | 4) Change name              |"
	echo "     +-----------------------------+"
	echo ""
	read -r -p "> " choice

    	case "$choice" in
        	1|add)
			echo ""
			echo "    Please enter what you have to do, separated by commas: "
			echo ""
            		read -r raw_inp
           		IFS=',' read -ra inp_items <<< "$raw_inp"

            		for task in "${inp_items[@]}"; do
                		task=$(echo "$task" | xargs)
                
				if [[ -n "$task" ]]; then
                    		todos+=("$task")
                		fi
            		done
            		save_todos
			echo ""
            		echo "    Tasks updated! Saving "$task" now ...."
			echo ""
			load_save_animation
		;;
            
        	2|remove|complete)
            		if (( ${#todos[@]} == 0 )); then
				echo ""
                		echo "     Nothing to remove! Add some tasks first."
				echo "------------------------------------------------------"
				echo ""
                		continue
            		fi
            
            		echo "     Enter the number of the task you finished: "
            		read -r task_num
            
            		if [[ "$task_num" =~ ^[0-9]+$ ]] && (( task_num > 0 && task_num <= ${#todos[@]} )); then
				index=$((task_num - 1))
                		removed_task="${todos[$index]}"
                
        
                		unset 'todos[index]'
                
                		todos=("${todos[@]}")
               		
                		save_todos
				echo ""
                		echo "     Great job! Checking off "$removed_task" ...."
				echo ""
				load_save_animation
            		else
				echo ""
                		echo "Invalid task number. Please try again."
				echo""
            		fi
            	;;
            
        	3|exit|quit)
            		echo "   Exiting program ...."
			load_save_animation
            		exit 0
            	;;

		4|name|change)
			echo "   What would you like me to call you instead?"
            		read -r new_name
            
            		if [[ -n "$new_name" ]]; then
                		user_name=$(echo "$new_name" | xargs)
                		echo "$user_name" > "$NAME"
				echo ""
                		echo "   Got it! I'll call you $user_name from now on."
				echo ""
            		else
				echo""
                		echo "   Name cannot be blank. Keeping it as $user_name."
            		fi
            	;;
            
        	*)
            		echo "   Invalid input, please enter 1, 2, or 3."
            	;;
    	esac
done
