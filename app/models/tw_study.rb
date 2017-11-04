class TwStudy < ActiveRecord::Base
  has_many :tw_stats, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  def self.get_or_create(study_name)
    list = TwStudy.find_by_name(study_name)
    unless list
      list = TwStudy.new(name: study_name)
      list.save
    end
    list
  end

  def self.stat_hash(study_name)
    list = find_by_name(study_name)
    return nil unless list
    list.stat_hash
  end

  def stat_hash
    items = {}
    tw_stats.each do |stat|
      items[stat.concept] = stat.value
    end
    items
  end

  def stats
    tw_stats
  end

  def include?(concept)
    tw_stats.find_by_concept(concept)
  end

  def add(concept, value, replace = false)
    stat = tw_stats.find_by_concept(concept)
    if stat
      if replace
        stat.value = value
      else
        stat.value += value
      end
    else
      stat = tw_stats.build({concept: concept, value: value})
    end
    stat.save!
  end

end