# Flights Data API

This project implements a JSON API for accessing and manipulating flight data from the `nycflights13` package using R, Ambiorix, data.table, and SQLite.

## Features

- Data processing with data.table
- RESTful API endpoints for CRUD operations
- SQLite database for data storage
- Error handling and input validation
- Logging system

## Project Structure

```
Copy
.
├── app.R              # API implementation
├── data_processing.R  # Data preparation script
├── data/              # Directory for database files
│   └── flights_db.sqlite
├── logs/              # Directory for log files
│   └── api.log
└── README.md          # Project documentation

```

## Requirements

- R (>=4.0.0)
- The following R packages:
    - ambiorix
    - data.table
    - nycflights13
    - DBI
    - RSQLite
    - jsonlite
    - logger

## Installation

1. Clone the repository:
    
    ```
    Copy
    git clone https://github.com/yourusername/flights-data-api.git
    cd flights-data-api
    
    ```
    
2. Install required packages:
    
    ```
    R
    Copy
    install.packages(c("ambiorix", "data.table", "nycflights13", "DBI", "RSQLite", "jsonlite", "logger"))
    
    ```
    
3. Process the flight data:
    
    ```
    R
    Copy
    source("data_processing.R")
    process_flights_data()
    
    ```
    
4. Run the API server:
    
    ```
    R
    Copy
    source("app.R")
    start_server()
    
    ```
    

## API Endpoints

### Create a new flight

```
Copy
POST /flight

```

Accept a JSON payload with flight details

### Get flight details

```
Copy
GET /flight/:id

```

Return details of the flight specified by ID

### Check if a flight was delayed

```
Copy
GET /check-delay/:id

```

Return whether the flight is classified as "delayed"

### Get average departure delay

```
Copy
GET /avg-dep-delay?id=<airline-code>

```

Return the average departure delay of an airline. If no airline is provided, return all airlines.

### Get top destinations

```
Copy
GET /top-destinations/:n

```

Return the top n destinations with the most flights

### Update a flight

```
Copy
PUT /flight/:id

```

Update details of the flight specified by ID. Accept a JSON payload with the new details.

### Delete a flight

```
Copy
DELETE /flight/:id

```

Delete the flight with the specified ID

### Health check

```
Copy
GET /health

```

Get the health status of the API and database connection

## Testing the API

You can test the API using curl, Postman, or any HTTP client:

```bash
bash
Copy
# Get flight with ID 1
curl http://localhost:8080/flight/1

# Check if flight was delayed
curl http://localhost:8080/check-delay/1

# Get average delay for American Airlines (AA)
curl http://localhost:8080/avg-dep-delay?id=AA

# Get top 5 destinations
curl http://localhost:8080/top-destinations/5

# Add a new flight
curl -X POST http://localhost:8080/flight \
  -H "Content-Type: application/json" \
  -d '{"year":2013,"month":1,"day":1,"carrier":"AA","flight":1,"origin":"JFK","dest":"LAX","air_time":320,"distance":2475}'

# Update flight details
curl -X PUT http://localhost:8080/flight/1 \
  -H "Content-Type: application/json" \
  -d '{"dep_delay":10}'

# Delete a flight
curl -X DELETE http://localhost:8080/flight/1

```

## Implementation Notes

1. The data processing script:
    - Loads the flights data from nycflights13
    - Adds a unique ID and delayed status for each flight
    - Computes average delays by airline
    - Identifies top destinations
    - Saves everything to an SQLite database
2. The API features:
    - Consistent error handling
    - Input validation
    - RESTful endpoints
    - JSON response format
    - Database connection management
    - Logging of requests and errors

## Performance Considerations

- SQLite indices are created on frequently queried columns
- Database connections are opened only when needed and closed after use
- Error handling is done systematically to prevent application crashes
