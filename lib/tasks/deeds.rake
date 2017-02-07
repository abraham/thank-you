namespace :deeds do
  desc 'Update the dittos count on '
  task update_dittos_count: :environment do
    Deed.all.each(&:update_dittos_count)
  end
end
