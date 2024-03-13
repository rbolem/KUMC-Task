#Open a Text editor like nano in the terminal and write the below commands 
#nano task1_script.R

#########################################################
#install the packages needed
# Load libraries
library(data.table)

# File paths
gene_info_path <- "Homo_sapiens.gene_info.gz"
gmt_file_path <- "h.all.v2023.1.Hs.symbols.gmt"
output_file_path <- "task-1_entrez_ids.gmt"


# create a function to map gene symbols and synonyms to Entrez IDs
create_gene_mapping <- function(file_path) {
  gene_info <- read.table(gzfile(file_path), sep="\t", header=TRUE, quote="", comment.char="", colClasses = "character")
  
  # Select only GeneID, Symbol, and Synonyms columns
  gene_info <- gene_info[, c("GeneID", "Symbol", "Synonyms")]
  
  # Create a mapping of Symbol to GeneID
  mapping <- setNames(as.character(gene_info$GeneID), as.character(gene_info$Symbol))
  
  # Include synonyms
  synonyms <- strsplit(gene_info$Synonyms, "[|]")
  for (i in seq_along(synonyms)) {
    valid_synonyms <- synonyms[[i]][synonyms[[i]] != "-"]
    mapping[valid_synonyms] <- gene_info$GeneID[i]
  }
  
  return(mapping)
}

# Replace gene symbols with Entrez IDs in GMT file
replace_symbols_with_entrez_ids <- function(gmt_path, mapping) {
  # Open connection to input GMT file in read mode
  con <- file(gmt_path, "r")
  
  # Open connection to output file in write mode
  output <- file(output_file_path, "w")
  
  # Iterate over each line in the input GMT file
  while (TRUE) {
    # Read one line from the input GMT file
    line <- readLines(con, n = 1)
    
    # If the length of the line is 0, it means end of file, so break out of the loop
    if (length(line) == 0) {
      break
    }
    
    # Split the line into elements using tab as delimiter
    elements <- strsplit(line, "\t")[[1]]
    
    # Extract pathway information (first two elements of the line)
    pathway_info <- elements[1:2]
    
    # Extract gene symbols (remaining elements after first two)
    gene_symbols <- elements[-(1:2)]
    
    # Replace each gene symbol with its corresponding Entrez ID using the mapping
    entrez_ids <- sapply(gene_symbols, function(x) ifelse(x %in% names(mapping), mapping[x], x))
    
    # Concatenate pathway information and updated gene IDs to form the new line
    new_line <- c(pathway_info, entrez_ids)
    
    # Write the new line to the output file
    writeLines(paste(new_line, collapse = "\t"), output)
  }
  
  # Close the input and output file connections
  close(con)
  close(output)
}

# Main script execution
gene_mapping <- create_gene_mapping(gene_info_path)
replace_symbols_with_entrez_ids(gmt_file_path, gene_mapping)

#Printing a message indicating the completion of the process
cat("Completed. Output written to:", output_file_path, "\n")

#Exit the text editor(ctrl+o, Enter, ctrl+x)

#############################

#Run the script using the below command 
#Rscript task1_script.R
