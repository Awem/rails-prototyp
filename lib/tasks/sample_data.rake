require './lib/tasks/trip_data'
@new_trips = false
namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    make_watchword
    make_users
    set_profile_pictures
    make_projects
    set_project_logos
    make_matchers
    set_matcher_logos
    make_budgets
    make_partnerships
    make_groups
    set_group_logos
    make_memberships
    make_contributions
    make_trips
    make_payments
    make_invoices
    pay_invoices
  end
end

def make_watchword
  Watchword.create!(token: 'cgu8g8010Jpx')
end

def make_users
  invite = 'cgu8g8010Jpx'
  watchword = Watchword.find(1)
  confirmed_at = Time.now
  admin = User.create(
    name:                    'Admin',
    email:                   'admin@rproto.de',
    password:                'fahrer',
    invite:                  invite,
    watchword:               watchword,
    contribution_visibility: 'hidden',
    admin:                   true,
    confirmed_at:            confirmed_at)
  99.times do |n|
    name  = FFaker::NameDE.name
    email = "user-#{n+1}@rproto.de"
    password  = 'password'
    if n % 4 == 0
      contribution_visibility = 'hidden'
    else
      contribution_visibility = 'full'
    end
    User.create(
      name:                    name,
      email:                   email,
      password:                password,
      invite:                  invite,
      watchword:               watchword,
      contribution_visibility: contribution_visibility,
      confirmed_at:            confirmed_at)
  end
end

def set_profile_pictures
  users = User.all
  users.each do |user|
    user.get_gravatar!
  end
  some_users = users.sort_by(&:id).first(2)
  some_users.each do |user|
    url = "defaults/user-#{user.id}.png"
    picture = user.pictures.create(url: url, name: 'profile')
    user.set_profile_picture!(picture)
  end
end

def make_projects
  50.times do |n|
    name  = "#{FFaker::Education.school} #{n+1}"
    description = FFaker::Lorem.paragraph(sentence_count=3)
    paypal_account  = 'paypal-facilitator@uniconcepts.de'
    if n < 2
      featured = 'full'
    else
      featured = nil
    end
    Project.create(
      name:           name,
      description:    description,
      featured:       featured,
      paypal_account: paypal_account
    )
  end
end

def set_project_logos
  projects = Project.all.sort_by(&:id).first(2)
  projects.each do |project|
    url = "defaults/project-#{project.id}.png"
    picture = project.pictures.create(url: url, name: 'logo')
    project.set_logo!(picture)
  end
end

def make_matchers
  50.times do |n|
    name  = "#{Forgery(:name).company_name} #{n+1}"
    description = FFaker::Lorem.paragraph(sentence_count=3)
    if n < 2
      featured = 'campaign'
    else
      featured = nil
    end
    Matcher.create(
      name:        name,
      description: description,
      featured:    featured)
  end
end

def set_matcher_logos
  matchers = Matcher.all.sort_by(&:id).first(2)
  matchers.each do |matcher|
    url = "defaults/matcher-#{matcher.id}.png"
    picture = matcher.pictures.create(url: url, name: 'logo')
    matcher.set_logo!(picture)
  end
end

def make_budgets
  all_matchers = Matcher.reorder('RANDOM()').map{|m| m.id}.uniq
  ninety_percent_matchers = all_matchers.take((all_matchers.length*Rational(9, 10)).to_int)
  matchers = Matcher.find(ninety_percent_matchers)
  matchers.each do |matcher|
    matcher.budgets.create(amount: rand(10000...25000), description: 'dummy budget', effective: true)
  end
end

def make_partnerships
  project_count = Project.count
  odd_projects = (1..project_count).step(2).to_a
  even_projects = (2..project_count).step(2).to_a
  40.times do |n|
    matched_projects_1 = Project.where(id: odd_projects).reorder('RANDOM()').limit(rand(1...3))
    matched_projects_2 = Project.where(id: even_projects).reorder('RANDOM()').limit(rand(1...3))
    matched_projects_1.each { |project| project.potential_partners.reorder('RANDOM()').first.match!(project) }
    matched_projects_2.each { |project| project.potential_partners.reorder('RANDOM()').first.match!(project, 2) }
  end
end

def make_groups
  users = User.all
  some_users = users.sort_by(&:id).first(5)
  some_users.each do |user|
    name = "Gruppe von #{user.name}"
    description = 'dummy group'
    category = 'public'
    user.found_group!(name, description, category)
  end
end

def set_group_logos
  groups = Group.all.sort_by(&:id).first(2)
  groups.each do |group|
    url = "defaults/group-#{group.id}.png"
    picture = group.pictures.create(url: url, name: 'logo')
    group.set_logo!(picture)
  end
end

def make_memberships
  def make_members(group, role, times)
    users = group.non_members.reorder('RANDOM()').limit(times)
    users.each do |user|
      user.join_group!(group, role)
    end
  end

  groups = Group.all
  groups.each do |group|
    make_members(group, 'member', 2)
    make_members(group, 'pending', 1)
    make_members(group, 'admin', 1)
  end
end

def make_contributions
  users = User.limit(50)
  users.each do |user|
    rand(1...5).times do
      amount = rand(10...100)
      project = Project.find(rand(1...Project.count))
      title = "Spende an #{project.name}"
      if project.matching_partners.any?
        matcher_id = project.matching_partners.offset(rand(project.matching_partners.count)).first.id
      else
        matcher_id = nil
      end
      user.contributions.create(
        title: title,
        project_id: project.id,
        matcher_id: matcher_id,
        amount: amount)
    end
  end
end

def make_trips
  if @new_trips
    Geocoder.configure(timeout: 10)
  else
    trips = TripData::Trips
    last_trip = trips.count - 1
  end
  users = User.limit(50)
  users.each do |user|
    rand(1...5).times do |n|
      if @new_trips
        origin = FFaker::AddressDE.city
        destination = FFaker::AddressDE.city
        while origin == destination do #unwahrscheinlich
         destination = FFaker::AddressDE.city
        end
        origin_lat = Geocoder.coordinates(origin, region: 'de', language: 'de')[0]
        sleep(0.5)
        origin_lng = Geocoder.coordinates(origin, region: 'de', language: 'de')[1]
        sleep(0.5)
        destination_lat = Geocoder.coordinates(destination, region: 'de', language: 'de')[0]
        sleep(0.5)
        destination_lng = Geocoder.coordinates(destination, region: 'de', language: 'de')[1]
        sleep(0.5)
        length = Geocoder::Calculations.distance_between([origin_lat, origin_lng], [destination_lat, destination_lng])
        sleep(0.5)
        multiplier = n+1
      else
        trip = trips[rand(0...last_trip)]
        origin = trip[:origin]
        destination = trip[:destination]
        origin_lat = trip[:origin_lat].to_f
        origin_lng = trip[:origin_lng].to_f
        destination_lat = trip[:destination_lat].to_f
        destination_lng = trip[:destination_lng].to_f
        length = trip[:length].to_f
        multiplier = trip[:multiplier].to_f
      end
      title = "#{origin} -> #{destination}"
      amount = (length * multiplier).round(2)
      project = Project.find(rand(1...Project.count))
      if project.matching_partners.any?
        matcher_id = project.matching_partners.offset(rand(project.matching_partners.count)).first.id
      else
        matcher_id = nil
      end
      trip_attributes = {
        origin:          origin,
        destination:     destination,
        origin_lat:      origin_lat,
        origin_lng:      origin_lng,
        destination_lat: destination_lat,
        destination_lng: destination_lng,
        length:          length,
        multiplier:      multiplier}
      contribution = user.contributions.create!(
        title: title,
        project_id: project.id,
        matcher_id: matcher_id,
        amount: amount,
        trip_attributes: trip_attributes)
    end
  end
end

def make_payments
  contributions = Contribution.reorder('RANDOM()').limit(80)
  message = {message: 'dummy payment'}
  provider = 'paypal'
  status = 'COMPLETED'
  contributions.each do |contribution|
    if contribution.matcher
      matched = 'pending'
    else
      matched = 'n/a'
    end
    contribution.create_payment!(
      provider: provider,
      payload: message.to_json,
      response: message.to_json,
      status: status,
      matched: matched
    )
  end
end

def make_invoices
  all_matchers = Payment.need_matching.map{|p| p.matcher.id}.uniq
  two_thirds_matchers = all_matchers.take((all_matchers.length*Rational(2, 3)).to_int)
  matchers = Matcher.find(two_thirds_matchers)
  matchers.each do |matcher|
    matcher.create_invoice!('dummy invoice')
  end
end

def pay_invoices
  some_matchers = Invoice.where(number: 'dummy invoice').map{|i| i.matcher.id}.uniq.select{|i| i.even?}
  matchers = Matcher.find(some_matchers)
  matchers.each do |matcher|
    invoice = matcher.invoices.where(number: 'dummy invoice').first.id
    matcher.pay_invoice!(invoice)
  end
end