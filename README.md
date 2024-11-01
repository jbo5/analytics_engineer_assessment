## AAA Life Insurance Analytics Engineer Assessment
### contact: JBickmeyer@aaalife.com

### setup:

- Make sure you have Docker installed on your local machine. Installation instructions for your OS
  can be found at https://www.docker.com/
- UNZIP the assessment project onto your machine, and access this new project directory using the
  text editor of you choice
- Go to terminal, and make sure you are in the project's root directory
- Run the command `docker compose up -d --build`
- Now exec into the dbt container with the command `docker exec -it analytics_engineer_assessment-dbt-1 /bin/bash`
- Here you should be able to run `dbt debug` successfully. If you can't then contact us for help.

This setup will create 2 docker containers, one of them is a containerized image of the dbt project
and the other is a postgres database that we are using as our data warehouse. The connection and
credentials for the postgres database are below. You should be able to query the database from any
SQL IDE that works with postgres. A free one can be downloaded at https://dbeaver.io/.

- **Database Name:** dbt_db
- **Username:** dbt_user
- **Password:** dbt_password
- **Host:** localhost
- **Port:** 5432