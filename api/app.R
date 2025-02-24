# test_api.R - Script to test the Flights Data API

library(httr)
library(jsonlite)
library(testthat)

# Configuration
base_url <- "http://localhost:8080"

# Helper function to make API requests
make_request <- function(method, endpoint, body = NULL) {
  url <- paste0(base_url, endpoint)
  
  if (method == "GET") {
    response <- GET(url)
  } else if (method == "POST") {
    response <- POST(url, body = body, encode = "json")
  } else if (method == "PUT") {
    response <- PUT(url, body = body, encode = "json")
  } else if (method == "DELETE") {
    response <- DELETE(url)
  } else {
    stop("Unsupported method")
  }
  
  list(
    status = status_code(response),
    content = if (status_code(response) < 300) fromJSON(content(response, "text", encoding = "UTF-8")) else NULL
  )
}

# Run tests
test_that("API health check works", {
  result <- make_request("GET", "/health")
  expect_equal(result$status, 200)
  expect_equal(result$content$status, "OK")
})

test_that("Can retrieve top destinations", {
  result <- make_request("GET", "/top-destinations/5")
  expect_equal(result$status, 200)
  expect_true(length(result$content$dest) == 5)
})

test_that("Can retrieve airline delay information", {
  # Get all airlines
  result <- make_request("GET", "/avg-dep-delay")
  expect_equal(result$status, 200)
  expect_true(length(result$content$carrier) > 0)
  
  # Get specific airline (using the first one from the previous request)
  airline <- result$content$carrier[1]
  result <- make_request("GET", paste0("/avg-dep-delay?id=", airline))
  expect_equal(result$status, 200)
  expect_equal(result$content$carrier, airline)
})

test_that("CRUD operations work for flights", {
  # 1. Create a new flight
  new_flight <- list(
    year = 2013,
    month = 1,
    day = 1,
    carrier = "AA",
    flight = 999,
    origin = "JFK",
    dest = "LAX",
    air_time = 320,
    distance = 2475,
    dep_delay = 10
  )
  
  result <- make_request("POST", "/flight", new_flight)
  expect_equal(result$status, 201)
  expect_true(!is.null(result$content$flight_id))
  
  flight_id <- result$content$flight_id
  
  # 2. Retrieve the created flight
  result <- make_request("GET", paste0("/flight/", flight_id))
  expect_equal(result$status, 200)
  expect_equal(result$content$carrier, "AA")
  expect_equal(result$content$flight, 999)
  
  # 3. Check if flight was delayed
  result <- make_request("GET", paste0("/check-delay/", flight_id))
  expect_equal(result$status, 200)
  expect_false(result$content$delayed)
  
  # 4. Update the flight
  update_data <- list(dep_delay = 20)
  result <- make_request("PUT", paste0("/flight/", flight_id), update_data)
  expect_equal(result$status, 200)
  
  # 5. Verify the update
  result <- make_request("GET", paste0("/check-delay/", flight_id))
  expect_equal(result$status, 200)
  expect_true(result$content$delayed)
  
  # 6. Delete the flight
  result <- make_request("DELETE", paste0("/flight/", flight_id))
  expect_equal(result$status, 200)
  
  # 7. Verify deletion
  result <- make_request("GET", paste0("/flight/", flight_id))
  expect_equal(result$status, 404)
})

test_that("API handles invalid requests properly", {
  # Invalid flight ID
  result <- make_request("GET", "/flight/9999999")
  expect_equal(result$status, 404)
  
  # Invalid JSON payload
  result <- make_request("POST", "/flight", list())
  expect_equal(result$status, 400)
  
  # Invalid route
  result <- make_request("GET", "/non-existent-route")
  expect_equal(result$status, 404)
})

# Print summary
cat("\nAPI Testing Complete\n")