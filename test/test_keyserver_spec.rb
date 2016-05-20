require "../key_server"
include KeyServer
require 'Delorean'

RSpec.configure do |config|
  config.include Delorean
end


describe KeyServerClass, "#create_keys" do
  context "given a size of 10 to create_keys method" do
    it "generates keys of size 10" do
      test = KeyServerClass.new
      test.create_keys(10)
      expect(test.keys.size).to eq(10)
    end
  end

  context "given a size exceeding keyserver capacity to create_keys method" do
    it "generates keys capped to keyserver's capacity" do
      test = KeyServerClass.new
      test.create_keys(1024)
      expect(test.keys.size).to eq(1000)
    end
  end

  context "given a size of 0 to create_keys method" do
    it "raises ArgumentError" do
      test = KeyServerClass.new
      expect{test.create_keys(0)}.to raise_error(ArgumentError)
    end
  end
  
  context "given a size < 0 to create_keys method" do
    it "raises ArgumentError" do
      test = KeyServerClass.new
      expect{test.create_keys(0)}.to raise_error(ArgumentError)
    end
  end
end

describe KeyServerClass, "#get_free_key" do
  context "asked to return a free key" do
    it "returns an unused key" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      expect(test.keys).not_to include(f)
      expect(test.used).to include(f)
    end
  end

  context "asked to return a free key when keyspace is 0" do
    it "returns nil" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      f = test.get_free_key
      expect(f).to eq(nil)
    end
  end

  context "asked to return a key after recycling" do
    it "returns correct key" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      jump 61
      test.freeup_keys 
      f1 = test.get_free_key
      back_to_the_present
      expect(f).to eq(f1)
    end
  end

  context "asked to return a key before recycling" do
    it "returns nil" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      jump 10
      test.freeup_keys 
      f1 = test.get_free_key
      back_to_the_present
      expect(f1).to eq(nil)
    end
  end
end

describe KeyServerClass, "#release_key" do
  context "asked to release a used key" do
    it "releases back to key space" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      test.release_key(f)
      expect(test.used).not_to include(f)
      expect(test.keys).to include(f)
    end
  end
  
  context "asked to release an unused/invalid key" do
    it "returns false" do
      test = KeyServerClass.new
      test.create_keys(1)
      f = test.get_free_key
      test.release_key(f)
      expect(test.release_key(f)).to eq(false)
    end
  end
end

describe KeyServerClass, "#delete_key" do
  context "asked to delete a used key" do
    it "deletes successfully" do
      test = KeyServerClass.new
      test.create_keys(1)
      k = test.get_free_key
      test.delete_key(k)
      expect(test.keys).not_to include(k)
      expect(test.used).not_to include(k)
    end
  end

  context "asked to delete an invalid key" do
    it "returns false" do
      test = KeyServerClass.new
      test.create_keys(1)
      k = test.get_free_key
      test.delete_key(k)
      expect(test.delete_key(k)).to eq(false)
    end
  end
end

describe KeyServerClass, "#keepalive" do
  context "asked to refresh a used key" do
    it "refreshed the ttl, retaining it in used keyspace" do
      test = KeyServerClass.new
      test.create_keys(1)
      k = test.get_free_key
      jump 59
      test.keepalive(k)
      test.freeup_keys
      expect(test.used).to include(k)
      back_to_the_present
    end
  end

  context "asked to refresh an unused key" do
    it "refreshed the ttl, retaining it in free keyspace" do
      test = KeyServerClass.new
      test.create_keys(1)
      k = test.get_free_key
      jump 65
      test.freeup_keys
      expect(test.used).not_to include(k)
      back_to_the_present
      jump 299
      test.freeup_keys
      jump 200
      expect(test.keys).to include(k)
      back_to_the_present
    end
  end
end

