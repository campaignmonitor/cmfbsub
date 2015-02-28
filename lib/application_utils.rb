module ApplicationUtils

  def white_label
    return (ENV["APP_CANVAS_NAME"] =~ /createsend$/ ? true : false)
  end

  def get_months
    [
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
    ]
  end

  def get_days
    (1..31)
  end

  def get_years
    (1900..2048)
  end

end
