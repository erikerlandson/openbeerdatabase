class Beer < ActiveRecord::Base
  belongs_to :brewer
  belongs_to :user

  validates :name,      :presence => true, :length => { :maximum => 255 }
  validates :brewer_id, :presence => true

  attr_accessible :name

  def self.paginate_with_options(options = {})
    paginate_without_options(options_for_pagination(options))
  end

  def as_json(options = {})
    { :id     => id,
      :name   => name,
      :brewer => {
        :id   => brewer.id,
        :name => brewer.name
      }
    }
  end

  class << self
    alias_method_chain :paginate, :options
  end

  private

  def self.conditions_for_pagination(options)
    user = User.find_by_token(options[:token]) if options[:token].present?

    if user.present?
      ['user_id IS NULL OR user_id = ?', user.id]
    else
      'user_id IS NULL'
    end
  end

  def self.options_for_pagination(options)
    { :page       => options[:page]     || 1,
      :per_page   => options[:per_page] || 50,
      :conditions => conditions_for_pagination(options),
      :order      => 'id ASC'
    }
  end
end
