# Set working directory for local system, uncomment and edit if necessary
setwd("~/quiztest")

# Libraries to load
library("sqldf")

download.file(
  "ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/gene_condition_source_id",
  "gene_condition_source_id.csv"
)

genedf <-
  read.csv("gene_condition_source_id.csv",
           sep = "\t",
           header = TRUE)

# Create a unique id (Primary Key) for each row
genedf$PrimaryKey <- seq.int(nrow(genedf))

# Convert 'LastUpdated' to date type
genedf$LastUpdated <- as.Date(genedf$LastUpdated, "%d %b %Y")

# Connect to SQLite
db.genedf <-
  dbConnect(SQLite(), dbname = "genedf.sqlite")

# Table to db
dbWriteTable(
  conn = db.genedf,
  name = "GENE_CONDITION_SOURCE_ID",
  genedf,
  overwrite = T,
  row.names = FALSE
)

# Test alzheimer query
alzheimer_query <- function() {
  df <- dbGetQuery(
    db.genedf,
    "SELECT * FROM GENE_CONDITION_SOURCE_ID WHERE [DiseaseName] LIKE '%Alzheimer%' OR '%alzheimer%'"
  )
  write.csv(df, file = "alz_ClinVar.csv")
  print(df)
}
print("Printing entries where 'DiseaseName' pertains to Alzheimer's Disease..")
alzheimer_query()