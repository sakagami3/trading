namespace :kabu_scraping do
  require 'open-uri'

  desc "Yahoo から株情報を取得"
  task import_shelfy_professional_dictionary: :environment do
    CODE = 6301 # 株コード

    # 取り込むデータの最初の日付
    START_YEAR = 1995
    START_MONTH = 1
    START_DAY = 1

    # 取り込むデータの最後の日付
    END_YEAR = 2015
    END_MONTH = 11
    END_DAY = 14

    YAHOO_SITE_URL = "http://info.finance.yahoo.co.jp/history/?code=#{CODE}.T&sy=#{START_YEAR}&sm=#{START_MONTH}&sd=#{START_DAY}&ey=#{END_YEAR}&em=#{END_MONTH}&ed=#{END_DAY}&tm=d"

    1.upto(1000) do |page|
      url = "#{YAHOO_SITE_URL}&p=#{page}"
      p url

      doc = Nokogiri::HTML(open(url)) # スクレイピング先のURLを指定
      doc_css = doc.css('.boardFin td')

      if doc_css.blank?
        exit
      end

      doc_css.each_with_index do |td, index|
        komatsu_price = KomatsuPrice.new

        next unless index % 7 == 0

        trading_date = td.content

        if /^[0-9]+年[0-9]+月[0-9]+日$/ =~ trading_date
          trading_date = trading_date.gsub('年', '-')
          trading_date = trading_date.gsub('月', '-')
          trading_date = trading_date.gsub('日', '')

          p "日付: #{trading_date}"

          if KomatsuPrice.where(trading_date: trading_date).exists?
            p 'この日付のデータはすでに登録されているため、スキップ。'
            next
          end

          komatsu_price.trading_date = trading_date
        else
          raise '日付が正しくありません。'
        end

        hajimene = KomatsuPrice.price_to_f(doc_css[index + 1].content)
        p "始値: #{hajimene}"
        komatsu_price.hajimene = hajimene

        takane = KomatsuPrice.price_to_f(doc_css[index + 2].content)
        p "高値: #{takane}"
        komatsu_price.takane = takane

        yasune = KomatsuPrice.price_to_f(doc_css[index + 3].content)
        p "安値: #{yasune}"
        komatsu_price.yasune = yasune

        owarine = KomatsuPrice.price_to_f(doc_css[index + 4].content)
        p "終値: #{owarine}"
        komatsu_price.owarine = owarine

        dekidaka = KomatsuPrice.price_to_f(doc_css[index + 5].content)
        p "出来高: #{dekidaka}"
        komatsu_price.dekidaka = dekidaka

        komatsu_price.save!
      end

      sleep(1)
    end
  end
end
