import geoip2.database

city    = geoip2.database.Reader('../../data/GeoLite2-City.mmdb')
country = geoip2.database.Reader('../../data/GeoLite2-Country.mmdb')

print "python.verify"

city.close()
country.close()
