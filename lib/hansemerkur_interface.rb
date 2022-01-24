require "hansemerkur_interface/version"
require "hansemerkur_interface/base"
require "hansemerkur_interface/requests/plan_search"

module HansemerkurInterface
  autoload :Base, "hansemerkur_interface/base"
  autoload :PlanSearch, "hansemerkur_interface/requests/plan_search"
  class Error < StandardError; end
  # Your code goes here...
end
