module.exports = {
  apps : [
    {
      name: 'mossu_server',
      script: 'RAILS_ENV=production bundle exec rails s -p 3002',
      watch: false,
    },
    {
      name: 'mossu_sidekiq',
      script: 'RAILS_ENV=production bundle exec sidekiq',
      watch: false,
    },
  ],
};
