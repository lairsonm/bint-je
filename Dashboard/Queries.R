# We work with packages that make the connection with databases easier
library(RPostgreSQL)
library(dplyr)

##
# Connection to postgres
# Edit user and password,
# User: team, password: team
# We created a database called datawarehouse in postgres (with PgAdmin)
##

GetConnection <- function(){
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                        host = "localhost",
                        user="team",
                        port=5433,
                        password="team",
                        dbname = "datawarehouse")
  return(con)
}

DATABASE <- GetConnection()

CloseConnection <- function(con){
  dbDisconnect(conn = con)
}

GetMeanH_IndexPaperForCountries <- function(){
  query = "SELECT AVG(h_index), country_name, country as country_id from papers
	INNER JOIN countries ON papers.country = country_id
  GROUP BY country_name, country;"
  
  return(dbGetQuery(DATABASE, query))
}

GetMaxH_IndexPaperForCountries <- function(){
  query = "SELECT MAX(h_index), country_name, country as country_id from papers
	INNER JOIN countries ON papers.country = country_id
  GROUP BY country_name, country;"
  
  return(dbGetQuery(DATABASE, query))
}


GetSumTotalCites3yrsPaperForCountries <- function(){
  query = "SELECT SUM(total_cites_3yrs) as total_citations, country_name, country as country_id from papers
	INNER JOIN countries ON papers.country = country_id
  GROUP BY country_name, country;"
  return(dbGetQuery(DATABASE, query))
}


GetMaxTotalCites3yrsPaperForCountries <- function(){
  query = "SELECT MAX(total_cites_3yrs) as most_citations, country_name, country as country_id from papers
  INNER JOIN countries ON papers.country = country_id
  GROUP BY country_name, country;"
  return(dbGetQuery(DATABASE, query))
}

GetAmountOfPapersPublishedForCountries <- function(){
  query = "SELECT count(*) as total_papers_published, country as country_id, country_name from papers
  INNER JOIN countries ON papers.country = country_id
  GROUP BY country, country_name;"
  return(dbGetQuery(DATABASE, query))
}


# ##
# # Queries
# # Organize queries by KPI
# ##
 TestFunction <- function(firstName){
   return(paste('Hello ', firstName, ' !'))
 }
 
 TestDatabase <- function(){
   test_tbl <- tbl(DATABASE, "TestTable")
   
   return(test_tbl  %>% distinct(Name, Firstname))
 }
 
 PercentageOfPopulationWorkingInScience <- function(){
   fact_sci_pop <- tbl(DATABASE,"fact_science_hr")
   
   return(fact_sci_pop)
 }
 
 