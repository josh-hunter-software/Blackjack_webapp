require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INITIAL_POT_AMOUNT = 2000


set :sessions, true

helpers do
  def calculate_total(cards) 
  arr = cards.map{|e| e[1] }
  total = 0
  arr.each do |value|
      if value == "ace"
      total += 11
    elsif value.to_i == 0 
      total += 10
    else
      total += value.to_i
    end
  end
  arr.select{|e| e == "Ace"}.count.times do
    break if total <= BLACKJACK_AMOUNT
    total -= 10
    end  
  total
  end
end

def card_image(card)
  suit = case card[0]
    when 'H' then 'hearts'
    when 'D' then 'diamonds'
    when 'C' then 'clubs'
    when 'S' then 'spades'  
  end
value = card[1]
  "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:player_pot] = session[:player_pot] + session[:player_bet]  
    @winner = "<strong>#{session[:player_name]}, you win #{session[:player_bet]}!</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:player_pot] = session[:player_pot] - session[:player_bet]  
    @loser = "<strong>#{session[:player_name]}, you lose $#{session[:player_bet]}.</strong> #{msg}"
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @winner = "<strong>#{session[:player_name]}, you tied with the dealer.</strong> #{msg}"
  end

before do
  @show_hit_or_stay_buttons=true
end

get '/' do
  if session[:player_name]
      redirect '/game'
  else
      redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name].capitalize
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i < 1
    @error = "You must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "You've tried to bet more than what you have. Please call Gambler's Anonymous (1-888-424-3577) for help."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end


get '/game' do
  session[:turn] = session[:player_name]
  suits = ["C","H","D","S"]
  values = ['2','3','4','5','6','7','8','9','10','jack','queen','king','ace']
  session[:deck] = suits.product(values).shuffle!
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop


  erb :game
end

post '/game/player/hit' do
   session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[player_name]}, you hit blackjack!")
    elsif player_total > BLACKJACK_AMOUNT
    loser!("Sorry #{session[:player_name]}, you busted.")
    end
   
   erb :game, layout: false
end

post '/game/player/stay' do
  @success = "You have chosen to stay!"
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"

  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Sorry #{session[:player_name]}, the dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Congratulations, #{session[:player_name]}! The dealer busted at #{dealer_total}!")
  elsif dealer_total >= DEALER_MIN_HIT
    redirect '/game/compare'
  else

    @show_dealer_hit_button = true
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("You stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("You stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("You and the dealer both stayed at #{player_total}.")
  end

  erb :game, layout: false
end

get '/game_over' do
  erb :game_over
end
