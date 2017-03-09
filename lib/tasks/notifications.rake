namespace :notifications do
  desc 'Send test push notification'
  task send: :environment do
    fcm = FCM.new(Rails.application.secrets.firebase_messaging_key)
    payload = {
      data: {
        version: 1,
        topic: :test,
        notification: {
          title: 'Test notification',
          body: 'This is just a test',
          icon: 'https://thankyou.delivery/assets/heart-6415107d2ffd301149ac39cda4a933feec08d2888b2b9350a9013836a6f66476.png',
          data: {
            click_action: 'https://thankyou.delivery'
          }
        }
      }
    }
    result = fcm.send_to_topic('test', payload)
    if result[:status_code] == 200
      puts 'Test notification sent'
    else
      puts 'Error', result
    end
  end
end
