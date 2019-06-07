class Scraper < ApplicationRecord

    def loadRelativePage
        # Here we are scraping a local page saved on this computer
        @page = Nokogiri::HTML(File.open(self.relative_path))
        self.iterateOverPage
    end 

    def iterateOverPage
        # Iterate over each 'results container' div and parse info for each
        @page.css('div.results-container').each do |container|
            container.children.each do |beer|
                if !beer.css('p.name').empty?     
                    @beer = beer
                    self.parseBeerInformation
                end 
            end 
        end 
    end

    def parseBeerInformation        
        # parse the scraped data, make sure there are no beer name or 
        # brewery name duplicates, save data in instance variables
        @name = @beer.css('p.name').children.text.downcase
        if !Beer.find_by(name: @name)   
            if @beer.css('p.brewery').children.text.empty?             
                @brewery = @beer.css('p.style')[0].text
                @style = @beer.css('p.style')[1].text
            else
                @brewery = @beer.css('p.brewery').children.text.downcase
                @style = @beer.css('p.style').text
            end
            @abv = @beer.css('p.abv').text.to_f
            @ibu = @beer.css('p.ibu').text.to_f
            @rating = @beer.css('span.num').text.gsub(/[()]/,"").to_f
            @img_url = @beer.css('img')[0].attributes['src'].value
            @brewery_id = Brewery.find_or_create_by(name: @brewery).id
            self.storeBeerToDB
        end
    end 

    def storeBeerToDB
        # save new beer to the DB
        newBeer = Beer.new(
            name: @name,
            style: @style,
            abv: @abv,
            ibu: @ibu,
            rating: @rating,
            img_url: @img_url,
            brewery_id: @brewery_id
        )             
        newBeer.save
    end 

    def scrapeToHTMLFile
        # curl method returns 25 new results at a time, so iterate 
        # until the page maxes out at 1000 brews
        loopControl = 1
        while loopControl < 40 do 
            multiplier = Counter.last.index 
            offset = multiplier*25
            #insert curl query
            sleep 6
            nextSearch = multiplier + 1
            Counter.create(index: nextSearch)
            loopControl += 1
        end 
    end

    def scrapeForNewBeer
       page = HTTParty.get("https://untappd.com/search?q=#{self.search_params}")
       @page = Nokogiri::HTML(page)
       @prospective_beer_list = []
       self.iterateOverProspectiveBeers
    end 

    def iterateOverProspectiveBeers
        @page.css('div.results-container').children.each do |beer|
            if !beer.css('p.name').empty?     
                @beer = beer
                self.parseProspectiveBeer
            end 
        end
        self.returnProspectiveBeers
    end 

    def parseProspectiveBeer
        @name = @beer.css('p.name').children.text.downcase
        if @beer.css('p.brewery').children.text.empty?             
            @brewery = @beer.css('p.style')[0].text
            @style = @beer.css('p.style')[1].text
        else
            @brewery = @beer.css('p.brewery').children.text.downcase
            @style = @beer.css('p.style').text
        end
        @abv = @beer.css('p.abv').text.to_f
        @ibu = @beer.css('p.ibu').text.to_f
        @rating = @beer.css('span.num').text.gsub(/[()]/,"").to_f
        @img_url = @beer.css('img')[0].attributes['src'].value
        # @brewery_id = Brewery.find_or_create_by(name: @brewery).id
        self.createBeerInstance
    end

    def createBeerInstance
        @prospective_beer = ProscpectiveBeer.new(
            name: @name,
            style: @style,
            abv: @abv,
            ibu: @ibu,
            rating: @rating,
            img_url: @img_url,
            brewery: @brewery
        ) 
        self.pushBeerToProspectiveBeerList
    end

    def pushBeerToProspectiveBeerList
        @prospective_beer_list << @prospective_beer
    end 

    def returnProspectiveBeers
        byebug
        @prospective_beer_list
    end

end



# !!!!!!!!!!!!!!!!!
# search for substring: Beer.where("name like ?", "%#{'Sister'}%") 


# curl 'https://untappd.com/search/more_search/beer?offset=25&q=ipa&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559698579.1559767339.12; __utmt=1; __utmb=13579763.5.10.1559767339' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' > authed.html

# curl 'https://untappd.com/search/more_search/beer?offset=50&q=ipa&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559767339.1559772492.13; __utmt=1; __utmb=13579763.1.10.1559772492' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' > next.html

# `curl 'https://untappd.com/search/more_search/beer?offset=75&q=ipa&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559767339.1559772492.13; __utmt=1; __utmb=13579763.1.10.1559772492' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`


#SCRAPE QUERIES
# First Scrape Query
# ipa
# Second Scrape Query
# `curl 'https://untappd.com/search/more_search/beer?offset=25&q=hazy%20ipa&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559772492.1559781252.14; __utmt=1; __utmb=13579763.1.10.1559781252' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=hazy+ipa&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`
# Third Query
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=milkshake%20ipa&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559772492.1559781252.14; __utmt=1; __utmb=13579763.7.9.1559782440765' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=milkshake+ipa&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`
# Fourth Query 
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=ipa%20-%20american&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559772492.1559781252.14; __utmt=1; __utmb=13579763.8.9.1559782440765' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa+-+american&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`
# Fifth Query
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=ipa%20-%20imperial%20%2F%20double&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559772492.1559781252.14; __utmt=1; __utmb=13579763.10.9.1559782440765' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa+-+imperial+%2F+double&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest'  >> authed.html`
# Sixth Query 
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=ipa%20-%20New%20England&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559772492.1559781252.14; __utmt=1; __utmb=13579763.13.9.1559782440765' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa+-+New+England&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`
# Seventh Query
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=IPA%20-%20Session&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559781252.1559782443.15; __utmt=1; __utmb=13579763.9.9.1559837465359' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=IPA+-+Session&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed.html`
# Eigth Query
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=ipa%20double&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; _gid=GA1.2.466165788.1559752579; __utma=13579763.575700913.1559588955.1559781252.1559782443.15; __utmt=1; __utmb=13579763.36.9.1559838306329' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=ipa+double&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed2.html`
# Query 9 
# `curl 'https://untappd.com/search/more_search/beer?offset=#{offset}&q=west%20coast%20IPA&sort=all' -H 'cookie: __cfduid=dcb80092af332319aaf285382c521ea471559588954; _ALGOLIA=a0654fbc-0d9d-4a71-9542-09a88478c4cd; __utmc=13579763; ut_d_l=24c200008ab897c2ddf4e25927106e0aba8a52ca808c573796d9cc74e4cf5f1b9fab520b7136b3773bc29ec4762ef33aaf29f2fca8880a022c889c8d7c11d856k%2FUf5RhJ5y8k%2FDV4dDjgcaExV5DiFzbRVLTn90Xsz%2Bpm%2Bicxl8NV5H5pSsV9LPOPohvGiodunKXwjgQpJ%2FUo0A%3D%3D; untappd_user_v3_e=9326f5796118c4be8106eb330fa0c7e86c1841b392407c2720ae03a88d7426b5716d6921e4001b6c02ebb29ff3d0ca601e83a75fb9b8414a9dbdc43550a75669yXuNAJZOgB3lZ%2FZZwvMHo0LDvx9%2BIMQd%2BtGvtiimjYt0OMULHnoOeqWapMalFC0TlZoClR15yT%2F1SCwEpjf%2Fyg%3D%3D; ut_tos_update=true; __utmz=13579763.1559687632.7.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.575700913.1559588955; __utma=13579763.575700913.1559588955.1559782443.1559849752.16; __utmt=1; __utmb=13579763.31.9.1559850071518' -H 'accept-language: en-US,en;q=0.9' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'accept: */*' -H 'referer: https://untappd.com/search?q=west+coast+IPA&type=beer&sort=all' -H 'authority: untappd.com' -H 'x-requested-with: XMLHttpRequest' >> authed2.html`


# Currently no hawaiian crunk or sister ipa. 