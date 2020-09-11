# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CommonMethods do
  subject(:common_methods) { CommonMethods.new }

  describe 'log output' do
    it 'prints given result to STDOUT' do
      output_str = 'output string'
      expect(STDOUT).to receive(:puts).with(output_str)
      common_methods.log_output output_str
    end
  end

  describe 'receive_user_input' do
    it 'receive and return user input' do
      input_str = 'input string'
      allow(STDIN).to receive(:gets) { input_str }
      expect(common_methods.receive_user_input).to eq(input_str)
    end
  end

  describe 'to_int_or_nil' do
    context 'string convertable to int number' do
      it 'return int number' do
        expect(common_methods.to_int_or_nil('123')).to eq(123)
      end
    end

    context 'string unconvertable to int number' do
      it 'return nil' do
        expect(common_methods.to_int_or_nil('one')).to eq(nil)
      end
    end
  end

  describe 'convert_to_int' do
    context 'given string is convertable to int' do
      it 'returns int number' do
        expect(common_methods).to receive(:to_int_or_nil).with('2').and_return(2)
        expect(common_methods.convert_to_int('2')).to eq(2)
      end
    end

    context 'given string is not convertable' do
      it 'exit' do
        expect(common_methods).to receive(:to_int_or_nil).with('two').and_return(nil)
        expect(common_methods).to receive(:exit)
        common_methods.convert_to_int('two')
      end
    end
  end

  describe 'print_table' do
    let(:car1) { instance_double Car }
    let(:car2) { instance_double Car }

    let(:slots) { [car1, car2] }

    before do
      allow(car1).to receive(:reg_no).and_return('qwe')
      allow(car2).to receive(:reg_no).and_return('asd')

      allow(car1).to receive(:color).and_return('white')
      allow(car2).to receive(:color).and_return('black')
    end

    it 'prints array of Car object in proper string format' do
      table_format = "Slot No.    Registration No    Colour\n"

      slots.each_with_index do |slot, index|
        next unless slot

        table_format += (index + 1).to_s + '           ' + slot.reg_no + '      ' + slot.color
        table_format += "\n"
      end

      expect(common_methods).to receive(:log_output).with(table_format)

      common_methods.print_table(slots)
    end
  end
end