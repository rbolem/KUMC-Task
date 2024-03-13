#Open a Text editor like nano in the terminal  
#nano task2.sh

################################################
# Change directory
cd path

# Count the number of proteins
num_proteins=$(gzcat NC_000913.faa.gz | grep -c '^>')

# Count the total number of amino acids
total_aa=$(gzcat NC_000913.faa.gz | grep -v '^>' | tr -d '\n' | wc -c)

# Calculate the average length
average_length=$(echo "scale=2; $total_aa / $num_proteins" | bc)

# Print the result
echo "Average protein length: $average_length"

#exit the text editor(ctrl+o, Enter, ctrl+x)

#######################################
#Make the script executable
#chmod +x task2.sh

#Run the script
#./task2.sh
