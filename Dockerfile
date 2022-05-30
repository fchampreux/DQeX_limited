FROM ruby:2.7.2 AS rails-toolbox
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /dqm_application
WORKDIR /dqm_application
COPY Gemfile /dqm_application/Gemfile
COPY Gemfile.lock /dqm_application/Gemfile.lock
RUN bundle install
COPY . /dqm_application

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
