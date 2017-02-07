namespace :deeds do
  desc 'Update the Thank You count on Deeds'
  task update_thanks_count: :environment do
    Deed.all.each(&:update_thanks_count)
  end
end
