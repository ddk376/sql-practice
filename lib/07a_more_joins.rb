# == Schema Information
#
# Table name: albums
#
#  asin        :string       not null, primary key
#  title       :string
#  artist      :string
#  price       :float
#  rdate       :date
#  label       :string
#  rank        :integer
#
# Table name: styles
#
# album        :string       not null
# style        :string       not null
#
# Table name: tracks
# album        :string       not null
# disk         :integer      not null
# posn         :integer      not null
# song         :string

require_relative './sqlzoo.rb'

def alison_artist
  # Select the name of the artist who recorded the song 'Alison'.
  execute(<<-SQL)
    SELECT
      albums.artist
    FROM
      albums
    JOIN
      tracks
    ON
      albums.asin = tracks.album
    WHERE
      tracks.song = 'Alison'
  SQL
end

def exodus_artist
  # Select the name of the artist who recorded the song 'Exodus'.
  execute(<<-SQL)
    SELECT
      albums.artist
    FROM
      albums JOIN tracks
    ON
      albums.asin = tracks.album
    WHERE
      tracks.song = 'Exodus'
  SQL
end

def blur_songs
  # Select the `song` for each `track` on the album `Blur`.
  execute(<<-SQL)
    SELECT
      tracks.song
    FROM
      albums
    JOIN
      tracks
    ON
      albums.asin = tracks.album
    WHERE
      albums.title = 'Blur'
  SQL
end

def heart_tracks
  # For each album show the title and the total number of tracks containing
  # the word 'Heart' (albums with no such tracks need not be shown). Order first by
  # the number of such tracks, then by album title.
  execute(<<-SQL)
    SELECT
      albums.title, COUNT(albums.title) AS Heart_Count
    FROM
      albums JOIN tracks
    ON
      albums.asin = tracks.album
    WHERE
      tracks.song LIKE '%Heart%'
    GROUP BY
      albums.title
    ORDER BY
      Heart_Count DESC, albums.title
  SQL
end

def title_tracks
  # A 'title track' has a `song` that is the same as its album's `title`. Select
  # the names of all the title tracks.
  execute(<<-SQL)
    SELECT
      tracks.song
    FROM
      albums
    JOIN
      tracks
    ON
      albums.asin = tracks.album
    WHERE
      tracks.song = albums.title
  SQL
end

def eponymous_albums
  # An 'eponymous album' has a `title` that is the same as its recording
  # artist's name. Select the titles of all the eponymous albums.
  execute(<<-SQL)
    SELECT
      a.title
    FROM
      albums a
    JOIN
      albums b
    ON
      a.asin = b.asin
    WHERE
      a.title = b.artist
  SQL
end

def song_title_counts
  # Select the song names that appear on more than two albums. Also select the
  # COUNT of times they show up.
  execute(<<-SQL)
    SELECT
      *
    FROM
      (SELECT
        A.song, COUNT(A.song) AS count
      FROM (SELECT DISTINCT
              a.*
            FROM tracks a JOIN tracks b
            ON a.song = b.song) AS A
      GROUP BY A.song) AS T
    WHERE T.count > 2
  SQL
end

def best_value
  # A "good value" album is one where the price per track is less than 50
  # pence. Find the good value albums - show the title, the price and the number
  # of tracks.
  execute(<<-SQL)
    SELECT
      M.title, M.price, M.num_of_tracks
    FROM
      (SELECT
        a.title, a.price, album_and_track_count.num_of_tracks
      FROM
        (SELECT
            albums.asin, COUNT(albums.asin) AS num_of_tracks
         FROM
            albums
         JOIN tracks
         ON
            albums.asin = tracks.album
         GROUP BY
            albums.asin
       ) AS album_and_track_count
      JOIN
        albums a
      ON
        a.asin = album_and_track_count.asin) AS M
    WHERE
      M.price/M.num_of_tracks < 0.50

  SQL
end

def top_track_counts
  # Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101
  # tracks. List the top 10 albums. Select both the album title and the track
  # count, and order by both track count and title (descending).
  execute(<<-SQL)
    SELECT
      a.title, album_and_track_count.num_of_tracks
    FROM
      (SELECT
          albums.asin, COUNT(albums.asin) AS num_of_tracks
       FROM albums JOIN tracks
       ON albums.asin = tracks.album
       GROUP BY albums.asin
     ) AS album_and_track_count
    JOIN albums a ON a.asin = album_and_track_count.asin
    ORDER BY album_and_track_count.num_of_tracks DESC, a.title DESC
    LIMIT 10

  SQL
end

def rock_superstars
  # Select the artist who has recorded the most rock albums, as well as the
  # number of albums. HINT: use LIKE '%Rock%' in your query.
  execute(<<-SQL)
    SELECT
      *
    FROM
      (SELECT
        rock_artists.artist, COUNT(rock_artists.artist) AS num_of_rock_albums
      FROM
        (SELECT DISTINCT
          albums.artist, albums.title
        FROM albums JOIN styles
        ON albums.asin = styles.album
        WHERE styles.style LIKE '%Rock%') AS rock_artists
      GROUP BY rock_artists.artist) rock_artists_and_num
    ORDER BY rock_artists_and_num.num_of_rock_albums DESC
    LIMIT 1


  SQL

end

def expensive_tastes
  # Select the five styles of music with the highest average price per track,
  # along with the price per track. One or more of each aggregate functions,
  # subqueries, and joins will be required.
  execute(<<-SQL)
    SELECT
      *
    FROM
      (SELECT
        style_price_tracks.style, t_price/t_count As avg
      FROM
        (SELECT
          styles.style, SUM(T.price) AS t_price, SUM(T.count) AS t_count
        FROM
          (SELECT
            albums.asin, albums.price, COUNT(albums.asin) AS count
          FROM albums JOIN tracks
          ON albums.asin = tracks.album
          GROUP BY albums.asin) AS T
        JOIN styles
        ON styles.album = T.asin
        GROUP BY styles.style) AS style_price_tracks
      ORDER BY avg DESC) as F
    WHERE F.avg IS NOT NULL
    LIMIT 5

  SQL
end
