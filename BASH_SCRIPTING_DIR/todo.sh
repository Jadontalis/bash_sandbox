#!/bin/bash

shopt -s nocasematch

TODO_FILE="my_todos.txt"
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
	for c in '█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████████▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████████▒▒▒▒▒▒▒▒▒▒▒' '██████████████████████▒▒▒▒▒▒▒▒▒▒' '███████████████████████▒▒▒▒▒▒▒▒▒' '████████████████████████▒▒▒▒▒▒▒▒' '█████████████████████████▒▒▒▒▒▒▒' '██████████████████████████▒▒▒▒▒▒' '███████████████████████████▒▒▒▒▒' '████████████████████████████▒▒▒▒' '█████████████████████████████▒▒▒' '██████████████████████████████▒▒' '███████████████████████████████▒' '████████████████████████████████'; do
		printf '\r%s' "$c"
			sleep .01
		done
	echo ""
}

display_todos() {
	if (( ${#todos[@]} == 0 )); then
        	echo "Looks like your todo list is empty..."
    	else
		load_animation

		echo ""
        	echo "---------- YOUR CURRENT TODOS -----------"
        	for i in "${!todos[@]}"; do
            		echo " $((i + 1)). ${todos[$i]}"
        	done
	fi
}

load_todos

echo " Please enter your name to get started: "
read -r name

echo "Hey $name! Loading your todos for you now.."

while true; do
    	echo ""
    	display_todos
    
	echo ""
    	echo "What would you like to do? "
    	echo " 1) Add task(s) "
    	echo " 2) Complete/Remove a task "
    	echo " 3) Exit "
    
	read -r -p "> " choice

    	case "$choice" in
        	1|add)
		echo " Please enter what you have to do, separated by commas: "
            	read -r raw_inp
           	IFS=',' read -ra inp_items <<< "$raw_inp"

            	for task in "${inp_items[@]}"; do
                	task=$(echo "$task" | xargs)
                
			if [[ -n "$task" ]]; then
                    		todos+=("$task")
                	fi
            	done
            	
		load_animation
            	save_todos
		echo ""
            	echo " Tasks updated! "
		echo "----------------------"
            	;;
            
        	2|remove|complete)
            	if (( ${#todos[@]} == 0 )); then
                	echo "Nothing to remove! Add some tasks first."
			echo "----------------------"
			echo ""
                	continue
            	fi
            
            	echo " Enter the number of the task you finished: "
            	read -r task_num
            
            	if [[ "$task_num" =~ ^[0-9]+$ ]] && (( task_num > 0 && task_num <= ${#todos[@]} )); then
			index=$((task_num - 1))
                	removed_task="${todos[$index]}"
                
        
                	unset 'todos[index]'
                
                	todos=("${todos[@]}")
                
                	save_todos
                	echo "Great job! Checked off: '$removed_task'"
            	else
                	echo "Invalid task number. Please try again."
            	fi
            	;;
            
        	3|exit|quit)
            		echo "Leaving TODO app..."
            		exit 0
            	;;
            
        	*)
            		echo "Invalid input, please enter 1, 2, or 3."
            	;;
    	esac
done
