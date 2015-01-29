import geoip2.database
import io

city    = geoip2.database.Reader('../../data/GeoLite2-City.mmdb')
country = geoip2.database.Reader('../../data/GeoLite2-Country.mmdb')
ips     = file('../ip_set.txt', 'r')
results = io.open('../python_results.txt', mode='w', encoding='utf-8')

for ip in ips:
  ip          = ip.strip()
  city_res    = ''
  country_res = ''

  try:
    city_data = city.city(ip)
    city_res  = u'%s_%s_' % (
      city_data.location.latitude,
      city_data.location.longitude
    )
    city_res  = u'%s%s' % (
      city_res,
      city_data.city.names['en']
    )
  except:
    pass

  try:
    country_data = country.country(ip)
    country_res  = country_data.country.names['en']
  except:
    pass

  results.write(u'%s-%s-%s\n' % (ip, city_res, country_res))

city.close()
country.close()
results.close()
