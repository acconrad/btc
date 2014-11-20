require 'pry'
require 'curb'
require 'active_support'
require 'json'

#Investigations into the Circle API

def circle_customer_session_token
  ENV['CIRCLE_CUSTOMER_SESSION_TOKEN']
end

curl = Curl::Easy.new("https://www.circle.com/api/v2/customers/168900") do |http|
  http.headers['host'] = 'www.circle.com'
  http.headers['method'] = 'GET'
  http.headers['path'] = '/api/v2/customers/168900'
  http.headers['scheme'] = 'https'
  http.headers['version'] = 'HTTP/1.1'
  http.headers['accept'] = 'application/json, text/plain, */*'
  http.headers['accept-encoding'] = 'gzip,deflate,sdch'
  http.headers['accept-language'] = 'en-US,en;q=0.8'
  http.headers['cookie'] = "__cfduid=d0de65aad44eddf6207369c49a488806f1410231774404; optimizelyEndUserId=oeu1416148420288r0.7686132828239352; _ys_trusted=%7B%22_%22%3A%2269b9db727e9281eb49c980e11f349c074fc62c9b%22%7D; optimizelySegments=%7B%7D; optimizelyBuckets=%7B%222169471078%22%3A%222162540652%22%7D; AWSELB=6DE1C52F06D2FAD97948D9C525A94E7AAFA0177A18F0E0AF588D85BA3F707B2324DC85D6467A080C3C55A596F5F12AF54EFBD28ACB95EEF089DAF61F007FEAEB120747ABFC; _ys_session=%7B%22_%22%3A%7B%22value%22%3A%22920567339e61ee8fcd556e0f82d46d209910eca2%22%2C%22customerId%22%3A168900%2C%22expiryDate%22%3A1416279016350%7D%7D; __utma=100973971.7568760.1410231775.1416269203.1416277808.16; __utmb=100973971.3.10.1416277808; __utmc=100973971; __utmz=100973971.1410231775.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ys_state=%7B%22_%22%3A%7B%22isEmailVerified%22%3Atrue%2C%22isMfaVerified%22%3Atrue%7D%7D; i18next=en"
  http.headers['referer'] = "https://www.circle.com/accounts"
  http.headers['user-agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
  http.headers['x-customer-id'] = "168900"
  http.headers['x-customer-session-token'] = circle_customer_session_token
end

response = curl.perform

json_data = ActiveSupport::Gzip.decompress(curl.body_str)
parsed_json = JSON.parse(json_data)
exchange_rate = parsed_json['response']['customer']['exchangeRate']['USD']['rate']
account_balance_in_btc_raw = parsed_json['response']['customer']['accounts'].first['satoshiAvailableBalance']
account_balance_in_btc_normalized = account_balance_in_btc_raw / 100000000.0
account_balance_in_usd = exchange_rate * account_balance_in_btc_normalized

puts 'Exchange Rate:'
puts exchange_rate
puts 'Account Balance in BTC:'
puts account_balance_in_btc_normalized
puts 'Account Balance in USD:'
puts account_balance_in_usd





