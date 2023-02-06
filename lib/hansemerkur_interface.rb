require "hansemerkur_interface/version"
require "hansemerkur_interface/request"
require "hansemerkur_interface/requests/plan_search"
require "hansemerkur_interface/requests/book_insurance"
require "hansemerkur_interface/requests/cancel_insurance"
require "hansemerkur_interface/requests/read_insurance"
require "hansemerkur_interface/hanse_merkur_exception"


module HansemerkurInterface
  autoload :Request, "hansemerkur_interface/request"
  autoload :PlanSearch, "hansemerkur_interface/requests/plan_search"
  autoload :BookInsurance, "hansemerkur_interface/requests/book_insurance"
  autoload :HanseMerkurException, "hansemerkur_interface/hanse_merkur_exception"
  autoload :CancelInsurance, "hansemerkur_interface/requests/cancel_insurance"
  autoload :ReadInsurance, "hansemerkur_interface/requests/read_insurance"
  class Error < StandardError; end
  # Your code goes here...
end
