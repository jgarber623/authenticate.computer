require File.expand_path('config/environment', __dir__)

ApplicationController.subclasses.each { |klass| use klass }

run ApplicationController
