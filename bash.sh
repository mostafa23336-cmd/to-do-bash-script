#!/bin/bash
file="code.csv"
if [ ! -f "$file" ]; then
touch "$file"

fi
Add_task(){
    read -p "Enter the title:" title



if [ -z "$title" ]; then
    echo "Task title cannot be empty!"
    return
fi
    while true
    do 
    read -p "Enter the date(yyyy-mm-dd)" date
    if ! date -d "$date" >/dev/null 2>&1; then
    echo "Date is false"
    continue
    fi




    currentdate=$(date +%F)

    max_date=$(date -d "+1 year" +%F)

if [[ "$date" < "$currentdate" ]]; then
    echo "we can't be in the past"

elif [[ "$date" > "$max_date" ]]; then
    echo "we can't be in the future"

else
    break
fi
       done




if grep -q ",$title," "$file"; then
    echo "Task already exists!"
    return
fi

     id=$(wc -l < "$file")
     id=$((id + 1))
status="Pending"
  echo "$id,$title,$status,$date" >> "$file"

    echo "Task added successfully!"
}


View_task() {

    if [ ! -s "$file" ]; then
        echo "No tasks found!"
        return
    fi

    echo "=============================================="
    echo "| ID | TITLE | STATUS | DATE                    |"
    echo "=============================================="


    mapfile -t tasks < "$file"



    for task in "${tasks[@]}"
    do
        IFS=, read -r id title status date <<< "$task"

        echo "$id | $title | $status | $date"
    done
}



Edit_task() {

    read -p "Enter task ID to edit: " task_id


    if ! grep -q "^$task_id," "$file"; then
        echo "Task ID not found!"
        return
    fi

    echo "1. Edit Title"
    echo "2. Edit Date"
    echo "3. Edit Both"

    read -p "Choose an option: " option


    old_title=$(grep "^$task_id," "$file" | cut -d',' -f2)
    old_status=$(grep "^$task_id," "$file" | cut -d',' -f3)
    old_date=$(grep "^$task_id," "$file" | cut -d',' -f4)

    case $option in

        1)
            read -p "Enter new title: " new_title

            sed -i "/^$task_id,/c\\$task_id,$new_title,$old_status,$old_date" "$file"

            echo "Title updated successfully!"
            ;;

        2)
            read -p "Enter new date (YYYY-MM-DD): " new_date


            if ! date -d "$new_date" >/dev/null 2>&1; then
                echo "Invalid date format!"
                return
            fi

            currentdate=$(date +%F)
            max_date=$(date -d "+1 year" +%F)

            if [[ "$new_date" < "$currentdate" ]]; then
                echo "Date cannot be in the past!"
                return

            elif [[ "$new_date" > "$max_date" ]]; then
                echo "Date is too far in the future!"
                return
            fi

            sed -i "/^$task_id,/c\\$task_id,$old_title,$old_status,$new_date" "$file"

            echo "Date updated successfully!"
            ;;

        3)
            read -p "Enter new title: " new_title
            read -p "Enter new date (YYYY-MM-DD): " new_date

    
            if ! date -d "$new_date" >/dev/null 2>&1; then
                echo "Invalid date format!"
                return
            fi

            currentdate=$(date +%F)
            max_date=$(date -d "+1 year" +%F)

            if [[ "$new_date" < "$currentdate" ]]; then
                echo "Date cannot be in the past!"
                return

            elif [[ "$new_date" > "$max_date" ]]; then
                echo "Date is too far in the future!"
                return
            fi

            sed -i "/^$task_id,/c\\$task_id,$new_title,$old_status,$new_date" "$file"

            echo "Task updated successfully!"
            ;;

        *)
            echo "Invalid option!"
            ;;
    esac
}





Delete_task() {

    read -p "Enter task ID to delete: " task_id


    if ! grep -q "^$task_id," "$file"; then
        echo "Task ID not found!"
        return
    fi

  
    sed -i "/^$task_id,/d" "$file"


    temp_file="temp.csv"
    new_id=1

    while IFS=, read -r id title status date
    do
        echo "$new_id,$title,$status,$date" >> "$temp_file"
        new_id=$((new_id + 1))

    done < "$file"


    mv "$temp_file" "$file"

    echo "Task deleted successfully!"
}







Mark_completed() {

    read -p "Enter task ID to mark as completed: " task_id


    if ! grep -q "^$task_id," "$file"; then
        echo "Task ID not found!"
        return
    fi



    sed -i "/^$task_id,/ s/Pending/Completed/" "$file"

    echo "Task marked as completed!"
}


    while true 
    do
    echo "Menu"
    echo "1. Add task"
    echo "2.view task"
    echo "3.Edit task"
    echo "4. delete task"
    echo "5. Mark Task as Completed"
    echo "6. Exit"


     read -p "Enter your choice:" choice



     if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number!"
    continue
fi



     case $choice in
        1)
            Add_task
            ;;
        2)
            View_task
            ;;
        3)
            Edit_task
            ;;
        4)
            Delete_task
            ;;
        5)
            Mark_completed
            ;;
        6)
            echo "Goodbye!"
            exit
            ;;
        *)
            echo "Invalid choice!"
            ;;
    esac

done