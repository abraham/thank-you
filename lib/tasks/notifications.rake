namespace :notifications do
  desc 'Send test push notification'
  task send: :environment do
    fcm = FCM.new(Rails.application.secrets.firebase_messaging_key)
    payload = {
      notification: {
        title: 'Test notification',
        body: 'This is just a test',
        icon: 'https://thankyou.delivery/assets/heart-6415107d2ffd301149ac39cda4a933feec08d2888b2b9350a9013836a6f66476.png',
        click_action: 'https://thankyou.delivery'
      }
    }
    result = fcm.send_to_topic('test', payload)
    if result[:status_code] == 200
      puts 'Test notification sent'
    else
      puts 'Error', result
    end
  end

  desc 'Send v1 test push notification'
  task v1: :environment do
    fcm = FCM.new(Rails.application.secrets.firebase_messaging_key)
    payload = {
      data: {
        version: 1,
        notification: {
          title: 'Test notification v1',
          body: 'This is just a test',
          icon: 'https://thankyou.delivery/assets/heart-6415107d2ffd301149ac39cda4a933feec08d2888b2b9350a9013836a6f66476.png',
          click_action: 'https://thankyou.delivery'
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
