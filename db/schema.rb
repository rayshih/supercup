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

ActiveRecord::Schema.define(version: 20141006134230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leaves", force: true do |t|
    t.integer  "worker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "hours"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leaves", ["worker_id"], name: "index_leaves_on_worker_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "dependencies"
    t.integer  "milestone"
    t.integer  "parent_id"
    t.integer  "duration"
    t.integer  "assigned_to"
  end

  create_table "workers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
