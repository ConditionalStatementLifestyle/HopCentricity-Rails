Beer.destroy_all

s1 = Scraper.new

s1.relative_path = 'authed.html'
s1.loadRelativePage

s1.relative_path = 'authed2.html'
s1.loadRelativePage

s1.relative_path = 'authed3.html'
s1.loadRelativePage
