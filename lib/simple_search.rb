module SimpleSearch
  def search(filter)
    if filter.present?
      where('name like ?', "%#{filter}%")
    else
      where('1=1')
    end
  end
end
