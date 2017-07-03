require 'open-uri'
require 'json'

class GridController < ApplicationController
  def game
    @grid =  Array.new(10) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now.to_i
  end

  def score
    @guess = params[:guess] # NOT SURE
    @end_time = Time.now.to_i
    @time = @end_time - params[:time].to_i
    @results = run_game(@guess, params[:grid], params[:time].to_i, @end_time )
  end

  def included?(attempt, grid)
    letters = attempt.split("")
    if(letters.length <= grid.length)
      # check if letters are in grid
      letters.each do |letter|
        unless grid.include?(letter)
          return false
          exit
        end
      end
      true
    end
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "c5da2f41-c4f8-4a7e-9bdb-881872591bfd"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      words = File.read('/usr/share/dict/words').split("\n")
      words.each do |word|
        word.upcase!
      end
      if words.include? word.upcase
        return word
      else
        return nil
      end
    end
  end
end
