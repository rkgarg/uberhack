class UberApi
    include HTTParty
    HTTP_TIMEOUT = 10
    BASE_URI = "https://walletapi.mobikwik.com/"
    MERCHANT_NAME = "OYORooms"
    KEY = "ePpNsKd1VOulGKp7okPPQEr2nJQD"
    SI_KEY = "fLplsKd1VOulGKg8okPPQEr3nJFG"
    M_ID = "MBK5770"
    MERCHANTS_EMAIL_ID = "achal.gupta@oyorooms.com"
    DEFAULT_SI_AMOUNT = 20

    def query_wallet(payment_method)
      data = {
          "action" => "existingusercheck",
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 500
      }
      get("querywallet", data)
    end

    def otp_generate(payment_method, amount = DEFAULT_SI_AMOUNT, get_standing_instruction = true)
      data = {
          "amount" => amount,
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 504,
          "tokentype" => (get_standing_instruction ? 1 : 0)
      }
      get("otpgenerate", data)
    end

    def resolve_or_create_user(payment_method)
      data = {
          "cell" => payment_method.phone,
          "email" => payment_method.email,
          "merchantname" => merchant_name,
          "mid" => m_id
      }
      data.merge!("checksum" => checksum(data, false))
      data.merge!("sendotp" => true)
      get("resolveorcreateuser", data, si = false, avoid_checksum = true, avoid_checksum_verification = true)
    end

    def token_generate(payment_method, otp, amount = DEFAULT_SI_AMOUNT, get_standing_instruction = true)
      data = {
          "amount" => amount,
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 507,
          "otp" => otp,
          "tokentype" => (get_standing_instruction ? 1 : 0)
      }
      get("tokengenerate", data)
    end

    def user_balance(payment_method)
      data = {
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 501,
          "token" => payment_method.meta_data["token"]
      }
      get("userbalance", data)
    end

    def user_balance_and_token_with_otp(payment_method, otp, get_standing_instruction = true)
      data = {
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 501,
          "otp" => otp,
          "returnedtokentype" => (get_standing_instruction ? 1 : 0),
          "returntoken" => true
      }
      get("userbalance", data, si = false, avoid_checksum = false, avoid_checksum_verification = true)
    end

    def create_wallet_user(payment_method)
      data = {
          "cell" => payment_method.phone,
          "email" => payment_method.email,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 502,
          "token" => payment_method.meta_data["token"]
      }
      get("createwalletuser", data)
    end

    def debit_wallet(payment_method, amount, txn_id, debit = true, comment = "Pay through wallet")
      data = {
          "amount" => amount,
          "cell" => payment_method.phone,
          "comment" => comment,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 503,
          "orderid" => txn_id,
          "token" => payment_method.meta_data["token"],
          "txntype" => (debit ? "debit" : "credit")
      }
      get("debitwallet", data)
    end

    # This needs to be a separate transaction, this is not a refund for a transaction, but a separate transaction.
    def load_money(payment_method, amount, txn_id, comment = "Pay out of wallet")
      walletid = MERCHANTS_EMAIL_ID
      walletid = 'testapisupport@gmail.com' if !Rails.env.production?
      data = {
          "amount" => amount,
          "cell" => payment_method.phone,
          "comment" => comment,
          "creditmethod" => "cashback",
          "merchantname" => merchant_name,
          "mid" => m_id,
          "orderid" => txn_id,
          "typeofmoney" => 0,
          "walletid" => walletid
      }
      get("loadmoney", data)
    end

    #This is a separate API which works on Mobikwik version 3.2. So not using the generic framework.
    def refund_money(payment_method, amount, refund)
      url = 'https://www.mobikwik.com/walletrefund'
      data = {
          "mid" => m_id,
          "txid" => refund.payment_transac.txnid,
          "amount" => amount,
          "email" => payment_method.email
      }
      data.merge!("checksum" => checksum(data, false), "ispartial" => 'yes')
      self.class.headers({"payloadtype" => "json"})
      response = self.class.post(url, :query => data, timeout: HTTP_TIMEOUT)
    end

    # This needs to be a separate transaction, this is not a refund for a transaction, but a separate transaction.
    def token_regenerate(payment_method, si = true)
      data = {
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 507,
          "token" => payment_method.meta_data["token"],
          "tokentype" => 1
      }
      get("tokenregenerate", data, si)
    end

    def auth_wallet_complete(payment_method, amount, txn_id, comment = "Money from the customer")
      data = {
          "amount" => amount,
          "captureamount" => amount,
          "cell" => payment_method.phone,
          "comment" => comment,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 508,
          "orderid" => txn_id,
          "userrequest" => "capture"
      }
      get("authwalletrequest", data)
    end

    def auth_wallet_request(payment_method, amount, txn_id, comment = "Money from the customer")
      data = {
          "amount" => amount,
          "cell" => payment_method.phone,
          "comment" => comment,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "msgcode" => 509,
          "orderid" => txn_id,
          "token" => payment_method.meta_data["token"],
          "txntype" => "debit"
      }
      get("authwalletcomplete", data)
    end

    def add_money_to_wallet(payment_method, recharge)
      data = {
          "amount" => recharge["amount"],
          "cell" => payment_method.phone,
          "merchantname" => merchant_name,
          "mid" => m_id,
          "orderid" => ('A'..'Z').to_a.sample(4).join + (0..9).to_a.sample(4).join,
          "redirecturl" => "https://www.oyorooms.com/booking-paid",
          "token" => payment_method.meta_data["token"]
      }
      data.merge!("checksum" => checksum(data, false))
      if recharge["paymenttype"] == "NB"
        data.merge!({
                        "bankname" => recharge["bankname"] == "HDFC" ? "HDF" : recharge["bankname"],
                        "paymenttype" => recharge["paymenttype"]
                    })
      else
        data.merge!({
                        "ccnumber" => recharge["ccnumber"],
                        "cvv" => recharge["cvv"],
                        "expmonth" => recharge["expmonth"],
                        "expyear" => recharge["expyear"],
                        "paymenttype" => recharge["paymenttype"]
                    })
      end
      return {
          address: base_url + "addmoneytowallet",
          headers: {"payloadtype" => "json"},
          query: data
      }
    end

    private

    def get(url_path, options, si = false, avoid_checksum = false, avoid_checksum_verification = false)
      address = base_url + url_path
      address = "https://test.mobikwik.com/mobikwik/tokenregenerate" if (!Rails.env.production? and url_path == "tokenregenerate")
      self.class.headers({"payloadtype" => "json"})
      options.merge!("checksum" => checksum(options, si)) unless avoid_checksum
      response = self.class.get(address, :query => options, timeout: HTTP_TIMEOUT)
      response = JSON.parse(response)
      verify_checksum(response) unless avoid_checksum_verification
      return response
    end

    def verify_checksum(response)
      sorted_data = []
      checksum = response["checksum"]
      response.reject! { |k, v| k == "checksum" or v.blank? }
      response.sort.map { |i| sorted_data << i[1] }
      str = sorted_data.each.inject("") { |str, k| str += "'#{k}'" }
      calc_hash = OpenSSL::HMAC.hexdigest("sha256", key, str)
      raise 'Verify checksum failed!' unless checksum == calc_hash
    end

    def checksum(data, si)
      non_null_data = data.reject { |k, v| v.blank? }
      str = non_null_data.values.map{|s| "'#{s}'"}.join
      OpenSSL::HMAC.hexdigest("sha256", (si ? si_key : key), str)
    end

    def m_id
      return Rails.env.production? ? M_ID : "MBK9009"
    end

    def base_url
      return Rails.env.production? ? BASE_URI : "https://test.mobikwik.com/"
    end

    def merchant_name
      return Rails.env.production? ? MERCHANT_NAME : "test"
    end

    def key
      return Rails.env.production? ? KEY : "ju6tygh7u7tdg554k098ujd5468o"
    end

    def si_key
      return Rails.env.production? ? SI_KEY : "xcmypysQoqnFMEQ57vlfaDsIvY59"
    end
  end
