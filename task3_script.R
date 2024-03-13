#install the packages needed
#Load the packages
library(ggplot2)
library(dplyr)
library(stringr) 

# Path to the gzipped gene info file
gz_file_path <- "Homo_sapiens.gene_info.gz"

# Read the data directly from the gzipped file without unziping.
gene_info <- read.delim(gzfile(gz_file_path), stringsAsFactors = FALSE)

# Clean the data to remove ambiguous chromosome values, "??", or any chromosome with non-alphanumeric characters or a hyphen "-"
gene_info_clean <- gene_info %>% 
  filter(!str_detect(chromosome, "[^[:alnum:]]"), 
         chromosome != "??")

# Count the number of genes per chromosome
gene_count <- gene_info_clean %>%
  count(chromosome) %>%
  rename(Chromosome = chromosome, GeneCount = n)

# Sort chromosomes by numeric value first and then alphabetically
gene_count <- gene_count %>%
  mutate(
    Chromosome = as.character(Chromosome),
    NumericChromosome = as.numeric(Chromosome),  # Will be NA for non-numeric values
    ChromosomeLength = nchar(Chromosome)
  ) %>%
  arrange(is.na(NumericChromosome), ChromosomeLength, Chromosome) %>%
  select(-NumericChromosome, -ChromosomeLength)

# Convert Chromosome back to a factor for plotting
gene_count$Chromosome <- factor(gene_count$Chromosome, levels = gene_count$Chromosome)

# Creating the bar plot using ggplot2
p <- ggplot(gene_count, aes(x = Chromosome, y = GeneCount)) +
  geom_bar(stat = "identity", fill = "black") +
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5),  
    axis.line = element_line(color = "black"),  
    axis.text.x = element_text(angle = 0, hjust = 0.5)  
  ) +
  labs(title = "Number of genes in each chromosome",
       x = "Chromosomes",
       y = "Gene count")

# View the plot
print(p)

# Define the size of the plot to save - width, height in inches
plot_width <- 9
plot_height <- 5.5

# Saving the plot to a PDF file with specified dimensions
ggsave("gene_chromosome_plot.pdf", plot = p, width = plot_width, height = plot_height, path = "output pdf path")

# Print the path to the PDF
cat("The plot has been saved to: output pdf path\\gene_chromosome_plot.pdf", "\n")
