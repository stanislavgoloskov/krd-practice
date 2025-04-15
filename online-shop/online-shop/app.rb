require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

# Настройки приложения
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'
enable :sessions

# Имитация БД с товарами
PRODUCTS = [
  { 
    id: 1, 
    name: 'Книга 45 татуировок менеджера', 
    price: 450, 
    image: '/images/book.jpg', 
    description: 'Правила российского руководителя' 
  }
]

# Допустимые промокоды
VALID_PROMO_CODES = {
  'СКИДКА10' => 50, # Скидка 50 рублей
  '12345' => 25     # Скидка 25 рублей
}

# Имитация состояний 3D-Secure
SECURE_STATUS = {
  'success' => 'Проверка 3D-Secure успешно пройдена',
  'failed' => 'Ошибка 3D-Secure: неверные данные аутентификации',
  'connection_error' => 'Ошибка соединения с банком, попробуйте позже',
  'insufficient_funds' => 'Недостаточно средств на карте'
}

# Варианты времени доставки
DELIVERY_TIMES = [
  "с 09:00 до 12:00",
  "с 12:00 до 15:00",
  "с 15:00 до 18:00",
  "с 18:00 до 21:00"
]

# Главная страница / список товаров
get '/' do
  erb :index
end

# Страница корзины
get '/cart' do
  @cart_items = session[:cart] || []
  @total = calculate_total(@cart_items)
  @promo_success = session[:promo_success]
  session[:promo_success] = nil # Сбрасываем после показа
  
  erb :cart
end

# Добавление товара в корзину
post '/cart/add/:id' do
  id = params[:id].to_i
  session[:cart] ||= []
  
  item = session[:cart].find { |i| i[:id] == id }
  if item
    item[:quantity] += 1
  else
    session[:cart] << { id: id, quantity: 1 }
  end
  
  redirect '/cart'
end

# Увеличение количества товара
get '/cart/increase/:id' do
  id = params[:id].to_i
  session[:cart] ||= []
  
  item = session[:cart].find { |i| i[:id] == id }
  item[:quantity] += 1 if item
  
  redirect '/cart'
end

# Уменьшение количества товара
get '/cart/decrease/:id' do
  id = params[:id].to_i
  session[:cart] ||= []
  
  item = session[:cart].find { |i| i[:id] == id }
  if item && item[:quantity] > 1
    item[:quantity] -= 1
  elsif item
    session[:cart].delete_if { |i| i[:id] == id }
  end
  
  redirect '/cart'
end

# Удаление товара из корзины
get '/cart/remove/:id' do
  id = params[:id].to_i
  session[:cart] ||= []
  
  session[:cart].delete_if { |item| item[:id] == id }
  
  redirect '/cart'
end

# Страница оформления заказа
get '/checkout' do
  @cart_items = session[:cart] || []
  @total = calculate_total(@cart_items)
  @discount = session[:discount] || 0
  @final_total = @total + 49 - @discount # Товар + доставка - скидка
  @payment_method = session[:payment_method] || 'card_online'
  @checkout_step = 1 # Для прогресс-бара
  @delivery_time = session[:delivery_time] || "с 12:00 до 15:00"
  @delivery_times = DELIVERY_TIMES
  
  erb :checkout
end

# Установка времени доставки
post '/checkout/set_delivery_time' do
  session[:delivery_time] = params[:delivery_time]
  redirect '/checkout'
end

# Выбор способа оплаты
post '/checkout/set_payment' do
  session[:payment_method] = params[:payment_method]
  redirect '/checkout'
end

# Страница добавления промокода
get '/promo' do
  erb :promo
end

# Применение промокода
post '/promo/apply' do
  promo_code = params[:promo_code]
  
  if VALID_PROMO_CODES.key?(promo_code)
    session[:discount] = VALID_PROMO_CODES[promo_code]
    session[:promo_success] = true # Сигнал для зеленого уведомления
    redirect '/checkout'
  else
    @error = "Неверный промокод"
    erb :promo
  end
end

# Оформление заказа
post '/checkout/process' do
  payment_method = params[:payment_method] || session[:payment_method] || 'card_online'
  session[:payment_method] = payment_method
  
  if payment_method == 'card_online'
    redirect '/payment'
  else
    # Для оплаты при получении просто завершаем заказ
    session[:cart] = []
    session[:discount] = 0
    redirect '/success'
  end
end

# Страница оплаты (ввод номера карты)
get '/payment' do
  @checkout_step = 2 # Для прогресс-бара
  @saved_cards = [
    { id: 1, mask: "xxxx-xxxx-xxxx-1234", expiry: "12/25" }
  ]
  session[:saved_cards] ||= @saved_cards
  erb :payment
end

# Выбор сохраненной карты
post '/payment/use_saved_card' do
  card_id = params[:card_id].to_i
  
  # В реальном приложении здесь была бы обработка выбора карты
  # Для демо просто переходим к CVV
  session[:using_saved_card] = true
  redirect '/payment/cvv'
end

# Обработка формы с номером карты и переход к CVV
post '/payment/process' do
  # Имитация проверки карты
  card_number = params[:card_number]
  expiry_month = params[:expiry_month]
  expiry_year = params[:expiry_year]
  save_card = params[:save_card] == 'on'
  
  session[:save_card] = save_card
  
  if card_number.to_s.gsub(/\s+/, '').length != 16
    @error = "Неверные данные карты"
    @checkout_step = 2
    @saved_cards = session[:saved_cards] || []
    erb :payment
  else
    session[:card] = {
      number: card_number,
      expiry_month: expiry_month,
      expiry_year: expiry_year
    }
    redirect '/payment/cvv'
  end
end

# Страница ввода CVV
get '/payment/cvv' do
  @checkout_step = 3 # Для прогресс-бара
  erb :payment_cvv
end

# Обработка оплаты
post '/payment/complete' do
  # Имитация обработки платежа
  cvv = params[:cvv]
  
  if cvv.to_s.length != 3
    @error = "Неверные данные карты"
    @checkout_step = 3
    erb :payment_cvv
  else
    # Имитация 3D-Secure проверки
    redirect '/payment/3dsecure'
  end
end

# Страница 3D-Secure
get '/payment/3dsecure' do
  @checkout_step = 4 # Для прогресс-бара
  erb :secure_3d
end

# Обработка 3D-Secure
post '/payment/3dsecure/process' do
  # Имитация разных сценариев с 3D-Secure
  secure_code = params[:secure_code]
  
  # Для демонстрации разных сценариев ошибок
  case secure_code
  when '123456' # Успешно
    session[:secure_status] = 'success'
    
    # Если пользователь согласился сохранить карту
    if session[:save_card]
      card_mask = "xxxx-xxxx-xxxx-" + session[:card][:number].gsub(/\s+/, '')[-4..-1]
      session[:saved_cards] ||= []
      session[:saved_cards] << {
        mask: card_mask,
        expiry: "#{session[:card][:expiry_month]}/#{session[:card][:expiry_year]}"
      }
    end
    
    # Очистка корзины и других данных заказа
    session[:cart] = []
    session[:discount] = 0
    session[:card] = nil
    
    redirect '/success'
  when '111111' # Недостаточно средств
    session[:secure_status] = 'insufficient_funds'
    @error = SECURE_STATUS['insufficient_funds']
    @checkout_step = 4
    erb :secure_3d
  when '222222' # Ошибка соединения
    session[:secure_status] = 'connection_error'
    @error = SECURE_STATUS['connection_error']
    @checkout_step = 4
    erb :secure_3d
  else # Неверный код
    session[:secure_status] = 'failed'
    @error = SECURE_STATUS['failed']
    @checkout_step = 4
    erb :secure_3d
  end
end

# Страница успешного оформления заказа
get '/success' do
  @checkout_step = 5 # Для прогресс-бара
  @delivery_time = session[:delivery_time] || "с 12:00 до 15:00"
  erb :success
end

# Вспомогательный метод для расчета суммы заказа
def calculate_total(cart_items)
  cart_items.sum do |item| 
    product = PRODUCTS.find { |p| p[:id] == item[:id] }
    product[:price] * item[:quantity] if product
  end || 0
end