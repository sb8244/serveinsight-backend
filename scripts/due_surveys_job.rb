# Enqueue once per day at 9am EST
DueSurveyMailerJob.perform_later(2)
DueSurveyMailerJob.perform_later(1)
DueSurveyMailerJob.perform_later(0)
