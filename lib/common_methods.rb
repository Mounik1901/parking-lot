# frozen_string_literal: true

class CommonMethods
  def log_output(output)
    puts output
  end

  def receive_user_input
    STDIN.gets.strip
  end

  def to_int_or_nil(string)
    Integer(string || '')
  rescue ArgumentError
    nil
  end

  def convert_to_int(str)
    int = to_int_or_nil(str)
    exit unless int
    int
  end

  def print_table(slots)    
    table_format = "Slot No.    Registration No    Colour\n"

    slots.each_with_index do |slot, index|
      next unless slot

      table_format += (index + 1).to_s + '           ' + slot.reg_no + '      ' + slot.color
      table_format += "\n"
    end
    log_output table_format
  end

  private

  def exit
    utilities.log_output 'Argument is not integer, check again'
    exit 1
  end
end
