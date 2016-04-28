# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../../lib/patches/abstract_mysql_adapter', __FILE__)

# Initialize the rails application
DMPonline4::Application.initialize!
