namespace :kabu_analysis do

  desc "コマツ株を解析"
  task komatsu: :environment do
    KomatsuPrice.order(:trading_date).each do |komatsu_price|
      p komatsu_price.trading_date
    end
  end
end
