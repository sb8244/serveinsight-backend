Mention::Creator = Struct.new(:mentionable, :organization_membership) do
  COMMENT_REGEX = /(@[a-zA-Z0-9]*)/

  def call(text)
    return unless text

    text.scan(COMMENT_REGEX) do |match|
      mention_name = match[0].split("@").last
      mentioned = organization.organization_memberships.where("LOWER(mention_name) = LOWER(?)", mention_name).first
      next if !mentioned
      next if mentioned == organization_membership
      mentionable.mentions.create!(organization_membership: mentioned, mentioned_by: organization_membership)
    end
  end

  private

  def organization
    @organization ||= organization_membership.organization
  end
end
