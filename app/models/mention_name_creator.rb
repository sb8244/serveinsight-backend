class MentionNameCreator
  attr_reader :name, :organization, :organization_membership_id

  def initialize(name, organization:, organization_membership: nil)
    @name = name
    @organization = organization
    @organization_membership_id = organization_membership.try!(:id)
  end

  def mention_name
    @mention_name ||= begin
      count = 1
      while name_scope.where("LOWER(mention_name) = LOWER(?)", counted_name(count)).exists?
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

  def name_scope
    organization.organization_memberships.where.not(id: organization_membership_id)
  end
end
