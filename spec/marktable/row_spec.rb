# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Row do
  describe '#initialize' do
    it 'accepts a hash' do
      row = described_class.new({"Name" => "John", "Age" => "30"})
      expect(row.data).to eq({"Name" => "John", "Age" => "30"})
    end
    
    it 'accepts an array' do
      row = described_class.new(["John", "30"])
      expect(row.data).to eq(["John", "30"])
    end
    
    it 'converts array to hash when headers are provided' do
      row = described_class.new(["John", "30"], headers: ["Name", "Age"])
      expect(row.data).to eq({"Name" => "John", "Age" => "30"})
    end
    
    it 'handles arrays shorter than headers' do
      row = described_class.new(["John"], headers: ["Name", "Age"])
      expect(row.data).to eq({"Name" => "John", "Age" => ""})
    end
  end
  
  describe '#[]' do
    it 'retrieves value by key for hash-based rows' do
      row = described_class.new({"Name" => "John", "Age" => "30"})
      expect(row["Name"]).to eq("John")
    end
    
    it 'retrieves value by index for array-based rows' do
      row = described_class.new(["John", "30"])
      expect(row[0]).to eq("John")
    end
    
    it 'returns nil for missing keys' do
      row = described_class.new({"Name" => "John"})
      expect(row["Age"]).to be_nil
    end
    
    it 'returns nil for out of bounds index' do
      row = described_class.new(["John"])
      expect(row[1]).to be_nil
    end
  end
  
  describe '#[]=' do
    it 'sets value by key for hash-based rows' do
      row = described_class.new({"Name" => "John"})
      row["Age"] = "30"
      expect(row["Age"]).to eq("30")
    end
    
    it 'sets value by index for array-based rows' do
      row = described_class.new(["John"])
      row[1] = "30"
      expect(row[1]).to eq("30")
    end
  end
  
  describe '#values' do
    it 'returns values for hash-based rows' do
      row = described_class.new({"Name" => "John", "Age" => "30"})
      expect(row.values).to eq(["John", "30"])
    end
    
    it 'returns data for array-based rows' do
      row = described_class.new(["John", "30"])
      expect(row.values).to eq(["John", "30"])
    end
  end
  
  describe '#to_h' do
    it 'returns the hash for hash-based rows' do
      data = {"Name" => "John", "Age" => "30"}
      row = described_class.new(data)
      expect(row.to_h).to eq(data)
    end
    
    it 'converts array to hash with headers' do
      row = described_class.new(["John", "30"], headers: ["Name", "Age"])
      expect(row.to_h).to eq({"Name" => "John", "Age" => "30"})
    end
    
    it 'returns empty hash for array without headers' do
      row = described_class.new(["John", "30"])
      expect(row.to_h).to eq({})
    end
  end
  
  describe '#to_a' do
    it 'returns values for hash-based rows' do
      row = described_class.new({"Name" => "John", "Age" => "30"})
      expect(row.to_a).to eq(["John", "30"])
    end
    
    it 'returns the array for array-based rows' do
      data = ["John", "30"]
      row = described_class.new(data)
      expect(row.to_a).to eq(data)
    end
  end
end
