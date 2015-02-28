require "helper"

set :environment, :test

describe "ApplicationUtils" do
  subject do
    Class.new { include ApplicationUtils }
  end
  let(:utils) { subject.new }

  describe "#white_label?" do
    it "determines whether it's the white-label app based on its canvas name" do
      # Test helper sets ENV["APP_CANVAS_NAME"] to "testcampaignmonitor"
      expect(utils.white_label?).to eq(false)
    end
  end

  describe "#get_months" do
    it "gets a list of months" do
      expect(utils.get_months).to eq([
        {:index => 1, :name => "Jan"},
        {:index => 2, :name => "Feb"},
        {:index => 3, :name => "Mar"},
        {:index => 4, :name => "Apr"},
        {:index => 5, :name => "May"},
        {:index => 6, :name => "Jun"},
        {:index => 7, :name => "Jul"},
        {:index => 8, :name => "Aug"},
        {:index => 9, :name => "Sep"},
        {:index => 10, :name => "Oct"},
        {:index => 11, :name => "Nov"},
        {:index => 12, :name => "Dec"}
      ])
    end
  end

  describe "#get_days" do
    it "gets a list of days" do
      expect(utils.get_days).to eq((1..31))
    end
  end

  describe "#get_years" do
    it "gets a list of years" do
      expect(utils.get_years).to eq((1900..2048))
    end
  end

end
