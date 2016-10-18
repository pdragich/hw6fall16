class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end

 def self.find_in_tmdb(string)
   begin
   Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
   rescue Tmdb::InvalidApiKeyError
       raise Movie::InvalidKeyError, 'Invalid API key'
   end
    @search = Tmdb::Search.new 
    @search.resource('movie')
    @search.query(string)
    @matching_movies = @search.fetch 
    movies_hold = Array.new
      @matching_movies.each do |movie|
         releases = Tmdb::Movie.releases(movie['id'])
         country_releases = releases['countries']
         us_release = country_releases.select {|release| release['iso_3166_1'] == 'US'}
         if !us_release.blank?
           rating = us_release[0]['certification'] 
         else
           rating = 'N/A'
         end

         release_date = movie['release_date']
         if release_date.blank?
           release_date = 'TBD'
         end
         
         movie_vals = {}
         movie_vals[:tmdb_id] = movie['id']
         movie_vals[:rating] = rating
         movie_vals[:title] = movie['title']
         movie_vals[:release_date] = release_date
         movie_vals[:overview] = movie['overview']
    
         movies_hold.push(movie_vals)
     end
     movies_hold
  end
  
  def self.add_movies(movie_id)
    movie = Tmdb::Movie.detail(movie_id)
    releases = Tmdb::Movie.releases(movie_id)
    title = movie['original_title']
    release_date = movie['release_date']

    country_releases = releases['countries']
    us_release = country_releases.select {|release| release['iso_3166_1'] == 'US'}
    if !us_release.blank? 
      rating = us_release[0]['certification']
    else
      rating = 'N/A'
    end
    
    new_movie = {}
    new_movie[:title] = title
    new_movie[:release_date] = release_date
    new_movie[:rating] = rating

    Movie.create!(new_movie)
  end
end