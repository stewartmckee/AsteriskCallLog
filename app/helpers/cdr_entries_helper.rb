module CdrEntriesHelper
  
  def parse_phone(number)
    #if number.length == 4
    #  number = "0141574#{number}"
    #end
    
    number = "0#{number}" if number.length == 10 and (number.starts_with?("2") or number.starts_with?("1"))
    number = "switchboard" if number == "s"
    number = "answered main number" if number == "*8"
    puts "#{number} - #{Phone.parse(number, :country_code => "44", :area_code => "0141")}"
    #Phone.parse(number, :country_code => "44", :area_code => "141")
    number
  end
end
  