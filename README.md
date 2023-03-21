# Sphere AI

(Notes updated March 2023)

The Sphere AI app is written in Ruby on Rails.

### Getting setup for development

If you have the good fortune of being on a Mac, you can simply:

```
brew install postgresql@12 ruby@2.7
brew link ruby@2.7 && brew link postgres@12
```

We tried to get things going under both Powershell and Windows subsystem for Linux but in the end Ubuntu was quicker and far more pleasant.

I recall we followed this guide: https://gorails.com/setup/ubuntu/20.04

This alias was also helpful: `alias rails="bundle exec"`

### Running the app

Clone the repository. From memory I think the steps are:

```
git clone git@github.com:scholarsite/scholarsite.git
bundle install
rails db:create
rails db:migrate
```

To start the Rails server, run:

```
rails s
```