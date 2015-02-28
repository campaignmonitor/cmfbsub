require "helper"

set :environment, :test

describe "ApplicationUtils" do
  subject do
    Class.new { include ApplicationUtils }
  end
  let(:utils) { subject.new }

  describe "#white_label?" do
    context "when the white-label app is running" do
      before do
        allow(ENV).to receive(:[]).with("APP_CANVAS_NAME").and_return("createsend")
      end

      it "knows that the white-label app is runnning" do
        expect(utils.white_label?).to eq(true)
      end
    end

    context "when the non-white-label app is running" do
      before do
        allow(ENV).to receive(:[]).with("APP_CANVAS_NAME").and_return("campaignmonitor")
      end

      it "knows that the non-white-label app is runnning" do
        expect(utils.white_label?).to eq(false)
      end
    end
  end

  describe "#app_name" do
    context "when the white-label app is running" do
      before do
        allow(ENV).to receive(:[]).with("APP_CANVAS_NAME").and_return("createsend")
      end

      it "knows the name of the white-label app" do
        expect(utils.app_name).to eq("Subscribe Form")
      end
    end

    context "when the non-white-label app is running" do
      before do
        allow(ENV).to receive(:[]).with("APP_CANVAS_NAME").and_return("campaignmonitor")
      end

      it "knows the name of the non-white-label app" do
        expect(utils.app_name).to eq("Campaign Monitor Subscribe Form")
      end
    end
  end

  describe "#att_friendly_key" do
    it "gets an attribute-friendly string to use as a custom field key" do
      expect(utils.att_friendly_key("[my-field]")).to eq("cf-my-field")
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
