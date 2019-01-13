# frozen_string_literal: true

module Pytty
  module Daemon
    @@yields = {}

    def self.yields
      @@yields
    end

    def self.dump
      FileUtils.mkdir_p File.dirname(yields_json)
      File.write yields_json, @@yields.to_json
    end

    def self.load
      return unless File.exist? yields_json
      puts "restoring from #{yields_json}"

      objs = JSON.parse(File.read(yields_json))
      objs.each do |k,obj|
        process_yield = ProcessYield.new obj["cmd"], id: obj["id"], env: obj["env"]
        @@yields[obj["id"]] = process_yield
        print "spawning #{process_yield.cmd} ... "
        process_yield.spawn if obj["running"]
        puts "done"
      end

    end

    def self.yields_json
      File.join(Dir.home,".pytty","yields.json")
    end
  end
end

require_relative "daemon/process_yield"
require_relative "daemon/components"