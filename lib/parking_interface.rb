# frozen_string_literal: true

class ParkingInterface
  attr_reader :input_file_path, :parking_lot, :common_methods, :commands_list

  def initialize(common_methods)
    @common_methods = common_methods

    @commands_list = {
      create_parking_lot: method(:create_parking_lot),
      leave: method(:leave_process),
      registration_numbers_for_cars_with_colour: method(:get_reg_nums_by_color),
      slot_numbers_for_cars_with_colour: method(:get_slot_nums_by_color),
      slot_number_for_registration_number: method(:slot_num_by_reg_number)
    }
  end

  def leave_slot(slot_num)
    parking_lot.leave slot_num
  end

  def create_parking_lot(size)
    size_in_int = common_methods.convert_to_int size
    @parking_lot = ParkingLot.new(size_in_int)

    common_methods.log_output('Created a parking lot with ' + size + ' slots')
  end

  def get_reg_nums_by_color(color)
    reg_nos = parking_lot.get_reg_numbers_by_color(color)
    common_methods.log_output reg_nos.join(", ")
  end

  def get_slot_nums_by_color(color)
    slot_nums = parking_lot.get_slot_numbers_by_color(color)
    common_methods.log_output slot_nums.join(", ")
  end

  def slot_num_by_reg_number(reg_no)
    slot_num = parking_lot.get_slot_num_by_reg_no(reg_no)
    return 'Not found' unless slot_num
    common_methods.log_output slot_num.to_s
  end

  def park_on_slot(reg_no:, color:, slot_num:)
    car = Car.new(reg_no: reg_no, color: color)
    parking_lot.park(car: car, slot_num: slot_num)
  end

  def park_process(reg_no:, color:, slot_num:)
    park_on_slot(reg_no: reg_no, color: color, slot_num: slot_num)
    common_methods.log_output 'Allocated slot number: ' + (slot_num + 1).to_s
  end

  def leave_process(str_num)
    num = common_methods.convert_to_int(str_num)
    leave_slot(num - 1)
    common_methods.log_output 'Slot number ' + str_num + ' is free'
  end

  def command_with_two_statments(splitted_input)
    commands_list[splitted_input[0].to_sym].call splitted_input[1]
  end

  def check_solt_and_park(splitted_input)
    slot_num = parking_lot.available_slot

    if slot_num
      park_process(reg_no: splitted_input[1],
                   color: splitted_input[2],
                   slot_num: slot_num)
    else
      common_methods.log_output 'Sorry, parking lot is full'
    end
  end

  def parse_command(input)
    splitted_input = input.split
    if splitted_input.size == 1
      common_methods.print_table parking_lot.slots
    elsif splitted_input.size == 2
      command_with_two_statments splitted_input
    elsif splitted_input.size == 3
      check_solt_and_park splitted_input
    end
  end

  def interactive_mode
    loop do
      parse_command common_methods.receive_user_input
    end
  end

  def file_mode
    input_file = File.open(input_file_path, 'r')

    input_file.each_line do |line|
      parse_command line
    end
  end

  def execute
    file = ARGV[0]

    if file
      set_input_path file
      file_mode
    else
      interactive_mode
    end
  end

  private

  def set_input_path(file)
    @input_file_path = file
  end
end
