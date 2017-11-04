class CreateTwProxies < ActiveRecord::Migration
  def change
    create_table :tw_proxies do |t|
      t.string :nickname
      t.string :host
      t.string :port
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
