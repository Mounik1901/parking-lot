# frozen_string_literal: true

class ParkingLot
  attr_reader :slots
  def initialize(size)
    @slots = Array.new(size)
  end

  def available_slot
    slots.each_with_index do |slot, index|
      return index if slot.nil?
    end

    nil
  end

  def park(car:, slot_num:)
    slots[slot_num] = car
  end

  def leave(slot_num)
    slots[slot_num] = nil
  end

  def get_reg_numbers_by_color(color)
    reg_nos = []
    slots.each do |slot|
      next unless slot
      reg_nos << slot.reg_no if slot.color == color
    end
    reg_nos
  end

  def get_slot_num_by_reg_no(reg_no)
    slots.each_with_index do |slot, id|
      next unless slot
      return (id + 1).to_s if slot.reg_no == reg_no
    end
    nil
  end

  def get_slot_numbers_by_color(color)
    slot_nums = []
    slots.each_with_index do |slot, id|
      next unless slot
      slot_nums << (id + 1).to_s if slot.color == color
    end
    slot_nums
  end
end
