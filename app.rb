# frozen_string_literal: true
require 'roda'
require 'telegram/bot'
require 'json'
require 'cgi'

# Инициализируем клиента Telegram один раз
BOT = Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])

class App < Roda
  plugin :json

  # Список разрешённых Telegram user IDs как строки
  ALLOWED = %w[53899467 5048745 195597895 259297588].freeze

  route do |r|
    # Точка входа для Telegram webhook
    r.post do
      payload = JSON.parse(request.body.read)
      update  = Telegram::Bot::Types::Update.new(payload)

      if update.message && update.message.from
        user_id = update.message.from.id.to_s
        chat_id = update.message.chat.id
        text    = update.message.text.to_s.strip

        # Проверяем доступ
        unless ALLOWED.include?(user_id)
          BOT.api.send_message(chat_id: chat_id,
                               text: 'This is a private bot. Sorry.')
          response.status = 200
          next ''
        end

        case text
        when '/start'
          BOT.api.send_message(chat_id: chat_id,
                               text: 'Перевод строки, запятую и вертикальную палочку — всё заменю на вертикальную палочку!')

        else
          # Обработка пользовательского ввода
          parts = text.split(/[\s,|]+/).map(&:strip).uniq
          reply_text = parts.join('|')

          opts = { chat_id: chat_id, text: reply_text }

          # Добавляем inline-кнопку, если ответ не слишком длинный
          if reply_text.length < 1900 && !reply_text.empty?
            showcase_btn = Telegram::Bot::Types::InlineKeyboardButton.new(
              text: 'Showcase',
              url: "http://smo3-master-2.local/tasks?filter=#{CGI.escape(reply_text)}&commit=Filter"
            )
            keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
              inline_keyboard: [[showcase_btn]]
            )
            opts[:reply_markup] = keyboard
          end

          BOT.api.send_message(opts)
        end
      end

      # Всегда возвращаем 200 OK
      response.status = 200
      ''
    end
  end
end
