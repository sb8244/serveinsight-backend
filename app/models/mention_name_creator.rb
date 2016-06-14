class MentionNameCreator
  attr_reader :name, :organization, :membership

  def initialize(name, organization:, membership: nil)
    @name = name
    @organization = organization
    @membership = membership
  end

  def mention_name
    @mention_name ||= begin
      count = 1
      while organization.organization_memberships.where("LOWER(mention_name) = LOWER(?)", counted_name(count)).exists?
        count += 1
      end
      counted_name(count)
    end
  end

  private

  def cleaned_name
    @cleaned_name ||= name.gsub(/\W/,'')
  end

  def counted_name(count)
    return cleaned_name if count == 1
    "#{cleaned_name}#{count}"
  end
end
