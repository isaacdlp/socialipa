namespace :twitter do

  require 'social'

  # Windows SSL Issues
  I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil
  warn_level = $VERBOSE
  $VERBOSE = nil
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  $VERBOSE = warn_level

  desc 'Test Sandbox'
  task test: :environment do
    conn = Connection.new('isaacdlp')
    # conn.logger = Logger.new(STDOUT)
    # conn.login
    users = []
    list, position = conn.search('mediterránea near:lima,peru within:50km', 10000) do |tweet|
    #list, position = conn.search('#miraflores', 10000) do |tweet|
    #conn.login
    #list, position = conn.download_list('josancru', 'following') do |tweet|
      print '.'
      username = tweet[:username]
      unless users.include? username
        user = conn.get_profile(username, true)
        users.push username
        unless user[:followers] < 1000
          p user
        end
      end
    end
    p position
    #conn.login
    #user = conn.get_profile('p5svpgb3yife')
    #media_id = conn.upload_media('agora_historia.jpg')
    #conn.message(user[:user_id], '¡Gracias por seguirme! ¿Ya conoces @AgoraEAFI? Por favor explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)', media_id)
  end

  def valuable?(user, lists)
    return false if user[:protected]
    return false if user[:block_him]
    return false if user[:follow_him]
    return false if user[:follows_me]
     lists.each do |list|
      if list.include?(user[:username])
        return false
      end
    end
    true
  end

  desc 'carlosdoblado'
  task carlosdoblado: :environment do
    ENV['account'] = 'carlosdoblado'
    ENV['list_id'] = '744285108048371712'
    #ENV['mention_msg'] = '% ¿Ya conoces @AgoraEAFI? Explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_msg'] = '¡Gracias por seguirme! ¿Ya conoces @AgoraEAFI? Por favor explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_img'] = 'lib/agora_historia.jpg'
    Rake::Task['twitter:bot'].execute
  end

  desc 'llorentef'
  task llorentef: :environment do
    ENV['account'] = 'llorentef'
    ENV['list_id'] = '743968689150656512'
    #ENV['mention_msg'] = '% ¿Ya conoces @AgoraEAFI? Explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_msg'] = '¡Gracias por seguirme! ¿Ya conoces @AgoraEAFI? Por favor explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_img'] = 'lib/agora_historia.jpg'
    Rake::Task['twitter:bot'].execute
  end

  desc 'agoraeafi'
  task agoraeafi: :environment do
    ENV['account'] = 'agoraeafi'
    ENV['list_id'] = '743940698379026432'
    ENV['mention_msg'] = '% ¿Ya conoces @AgoraEAFI? Explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    ENV['welcome_msg'] = '¡Gracias por seguirme! ¿Ya conoces @AgoraEAFI? Por favor explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    ENV['welcome_img'] = 'lib/agora_historia.jpg'
    Rake::Task['twitter:bot'].execute
  end

  desc 'isaacdlp'
  task isaacdlp: :environment do
    ENV['account'] = 'isaacdlp'
    ENV['list_id'] = '740708344365764608'
    #ENV['mention_msg'] = '% ¿Ya conoces @AgoraEAFI? Explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_msg'] = '¡Gracias por seguirme! ¿Ya conoces @AgoraEAFI? Por favor explora las opciones gratuitas y si quieres te envío un cupón de descuento. ¡Un saludo! :)'
    #ENV['welcome_img'] = 'lib/agora_historia.jpg'
    Rake::Task['twitter:bot'].execute
  end

  desc 'Bot Template'
  task bot: :environment do
    list_id = ENV['list_id']
    mention_msg = ENV['mention_msg']
    if mention_msg and mention_msg.encoding != Encoding::UTF_8
      mention_msg = mention_msg.encode('Windows-1252')
    end
    mention_img = ENV['mention_img']
    welcome_msg = ENV['welcome_msg']
    if welcome_msg and welcome_msg.encoding != Encoding::UTF_8
      welcome_msg = welcome_msg.encode('Windows-1252')
    end
    welcome_img = ENV['welcome_img']

    no_reload = ENV['no_reload']
    no_retweet = ENV['no_retweet']
    no_follow = ENV['no_follow']
    no_unfollow = ENV['no_unfollow']
    no_like = ENV['no_like']
    no_unlike = ENV['no_unlike']

    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    span = ENV['span']
    span = '3' unless span
    span = span.to_i

    silent = true

    conn = Connection.new(username)
    conn.logger = Logger.new(STDOUT)
    conn.delays = {
        # Secs to remain logged in
        rest: lambda { rand(3600..21600) },
        # Secs to remain logged out
        act: lambda { rand(1800..3600) },
        # Secs to wait in between requests
        request: lambda { rand(5..10) },

        edit_profile: lambda { rand(10..20) },
        tweet: lambda { rand(60..180) },
        untweet: lambda { rand(20..120) },
        follow: lambda { rand(60..180) },
        unfollow: lambda { rand(20..120) },
        like: lambda { rand(20..120) },
        unlike: lambda { rand(10..60) },
        create_list: lambda { rand(180..720) },
        edit_list: lambda { rand(180..720) },
        delete_list: lambda { rand(60..180) },
        add_to_list: lambda { rand(20..120) },
        delete_from_list: lambda { rand(10..60) },
    }
    begin
      conn.studies_on
      conn.login

      store_lists = []

      list_followed = conn.list_followed
      store_lists.push list_followed
      list_unfollow = conn.list_unfollow
      list_liked = conn.list_liked
      store_lists.push list_liked
      list_unlike = conn.list_unlike
      list_listed = conn.list_listed
      store_lists.push list_listed
      list_mentioned = conn.list_mentioned
      store_lists.push list_mentioned
      list_retweeted = conn.list_retweeted
      store_lists.push list_retweeted

      sources = {}
      source_lists = conn.list_sources.item_array
      source_lists.each do |name|
        sources[name] = conn.list_source(name)
      end

      list_followers = conn.list_followers

      conn.delays[:reload] = lambda { 3600 * 24 * 7 }         # one week
      conn.delays[:welcome] = lambda { 3600 * 4 }             # four hours

      conn.delays[:mention] = lambda { rand(43200..172800) }
      conn.next_time :mention
      conn.delays[:retweet] = lambda { rand(43200..172800) }
      conn.next_time :retweet

      errors = 0

      loop do
        begin
          done = {}

          if conn.allowed? :reload and not no_reload
            p 'Op reload' unless silent
            sources.each do |name, source|
              conn.store_list(source, name, 'followers')
            end
            conn.next_time :reload
          end

          if conn.allowed? :welcome and welcome_msg
            p 'Op welcome' unless silent
            leads, position = conn.download_list(conn.account.username, 'followers', list_followers.position)
            leads.reverse_each do |lead|
              unless list_followers.include? lead[:username]
                begin
                  user = conn.get_profile(lead[:username])
                  if user
                    media_id = nil
                    if welcome_img
                      media_id = conn.upload_media(welcome_img)
                    end
                    message = welcome_msg.gsub(/%/, "@#{lead[:username]}")
                    conn.message(user[:user_id], message, media_id)
                    conn.stats_add :welcome
                  end
                  list_followers.add(lead[:username])
                rescue KnownIssue
                  p $!
                end
              end
            end

            list_followers.position = position
            list_followers.save!

            conn.next_time :welcome
          end

          if conn.allowed? :mention and conn.allowed? :tweet and mention_msg
            p 'Op mention' unless silent
            sources.values.each do |source|
              source.lines.order('created_at ASC').each do |lead|
                begin
                  user = conn.get_profile(lead.item)
                  if valuable?(user, store_lists)
                    media_id = nil
                    if mention_img
                      media_id = conn.upload_media(mention_img)
                    end
                    message = mention_msg.gsub(/%/, "@#{user[:username]}")
                    if conn.tweet(message, media_id)
                      list_mentioned.add(user[:username])
                      done[:mention] = true
                      conn.next_time :mention
                      conn.stats_add :mention
                    end
                  end
                rescue KnownIssue
                  p $!
                end
                lead.destroy
                break if done[:mention]
              end
              break if done[:mention]
            end
          end

          if conn.allowed? :retweet and conn.allowed? :tweet and not no_retweet
            p 'Op retweet' unless silent
            sources.values.each do |source|
              source.lines.order('created_at ASC').each do |lead|
                begin
                  user = conn.get_profile(lead.item)
                  if valuable?(user, store_lists)
                    if conn.retweet_last(user[:username])
                      list_retweeted.add(user[:username])
                      done[:retweet] = true
                      conn.next_time :retweet
                      conn.stats_add :retweet
                    end
                  end
                rescue KnownIssue
                  p $!
                end
                lead.destroy
                break if done[:retweet]
              end
              break if done[:retweet]
            end
          end

          if conn.allowed? :follow and not no_follow
            p 'Op follow' unless silent
            sources.values.each do |source|
              source.lines.order('created_at ASC').each do |lead|
                begin
                  user = conn.get_profile(lead.item)
                  if valuable?(user, store_lists)
                    if conn.follow(user[:user_id])
                      list_followed.add(user[:username])
                      list_unfollow.add(user[:username])
                      done[:follow] = true
                    end
                  end
                rescue KnownIssue
                  p $!
                end
                lead.destroy
                break if done[:follow]
              end
              break if done[:follow]
            end
          end

          if conn.allowed? :unfollow and not no_unfollow
            p 'Op unfollow' unless silent
            thresshold = Time.now - span.days
            list_unfollow.tw_list_items.where('created_at < (?)', thresshold).order('created_at ASC').each do |lead|
              begin
                user = conn.get_profile(lead.item)
                unless user[:follows_me] or not user[:follow_him]
                  if conn.unfollow(user[:user_id])
                    done[:unfollow] = true
                  end
                end
              rescue KnownIssue
                p $!
              end
              lead.destroy
              break if done[:unfollow]
            end
          end

          if conn.allowed? :like and not no_like
            p 'Op like' unless silent
            sources.values.each do |source|
              source.lines.order('created_at ASC').each do |lead|
                begin
                  user = conn.get_profile(lead.item)
                  if valuable?(user, store_lists)
                    tweet_id = conn.get_last_tweet_id(user[:username])
                    if tweet_id and conn.like(tweet_id)
                      list_liked.add(user[:username])
                      list_unlike.add(tweet_id)
                      done[:like] = true
                    end
                  end
                rescue Mechanize::ResponseCodeError => ex
                  raise unless ex.response_code == '401'      # Unauthorized!
                  p 'Unauthorized!'
                rescue KnownIssue
                  p $!
                end
                lead.destroy
                break if done[:like]
              end
              break if done[:like]
            end
          end

          if conn.allowed? :unlike and not no_unlike
            p 'Op unlike' unless silent
            thresshold = Time.now - span.days
            list_unlike.tw_list_items.where('created_at < (?)', thresshold).order('created_at ASC').each do |lead|
              begin
                user = conn.get_profile_by_tweet(lead.item)
                unless user[:follows_me]
                  if conn.unlike(lead.item)
                    done[:unlike] = true
                  end
                end
              rescue KnownIssue
                p $!
              end
              lead.destroy
              break if done[:unlike]
            end
          end

          if conn.allowed? :add_to_list and list_id
            p 'Op list' unless silent
            sources.values.each do |source|
              source.lines.order('created_at ASC').each do |lead|
                begin
                  user = conn.get_profile(lead.item)
                  if valuable?(user, store_lists)
                    if conn.add_to_list(user[:user_id], list_id)
                      list_listed.add(user[:username])
                      done[:list] = true
                    end
                  end
                rescue KnownIssue
                  p $!
                end
                lead.destroy
                break if done[:list]
              end
              break if done[:list]
            end
          end

          p 'Loop done'

          pause = true
          done.values.each do |value|
            if value
              pause = false
              break
            end
          end
          sleep(5) if pause

        rescue CannotAct
          "Sleeping until #{conn.times[:act]}"
          conn.wait_until(:act)
        rescue CannotDo
          p $!
        rescue Interrupt
          raise
        rescue Exception => ex
          p $!
          errors += 1
          if errors > 10
            p ex.backtrace
            p 'Too many errors. End.'
            exit
          end
        end

      end
    ensure
      conn.shutdown
    end
  end

  desc 'Reload Sources'
  task reload: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    followers = ENV['followers']

    conn = Connection.new(username)
    conn.logger = Logger.new(STDOUT)
    conn.login

    sources = conn.list_sources.item_array
    sources.each do |name|
      source = conn.list_source(name)
      conn.store_list(source, name, 'followers')
    end

    conn.store_list(conn.list_followers, username, 'followers') if followers

    conn.logout
  end

  desc 'Calculate Conversion Rates'
  task rates: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    study_name = ENV['study']
    study_name = "#{username} @ all" unless study_name

    study = TwStudy.find_by_name(study_name)
    stats = study.stat_hash

    conn = Connection.new(username)
    list_followers = conn.list_followers

    actions = {}
    actions['follow'] = conn.list_followed if stats['follow']
    actions['like'] = conn.list_liked if stats['like']
    actions['add_to_list'] = conn.list_listed if stats['add_to_list']
    actions['mention'] = conn.list_mentioned if stats['mention']
    actions['retweet'] = conn.list_retweeted if stats['retweet']

    conversions = {}
    actions.keys.each do |action|
      conversions[action] = 0
    end

    list_followers.lines.each do |line|
      actions.each do |action, list|
        if list.include? line.item
          conversions[action] += 1
          break
        end
      end
    end

    p "Conversion rates for #{study_name}:"
    conversions.each do |action, conversion|
      if stats[action]
        total = stats[action]
        rate = '%.4f' % ((conversion / total) * 100)
        p "#{action}: #{conversion} of #{total} (#{rate}%)"
      end
    end
  end

  desc 'Cleanup Account'
  task clean: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end
    no_reload = ENV['no_reload']
    no_unfollow = ENV['no_unfollow']
    no_unlike = ENV['no_unlike']
    total = ENV['total']

    conn = Connection.new username
    conn.logger = Logger.new(STDOUT)

    conn.delays[:unfollow] = lambda { rand(2..8) }      # OPCIONAL!
    conn.delays[:unlike] = lambda { rand(2..8) }        # OPCIONAL!

    conn.login

    list_following = conn.list_following
    list_likes = conn.list_likes
    list_vip = conn.list_vip
    unless no_reload
      list_following = conn.store_own(list_following, 'following')
      list_likes = conn.store_own(list_likes, 'likes')
      list_vip = conn.store_own(list_vip, 'lists', 'vip')
    end

    errors = 0

    loop do
      begin

        done = {}

        if conn.allowed? :unfollow and not no_unfollow
          #p 'Op unfollow'
          list_following.tw_list_items.order('created_at ASC').each do |lead|
            begin
              username = lead.item
              unless list_vip.include? username
                user = conn.get_profile(username)
                unless user[:follows_me] or total
                  done[:unfollow] = conn.unfollow(user[:user_id])
                end
              end
            rescue KnownIssue
              p $!
            end
            lead.destroy
            break if done[:unfollow]
          end
        end

        if conn.allowed? :unlike and not no_unlike
          #p 'Op unlike'
          list_likes.tw_list_items.order('created_at ASC').each do |lead|
            begin
              tweet_id = lead.item
              user = conn.get_profile_by_tweet(tweet_id)
              unless list_vip.include? user[:username]
                unless user[:follows_me] or total
                  done[:unlike] = conn.unlike(tweet_id)
                end
              end
            rescue KnownIssue
              p $!
            end
            lead.destroy
            break if done[:unlike]
          end
        end

        p 'Loop done'

        pause = true
        done.values.each do |value|
          if value
            pause = false
            break
          end
        end
        sleep(5) if pause
      rescue CannotAct
        p $!
      rescue CannotDo
        p $!
      rescue Interrupt
        raise
      rescue Exception => ex
        p $!
        errors += 1
        if errors > 10
          p ex.backtrace
          p 'Too many errors. End.'
          exit
        end
      end
    end
  end

  # LIGA DE LA JUSTICIA

  LIGA_JUSTICIA = '# justicieros'

  desc 'Create Bot'
  task create: :environment do

    username = ENV['account']
    proxy = ENV['proxy']
    phone = ENV['phone']

    no_breed = ENV['no_breed']

    bot_list = '# justicieros'

    proxy = true unless proxy
    email_domain = 'gobeleza.com'

    el_email = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + %w(_)
    el_pass = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + %w(. _ $ ! % * # & @ ^)

    unless username
      el_names = []
      File.open('lib/nombres-es.txt', 'r') do |file|
        file.each_line do |line|
          el_names.push line.strip
        end
      end

      el_surnames = []
      File.open('lib/apellidos-es.txt', 'r') do |file|
        file.each_line do |line|
          el_surnames.push line.strip
        end
      end

      name = el_names.sample
      surname = el_surnames.sample

      full_name = "#{name} #{surname}"

      # email_name = el_email.shuffle[0..rand(8..16)].join
      email_name = (0..rand(8..16)).map{ el_email.sample }.join
      email = "#{email_name}@#{email_domain}"

      # password = el_pass.shuffle[0..10].join
      password = (0..10).map{ el_pass.sample }.join

      p "#{full_name} | #{email} | #{password} | #{proxy} | #{phone}"

      account = Connection.create(full_name, email, password, "Bot #{full_name}", proxy, phone)
      exit unless account
      username = account.username
    end

    p "Add to list #{bot_list}"

    list = TwList.get_or_create(bot_list)
    list.add(username)

    unless no_breed
      ENV['account'] = username
      Rake::Task['twitter:rename'].execute
      Rake::Task['twitter:dress'].execute                  # without dependencies
      Rake::Task['twitter:rite'].execute
      #Rake::Task['twitter:cub'].reenable
      #Rake::Task['twitter:cub'].invoke                    # with dependencies, but only once
    end
  end

  desc 'Put on a hide'
  task dress: :environment do

    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    avatar_url = 'http://lorempixel.com/400/400'
    header_url = 'http://lorempixel.com/1500/500'
    website = 'www.carlosdoblado.com'

    conn = Connection.new(username)
    conn.login

    description = get_random_quote(160)

    bdate = Date.today - rand(7300..21900) # days between 20 and 60 years ago
    locations = conn.get_geo_profile
    location = locations.sample
    color = '%06x' % (rand * 0xffffff)
    color = "##{color}"

    p "#{description} | #{bdate} | #{color} | #{location}"

    conn.wait_until(:edit_profile)
    conn.edit_profile(nil, description, bdate, true, true, location[:place_name], location[:place_id], website, color)

    p 'Upload Avatar'

    avatar_id = conn.upload_media(avatar_url)
    conn.wait_until(:edit_profile)
    conn.edit_profile_image('avatar', avatar_id)

    p 'Upload Header'

    header_id = conn.upload_media(header_url)
    conn.wait_until(:edit_profile)
    conn.edit_profile_image('header', header_id)

    p 'Ready to Rock!'

    conn.logout
  end

  desc 'Join the wolf pack'
  task rite: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    cub_conn = Connection.new(username)
    cub_conn.delays[:follow] = lambda { rand(0..5) }
    cub_conn.login

    # noinspection RubyLiteralArrayInspection
    masters = ['isaacdlp', 'carlosdoblado']
    masters.each_with_index do |master, index|
      p "[#{index}] bowing to #{master}"

      user = cub_conn.get_profile(master)
      cub_conn.wait_until(:follow)
      cub_conn.follow(user[:user_id])
    end

    cub_user = nil

    justicieros = TwList.item_array(LIGA_JUSTICIA).shuffle
    justicieros.each_with_index do |justiciero, index|
      p "[#{index}] embracing #{justiciero}"

      unless justiciero == username
        begin
          user = cub_conn.get_profile(justiciero)
          cub_conn.wait_until(:follow)
          cub_conn.follow(user[:user_id])

          conn = Connection.new(justiciero)
          conn.login
          cub_user = conn.get_profile(username) unless cub_user
          conn.follow(cub_user[:user_id])
          conn.logout
        rescue Interrupt
          raise
        rescue Exception
          p $!
        end
      end
    end

    cub_conn.logout
  end

  desc 'Rename Account'
  task rename: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    conn = nil

    online = ENV['online']
    name = ENV['name']
    unless name
      online = 'true'

      conn = Connection.new(username)
      suggestions = []
      loop do
        p "Propose alternative username for #{conn.account.description} (#{conn.account.proxy}):"
        proposal = STDIN.gets.chomp

        if proposal.size > 15
          p 'Too long! Max 15 characters'
          next
        end

        choice = Integer(proposal) rescue nil         # interesting one-liner!
        if choice and choice < suggestions.size
          proposal = suggestions[choice]
        end

        available, suggestions = conn.name_available?(proposal, true)
        if available
          name = proposal
          break
        else
          p "#{proposal} not available"
          unless suggestions.empty?
            p 'Suggestions:'
            suggestions.each_with_index do |suggestion, index|
              p "[#{index}]: #{suggestion}"
            end
          end
        end

      end
    end

    if online
      conn = Connection.new(username) unless conn
      conn.login
      conn.edit_settings name
      p "Renaming account #{username} to #{name} online"
    else
      account = TwAccount.find_by_username(username)
      if account
        account.username = name
        account.save!
        p "Renaming account #{username} to #{name}"
      end
    end

    justicieros = TwList.find_by_name(LIGA_JUSTICIA)
    justiciero = justicieros.lines.find_by_item(username)
    if justiciero
      justiciero.item = name
      justiciero.save!
      p "Renaming #{username} to #{name} in Justicieros' list"
    end

    ENV['account'] = name   # for chained events

    conn.logout if conn
  end

  desc 'Unlock Account'
  task unlock: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    conn = Connection.new(username)
    conn.logger = Logger.new(STDOUT)
    conn.unlock
  end

  desc 'Kill Bot'
  task kill: :environment do
    username = ENV['account']
    unless username
      p 'The account cannot be empty'
      exit
    end

    user = TwAccount.find_by_username(username)
    if user
      p "Destroying #{username}"
      user.destroy
    end

    justicieros = TwList.find_by_name(LIGA_JUSTICIA)
    line = justicieros.tw_list_items.find_by_item(username)
    if line
      p "Removing #{username} from #{LIGA_JUSTICIA}"
      line.destroy
    end
  end

  desc 'Unlock All Phone Accounts'
  task pack_unlock: :environment do
    accounts = TwAccount.where('phone <> ""').order('phone ASC')
    accounts.each_with_index do |account, index|
      begin
        p "[#{index}] #{account.username}"

        begin
        conn = Connection.new(account.username)
        conn.login
        rescue CannotLogin => ex
          if ex.code == :locked
            unlock = true
            loop do
              p "Unlock #{account.username} (#{account.phone}) [y/n]?"
              unlock = STDIN.gets.chomp
              break if unlock == 'y' or unlock == 'n'
            end
            if unlock == 'y'
              conn = Connection.new(account.username)
              conn.unlock
            end
          end
        end
      rescue Interrupt
        raise
      rescue Exception
        p $!
      end
    end
  end

  desc 'Use the Wolfpack to like something'
  task pack_like: :environment do
    tweet_id = ENV['tweet_id']
    unless tweet_id
      p 'Tweet ID missing'
      exit
    end

    justicieros = TwList.item_array(LIGA_JUSTICIA).shuffle
    justicieros.each_with_index do |justiciero, index|
      begin
          p "[#{index}] #{justiciero}"

          conn = Connection.new(justiciero)
          conn.login
          conn.like(tweet_id)
          conn.logout
      rescue Interrupt
        raise
      rescue Exception
        p "Problems with #{justiciero}"
        p $!
      end
    end
  end

  desc 'Use the Wolfpack to retweet something'
  task pack_retweet: :environment do
    tweet_id = ENV['tweet_id']
    unless tweet_id
      p 'Tweet ID missing'
      exit
    end
    user_id = ENV['user_id']
    msg = ENV['msg']

    justicieros = TwList.item_array(LIGA_JUSTICIA).shuffle
    justicieros.each_with_index do |justiciero, index|
      begin
        p "[#{index}] #{justiciero}"

        conn = Connection.new(justiciero)
        conn.login
        unless user_id
          user = conn.get_profile_by_tweet(tweet_id)
          user_id = user[:user_id]
        end
        conn.retweet(tweet_id, user_id, msg)
        conn.logout
      rescue Interrupt
        raise
      rescue Exception
        p "Problems with #{justiciero}"
        p $!
      end
    end
  end

  desc 'Use the Wolfpack to follow somebody'
  task pack_follow: :environment do
    username = ENV['account']
    unless username
      p 'Account missing'
      exit
    end
    user_id = ENV['user_id']

    justicieros = TwList.item_array(LIGA_JUSTICIA).shuffle
    justicieros.each_with_index do |justiciero, index|
      begin
        p "[#{index}] #{justiciero}"

        conn = Connection.new(justiciero)
        conn.login
        unless user_id
          user = conn.get_profile(username)
          user_id = user[:user_id]
        end
        conn.follow(user_id)
        conn.logout
      rescue Interrupt
        raise
      rescue Exception
        p "Problems with #{justiciero}"
        p $!
      end
    end
  end

  def get_random_quote(max_size = 0, retries = 10)
    text = nil
    retries.times do
      quotes = nil
      until quotes
        page = open('https://es.wikiquote.org/wiki/Especial:Aleatoria')
        p page.base_uri.to_s
        body = Nokogiri::HTML page
        quotes = body.css('div#mw-content-text/ul/li')
      end
      quote = quotes.to_a.sample
      if quote
        quote.children.each do |child|
          if child.name == 'ul'
            child.remove
          end
        end
        text = quote.text.squish.strip
        text.gsub!(/\"/, '')
        pre = text
        loop do                              # AWESOME nested [] regex
          text.gsub!(/\[([^\[\]]*)\]/, '')
          break if text == pre
        end
        # text += '.' unless text.last == '.'
        break unless max_size > 0 and text.length > max_size
      end
    end
    text
  end

  desc 'Bot Warfare'
  task warfare: :environment do
    down_proxies = []
    total_war = ENV['total']

    logger = Logger.new(STDOUT)
    delays = {
        # Secs to remain logged in
        rest: lambda { rand(3600..21600) },
        # Secs to remain logged out
        act: lambda { rand(1800..3600) },
        # Secs to wait in between requests
        request: nil,

        tweet: lambda { rand(30..90) },

        quote: lambda { rand(5000..25000) },
        retweet: lambda { rand(1000..5000) }
    }

    study_all = TwStudy.get_or_create('justicieros @ all')
    study_last = TwStudy.get_or_create('justicieros @ last')
    study_last.stats.destroy_all

    errors = {}
    conns = []
    begin
      justicieros = TwList.item_array(LIGA_JUSTICIA).shuffle
      justicieros.each_with_index do |justiciero, index|
        begin
          begin
            p "[#{index}] #{justiciero}"

            conn = Connection.new(justiciero)
            proxy = conn.account.proxy
            if down_proxies.include? proxy
              p "Proxy #{proxy} down. Skipping."
              next
            end
            conn.login
          rescue CannotLogin => ex
            raise unless ex.code == :locked and total_war
            unlock = true
            loop do
              p "Unlock #{justiciero} (#{conn.account.phone}) [y/n]?"
              unlock = STDIN.gets.chomp
              break if unlock == 'y' or unlock == 'n'
            end
            raise unless unlock == 'y'
            conn = Connection.new(justiciero)
            raise unless conn.unlock
          end

          conn.logger = logger
          conn.delays = delays
          conn.studies.push study_all
          conn.studies.push study_last
          conn.next_time :quote
          conn.next_time :retweet
          conns.push conn
          errors[justiciero] = 0
        rescue Interrupt
          raise
        rescue Exception
          p "Problems with #{justiciero}"
          p $!
        end
      end

      list_name = ENV['list']
      list = TwList.find_by_name(list_name)
      unless list
        p 'List not found'
        exit
      end

      templates = [
          '¿Esto es lo que queremos del medio de comunicación que seguimos?',
          '¿Encarnan las acciones de elEconomista los valores que dice representar?',
          '¿Vas a seguir leyendo elEconomista como si nada después de esto?',
          'La ética de elEconomista severamente cuestionada por sus actos.',
          'Inaceptable comportamiento de elEconomista narrado por su antigua estrella.',
          '¡Basta ya! ¡Queremos un elEconomista coherente con sus principios!',
          'Hace falta mucha cara, señores de elEconomista, para salir a la calle tras esto.',
          'Conocíamos los principios de elEconomista. Ahora conocemos sus actos.',
          '¿Qué se puede esperar de elEconomista? Con este comportamiento muy poco.',
          'Hagamos algo para que a los que dan lecciones se les exija coherencia.',
          'Alucinante testimonio del antiguo referente de elEconomista. Alucinante.',
          'Inmoral comportamiento de elEconomista narrado por un ex muy top.',
          'Es indignante. Hay que limpiar medios como elEconomista.',
          '¡Basta ya de corrupción y mentiras! elEconomista tiene que pagar.',
          'elEconomista matando a sus empleados. Por sus actos les conoceréis.',
          'elEconomista, medio con principios, machacando a su trabajadores.',
          'Increíble que esto pase en un medio en España... o no.',
          'Joder con elEconomista, qué nivel. Lee a este valiente y juzga por tí.',
          'Mama mía los de elEconomista, parece que juegan muy sucio.',
          'En elEconomista se les tendría que caer la cara de vergüenza.'
      ]

      hashtags = [
          '',
          '#ecojonante',
          '#inmoral',
          '#medioslimpios',
          '#ecotimo'
      ]

      pleas = [
          '',
          'comparte',
          'lee y comparte PF',
          'hay que compartir',
          'colabora por favor',
          'por favor, ayuda',
          'por favor comparte',
          'ayuda, comparte',
          'comparte por favor',
          'comparte y ayuda',
          'colabora, comparte',
          'comparte. Gracias',
          'reenvia. Gracias',
          'ayuda, gracias',
          'colabora, reenvia',
          'lee y reenvia PF',
          'por favor, reenvia',
          'lee y colabora',
          'reenvia',
          'ayuda'
      ]

      # noinspection RubyLiteralArrayInspection
      links = [
          'https://carlosdoblado.com/2016/05/24/traicion-mentiras-y-corrupcion-en-eleconomista',
          # 'https://carlosdoblado.com/2016/06/01/2014-una-indecente-odisea-en-eleconomista',
          'https://carlosdoblado.com/2016/06/13/y-eleconomista-al-servicio-de-podemos'
      ]

      leads = list.lines

      loop do
        action = false
        p "Active conns: #{conns.size}"
        conns.each do |conn|
          active = false
          begin
            if conn.allowed? :tweet
              if conn.allowed? :quote
                quote = get_random_quote(140)
                #pic_url = 'http://lorempixel.com/880/440'
                #pic_id = conn.upload_media(pic_url)
                pic_id = nil
                active = conn.tweet(quote, pic_id)
                conn.next_time :quote
                conn.stats_add :quote
              else
                #lead = list.lines.order('created_at ASC').first
                lead = leads.last
                if lead
                  begin
                    if conn.allowed? :retweet
                      active = conn.retweet_last(lead.item)
                      conn.next_time :retweet
                      conn.stats_add :retweet
                    else
                      mention = "@#{lead.item}"

                      parts = []
                      msg_size = 140
                      while msg_size > 115
                        parts.clear
                        parts.push templates.sample
                        parts.push hashtags.sample
                        parts.push "#{[pleas.sample, mention].shuffle.join(' ')}.".capitalize
                        #mention = mention.gsub(/%/, "@#{item}")
                        msg = parts.shuffle.join(' ')
                        msg_size = msg.size
                      end

                      parts.push links.sample
                      message = parts.shuffle.join(' ')
                      active = conn.tweet(message)
                    end
                  rescue KnownIssue
                    p $!
                  end
                  lead.destroy
                else
                  p 'No more people to engage'
                  exit
                end
              end
            end
          rescue CannotDo
            p $!
          rescue Interrupt
            raise
          rescue Exception
            begin
              p $!
            rescue
              p 'Error printing the error :P'
            end
            errors[conn.account.username] += 1
            if errors[conn.account.username] > 5
              conn.shutdown
              conns.delete conn
            end
          end

          if active
            errors[conn.account.username] = 0
            action = true
          end
        end

        unless action
          p 'Nothing going on'
          sleep(10)
        end
      end
    ensure
      conns.each do |conn|
        conn.shutdown
      end
    end
  end

  task all: :environment do

  end

end