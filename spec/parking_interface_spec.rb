# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ParkingInterface do
  let(:common_methods) { instance_double CommonMethods }
  let(:commands_list) do
    { create_parking_lot: parking_interface.method(:create_parking_lot),
      leave: parking_interface.method(:leave_process),
      registration_numbers_for_cars_with_colour: parking_interface.method(:get_reg_nums_by_color),
      slot_numbers_for_cars_with_colour: parking_interface.method(:get_slot_nums_by_color),
      slot_number_for_registration_number: parking_interface.method(:slot_num_by_reg_number) }
  end

  subject(:parking_interface) { ParkingInterface.new common_methods }

  describe 'initialize and attr_reader' do
    it 'has common_methods object as attribute' do
      expect(parking_interface.common_methods).to eq(common_methods)
    end

    it 'has proper commands_list attribute' do
      expect(parking_interface.commands_list).to eq(commands_list)
    end
  end

  describe 'run' do
    context 'system argument given' do
      it 'runs in file mode' do
        ARGV.replace ['filename']
        expect(parking_interface).to receive(:set_input_path).with('filename')
        expect(parking_interface).to receive(:file_mode)
        parking_interface.execute
      end
    end

    context 'system argument not given' do
      it 'runs in interactive mode' do
        ARGV.replace [nil]
        expect(parking_interface).to receive(:interactive_mode)
        parking_interface.execute
      end
    end
  end

  describe 'parse_command' do
    let(:input) { double }

    context 'one statement command' do
      it 'prints report in table format' do
        parking_lot = instance_double ParkingLot
        slots = %w[aaa www]

        allow(input).to receive(:split).and_return(['command1'])
        allow(parking_interface).to receive(:parking_lot).and_return(parking_lot)
        allow(parking_lot).to receive(:slots).and_return(slots)

        allow(parking_interface).to receive(:common_methods).and_return(common_methods)
        expect(common_methods).to receive(:print_table).with(slots)
      end
    end

    context 'two statement command' do
      it 'calls command_with_two_statments parser function' do
        allow(input).to receive(:split).and_return(%w[command1 command2])

        expect(parking_interface).to receive(:command_with_two_statments)
          .with(%w[command1 command2])
      end
    end

    context 'three statement command' do
      it 'calls park_process parser function' do
        allow(input).to receive(:split)
          .and_return(%w[command1 command2 command3])

        expect(parking_interface).to receive(:check_solt_and_park)
          .with(%w[command1 command2 command3])
      end
    end

    after do
      parking_interface.parse_command input
    end
  end

  describe 'create_parking_lot' do
    it 'create new parking lot with given size' do
      input = Random.rand(1..10)
      parking_lot = instance_double ParkingLot

      allow(parking_interface).to receive(:common_methods).and_return(common_methods)

      expect(common_methods).to receive(:convert_to_int).with(input.to_s)
                                               .and_return(input)
      expect(ParkingLot).to receive(:new).with(input).and_return(parking_lot)
      expect(common_methods).to receive(:log_output)
        .with('Created a parking lot with ' + input.to_s + ' slots')

      parking_interface.create_parking_lot(input.to_s)
    end
  end

  describe 'leave_slot' do
    it 'empties the corresponding slot' do
      parking_lot = instance_double ParkingLot
      slot_num = Random.rand(1..10)

      allow(parking_interface).to receive(:parking_lot)
        .and_return(parking_lot)
      expect(parking_lot).to receive(:leave).with(slot_num)

      parking_interface.leave_slot(slot_num)
    end
  end

  describe 'leave_process' do
    it 'runs leaving parking slot process properly' do
      allow(parking_interface).to receive(:common_methods).and_return(common_methods)
      expect(common_methods).to receive(:convert_to_int).with('5').and_return(5)
      expect(parking_interface).to receive(:leave_slot).with(4)
      expect(common_methods).to receive(:log_output)
        .with('Slot number 5 is free')

      parking_interface.leave_process '5'
    end
  end

  describe 'get_reg_nums_by_color' do
    it 'retrieve reg_number of cars with corresponding color' do
      array = [
        'b 1234 a',
        'c 2345 b',
        'd 3456 d'
      ]
      expected_string = 'b 1234 a, c 2345 b, d 3456 d'

      parking_lot = double
      color = 'white'

      allow(parking_interface).to receive(:parking_lot)
        .and_return(parking_lot)
      expect(parking_lot).to receive(:get_reg_numbers_by_color)
        .with(color)
        .and_return(array)

      allow(parking_interface).to receive(:common_methods).and_return(common_methods)
    
      expect(common_methods).to receive(:log_output)
        .with(expected_string)

      parking_interface.get_reg_nums_by_color color
    end
  end

  describe 'get_slot_nums_by_color' do
    it 'retrieve slot number of cars with corresponding color' do
      array = [1, 3, 4]
      parking_lot = double
      color = 'white'
      expected_string = '1, 3, 4'

      allow(parking_interface).to receive(:parking_lot)
        .and_return(parking_lot)
      allow(parking_interface).to receive(:common_methods).and_return(common_methods)

      expect(parking_lot).to receive(:get_slot_numbers_by_color)
        .with(color)
        .and_return(array)

      expected_string = array.join(", ")
    
      expect(common_methods).to receive(:log_output).with(expected_string)

      parking_interface.get_slot_nums_by_color color
    end
  end

  describe 'slot_num_by_reg_number' do
    let(:parking_lot) { double }
    let(:reg_no) { 'qwe 123 asd' }

    context 'registration number exist' do
      it 'returns slot number in string' do
        slot_num = Random.rand(1..10).to_s

        allow(parking_interface).to receive(:parking_lot)
          .and_return(parking_lot)
        allow(parking_interface).to receive(:common_methods)
          .and_return(common_methods)

        expect(parking_lot).to receive(:get_slot_num_by_reg_no)
          .with(reg_no)
          .and_return(slot_num)

        expect(common_methods).to receive(:log_output)
          .with(slot_num.to_s)

        parking_interface.slot_num_by_reg_number(reg_no)
      end
    end

    context 'registration number not exist' do
      it 'returns not found string' do
        allow(parking_interface).to receive(:parking_lot)
          .and_return(parking_lot)
        expect(parking_lot).to receive(:get_slot_num_by_reg_no)
          .with(reg_no)
          .and_return(nil)

        result = parking_interface.slot_num_by_reg_number(reg_no)

        expect(result).to eq('Not found')
      end
    end
  end

  describe 'park_on_slot' do
    it 'parks new car in an empty slot' do
      car = double
      parking_lot = double
      reg_no = 'b 6213 z'
      color = 'black'
      slot_num = Random.rand(1...5)
      expect(Car).to receive(:new).with(reg_no: reg_no, color: color)
                                  .and_return(car)

      allow(parking_interface).to receive(:parking_lot)
        .and_return(parking_lot)
      expect(parking_lot).to receive(:park).with(car: car,
                                                 slot_num: slot_num)

      parking_interface.park_on_slot(reg_no: reg_no,
                                  color: color,
                                  slot_num: slot_num)
    end
  end

  describe 'check_solt_and_park' do
    let(:reg_no) { 'qwe' }
    let(:color) { 'blue' }
    let(:slot_num) { slot_num = Random.rand(1..10) }
    let(:parking_lot) { instance_double ParkingLot }

    before do
      allow(parking_interface).to receive(:parking_lot).and_return(parking_lot)
    end

    context 'slot available' do
      it 'calls park process' do
        allow(parking_lot).to receive(:available_slot).and_return(slot_num)

        expect(parking_interface).to receive(:park_process).with(reg_no: reg_no,
                                                              color: color,
                                                              slot_num: slot_num)
      end
    end

    context 'slot unavailable' do
      it 'calls log_output with prints not found message' do
        allow(parking_lot).to receive(:available_slot).and_return(nil)
        allow(parking_interface).to receive(:common_methods).and_return(common_methods)

        expect(common_methods).to receive(:log_output)
          .with('Sorry, parking lot is full')
      end
    end

    after do
      parking_interface.check_solt_and_park(['park', reg_no, color])
    end
  end

  describe 'file_mode' do
    it 'opens file and run program from file input' do
      file = StringIO.new "test1\ntest2\ntest3"
      path = 'dummy/path'

      allow(parking_interface).to receive(:input_file_path).and_return(path)
      expect(File).to receive(:open).with(path, 'r')
                                    .and_return(file)
      expect(parking_interface).to receive(:parse_command)
        .exactly(3).times

      parking_interface.file_mode
    end
  end

  describe 'command_with_two_statments' do
    let(:size) { Random.rand(3..10) }

    it 'calls proper function based on given command' do
      input = ['create_parking_lot', size]

      allow(parking_interface).to receive(:commands_list)
        .and_return(commands_list)

      expect(commands_list[input[0].to_sym])
        .to receive(:call).with(input[1])

      parking_interface.command_with_two_statments(input)
    end
  end

  describe 'park_process' do
    it 'parks a car and print allocated slot number' do
      reg_no = 'asd'
      color = 'maroon'
      slot_num = Random.rand(1..10)

      expect(parking_interface).to receive(:park_on_slot).with(
        reg_no: reg_no,
        color: color,
        slot_num: slot_num
      )

      allow(parking_interface).to receive(:common_methods).and_return(common_methods)

      expect(common_methods).to receive(:log_output)
        .with('Allocated slot number: ' + (slot_num + 1).to_s)

      parking_interface.park_process(reg_no: reg_no,
                                  color: color,
                                  slot_num: slot_num)
    end
  end
end
