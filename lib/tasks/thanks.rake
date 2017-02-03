namespace :thanks do
  desc 'Update the dittos count on '
  task update_dittos_count: :environment do
    Thank.all.each(&:update_dittos_count)
  end
end
