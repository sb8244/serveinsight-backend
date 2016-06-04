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

ActiveRecord::Schema.define(version: 20160604212029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invites", force: :cascade do |t|
    t.boolean  "accepted",                   default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "admin",                      default: false, null: false
    t.integer  "organization_membership_id",                 null: false
  end

  add_index "invites", ["organization_membership_id"], name: "index_invites_on_organization_membership_id", using: :btree

  create_table "organization_memberships", force: :cascade do |t|
    t.integer  "organization_id",                 null: false
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin",           default: false
    t.integer  "reviewer_id"
    t.string   "name",                            null: false
    t.string   "email",                           null: false
  end

  add_index "organization_memberships", ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true, using: :btree
  add_index "organization_memberships", ["organization_id"], name: "index_organization_memberships_on_organization_id", using: :btree
  add_index "organization_memberships", ["reviewer_id"], name: "index_organization_memberships_on_reviewer_id", using: :btree
  add_index "organization_memberships", ["user_id"], name: "index_organization_memberships_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "question",                           null: false
    t.integer  "organization_id",                    null: false
    t.integer  "survey_template_id",                 null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "order",                              null: false
    t.boolean  "deleted",            default: false
  end

  add_index "questions", ["organization_id"], name: "index_questions_on_organization_id", using: :btree
  add_index "questions", ["survey_template_id"], name: "index_questions_on_survey_template_id", using: :btree

  create_table "survey_instances", force: :cascade do |t|
    t.integer  "organization_membership_id", null: false
    t.integer  "survey_template_id",         null: false
    t.integer  "iteration",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "completed_at"
  end

  add_index "survey_instances", ["organization_membership_id"], name: "index_survey_instances_on_organization_membership_id", using: :btree
  add_index "survey_instances", ["survey_template_id"], name: "index_survey_instances_on_survey_template_id", using: :btree

  create_table "survey_templates", force: :cascade do |t|
    t.integer  "organization_id",                null: false
    t.integer  "creator_id",                     null: false
    t.string   "name",                           null: false
    t.boolean  "active",          default: true, null: false
    t.boolean  "recurring",       default: true, null: false
    t.boolean  "goals_section",   default: true, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "iteration",       default: 0,    null: false
  end

  add_index "survey_templates", ["organization_id"], name: "index_survey_templates_on_organization_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "email",      null: false
    t.text     "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name",       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
