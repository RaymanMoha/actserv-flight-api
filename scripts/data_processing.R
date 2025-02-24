# data_processing.R - Enhanced version
# This script processes the flights dataset and creates an SQLite database

library(data.table)
library(nycflights13)
library(DBI)
library(RSQLite)

#' Process flights data from nycflights13 package
#' 
#' This function loads the flights dataset, performs transformations, 
#' and saves the data to an SQLite database.
#' 
#' @param db_path Path where the SQLite database should be saved
#' @return Invisible TRUE if successful
#' @export
process_flights_data <- function(db_path = "data/flights_db.sqlite") {
  message("Starting flights data processing...")
  
  # Create data directory if it doesn't exist
  data_dir <- dirname(db_path)
  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
    message(sprintf("Created directory: %s", data_dir))
  }
  
  # Load the flights data and convert to data.table
  message("Loading flights data...")
  flights_dt <- as.data.table(nycflights13::flights)
  
  # Generate unique ID for each flight
  flights_dt[, flight_id := .I]
  
  # Add delayed column (TRUE if delay > 15 minutes)
  flights_dt[, delayed := dep_delay > 15]
  
  # Calculate average departure delay by airline
  message("Calculating airline delay statistics...")
  airline_delays <- flights_dt[, .(avg_delay = mean(dep_delay, na.rm = TRUE)), by = carrier]
  
  # Find top destinations by flight count
  message("Identifying top destinations...")
  top_destinations <- flights_dt[, .N, by = dest][order(-N)]
  
  message(sprintf("Creating SQLite database at %s...", db_path))
  
  # Create and populate SQLite database
  tryCatch({
    con <- dbConnect(RSQLite::SQLite(), db_path)
    
    # Create tables
    dbWriteTable(con, "flights", flights_dt, overwrite = TRUE)
    dbWriteTable(con, "airline_delays", airline_delays, overwrite = TRUE)
    dbWriteTable(con, "top_destinations", top_destinations, overwrite = TRUE)
    
    # Create indices for better performance
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_flight_id ON flights(flight_id)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_carrier ON flights(carrier)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_dest ON flights(dest)")
    
    message("Database created successfully.")
  }, error = function(e) {
    stop(sprintf("Error creating database: %s", e$message))
  }, finally = {
    # Close connection
    if (exists("con") && dbIsValid(con)) {
      dbDisconnect(con)
    }
  })
  
  message("Data processing completed successfully.")
  
  return(invisible(TRUE))
}

# If script is run directly, execute the processing function
if (!interactive() || getOption("run_data_processing", FALSE)) {
  process_flights_data()
}