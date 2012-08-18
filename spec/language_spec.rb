# encoding: utf-8
require_relative "./spec_helper"

describe Language do

  it "should contain language data" do
    Language.count.should == 103444
    first_record = Language.find_by_internet_archive_id('annualreporto46185052newy')
    first_record.name.should == 'English'
    second_record = Language.find_by_internet_archive_id('mathematischeund818891890magy')
    second_record.name.should == 'German'
  end

end