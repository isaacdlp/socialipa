require 'open-uri'
require 'csv'

TW_URL = 'https://twitter.com'

USER_AGENTS = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.6 Safari/537.11',
    'Mozilla/5.0 (Macintosh; PPC Mac OS X 10_5_8) AppleWebKit/537.1+ (KHTML, like Gecko) iCab/5.0 Safari/533.16',
    'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.19 (KHTML, like Gecko) Chrome/11.0.661.0 Safari/534.19',
    'Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/3.0.197.0 Safari/532.0',
    'Mozilla/5.0 (X11; U; Linux MIPS32 1074Kf CPS QuadCore; en-US; rv:1.9.2.13) Gecko/20110103 Fedora/3.6.13-1.fc14 Firefox/3.6.13',
    'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/3.0.197.0 Safari/532.0',
    'Mozilla/5.0 (Windows; U; Windows NT 6.0 x64; en-US; rv:1.9.1b2pre) Gecko/20081026 Firefox/3.1b2pre',
    'Mozilla/5.0 (Windows; U; Windows NT 5.1; fr-FR) AppleWebKit/525.28 (KHTML, like Gecko) Version/3.2.2 Safari/525.28.1',
    'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/533.3 (KHTML, like Gecko) Chrome/5.0.356.0 Safari/533.3',
    'Mozilla/5.0 (Windows; U; Windows NT 5.0; de-AT; rv:1.8.0.8) Gecko/20061030 SeaMonkey/1.0.6'
]

class JSONParser < Mechanize::File
  attr_reader :json

  def initialize(uri = nil, response = nil, body = nil, code = nil)
    super uri, response, body, code
    @json = JSON.parse(body)
  end
end

class Mechanize::HTTP::Agent
  MAX_RESET_RETRIES = 10

  # We need to replace the core Mechanize HTTP method:
  #
  #   Mechanize::HTTP::Agent#fetch
  #
  # with a wrapper that handles the infamous "too many connection resets"
  # Mechanize bug that is described here:
  #
  #   https://github.com/sparklemotion/mechanize/issues/123
  #
  # The wrapper shuts down the persistent HTTP connection when it fails with
  # this error, and simply tries again. In practice, this only ever needs to
  # be retried once, but I am going to let it retry a few times
  # (MAX_RESET_RETRIES), just in case.
  #
  def fetch_with_retry(
      uri,
      method    = :get,
      headers   = {},
      params    = [],
      referer   = current_page,
      redirects = 0
  )
    action      = "#{method.to_s.upcase} #{uri.to_s}"
    retry_count = 0

    begin
      fetch_without_retry(uri, method, headers, params, referer, redirects)
    rescue Net::HTTP::Persistent::Error => e
      # Pass on any other type of error.
      raise unless e.message =~ /too many connection resets/

      # Pass on the error if we've tried too many times.
      if retry_count >= MAX_RESET_RETRIES
        puts "**** WARN: Mechanize retried connection reset #{MAX_RESET_RETRIES} times and never succeeded: #{action}"
        raise
      end

      # Otherwise, shutdown the persistent HTTP connection and try again.
      puts "**** WARN: Mechanize retrying connection reset error: #{action}"
      retry_count += 1
      self.http.shutdown
      retry
    end
  end

  # Alias so #fetch actually uses our new #fetch_with_retry to wrap the
  # old one aliased as #fetch_without_retry.
  alias_method :fetch_without_retry, :fetch
  alias_method :fetch, :fetch_with_retry
end

class KnownIssue < Exception
  attr_reader :code
  def initialize(msg, code)
    @code = code
    super(msg)
  end
end

class CannotLogin < KnownIssue
end

class CannotDo < Exception
end

class CannotAct < CannotDo
end

class Connection

  attr_reader :account, :token, :user_id, :times, :studies, :stats
  attr_accessor :logger, :delays
  attr_accessor :logger, :delays

  def self.write(page, file_name)
    File.open(file_name, 'wb') do |file|
      file.write page.body
    end
  end

  # MAINTENANCE Actions

  def self.create(full_name, email, password, description, proxy = false, phone = nil, agent = nil, user_agent = nil, delay = nil, record = true)
    account = nil

    delay = lambda{ rand(5..10) } unless delay
    log_folder = "#{Rails.root}/log"

    user_agent = USER_AGENTS.sample unless user_agent
    p "Using agent #{user_agent}"
    unless agent
      agent = Mechanize.new
      agent.pluggable_parser['application/json'] = JSONParser
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    agent.user_agent = user_agent

    unless phone
      offset = rand(TwPhone.count)
      phone = TwPhone.offset(offset).first.nickname
    end
    phone = TwPhone.find_by_nickname(phone)
    p "Using phone #{phone.nickname}"

    if proxy == true
      offset = rand(TwProxy.count)
      proxy = TwProxy.offset(offset).first.nickname
    end
    if proxy != false
      proxy = TwProxy.find_by_nickname(proxy)
      p "Using proxy #{proxy.nickname}"
      agent.set_proxy(proxy.host, proxy.port, proxy.username, proxy.password)
    end

    page = agent.get "#{TW_URL}/signup"
    write(page, "#{log_folder}/create_1_signup.html") if record

    p "#{full_name} [1] Signup"
    sleep(delay.call.seconds)

    form = page.form_with(id: 'phx-signup-form')
    if form
      form.field_with(id: 'full-name').value = full_name
      form.field_with(id: 'email').value = email
      form.field_with(id: 'password').value = password

      page = agent.submit form
      write(page, "#{log_folder}/create_2_enter_mobile.html") if record

      p "#{full_name} [2] Enter Mobile"
      sleep(delay.call.seconds)

      #page = page.link_with(class: 'skip-link').click

      form = page.form_with(id: 'sms-phone-create-form')
      if form
        form.field_with(id: 'device_country_code').value = phone.code
        form.field_with(id: 'device_address').value = phone.number
      else
        form = page.form_with(class: 'Form')
        form.field_with(id: 'country_code').value = phone.code
        form.field_with(id: 'phone_number').value = phone.number
        form.checkbox_with(name: 'discoverable_by_mobile_phone').uncheck
      end

      page = agent.submit form
      write(page, "#{log_folder}/create_3_enter_code.html") if record

      field = nil
      form = page.form_with(id: 'verify-form')
      if form
        field = form.field_with(id: 'verify_code')
      else
        form = page.form_with(class: 'Form')
        if form
          field = form.field_with(id: 'code')
        end
      end

      if field
        p "#{full_name} [3] Enter Mobile Code or [skip]:"
        code = STDIN.gets.chomp

        if code == 'skip'
          p 'Skipping...'
        else
          field.value = code

          page = agent.submit form
          write(page, "#{log_folder}/create_4_code_entered.html") if record

          p "#{full_name} [4] Code Entered"
        end
      else
        el_text = page.at('div.TextGroup-text')

        p "#{full_name} [3][4] #{el_text.text.strip}"
      end

      p "#{full_name} [5] Enter Email Uri or [skip]:"
      uri = STDIN.gets.chomp

      if uri == 'skip'
        p 'Skipping...'
      else
        page = agent.get uri
        write(page, "#{log_folder}/create_5_validated.html") if record

        p "#{full_name} [5] Account Validated"
        sleep(delay.call.seconds)
      end

      page = agent.get "#{TW_URL}"
      write(page, "#{log_folder}/create_6_username.html") if record

      p "#{full_name} [6] Get Username"
      el_username = page.at('div.js-mini-current-user')
      if el_username
        username = el_username.attribute('data-screen-name').value
        p "#{full_name} [6] Username @#{username}"

        account = TwAccount.new
        account.username = username
        account.email = email
        account.password = password
        account.agent = user_agent
        account.proxy = proxy.nickname if proxy
        account.phone = phone.nickname
        account.description = description
        account.save!
      else
        p "#{full_name} [6] Username not found. Aborting"
      end
    else
      p "#{full_name} [2][3][4][5][6] Did not find form. Aborting"
    end

    account
  end

  def unlock(delay = nil, record = true)
    delay = lambda{ rand(0..5) } unless delay
    log_folder = "#{Rails.root}/log"

    full_name = @account.username

    locked = false
    begin
      login
    rescue CannotLogin => ex
      raise unless ex.code == :locked
      locked = true
    end

    unless locked
      p "#{full_name} does not appear to be locked"
      return false
    end

    page = @agent.get "#{TW_URL}/account/access"
    self.class.write(page, "#{log_folder}/unlock_1_access.html") if record

    p "#{full_name} [1] Access"
    sleep(delay.call.seconds)

    form = page.form_with(action: '/account/access')
    unless form
      p "#{full_name} Can't find form"
      return false
    end

    page = form.submit
    self.class.write(page, "#{log_folder}/unlock_2_send_code.html") if record

    phone = page.at('div.TextGroup-text b').text
    p "#{full_name} [2] Send Code to #{phone}"
    sleep(delay.call.seconds)

    form = page.form_with(class: 'Form')
    unless form
      p "#{full_name} Can't find form"
      return false
    end

    page = form.submit
    self.class.write(page, "#{log_folder}/unlock_3_enter_code.html") if record

    p "#{full_name} [3] Enter code or [skip]:"
    code = STDIN.gets.chomp

    if code == 'skip'
      p 'Skipping...'
      return false
    end

    form = page.form_with(class: 'Form')
    unless form
      p "#{full_name} Can't find form"
      return false
    end
    form.field_with(id: 'code').value = code

    page = form.submit
    self.class.write(page, "#{log_folder}/unlock_4_status.html") if record

    status = page.at('div.PageHeader').text.squish.strip
    p "#{full_name} [4] Status #{status}"
    sleep(delay.call.seconds)

    form = page.form_with(action: '/account/access')
    unless form
      p "#{full_name} Can't find form"
      return false
    end

    page = form.submit
    self.class.write(page, "#{log_folder}/unlock_5_done.html") if record

    p "#{full_name} [5] Done"
    @account.status = :ok
    @account.save!
    true
  end

  # INIT Actions

  def initialize(username, agent = nil)
    account = TwAccount.find_by_username(username)
    unless account
      raise "Account #{username} not found"
    end
    @account = account
    unless agent
      agent = Mechanize.new
      agent.pluggable_parser['application/json'] = JSONParser
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
      if @account.agent
        user_agent = @account.agent
      end
      agent.user_agent = user_agent

      proxy = TwProxy.find_by_nickname(@account.proxy)
      if proxy
        agent.set_proxy(proxy.host, proxy.port, proxy.username, proxy.password)
      end
    end
    @agent = agent

    @logger = Rails.logger

    @delays = {
        # Secs to remain logged in
        rest: lambda { rand(3600..21600) },
        # Secs to remain logged out
        act: lambda { rand(1800..3600) },
        # Secs to wait in between requests
        request: lambda { rand(0..5) },

        edit_profile: lambda { rand(5..10) },
        tweet: lambda { rand(30..90) },
        untweet: lambda { rand(10..60) },
        follow: lambda { rand(30..90) },
        unfollow: lambda { rand(10..60) },
        like: lambda { rand(10..60) },
        unlike: lambda { rand(5..30) },
        create_list: lambda { rand(90..360) },
        edit_list: lambda { rand(90..360) },
        delete_list: lambda { rand(30..90) },
        add_to_list: lambda { rand(10..60) },
        delete_from_list: lambda { rand(5..30) },
    }
    @times = {}
    @total_start = Time.now

    @studies = []
    @stats = {}
  end

  # STATUS Actions

  def known_issue?(ex)
    case ex.response_code
    when '404'
      raise KnownIssue.new('HTTP Not Found', :http404)
    #when '503'
      #raise KnownIssue.new('HTTP Service Unavailable', :http503)
    else
      raise ex
    end
  end

  def allowed?(event, ready = false, offline = false)
    unless offline
      if @times[:act]
        if @times[:act] <  Time.now
          @times[:act] = nil
          login
        else
          raise(CannotAct, "#{@account.username} cannot act") if ready
          return false
        end
      elsif @times[:rest]
        if @times[:rest] < Time.now
         @times[:rest] = nil
         logout
         raise(CannotAct, "#{@account.username} cannot act") if ready
         return false
        end
      end
    end

    if @times[event] and @times[event] > Time.now
      raise(CannotDo, "#{@account.username} cannot do #{event}") if ready
      return false
    end

    if ready
      # login unless logged?
      wait_until(:request)
    end
    true
  end

  def next_time(event)
    @times[event] = nil
    if @delays[event]
      @times[event] = Time.now + @delays[event].call.seconds
    end
    @times[event]
  end

  def secs_until(event)
    secs = 0
    if @times[event]
      secs = @times[event] - Time.now
      secs += 1
      if secs < 0
        secs = 0
      end
    end
    secs
  end

  def wait_until(event)
    secs = secs_until(event)
    sleep(secs) if secs > 0
    next_time(event) if event == :request
  end

  # ACCESS Actions

  def login
    logout if @token

    log 'Log in'

    page = @agent.get("#{TW_URL}/login")
    search_form = page.form_with(action: "#{TW_URL}/sessions")
    search_form.field_with(name: 'session[username_or_email]').value = @account.username
    search_form.field_with(name: 'session[password]').value = @account.password

    page = @agent.submit search_form

    @token = nil
    el_token = page.at('form#sms-confirmation-begin-form input#authenticity_token')
    if el_token
      @token = el_token.attribute('value').value
    end

    if @token
      el_msg = page.at('div#account-suspended span.title')          # Account suspended
      if el_msg
        error_msg = el_msg.text.strip
        log error_msg
        @account.status = :suspended
        @account.save!
        raise CannotLogin.new(error_msg, :suspended)
      end
    else
      error_msg = ''
      el_msg = page.at('div#message-drawer span.message-text')      # Unknown error
      code = :unknown
      unless el_msg
        el_msg = page.at('div.PageHeader') unless el_msg            # Account locked
        code = :locked
      end
      if el_msg
        error_msg = el_msg.text.strip
      end
      error_msg = "Failure logging in #{@account.username}: #{error_msg}"
      log error_msg
      @account.status = code
      @account.save!
      raise CannotLogin.new(error_msg, code)
    end

    @user_id = page.at('li#user-dropdown img.avatar').attribute('data-user-id').value

    @session_start = Time.now
    next_time :rest
    stats_add :login

    @account.status = :ok
    @account.save!
    true
  end

  def logout
    if @token
      log 'Log out'

      if @session_start
        session_time = Time.now - @session_start
        stats_add :time_online, session_time
        @session_start = nil
      end

      @agent.post("#{TW_URL}/logout", {
          authenticity_token: @token,
          reliability_event: '',
          scribe_log: ''
      })
      @token = nil

      next_time :act
    else
      log 'Not logged in'
    end

    true
  end

  def shutdown
    logout if @token

    if @total_start
      total_time = Time.now - @total_start
      stats_add :time_total, total_time
    end

    studies.each do | study |
      stats.each do |concept, value|
        study.add(concept, value)
      end
    end
  end

  # PROFILE Actions

  def get_if_needed(target_page)
    begin
      page = @agent.page
      if page and page.uri.to_s == target_page
        return page
      end

      wait_until(:request)

      return @agent.get target_page
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def logged?
    status = test_logged(@agent.page)
    if status == nil
      status = test_logged(get_if_needed "#{TW_U}/#{@account.username}")
    end
    #logged = @agent.page.at('a#user-dropdown-toggle')
    status
  end

  def test_logged(page)
    status = nil
    if page
      el_body = @agent.page.at('body')
      if el_body
        el_class = el_body.attribute('class')
        if el_class
          if el_class.value.include? 'logged-in'
            return true
          elsif el_class.value.include? 'logged-out'
            return false
          end
        end
      end
    end
    status
  end

  def get_username(user_id)
    page = get_if_needed "#{TW_URL}/intent/user?user_id=#{user_id}"

    el_field = page.at('span.nickname')
    if el_field
      return el_field.text[1..-1]
    end
    nil
  end

  def get_profile(target_user, extended = false)
    log "Get profile #{target_user}"
    get_profile_by_uri("#{TW_URL}/#{target_user}", extended)
  end

  def get_profile_by_tweet(tweet_id)
    log "Get profile behind tweet #{tweet_id}"
    get_profile_by_uri("#{TW_URL}/anyuser/status/#{tweet_id}", false)
  end

  def get_profile_by_uri(target_uri, extended = false)
    begin
      # login if logged and not logged?

      page = get_if_needed target_uri

      raise KnownIssue.new('User suspended', :suspended) if page.at('div.route-account_suspended')
      raise KnownIssue.new('User blocked you', :blocks_me) if page.at('div.BlocksYouTimeline')

      user = {}
      el_user = page.at('div.user-actions')

      raise KnownIssue.new('Own profile?', :own_profile) unless el_user       # No 'follow' on own profile

      user[:user_id] = el_user.attribute('data-user-id').value
      # user[:user_id] = page.at('div.ProfileNav').attribute('data-user-id').value
      user[:username] = el_user.attribute('data-screen-name').value
      # user[:username] = target_user
      user[:name] = el_user.attribute('data-name').value
      # user[:name] = page.at('a.ProfileHeaderCard-nameLink').text
      user[:protected] = el_user.attribute('data-protected').value == 'true'
      # user[:protected] =  page.at('div.ProtectedTimeline') ? true : false
      classes = el_user.attribute('class').value
      user[:block_him] = classes.include? ' blocked '
      user[:follow_him] = classes.include? ' following '
      user[:follows_me] = page.at('span.FollowStatus') ? true : false

      return user unless extended

      user[:mute_him] = classes.include? ' muting '
      user[:verified] = page.at('span.Icon--verified') ? true : false
      user[:bio] = page.at('p.ProfileHeaderCard-bio').text
      user[:avatar] = page.at('a.ProfileAvatar-container').attribute('href').value

      location = nil
      el_location = page.at('span.ProfileHeaderCard-locationText')
      if el_location
        location = el_location.text
        location.strip!
      end
      user[:location] = location

      user[:join_time] = page.at('span.ProfileHeaderCard-joinDateText').attribute('title').value

      [:tweets, :following, :followers, :favorites, :lists].each do |key|
        value = 0
        el_value = page.at("li.ProfileNav-item--#{key} span.ProfileNav-value")
        if el_value
          value = el_value.text
          if value.end_with? 'K'
            value = value[0..-2].to_f * 1000
          elsif value.end_with? 'M'
            value = value[0..-2].to_f * 1000000
          end
        end
        user[key] = value.to_i
      end
      return user
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def get_geo_profile
    allowed?(:edit_profile, true)

    begin
      locations = []
      resp = @agent.get "#{TW_URL}/account/geo_profile"
      resp_html = Nokogiri::HTML resp.json['html']
      resp_html.css('li.GeoSearch-result').each do |node|
        location = {}
        location[:place_id] = node['data-place-id']
        location[:place_name] = node.text
        locations.push location
      end

      next_time :edit_profile
      stats_add :edit_profile

      return locations
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def edit_profile(full_name = nil, description = nil, birthday = nil, bday_visibility = false, byear_visibility = false, place_name = nil, place_id = nil, website = nil, color = nil)
    allowed?(:edit_profile, true)

    begin
      log 'Edit profile'

      payload = {
          authenticity_token: @token
      }
      payload['user[name]'] = full_name[0..20] if full_name
      payload['user[description]'] = description[0..160] if description
      if birthday
        payload['user[birthdate][birthday_visibility]'] = bday_visibility ? 1 : 0
        payload['user[birthdate][birthyear_visibility]'] = byear_visibility ? 1 : 0
        payload['user[birthdate][day]'] = birthday.day
        payload['user[birthdate][month]'] = birthday.month
        payload['user[birthdate][year]'] = birthday.year
      end
      payload['user[location]'] = place_name if place_name
      payload['user[location_place_id]'] = place_id if place_id
      payload['user[url]'] = website if website
      payload['user[profile_link_color]'] = color if color

      @agent.post("#{TW_URL}/i/profiles/update", payload)

      next_time :edit_profile
      stats_add :edit_profile

    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def edit_profile_image(type, media_id)
    # type 'avatar' or 'header'
    allowed?(:edit_profile, true)

    begin
      log "Edit #{type} with #{media_id}"

      url = "#{TW_URL}/i/profiles/update_profile_image"
      url = "#{TW_URL}/i/profiles/update_profile_banner" if type == 'header'

      get_if_needed "#{TW_URL}/#{@account.username}"

      page = @agent.post(url, {
        authenticity_token: @token,
        mediaId: media_id,
        page_context: 'me',
        section_context: 'profile',
        uploadType: type
        #fileData: Base64.encode64(open(media_url) { |io| io.read }),
        #fileName: media_url,
        #height: 512 535,
        #offsetLeft: '0',
        #offsetTop: '0',
        #'scribeContext[page]' => 'me',
        #'scribeContext[component]' => 'profile_image_upload' 'header_image_upload',
        #'scribeContext[section]' => 'profile',
        #scribeElement: 'upload',
        #width: 512 1604,
      })

      next_time :edit_profile
      stats_add :edit_profile

      return true if page.json['useStatusAsImgUrl']
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def protected?(target_user)
    page = get_if_needed "#{TW_URL}/#{target_user}"
    if page.at('div.ProtectedTimeline')
      return true
    end
    false
  end

  def suspended?(target_user)
    page = get_if_needed "#{TW_URL}/#{target_user}"
    if page.at('div.route-account_suspended')
      return true
    end
    false
  end

  def get_last_tweet_id(target_user)
    page = get_if_needed "#{TW_URL}/#{target_user}"
    last_tweet = page.at('.js-stream-item')
    return false unless last_tweet
    last_tweet['data-item-id']
  end

  # SETTINGS Actions

  def name_available?(username, suggest = false)
    wait_until(:request)

    begin
      raise 'Max Twitter username size is 15' if username.size > 15

      # noinspection RubyStringKeysInHashInspection
      headers = {
          'accept' => 'application/json',
          'x-requested-with' => 'XMLHttpRequest'
      }

      payload = {
          # context: 'signup',
          custom: true,
          suggest: suggest ? 1 : 0,
          suggest_on_username: suggest,
          username: username
      }

      page = @agent.get("#{TW_URL}/users/username_available", payload, "#{TW_URL}/settings/accounts", headers)

      suggested = []
      suggestions = page.json['suggestions']
      if suggestions
        suggestions.each do |suggestion|
          suggested.push suggestion['suggestion']
        end
      end

      return page.json['valid'], suggested if suggest
      return page.json['valid']
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def edit_settings(username)
    raise 'You must be logged in!' unless @token
    allowed?(:edit_profile, true)

    begin
      log "Edit settings with username #{username}"

      # noinspection RubyStringKeysInHashInspection
      page = @agent.post("#{TW_URL}/settings/accounts/update", {
          _method: 'PUT',
          auth_password: @account.password,
          authenticity_token: @token,
          section_context: 'profile',
          orig_uname: @account.username,
          'user[screen_name]' => username
      })

      @account.username = username
      @account.save!

      next_time :edit_profile
      stats_add :edit_profile

      return true
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  # TWEET Actions

  def upload_media(media_url)
    wait_until(:request)

    begin
      log "Upload #{media_url}"

      media = Base64.encode64(open(media_url,'rb') { |io| io.read })
      if media
        resp = @agent.post('https://upload.twitter.com/i/media/upload.iframe?origin=https%3A%2F%2Ftwitter.com', {
            authenticity_token: @token,
            media: media,
            origin: TW_URL
        })

        img_html = resp.at('#responseJson').attribute('value').value
        img_json = JSON.parse(img_html)

        media_id = img_json['media_id']
        if media_id
          log "Upload successful. Media ID: #{media_id}"
          return media_id
        end
      end
      log 'ERROR Uploading Media'
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def tweet(message, media_ids = nil)
    allowed?(:tweet, true)

    begin
      log "Tweet '#{message}'"

      payload = {
          authenticity_token: @token,
          is_permalink_page: false,
          page_context: 'profile',
          place_id: '',
          status: message,
          tagged_users: ''
      }

      payload[:media_ids] = media_ids if media_ids

      resp = @agent.post("#{TW_URL}/i/tweet/create", payload)

      next_time :tweet
      stats_add :tweet

      tweet_id = resp.json['tweet_id']
      if tweet_id
        return tweet_id
      end
      log 'ERROR Tweeting'
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def untweet(tweet_id)
    allowed?(:untweet, true)

    begin
      log "Untweet #{tweet_id}"

      @agent.post("#{TW_URL}/i/tweet/destroy", {
          _method: 'DELETE',
          authenticity_token: @token,
          id: tweet_id,
      })

      next_time :untweet
      stats_add :untweet

      return true
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def retweet(target_tweet_id, target_user = nil, message = nil, media_ids = nil)
    allowed?(:tweet, true)

    begin
      uri = nil
      el_id = nil
      if message
        log "Retweet #{target_tweet_id} from #{target_user} with '#{message}'"
        return false unless target_user   # required only if message attached
        payload = {
            authenticity_token: @token,
            attachment_url: "https://twitter.com/#{target_user}/status/#{target_tweet_id}",
            page_context: 'profile',
            status: message
        }
        uri = "#{TW_URL}/i/tweet/create"
        el_id = 'tweet_id'
      else
        log "Retweet #{target_tweet_id}"
        payload = {
            authenticity_token: @token,
            id: target_tweet_id
        }
        uri = "#{TW_URL}/i/tweet/retweet"
        el_id = 'retweet_id'
      end

      payload[:media_ids] = media_ids if media_ids

      resp = @agent.post(uri, payload)

      next_time :tweet
      stats_add :tweet

      # resp_json = JSON.parse(resp.body)
      retweet_id = resp.json[el_id]
      if retweet_id
        return retweet_id
      end
      log 'ERROR Retweeting'
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def retweet_last(target_user, message = nil)
    tweet_id = get_last_tweet_id(target_user)
    return false unless tweet_id
    retweet(tweet_id, target_user, message)
  end

  # LIKE Actions

  def like(tweet_id)
    allowed?(:like, true)

    begin
      log "Like #{tweet_id}"

      @agent.post("#{TW_URL}/i/tweet/like", {
          authenticity_token: @token,
          id: tweet_id
          #tweet_stat_count: 1     # not checked anyway
      })

      next_time :like
      stats_add :like

      return true
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def unlike(tweet_id)
    allowed?(:unlike, true)

    begin
      log "Unlike #{tweet_id}"

      @agent.post("#{TW_URL}/i/tweet/unlike", {
          authenticity_token: @token,
          id: tweet_id
          #tweet_stat_count: 1     # not checked anyway
      })

      next_time :unlike
      stats_add :unlike

      return true
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def like_last(target_user)
    tweet_id = get_last_tweet_id(target_user)
    return false unless tweet_id
    like(tweet_id)
  end

  # FOLLOW Actions

  def follow(user_id)
    allowed?(:follow, true)

    begin
      log "Follow #{user_id}"

      resp = @agent.post("#{TW_URL}/i/user/follow", {
          authenticity_token: @token,
          challenges_passed: false,
          handles_challenges: 1,
          impression_id: '',
          inject_tweet: false,
          user_id: user_id
      })

      next_time :follow
      stats_add :follow

      if resp.json['new_state'] == 'following'
        return true
      end
      log "ERROR following #{user_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def unfollow(user_id)
    allowed?(:unfollow, true)

    begin
      log "Unfollow #{user_id}"

      resp = @agent.post("#{TW_URL}/i/user/unfollow", {
          authenticity_token: @token,
          challenges_passed: false,
          handles_challenges: 1,
          impression_id: '',
          inject_tweet: false,
          user_id: user_id
      })

      next_time :unfollow
      stats_add :unfollow

      if resp.json['new_state'] == 'not-following'
        return true
      end
      log "ERROR unfollowing #{user_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  # LIST Actions

  def create_list(name, public, description = '')
    allowed?(:create_list, true)

    begin
      log "Create list #{name}"

      resp = @agent.post("#{TW_URL}/i/lists/create", {
          authenticity_token: @token,
          description: description,
          mode: public ? 'public' : 'private',
          name: name,
      })

      next_time :create_list
      stats_add :create_list

      slug = resp.json['slug']

      if slug
        page = @agent.post("#{TW_URL}/#{@account.username}/lists/#{slug}")
        list_details = page.at('div.js-list-details')
        if list_details
          list_id = list_details['data-list-id']
          log "Created as #{slug} #{list_id}"
          return list_id
        end
      end
      log "ERROR creating list #{name}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def edit_list(list_id, name, public, description = '')
    allowed?(:edit_list, true)

    begin
      log "Edit list #{list_id}"

      resp = @agent.post("#{TW_URL}/i/lists/update", {
          authenticity_token: @token,
          description: description,
          list_id: list_id,
          mode: public ? 'public' : 'private',
          name: name,
      })

      next_time :edit_list
      stats_add :edit_list

      slug = resp.json['slug']

      if slug
        page = @agent.post("#{TW_URL}/#{@account.username}/lists/#{slug}")
        list_details = page.at('div.js-list-details')
        if list_details
          list_id = list_details['data-list-id']
          log "Edited as #{slug} #{list_id}"
          return list_id
        end
      end
      log "ERROR editing list #{list_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def delete_list(list_id)
    allowed?(:delete_list, true)

    begin
      log "Delete list #{list_id}"

      resp = @agent.post("#{TW_URL}/i/lists/destroy.json", {
          authenticity_token: @token,
          list_id: list_id,
      })

      next_time :delete_list
      stats_add :delete_list

      if resp.code == '200'
        return true
      end
      log "ERROR deleting list #{list_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def add_to_list(user_id, list_id)
    allowed?(:add_to_list, true)

    begin
      log "Add #{user_id} to list #{list_id}"

      resp = @agent.post("#{TW_URL}/i/#{user_id}/lists/#{list_id}/members", {
          authenticity_token: @token
      })

      next_time :add_to_list
      stats_add :add_to_list

      if resp.code == '200'
        return true
      end
      log "ERROR adding #{user_id} to list #{list_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def delete_from_list(user_id, list_id)
    allowed?(:delete_from_list, true)

    begin
      log "Delete #{user_id} from list #{list_id}"

      resp = @agent.post("#{TW_URL}/i/#{user_id}/lists/#{list_id}/members", {
          _method: 'DELETE',
          authenticity_token: @token
      })

      next_time :delete_from_list
      stats_add :delete_from_list

      if resp.code == '200'
        return true
      end
      log "ERROR deleting #{user_id} from list #{list_id}"
      return false
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  # DIRECT MESSAGE Actions

  def message(recipient_id, text = nil, media_id = nil)
    #DateTime.now.strftime('%s') # "1384526946" (seconds)
    #DateTime.now.strftime('%Q') # "1384526946523" (milliseconds)

    allowed?(:message, true)

    begin
      log "Message to #{recipient_id}"

      payload = {
          authenticity_token: @token
      }
      if recipient_id.kind_of? Array
        # Not implemented!
        # payload['recipient_ids[]'] = recipient_ids
      else
        payload[:conversation_id] = "#{@user_id}-#{recipient_id}"
      end

      payload[:text] = text if text   # no size limit (but only 1 image)
      if media_id
        payload[:media_id] = media_id
        get_if_needed TW_URL     # to set the referer
      end

      @agent.post('https://twitter.com/i/direct_messages/new', payload)

      next_time :message
      stats_add :message

      return true
    rescue Mechanize::ResponseCodeError => ex
      known_issue? ex
    end
  end

  def download_messages
    # Not implemented!
    # @agent.request_headers = { ... }
    # noinspection RubyStringKeysInHashInspection
    headers = {
        'accept' => 'application/json',
        'x-requested-with' => 'XMLHttpRequest'
    }

    page = @agent.get("#{TW_URL}/messages", {}, 'https://twitter.com/i/notifications', headers)
    blob = Nokogiri::HTML page.json['inner']['html']
  end

  # STORE Actions

  def search(terms, max = 10, timestamp = nil, up = false)
    # f = tweets | users | images | videos | news | top (nothing)
    # q = 'mediterránea near:lima,peru within:50km'
    # near = me
    # s = follows
    # hashtags: https://twitter.com/hashtag/Tomaso?f=tweets = https://twitter.com/search?q=%23Tomaso&f=tweets
    safe_terms = URI.encode(terms)
    timestamp = timestamp.to_i if timestamp

    initial_url = "#{TW_URL}/search?q=#{safe_terms}&f=tweets"
    stream_url = "#{TW_URL}/i/search/timeline?q=#{safe_terms}&f=tweets"
    style_data = 'div#timeline div.stream-container'

    page = @agent.get initial_url

    first_pass = true
    min_timestamp = nil
    max_timestamp = nil
    do_end = false
    # also can go UP!
    # max_position = page.at(style_data).attribute('data-max-position').value
    # min_position = page.at(style_data).attribute('data-min-position').value
    # init_position = min_position

    count = 0
    items = []

    loop do
      wait_until(:request)

      if first_pass
        log "Requesting #{terms} | #{timestamp} | #{max}"

        blob = page.parser
        first_pass = false
      else
        log "Requesting #{DateTime.strptime(min_timestamp.to_s,'%s')} timestamp #{min_timestamp}"

        # page = @agent.get("#{stream_url}&include_available_features=1&include_entities=1&max_position=#{min_position}")
        page = @agent.get("#{stream_url}&include_available_features=1&include_entities=1&max_position=#{min_timestamp}")

        blob = Nokogiri::HTML page.json['items_html']
        # min_position = page.json['min_position']
      end

      blob.css('.js-stream-tweet').each do |card|

        data_time = card.at('span.js-short-timestamp').attribute('data-time').value.to_i
        if timestamp and data_time <= timestamp
          do_end = true
          break
        end

        min_timestamp = data_time
        max_timestamp = data_time unless max_timestamp

        item = {
            timestamp: data_time,
            tweet_id: card.attribute('data-item-id').value,
            username: card.attribute('data-screen-name').value,
            user_id: card.attribute('data-user-id').value,
            follow_him: card.attribute('data-you-follow').value == 'true',
            follows_me: card.attribute('data-follows-you').value == 'true',
            blocked: card.attribute('data-you-block').value == 'true',
            message: card.at('div.js-tweet-text-container').text.strip
        }

        el_retweet = card.at('div.QuoteTweet-innerContainer')
        item[:retweet_id] = el_retweet.attribute('data-item-id').value if el_retweet

        if block_given?
          yield item
        else
          items.push item
        end
        count += 1

        if max > 0 and count >= max
          do_end = true
          break
        end
      end

      if do_end
        break
      end
    end

    return items, max_timestamp
  end

  def download_list(target = @account.username, style = 'followers', position = nil, target_list = nil, max = 0, extended = false)
  # style = followers | following | likes | lists | hashtag
    position = position.to_i if position

    initial_url = "#{TW_URL}/#{target}/#{style}"
    stream_url = "#{initial_url}/users"
    style_data = 'div.GridTimeline-items'
    case style
      when 'likes'
        initial_url = "#{TW_URL}/#{target}/#{style}"
        stream_url = "#{initial_url}/timeline"
        style_data = 'div#timeline div.stream-container'
      when 'lists'
        initial_url = "#{TW_URL}/#{target}/#{style}/#{target_list}/members"
        stream_url = "#{initial_url}/timeline"
        style_data = 'div#timeline div.stream-container'
    end

    page = @agent.get initial_url

    first_pass = true
    do_end = false
    min_position = page.at(style_data).attribute('data-min-position').value
    init_position = min_position

    count = 0
    items = []

    loop do
      wait_until(:request)

      if first_pass
        log "Requesting #{target} | #{style} | #{position} | #{target_list} | #{max} | #{extended}"

        blob = page.parser
        first_pass = false
      else
        log "Requesting cursor #{min_position}"

        page = @agent.get("#{stream_url}?include_available_features=1&include_entities=1&max_position=#{min_position}")

        blob = Nokogiri::HTML page.json['items_html']
        min_position = page.json['min_position']
      end

      blob.css('.js-stream-item').each do |card|
        case style
          when 'likes'
            item = {
                username: card.attribute('data-item-id').value
            }
          when 'lists'
            item = {
                username: card.at_css('div.account').attribute('data-screen-name').value.downcase
            }
            if extended
                item[:name] = card.at_css('strong.fullname').text.strip,
                item[:image_url] = card.at_css('img.js-action-profile-avatar').attribute('src').text,
                item[:description] = card.at_css('p.bio').text.strip
          end
            else
            item = {
                username: card.at_css('span.u-linkComplex-target').text.downcase
            }
            if extended
                item[:name] = card.at_css('a.ProfileNameTruncated-link').text.strip,
                item[:image_url] = card.at_css('img.ProfileCard-avatarImage').attribute('src').text,
                item[:description] = card.at_css('p.ProfileCard-bio').text.strip
            end
        end

        if block_given?
          yield item
        else
          items.push item
        end
        count += 1

        if max > 0 and count >= max
          do_end = true
          break
        end
      end

      if do_end or min_position == nil or min_position == '0' or (position and min_position.to_i <= position)
        break
      end
    end

    return items, init_position
  end

  def store_list(list, target, style = 'followers', target_list = nil)
    lines, position = download_list(target, style, list.position, target_list)

    lines.reverse_each do |line|
      # unless style == 'likes'
      #  TwUser.new(user).save
      #end
      item = line[:username]
      list.add(item)
    end

    list.position = position
    list.save
    list
  end

  def store_own(list, style = 'followers', target_list = nil)
    store_list(list, @account.username, style, target_list)
  end

  # ACCOUNT Lists

  def list_following
    TwList.get_or_create("#{@account.username} # following")
  end

  def list_followers
    TwList.get_or_create("#{@account.username} # followers")
  end

  def list_likes
    TwList.get_or_create("#{@account.username} # likes")
  end

  # Accounts whitelisted
  def list_vip
    TwList.get_or_create("#{@account.username} # vip")
  end

  # List of accounts used as sources
  def list_sources
    TwList.get_or_create("#{@account.username} # sources")
  end

  def list_source(list_name)
    TwList.get_or_create("#{@account.username} #{list_name}")
  end

  # List of accounts already followed
  def list_followed
    TwList.get_or_create("#{@account.username} # followed")
  end

  def list_unfollow
    TwList.get_or_create("#{@account.username} # unfollow")
  end

  # List of accounts already mentioned in tweets
  def list_mentioned
    TwList.get_or_create("#{@account.username} # mentioned")
  end

  # List of accounts with a tweet already retweeted
  def list_retweeted
    TwList.get_or_create("#{@account.username} # retweeted")
  end

  # List of accounts with a tweet already liked
  def list_liked
    TwList.get_or_create("#{@account.username} # liked")
  end

  def list_unlike
    TwList.get_or_create("#{@account.username} # unlike")
  end

  # List of accounts already added to a list
  def list_listed
    TwList.get_or_create("#{@account.username} # listed")
  end

  # STATS Actions

  def log(message, type = :info)
    if @logger
      @logger.send(type, "#{@account.username}: #{message}")
    end
  end

  def stats_add(event, amount = 1)
    @stats[event] = 0 unless @stats[event]
    @stats[event] += amount
  end

  #def stats_report
  #  CSV.open("#{Rails.root}/log/#{@account.username}_#{@start_time.strftime('%F_%H-%M-%S')}.csv", 'wb') do |csv|
  #    csv << @stats.keys
  #    csv << @stats.values
  #  end
  #end

  def studies_on
    last = study_last
    last.stats.destroy_all
    @studies.push study_all
    @studies.push last
  end

  # Study of lifetime stats
  def study_all
    TwStudy.get_or_create("#{@account.username} @ all")
  end

  # Study of last run stats
  def study_last
    TwStudy.get_or_create("#{@account.username} @ last")
  end

end