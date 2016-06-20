hex = SecureRandom.hex(3)
organization = FactoryGirl.create(:organization, name: "Test Org #{hex}")

your_user = FactoryGirl.create(:user, email: "steve+#{hex}@serveinsight.com")
boss_user = FactoryGirl.create(:user, email: "boss+#{hex}@serveinsight.com")
ceo_user = FactoryGirl.create(:user, email: "ceo+#{hex}@serveinsight.com")
d1_user = FactoryGirl.create(:user, email: "d1+#{hex}@serveinsight.com")
d2_user = FactoryGirl.create(:user, email: "d2+#{hex}@serveinsight.com")
d3_user = FactoryGirl.create(:user, email: "d3+#{hex}@serveinsight.com")

ceo = FactoryGirl.create(:organization_membership, organization: organization, reviewer: nil, name: "The CEO", user: ceo_user, email: "ceo@serveinsight.com", admin:true)
boss = FactoryGirl.create(:organization_membership, organization: organization, reviewer: ceo, name: "Your Boss", user: boss_user, email: "boss@serveinsight.com", admin: true)
peer = FactoryGirl.create(:organization_membership, organization: organization, reviewer: boss, name: "Your Peer", email: "peer@serveinsight.com", admin:true)
you = FactoryGirl.create(:organization_membership, organization: organization, reviewer: boss, name: "Steve Bussey", user: your_user, email: "steve@serveinsight.com", admin: true)
d1 = FactoryGirl.create(:organization_membership, organization: organization, reviewer: you, name: "Jack Johnson", user: d1_user, email: "d1@serveinsight.com")
d2 = FactoryGirl.create(:organization_membership, organization: organization, reviewer: you, name: "Pat Miller", user: d2_user, email: "d2@serveinsight.com")
d3 = FactoryGirl.create(:organization_membership, organization: organization, reviewer: you, name: "Sarah Marshall", user: d3_user, email: "d3@serveinsight.com")
boss_peer = FactoryGirl.create(:organization_membership, organization: organization, reviewer: ceo, name: "Jim Henson")
co_peer = FactoryGirl.create(:organization_membership, organization: organization, reviewer: boss_peer, name: "Cad Maple")

puts "Login with token=#{your_user.auth_token}"
puts "Boss with token=#{boss_user.auth_token}"
puts "D1 with token=#{d1_user.auth_token}"

recurring_template = SurveyTemplate.create!(
  organization: organization,
  creator_id: ceo.id,
  name: "Weekly Direction Report",
  next_due_at: Chronic.parse("next friday 5pm"),
  weeks_between_due: 1,
  goals_section: true
)
recurring_template.questions.create!(
  question: "How are you feeling?",
  organization: organization,
  order: 0,
  question_type: "num5"
)
recurring_template.questions.create!(
  question: "What do you think might hold you back next week?",
  organization: organization,
  order: 1,
  question_type: "string"
)
CreateSurveyInstancesJob.perform_now(recurring_template)
