# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
       gdp > (
         SELECT
            MAX(gdp)
         FROM
            countries
         WHERE
            continent = 'Europe'
         );
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
     SELECT
       continent,
       name,
       area
     FROM
       countries
     WHERE
       area IN (
         SELECT
           max_area
         FROM (
           SELECT
             continent, MAX(area) AS max_area
           FROM
             countries
           GROUP BY continent
           ) AS T
         );
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
    SELECT
      Max_Countries.name,
      Max_Countries.continent
    FROM (
      SELECT
        C.name,
        C.population,
        C.continent
      FROM
        countries C
      JOIN (
        SELECT
          continent,
          MAX(population) AS max_pop
        FROM
          countries
        GROUP BY
           continent
        ) AS M ON C.continent = M.continent
      WHERE C.population = M.max_pop) AS Max_Countries
    JOIN (
      SELECT
        T.name,
        T.population,
        T.continent
      FROM
        countries T
      JOIN (
        SELECT
          C.continent,
          MAX(C.population) AS second_max_pop
        FROM
           countries C
        JOIN (
             SELECT
                C.name,
                C.population,
                C.continent
             FROM
                countries C
             JOIN (
               SELECT
                 continent,
                 MAX(population) AS max_pop
               FROM
                 countries
               GROUP BY
                 continent
               ) AS M ON C.continent = M.continent
             WHERE
                C.population = M.max_pop
              ) AS Max_Countries ON C.continent = Max_countries.continent
        WHERE
           C.population != Max_Countries.population
        GROUP BY C.continent
      ) AS Without_Max ON T.continent = Without_Max.continent
    WHERE
      T.population = Without_Max.second_max_pop
    ) AS Second_Max_Countries ON Max_Countries.continent = Second_Max_Countries.continent
    WHERE
      Max_Countries.population > (3* Second_Max_Countries.population);
  SQL
end
