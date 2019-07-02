# Hop Centricity API

This program serves as an API to the Hop Centricity front end. 

## Tech Used

### Built With

- Ruby on Rails
- Nokogiri
- HTTParty
- Mechanize
- Google OAuth

## Features & Usage

For the most part, this rails backend is serving as a vanilla API, serving fetch requests from Hop Centricity clients. In order to seed the database, web scraping was used. After seeding, the database contains ~5000 IPAs. This only needs to be done on database initialization as the scraped files are local to the program (Authed1, 2 and 3). When a user searches for a beer name, rails checks for a match in the database. If there is no match, the scraper is utilized and visits Untappd as a guest user. As a result, Untappd only returns 5 beers matching the query, however most of the time the exact match is returned in those 5 beers. These results are scraped through and returned to the client as prospective beers. If the user decides to review one of these prospective beers, the beer information and the review are persisted to the database. Thus, the database is continuously growing as new beers are reviewed. Currently, beer type and brewery searches only search the database and do not live scrape. 

## Installation

- Fork and Clone this Repo
- If you don't have Postgres, install it!
- Run "bundle install", "rails db:setup" and "rails db:migrate" in the terminal from the project root
- Run "rails db:seed" to seed that database with the contents of Authed1, 2 and 3
- Run "rails s" in your terminal to start the server

## Credits

This App was inspired by the wonderful work that Untappd has done with their beer app. All of the beers in the database originated from them. 


