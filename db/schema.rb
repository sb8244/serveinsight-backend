# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160731024456) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer  "survey_instance_id",         null: false
    t.integer  "organization_id",            null: false
    t.integer  "question_id",                null: false
    t.text     "question_content",           null: false
    t.integer  "question_order",             null: false
    t.string   "content"
    t.integer  "order",                      null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "number"
    t.integer  "organization_membership_id", null: false
    t.string   "question_type",              null: false
  end

  add_index "answers", ["organization_id"], name: "index_answers_on_organization_id", using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["survey_instance_id"], name: "index_answers_on_survey_instance_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "comment",                                                 null: false
    t.string   "role",                               default: "comments"
    t.integer  "commentable_id",                                          null: false
    t.string   "commentable_type",                                        null: false
    t.integer  "organization_membership_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "private_organization_membership_id"
    t.string   "author_name",                                             null: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["organization_membership_id"], name: "index_comments_on_organization_membership_id", using: :btree

  create_table "goals", force: :cascade do |t|
    t.integer  "survey_instance_id",         null: false
    t.integer  "organization_id",            null: false
    t.text     "content",                    null: false
    t.integer  "order",                      null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "status"
    t.integer  "organization_membership_id", null: false
  end

  add_index "goals", ["organization_id"], name: "index_goals_on_organization_id", using: :btree
  add_index "goals", ["survey_instance_id"], name: "index_goals_on_survey_instance_id", using: :btree

  create_table "invites", force: :cascade do |t|
    t.boolean  "accepted",                   default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "admin",                      default: false, null: false
    t.integer  "organization_membership_id",                 null: false
    t.string   "code",                                       null: false
  end

  add_index "invites", ["code"], name: "index_invites_on_code", unique: true, using: :btree
  add_index "invites", ["organization_membership_id"], name: "index_invites_on_organization_membership_id", using: :btree

  create_table "mentions", force: :cascade do |t|
    t.integer  "mentionable_id",             null: false
    t.string   "mentionable_type",           null: false
    t.integer  "organization_membership_id", null: false
    t.integer  "mentioned_by_id",            null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "mentions", ["mentioned_by_id"], name: "index_mentions_on_mentioned_by_id", using: :btree
  add_index "mentions", ["organization_membership_id"], name: "index_mentions_on_organization_membership_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "organization_membership_id",                     null: false
    t.string   "notification_type",                              null: false
    t.json     "notification_details",                           null: false
    t.string   "status",                     default: "pending", null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "notifications", ["organization_membership_id"], name: "index_notifications_on_organization_membership_id", using: :btree

  create_table "organization_memberships", force: :cascade do |t|
    t.integer  "organization_id",                 null: false
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin",           default: false
    t.integer  "reviewer_id"
    t.string   "name",                            null: false
    t.string   "email",                           null: false
    t.string   "mention_name",                    null: false
  end

  add_index "organization_memberships", ["email", "organization_id"], name: "index_organization_memberships_on_email_and_organization_id", unique: true, using: :btree
  add_index "organization_memberships", ["mention_name", "organization_id"], name: "unique_mention_name_on_memberships", unique: true, using: :btree
  add_index "organization_memberships", ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true, using: :btree
  add_index "organization_memberships", ["organization_id"], name: "index_organization_memberships_on_organization_id", using: :btree
  add_index "organization_memberships", ["reviewer_id"], name: "index_organization_memberships_on_reviewer_id", using: :btree
  add_index "organization_memberships", ["user_id"], name: "index_organization_memberships_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "passups", force: :cascade do |t|
    t.integer  "organization_id",                     null: false
    t.integer  "passed_up_by_id",                     null: false
    t.integer  "passed_up_to_id",                     null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "status",          default: "pending", null: false
    t.integer  "passupable_id",                       null: false
    t.string   "passupable_type",                     null: false
  end

  add_index "passups", ["organization_id"], name: "index_passups_on_organization_id", using: :btree
  add_index "passups", ["passed_up_by_id"], name: "index_passups_on_passed_up_by_id", using: :btree
  add_index "passups", ["passed_up_to_id"], name: "index_passups_on_passed_up_to_id", using: :btree
  add_index "passups", ["passupable_id", "passupable_type", "passed_up_to_id", "passed_up_by_id"], name: "unique_passup_per_type_user", unique: true, using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "question",                              null: false
    t.integer  "organization_id",                       null: false
    t.integer  "survey_template_id",                    null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "order",                                 null: false
    t.boolean  "deleted",            default: false
    t.string   "question_type",      default: "string", null: false
  end

  add_index "questions", ["organization_id"], name: "index_questions_on_organization_id", using: :btree
  add_index "questions", ["survey_template_id"], name: "index_questions_on_survey_template_id", using: :btree

  create_table "shoutouts", force: :cascade do |t|
    t.integer  "shouted_by_id",   null: false
    t.text     "content",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id", null: false
  end

  add_index "shoutouts", ["organization_id"], name: "index_shoutouts_on_organization_id", using: :btree
  add_index "shoutouts", ["shouted_by_id"], name: "index_shoutouts_on_shouted_by_id", using: :btree

  create_table "survey_instances", force: :cascade do |t|
    t.integer  "organization_membership_id", null: false
    t.integer  "survey_template_id",         null: false
    t.integer  "iteration",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "completed_at"
    t.datetime "due_at",                     null: false
    t.datetime "reviewed_at"
    t.datetime "missed_at"
  end

  add_index "survey_instances", ["iteration", "organization_membership_id", "survey_template_id"], name: "survey_instances_unique_members", unique: true, using: :btree
  add_index "survey_instances", ["missed_at"], name: "index_survey_instances_on_missed_at", using: :btree
  add_index "survey_instances", ["organization_membership_id"], name: "index_survey_instances_on_organization_membership_id", using: :btree
  add_index "survey_instances", ["survey_template_id"], name: "index_survey_instances_on_survey_template_id", using: :btree

  create_table "survey_templates", force: :cascade do |t|
    t.integer  "organization_id",                 null: false
    t.integer  "creator_id",                      null: false
    t.string   "name",                            null: false
    t.boolean  "active",           default: true, null: false
    t.boolean  "recurring",        default: true, null: false
    t.boolean  "goals_section",    default: true, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "iteration",        default: 0,    null: false
    t.datetime "next_due_at",                     null: false
    t.datetime "completed_at"
    t.integer  "days_between_due"
  end

  add_index "survey_templates", ["organization_id"], name: "index_survey_templates_on_organization_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "email",                                  null: false
    t.text     "image_url"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name",                                   null: false
    t.string   "encrypted_password",        default: "", null: false
    t.string   "unconfirmed_email"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",             default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmation_last_send_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
