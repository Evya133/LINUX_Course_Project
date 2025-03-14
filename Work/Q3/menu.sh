#!/bin/bash

# Variable to hold the current CSV file
CURRENT_CSV=""

# Function to create a new CSV file and set it as current
create_csv() {
    read -p "Enter new CSV file name (e.g., plants1.csv): " filename
    echo "Plant,Height,Leaf Count,Dry Weight" > "$filename"
    echo "CSV file '$filename' created and set as current."
    CURRENT_CSV="$filename"
}

# Function to select an existing CSV file as current
select_csv() {
    read -p "Enter the CSV file name to set as current: " filename
    if [[ -f "$filename" ]]; then
        CURRENT_CSV="$filename"
        echo "CSV file '$filename' is now current."
    else
        echo "File '$filename' not found."
    fi
}

# Function to view the current CSV file
view_csv() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set as current."
    else
        echo "Current CSV file ($CURRENT_CSV) contents:"
        cat "$CURRENT_CSV"
    fi
}

# Function to add a new row for a particular plant
add_row() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set. Please create or select one first."
        return
    fi
    read -p "Enter plant name: " plant
    echo "Enter heights (each on a new line, finish with an empty line):"
    heights=""
    while read line && [[ -n "$line" ]]; do
        heights+="$line "
    done
    echo "Enter leaf counts (each on a new line, finish with an empty line):"
    leaf_counts=""
    while read line && [[ -n "$line" ]]; do
        leaf_counts+="$line "
    done
    echo "Enter dry weights (each on a new line, finish with an empty line):"
    dry_weights=""
    while read line && [[ -n "$line" ]]; do
        dry_weights+="$line "
    done
    # Append new row; wrap multi-value fields in quotes
    echo "$plant,\"$heights\",\"$leaf_counts\",\"$dry_weights\"" >> "$CURRENT_CSV"
    echo "New row added for plant $plant."
}

# Function to run the enhanced Python code to generate diagrams
run_python() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set. Please create or select one first."
        return
    fi
    read -p "Enter plant name for generating diagrams: " plant
    # Adjust the path to plant_plots.py if needed.
    python3 ../Q2/plant_plots.py --plant "$plant" --height 50 55 60 65 70 --leaf_count 35 40 45 50 55 --dry_weight 2.0 2.2 2.5 2.7 3.0
}

# Function to update a row in the CSV file by plant name
update_row() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set. Please create or select one first."
        return
    fi
    read -p "Enter plant name to update: " plant
    echo "Enter new heights (finish with an empty line):"
    new_heights=""
    while read line && [[ -n "$line" ]]; do
        new_heights+="$line "
    done
    echo "Enter new leaf counts (finish with an empty line):"
    new_leaf_counts=""
    while read line && [[ -n "$line" ]]; do
        new_leaf_counts+="$line "
    done
    echo "Enter new dry weights (finish with an empty line):"
    new_dry_weights=""
    while read line && [[ -n "$line" ]]; do
        new_dry_weights+="$line "
    done
    # Replace the line starting with the plant name with the new values.
    sed -i "/^${plant},/c\\${plant},\\\"${new_heights}\\\",\\\"${new_leaf_counts}\\\",\\\"${new_dry_weights}\\\"" "$CURRENT_CSV"
    echo "Row updated for plant ${plant}."
}

# Function to delete a row by index or plant name
delete_row() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set. Please create or select one first."
        return
    fi
    read -p "Delete by (1) row index or (2) plant name? " option
    if [ "$option" == "1" ]; then
        read -p "Enter row index (excluding header, starting at 1): " index
        # Adjust for header (delete line index+1)
        sed -i "$((index+1))d" "$CURRENT_CSV"
        echo "Row $index deleted."
    elif [ "$option" == "2" ]; then
        read -p "Enter plant name to delete: " plant
        sed -i "/^${plant},/d" "$CURRENT_CSV"
        echo "Row for plant ${plant} deleted."
    else
        echo "Invalid option."
    fi
}

# Function to print the plant with the highest average leaf count
highest_leaf() {
    if [[ -z "$CURRENT_CSV" ]]; then
        echo "No CSV file is set. Please create or select one first."
        return
    fi
    echo "Plant with the highest average leaf count:"
    awk -F',' 'NR>1 {
        gsub(/"/, "", $3);
        split($3, a, " ");
        sum=0; count=0;
        for(i in a) { if(a[i] != "") { sum += a[i]; count++ } }
        avg = (count > 0 ? sum/count : 0);
        print $1, avg;
    }' "$CURRENT_CSV" | sort -k2 -nr | head -1
}

# Main menu loop
while true; do
    echo "--------------------------------------"
    echo "Plant CSV Menu Options:"
    echo "1) Create a CSV file and set it as current"
    echo "2) Select a CSV file as current"
    echo "3) View the current CSV file"
    echo "4) Add a new row to a particular plant"
    echo "5) Run enhanced Python code to generate diagrams"
    echo "6) Update a row by plant name"
    echo "7) Delete a row (by index or plant)"
    echo "8) Print the plant with the highest average leaf count"
    echo "9) Exit"
    echo "--------------------------------------"
    read -p "Select an option: " choice
    case $choice in
        1) create_csv ;;
        2) select_csv ;;
        3) view_csv ;;
        4) add_row ;;
        5) run_python ;;
        6) update_row ;;
        7) delete_row ;;
        8) highest_leaf ;;
        9) echo "Exiting menu."; break ;;
        *) echo "Invalid option. Try again." ;;
    esac
done

