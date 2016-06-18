class PassupSerializer < Plain::PassupSerializer
  attributes :passup_grant

  def passup_grant
    PassupGrant.encode(object.passupable)
  end
end
