module RbtcArbitrage
  module Clients
    class CircleClient
      include RbtcArbitrage::Client

      require 'pry'
      require 'curb'
      require 'active_support'
      require 'json'

      # return a symbol as the name
      # of this exchange
      def exchange
        :circle
      end

      # Returns an array of Floats.
      # The first element is the balance in BTC;
      # The second is in USD.
      def balance
        return @balance if @balance.present?

        result = api_customers_command

        @balance = [ result[:account_balance_in_btc_normalized], result[:account_balance_in_usd] ]
      end

      def interface
      end

      # Configures the client's API keys.
      #
      # circle_customer_id is the user's customer id (ie 168900 in the api call "www.circle.com/api/v2/customers/168900/accounts/186074/deposits")
      #
      # circle_bank_account_id is the user's bank account that is to be used (ie 186074 in the api call "www.circle.com/api/v2/customers/168900/accounts/186074/deposits")
      def validate_env
        validate_keys :circle_customer_session_token, :circle_cookie, :circle_customer_id, :circle_bank_account_id
      end

      # `action` is :buy or :sell
      def trade action
      end

      # `action` is :buy or :sell
      # Returns a Numeric type.
      def price action
      end

      # Transfers BTC to the address of a different
      # exchange.
      def transfer(other_client)
        volume = @options[:volume]
        transfer_btc(volume, other_client)
      end

      # If there is an API method to fetch your
      # BTC address, implement this, otherwise
      # remove this method and set the ENV
      # variable [this-exchange-name-in-caps]_ADDRESS
      def address
      end

    private

      # btc_to_dollar_exchange_rate is the rate to exchange one bitcoin into dollars,
      # so if the exchange rate is 1 Btc = 376.78, then btc_to_dollar_exchange_rate
      # should be 376.78
      def calculate_fiat_value_for_exchange_rate(btc_to_dollar_exchange_rate, amount_of_btc_to_purchase = 0.01)
        (amount_of_btc_to_purchase * btc_to_dollar_exchange_rate).round(2)
      end

      def transfer_btc(volume_in_btc, other_client)
        customers_command_result = api_customers_command

        volume = volume_in_btc

        exchange_rate_object = customers_command_result[:exchange_rate_object]
        exchange_rate = customers_command_result[:exchange_rate]
        fiat_value = calculate_fiat_value_for_exchange_rate(exchange_rate, volume)
        satoshi_value = 1000000 * (fiat_value / exchange_rate.to_f).round(18)

        btc_transfer_json_data = {"transaction" =>
          {"exchangeRate" => exchange_rate_object_for_btc_transfer,
          "bitcoinOrEmailAddress" => coinbase_btc_address,
          "satoshiValue" => satoshi_value,
          "fiatValue" => fiat_value,
          "currencyCode" => "USD",
          "message" => "sending 0.11 btc (#{fiat_value}) to coinbase."
          }
        }

        btc_transfer_json_data = btc_transfer_json_data.to_json
        content_length = btc_transfer_json_data.length

        # {
        #   exchange_rate_object: exchange_rate_object,
        #   exchange_rate: exchange_rate,
        #   account_balance_in_btc_raw: account_balance_in_btc_raw,
        #   account_balance_in_btc_normalized: account_balance_in_btc_normalized,
        #   account_balance_in_usd: account_balance_in_usd
        # }



        # exchange_rate_object_for_btc_transfer = exchange_rate_object["USD"]
        # fiat_value = calculate_fiat_value_for_exchange_rate(exchange_rate, 0.11)
        # satoshi_value = 1000000 * (fiat_value / exchange_rate.to_f).round(18)

        # btc_transfer_json_data = {"transaction" =>
        #   {"exchangeRate" => exchange_rate_object_for_btc_transfer,
        #   "bitcoinOrEmailAddress" => coinbase_btc_address,
        #   "satoshiValue" => satoshi_value,
        #   "fiatValue" => fiat_value,
        #   "currencyCode" => "USD",
        #   "message" => "sending 0.11 btc (#{fiat_value}) to coinbase."
        #   }
        # }

        # btc_transfer_json_data = btc_transfer_json_data.to_json
        # content_length = btc_transfer_json_data.length

        # curl = Curl::Easy.http_post("https://www.circle.com/api/v2/customers/168900/accounts/186074/transactions", btc_transfer_json_data) do |http|
        #   http.headers['host'] = 'www.circle.com'
        #   http.headers['method'] = 'POST'
        #   http.headers['path'] = '/api/v2/customers/168900/accounts/186074/transactions'
        #   http.headers['scheme'] = 'https'
        #   http.headers['version'] = 'HTTP/1.1'
        #   http.headers['accept'] = 'application/json, text/plain, */*'
        #   http.headers['accept-encoding'] = 'gzip,deflate'
        #   http.headers['accept-language'] = 'en-US,en;q=0.8'
        #   http.headers['content-length'] = content_length
        #   http.headers['content-type'] = 'application/json;charset=UTF-8'
        #   http.headers['cookie'] = circle_cookie
        #   http.headers['origin'] = 'https://www.circle.com'
        #   http.headers['referer'] = "https://www.circle.com/send/confirm"
        #   http.headers['user-agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
        #   http.headers['x-app-id'] = 'angularjs'
        #   http.headers['x-app-version'] = "0.0.1"
        #   http.headers['x-customer-id'] = "168900"
        #   http.headers['x-customer-session-token'] = circle_customer_session_token
        # end

        # json_data = ActiveSupport::Gzip.decompress(curl.body_str)
        # parsed_json = JSON.parse(json_data)

        # btc_transfer_response_status = parsed_json
        # response_code = btc_transfer_response_status['response']['status']['code']
        # if response_code == 0
        #   puts 'Successful BTC tansfer!'
        #   puts 'Transfer Details:'
        #   puts btc_transfer_response_status
        # else
        #   puts '** ERROR ** BTC Transfer Unsuccessful'
        #   puts 'Transfer Details:'
        #   puts btc_transfer_response_status
        # end
      end

      def circle_cookie
        ENV['CIRCLE_COOKIE']
      end

      def circle_customer_session_token
        ENV['CIRCLE_CUSTOMER_SESSION_TOKEN']
      end

      def api_customers_command(customer_id = ENV['CIRCLE_CUSTOMER_ID'], customer_session_token = ENV['CIRCLE_CUSTOMER_SESSION_TOKEN'])
        api_url = "https://www.circle.com/api/v2/customers/#{customer_id}"

        path_header = "/api/v2/customers/#{customer_id}"

        curl = Curl::Easy.new(api_url) do |http|
          http.headers['host'] = 'www.circle.com'
          http.headers['method'] = 'GET'
          http.headers['path'] = path_header
          http.headers['scheme'] = 'https'
          http.headers['version'] = 'HTTP/1.1'
          http.headers['accept'] = 'application/json, text/plain, */*'
          http.headers['accept-encoding'] = 'gzip,deflate,sdch'
          http.headers['accept-language'] = 'en-US,en;q=0.8'
          http.headers['cookie'] = circle_cookie
          http.headers['referer'] = "https://www.circle.com/accounts"
          http.headers['user-agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
          http.headers['x-customer-id'] = customer_id
          http.headers['x-customer-session-token'] = customer_session_token
        end

        response = curl.perform

        json_data = ActiveSupport::Gzip.decompress(curl.body_str)
        parsed_json = JSON.parse(json_data)
        exchange_rate_object = parsed_json['response']['customer']['exchangeRate']
        exchange_rate = parsed_json['response']['customer']['exchangeRate']['USD']['rate']
        account_balance_in_btc_raw = parsed_json['response']['customer']['accounts'].first['satoshiAvailableBalance']
        account_balance_in_btc_normalized = account_balance_in_btc_raw / 100000000.0
        account_balance_in_usd = exchange_rate * account_balance_in_btc_normalized

        {
          exchange_rate_object: exchange_rate_object,
          exchange_rate: exchange_rate,
          account_balance_in_btc_raw: account_balance_in_btc_raw,
          account_balance_in_btc_normalized: account_balance_in_btc_normalized,
          account_balance_in_usd: account_balance_in_usd
        }
      end
    end
  end
end
