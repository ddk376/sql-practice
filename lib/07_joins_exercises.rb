# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    INNER JOIN
      castings ON movies.id = castings.movie_id
    INNER JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery';
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
     SELECT
       m.title
     FROM
       movies AS m
     INNER JOIN
       castings AS c ON m.id = c.movie_id
     WHERE
       c.actor_id = (
         SELECT
           id
         FROM
           actors
         WHERE
           name = 'Harrison Ford'
         );
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    SELECT
      m.title
    FROM
      movies AS m
    INNER JOIN
      castings AS c ON m.id = c.movie_id
    WHERE
      c.actor_id = (
        SELECT
          id
        FROM
          actors
        WHERE
          name = 'Harrison Ford'
        )
      AND c.ord != 1;

  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
     SELECT
       m.title,
       a.name
     FROM
       movies AS m
     JOIN
       castings AS c ON m.id = c.movie_id
     JOIN
       actors AS a ON a.id = c.actor_id
     WHERE
       m.yr = 1962 AND c.ord = 1;
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT
      yr,
      num_of_movies
    FROM(
      SELECT
        m.yr,
        COUNT(m.id) AS num_of_movies
      FROM
        movies AS m
      JOIN
        castings AS c ON m.id = c.movie_id
      JOIN
        actors AS a ON a.id = c.actor_id
      WHERE a.name = 'John Travolta'
      GROUP BY m.yr
      ) AS Travolta_yearly_movies
    WHERE
      Travolta_yearly_movies.num_of_movies >= 2;

  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    SELECT
      movies_with_Julie_Andrews.title,
      leading_roles.name
    FROM (
       SELECT
          m.id,
          m.title
       FROM
          movies m
       JOIN
          castings c ON m.id = c.movie_id
       JOIN
          actors a ON a.id = c.actor_id
       WHERE
          a.name = 'Julie Andrews'
      ) AS movies_with_Julie_Andrews
    JOIN (
      SELECT
         m.id,
         a.name
      FROM
        movies m
      JOIN
        castings c ON m.id = c.movie_id
      JOIN
        actors a ON a.id = c.actor_id
      WHERE
        c.ord = 1
      ) AS leading_roles
    ON movies_with_Julie_Andrews.id = leading_roles.id;

  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT
      name
    FROM (
      SELECT
        name,
        COUNT(name) AS num_of_starring_roles
      FROM (
        SELECT
          a.name
        FROM
          movies m
        JOIN
          castings c ON m.id = c.movie_id
        JOIN
          actors a ON a.id = c.actor_id
        WHERE
          c.ord = 1
        ) AS leading_roles
      GROUP BY name
    ) AS actors_and_num_of_starring_roles
    WHERE
      num_of_starring_roles >= 15
    ORDER BY
      name ASC;

  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT
      title,
      num_of_actors
    FROM (
      SELECT
        movies_released_in_1978.title,
        COUNT(c.actor_id) AS num_of_actors
      FROM
        castings c
      JOIN (
        SELECT
          m.id,
          m.title
        FROM
          movies m
        WHERE
          m.yr = 1978
        ) AS movies_released_in_1978
      ON c.movie_id = movies_released_in_1978.id
      GROUP BY
        movies_released_in_1978.title
      ) AS movies_and_cast_num
    ORDER BY
      num_of_actors DESC, title ASC;
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    SELECT
      a.name
    FROM
      castings c
    JOIN
      actors a ON c.actor_id = a.id
    WHERE
      c.movie_id IN (
        SELECT
          c.movie_id
        FROM
          castings c
        JOIN
          actors a ON c.actor_id = a.id
        WHERE
          a.name = 'Art Garfunkel'
        )
      AND a.name != 'Art Garfunkel';
  SQL
end
